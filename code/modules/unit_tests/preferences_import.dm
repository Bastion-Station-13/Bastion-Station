/// Checks uploaded preferences files are refused when they are wrong, and that an import keeps what the server owns
/datum/unit_test/preferences_import
	var/test_ckey = "importtester"
	var/test_dir = "data/preferences_import_test/"
	var/save_path = "data/player_saves/i/importtester/preferences.json"
	var/datum/preferences/target
	var/version

/datum/unit_test/preferences_import/Destroy()
	fdel(test_dir)
	fdel("data/player_saves/i/importtester/")
	GLOB.preferences_datums -= test_ckey
	target = null
	return ..()

/datum/unit_test/preferences_import/proc/upload(text)
	var/path = "[test_dir]upload.json"
	fdel(path)
	text2file(text, path)
	return file(path)

/datum/unit_test/preferences_import/proc/parse(text)
	return parse_preferences_import(upload(text), target)

/datum/unit_test/preferences_import/proc/nested(depth)
	var/list/open = list()
	var/list/close = list()
	for(var/i in 1 to depth)
		open += "\["
		close += "]"
	return "{\"version\": [version], \"character1\": {}, \"a\": [open.Join()]1[close.Join()]}"

/datum/unit_test/preferences_import/Run()
	var/datum/client_interface/mock = allocate(/datum/client_interface, test_ckey)
	target = new /datum/preferences(mock)
	target.save_preferences()
	target.save_character()
	version = target.savefile.get_entry("version")
	TEST_ASSERT(isnum(version), "The test preferences have no version")

	check_refused()
	check_clean_tree()
	check_loadout()
	check_apply()

/datum/unit_test/preferences_import/proc/assert_refused(text, message)
	var/list/result = parse(text)
	TEST_ASSERT_NOTNULL(result["error"], message)
	TEST_ASSERT_NULL(result["tree"], "A refused file still gave something to import")

/datum/unit_test/preferences_import/proc/check_refused()
	assert_refused("", "An empty file was accepted")
	assert_refused("hello there", "Text that isn't json was accepted")
	assert_refused("\[1, 2, 3]", "A json list was accepted")
	assert_refused("{\"character1\": {}}", "A file without a version was accepted")
	assert_refused("{\"version\": \"[version]\", \"character1\": {}}", "A version that isn't a number was accepted")
	assert_refused("{\"version\": 1, \"character1\": {}}", "A file from a version that is too old was accepted")
	assert_refused("{\"version\": [version]}", "A file without characters was accepted")
	assert_refused("{\"version\": [version], \"character0\": {}, \"character99\": {}, \"character1.5\": {}, \"character01\": {}}", "A file without a usable character slot was accepted")
	assert_refused(nested(5000), "A file nested far too deep was accepted")

	var/list/too_many = list("\"version\": [version]", "\"character1\": {}")
	for(var/i in 1 to PREFERENCES_IMPORT_MAX_KEYS)
		too_many += "\"filler[i]\": 1"
	assert_refused("{[too_many.Join(", ")]}", "A file with too many entries was accepted")

	assert_refused("{\"version\": [version], \"character1\": {}, \"filler\": \"[jointext(new /list(PREFERENCES_IMPORT_MAX_SIZE), "x")]\"}", "A file that is too big was accepted")

/datum/unit_test/preferences_import/proc/check_clean_tree()
	var/list/export = target.savefile.get_entry()
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A normal export was refused: [result["error"]]")
	var/list/tree = result["tree"]
	TEST_ASSERT_NOTNULL(tree["version"], "The version wasn't imported")
	TEST_ASSERT(islist(tree["character1"]), "The first character wasn't imported")
	for(var/key in GLOB.preferences_import_kept_keys)
		TEST_ASSERT(!(key in tree), "[key] belongs to the server but would be imported")

	var/list/forged = export.Copy()
	forged["evil"] = list("a" = 1)
	forged["toggles"] = "lots"
	forged["modular_version"] = "high"
	forged["character99"] = list()
	forged["antag_rep"] = 9999
	forged["saved_tokens"] = list("high_threat" = 99)
	result = parse(json_encode(forged))
	TEST_ASSERT_NULL(result["error"], "A file with extra entries was refused: [result["error"]]")
	tree = result["tree"]
	TEST_ASSERT(!("evil" in tree), "An entry the server doesn't know was imported")
	TEST_ASSERT(!("toggles" in tree), "A setting of the wrong type was imported")
	TEST_ASSERT(!("modular_version" in tree), "A version of the wrong type was imported")
	TEST_ASSERT(!("character99" in tree), "A character slot that doesn't exist was imported")
	TEST_ASSERT(!("antag_rep" in tree) && !("saved_tokens" in tree), "Rep or tokens from the file were imported")

/datum/unit_test/preferences_import/proc/check_loadout()
	var/datum/loadout_item/plain
	var/datum/loadout_item/donator
	for(var/path in GLOB.all_loadout_datums)
		var/datum/loadout_item/item = GLOB.all_loadout_datums[path]
		if(item.donator_only)
			donator ||= item
		else if(!item.admin_only && !item.mentor_only && isnull(item.ckeywhitelist) && !item.required_season)
			plain ||= item
	TEST_ASSERT_NOTNULL(plain, "There is no loadout item anyone can pick")
	TEST_ASSERT_NOTNULL(donator, "There is no donator loadout item")

	// without a database everyone counts as a donator
	var/datum/persistent_client/persistent = target.parent.persistent_client
	persistent.patreon.owned_rank = NO_RANK
	persistent.twitch.owned_rank = NO_TWITCH_SUB

	target.extra_stat_inventory["unusual"] = list(list("unusual_type" = "/obj/item/pen"))
	var/list/live_tree = target.savefile.get_entry()
	var/list/export = live_tree.Copy()
	var/list/character = list(
		"loadout_list" = list(
			"[plain.item_path]" = list(),
			"[donator.item_path]" = list(),
			"/obj/item/not_a_real_loadout_item" = list(),
			"not even a path" = list(),
		),
		"special_loadout_list" = list(
			"unusual" = list("1", "0", "-1", "7", "abc", 1.5),
			"made up" = list("1"),
		),
	)
	export["character1"] = character
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file with a loadout was refused: [result["error"]]")
	var/list/clean = result["tree"]["character1"]
	var/list/loadout = clean["loadout_list"]
	TEST_ASSERT("[plain.item_path]" in loadout, "A loadout item anyone can pick was removed")
	TEST_ASSERT(!("[donator.item_path]" in loadout), "A donator item was imported for someone who isn't a donator")
	TEST_ASSERT_EQUAL(length(loadout), 1, "Loadout items that don't exist were imported")
	var/list/special = clean["special_loadout_list"]
	TEST_ASSERT_EQUAL(jointext(special["unusual"], ","), "1", "Only the unusual that the player owns should stay")
	TEST_ASSERT(!("made up" in special), "An unknown inventory section was imported")

	persistent.patreon.owned_rank = THANKS_RANK
	result = parse(json_encode(export))
	loadout = result["tree"]["character1"]["loadout_list"]
	TEST_ASSERT("[donator.item_path]" in loadout, "A donator lost their donator item")

/datum/unit_test/preferences_import/proc/write_pending(list/staged)
	var/pending_path = preferences_import_pending_path(test_ckey)
	fdel(pending_path)
	text2file(json_encode(staged), pending_path)
	return pending_path

/datum/unit_test/preferences_import/proc/check_apply()
	TEST_ASSERT_NULL(apply_pending_preferences_import(test_ckey), "Something was applied while nothing was waiting")
	TEST_ASSERT_NULL(apply_pending_preferences_import("Guest-1234567"), "Something was applied to a guest")

	target.antag_rep = 77
	target.saved_tokens["high_threat"] = 4
	target.extra_stat_inventory["unusual"] = list(list("unusual_type" = "/obj/item/pen"))
	target.job_xp_list["import_test_job"] = 123
	target.save_preferences()
	var/old_text = rustg_file_read(save_path)
	TEST_ASSERT(length(old_text), "The test preferences weren't saved")

	// a staged file that isn't json changes nothing
	var/pending_path = preferences_import_pending_path(test_ckey)
	fdel(pending_path)
	text2file("this is not json", pending_path)
	TEST_ASSERT_NOTNULL(apply_pending_preferences_import(test_ckey), "A broken import didn't tell the player")
	TEST_ASSERT_EQUAL(rustg_file_read(save_path), old_text, "A broken import changed the saved preferences")
	TEST_ASSERT(!fexists(pending_path), "A broken import was left waiting")

	// even if the waiting file has the server's entries edited, the player's own are kept
	var/list/staged = list(
		"version" = version,
		"character1" = list("real_name" = "Imported Person"),
		"antag_rep" = 9999,
		"saved_tokens" = list("high_threat" = 99),
		"job_xp_list" = list("import_test_job" = 99999),
		"extra_stat_inventory" = list("unusual" = list(list("unusual_type" = "/obj/item/gun"), list("unusual_type" = "/obj/item/gun"))),
	)
	write_pending(staged)
	GLOB.preferences_datums[test_ckey] = target
	TEST_ASSERT_NOTNULL(apply_pending_preferences_import(test_ckey), "A good import didn't tell the player")
	target = null
	TEST_ASSERT_NULL(GLOB.preferences_datums[test_ckey], "The old preferences datum was kept and would save over the import")
	TEST_ASSERT(!fexists(pending_path), "An applied import was left waiting")
	TEST_ASSERT(fexists("[save_path].importbak"), "The old preferences weren't backed up")
	TEST_ASSERT_EQUAL(rustg_file_read("[save_path].importbak"), old_text, "The backup isn't the old preferences")

	var/list/saved = preferences_import_read(save_path)
	TEST_ASSERT_NOTNULL(saved, "The imported preferences can't be read back")
	var/list/character = saved["character1"]
	TEST_ASSERT_EQUAL(character?["real_name"], "Imported Person", "The imported character wasn't saved")
	TEST_ASSERT_EQUAL(saved["antag_rep"], 77, "The player's antag rep was replaced by the file")
	var/list/tokens = saved["saved_tokens"]
	TEST_ASSERT_EQUAL(tokens?["high_threat"], 4, "The player's antag tokens were replaced by the file")
	var/list/job_xp = saved["job_xp_list"]
	TEST_ASSERT_EQUAL(job_xp?["import_test_job"], 123, "The player's job xp was replaced by the file")
	var/list/inventory = saved["extra_stat_inventory"]
	TEST_ASSERT_EQUAL(length(inventory?["unusual"]), 1, "The player's owned items were replaced by the file")
