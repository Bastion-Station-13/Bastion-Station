/// Checks uploaded preferences files are refused when they are wrong, and that an import keeps what the server owns
/datum/unit_test/preferences_import
	var/test_ckey = "importtester"
	var/test_dir = "data/preferences_import_test/"
	var/save_path = "data/player_saves/i/importtester/preferences.json"
	var/datum/client_interface/client
	var/datum/preferences/target
	var/version

/datum/unit_test/preferences_import/Destroy()
	fdel(test_dir)
	fdel("data/player_saves/i/importtester/")
	GLOB.preferences_datums -= test_ckey
	target = null
	// loading preferences gives the client an interaction mode that points back at it
	if(client)
		QDEL_NULL(client.imode)
	client = null
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

/// Starts again from a freshly saved preferences file and nothing waiting to be imported
/datum/unit_test/preferences_import/proc/reset_baseline()
	GLOB.preferences_datums -= test_ckey
	fdel("data/player_saves/i/importtester/")
	target = allocate(/datum/preferences, client)
	target.save_preferences()
	target.save_character()

/datum/unit_test/preferences_import/Run()
	client = allocate(/datum/client_interface, test_ckey)
	reset_baseline()
	version = target.savefile.get_entry("version")
	TEST_ASSERT(isnum(version), "The test preferences have no version")

	check_refused()
	check_clean_tree()
	check_loadout()
	check_nothing_dropped()
	check_slots()
	check_character_versions()
	check_values()
	check_round_trip()
	check_hostile_load()

	// what a maintainer would try by uploading files
	check_valid_file()
	check_gibberish()
	check_wrong_json()
	check_malicious_file()

	check_apply()
	check_older_file()

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
	var/list/character = character_named("Loadout Person")
	character["loadout_list"] = list(
		"[plain.item_path]" = list(),
		"[donator.item_path]" = list(),
		"/obj/item/not_a_real_loadout_item" = list(),
		"not even a path" = list(),
	)
	character["special_loadout_list"] = list(
		"unusual" = list("1", "0", "-1", "7", "abc", 1.5),
		"made up" = list("1"),
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

/// A copy of the saved preferences file, the lists inside are shared so only replace entries
/datum/unit_test/preferences_import/proc/export_copy()
	var/list/live_tree = target.savefile.get_entry()
	return live_tree.Copy()

/// A copy of the saved first character with another name
/datum/unit_test/preferences_import/proc/character_named(real_name)
	var/list/saved = target.savefile.get_entry("character1")
	var/list/character = saved.Copy()
	character["real_name"] = real_name
	return character

/// Stages the entries like the verb does, applies them like a login does and loads them in a new preferences datum
/datum/unit_test/preferences_import/proc/import_and_reload(list/tree)
	var/error = target.stage_preferences_import(upload(json_encode(tree)))
	TEST_ASSERT_NULL(error, "The import was refused: [error]")
	TEST_ASSERT_NOTNULL(apply_pending_preferences_import(test_ckey), "Nothing was applied")
	return allocate(/datum/preferences, client)

/datum/unit_test/preferences_import/proc/check_nothing_dropped()
	reset_baseline()
	var/list/export = export_copy()
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A normal export was refused: [result["error"]]")
	var/list/tree = result["tree"]
	for(var/key in export)
		TEST_ASSERT((key in tree) || (key in GLOB.preferences_import_kept_keys), "[key] is saved by the game but an import would lose it")

/datum/unit_test/preferences_import/proc/check_slots()
	reset_baseline()
	var/list/export = export_copy()
	export -= "character1"
	export["character2"] = character_named("Second Person")
	export["character3"] = character_named("Third Person")
	export["default_slot"] = 1
	export["default_character"] = 1
	export["enabled_characters"] = list(1, 2, 7)
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file without a first character was refused: [result["error"]]")
	var/list/tree = result["tree"]
	TEST_ASSERT(("character[tree["default_slot"]]" in tree), "The default slot is a character that wasn't imported")
	TEST_ASSERT(("character[tree["default_character"]]" in tree), "The default character is one that wasn't imported")
	TEST_ASSERT_EQUAL(jointext(tree["enabled_characters"], ","), "2", "The enabled characters aren't only the imported ones")

	export["enabled_characters"] = list(1, 7)
	result = parse(json_encode(export))
	TEST_ASSERT(length(result["tree"]["enabled_characters"]), "Nothing is enabled when none of the enabled characters were imported")

/datum/unit_test/preferences_import/proc/check_character_versions()
	reset_baseline()
	var/list/export = export_copy()
	var/list/no_version = character_named("No Version")
	no_version -= "version"
	var/list/text_version = character_named("Text Version")
	text_version["version"] = "x"
	var/list/old_version = character_named("Old Version")
	old_version["version"] = 1
	var/list/odd_modular = character_named("Odd Modular")
	odd_modular["modular_version"] = "high"
	export["character1"] = no_version
	export["character2"] = text_version
	export["character3"] = old_version
	export["character4"] = odd_modular
	export["character5"] = character_named("Good One")
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file with some usable characters was refused: [result["error"]]")
	var/list/tree = result["tree"]
	TEST_ASSERT(!("character1" in tree) && !("character2" in tree) && !("character3" in tree), "A character with a missing, broken or too old version was imported")
	TEST_ASSERT(("character4" in tree) && ("character5" in tree), "A usable character wasn't imported")
	var/list/odd = tree["character4"]
	TEST_ASSERT(isnull(odd["modular_version"]) || isnum(odd["modular_version"]), "A modular version that isn't a number was imported")

	export -= "character4"
	export -= "character5"
	assert_refused(json_encode(export), "A file where no character has a usable version was accepted")

/datum/unit_test/preferences_import/proc/check_values()
	check_alt_titles()
	check_volumes()
	check_keybinds()
	check_toggles()
	check_quirks_and_jobs()

/datum/unit_test/preferences_import/proc/check_quirks_and_jobs()
	var/list/quirks = SSquirks.get_quirks()
	var/real_quirk = quirks[1]
	var/datum/job/job = SSjob.joinable_occupations[1]

	reset_baseline()
	var/list/export = export_copy()
	var/list/character = character_named("Quirky Person")
	character["all_quirks"] = list("Not A Quirk", 5, list("x"), real_quirk)
	character["job_preferences"] = list("[job.title]" = JP_HIGH, "Not A Job" = JP_LOW)
	export["character1"] = character
	export["job_preferences_overall"] = list("[job.title]" = 7)
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file with quirks and job preferences was refused: [result["error"]]")
	var/list/clean = result["tree"]["character1"]
	TEST_ASSERT_EQUAL(jointext(clean["all_quirks"], ","), real_quirk, "Quirks that don't exist, or aren't text, were imported")
	var/list/job_preferences = clean["job_preferences"]
	TEST_ASSERT_EQUAL(job_preferences[job.title], JP_HIGH, "A valid job preference was removed")
	TEST_ASSERT_EQUAL(length(job_preferences), 1, "A job preference for a job that doesn't exist was imported")
	TEST_ASSERT_EQUAL(length(result["tree"]["job_preferences_overall"]), 0, "A job preference level that doesn't exist was imported")

/datum/unit_test/preferences_import/proc/check_toggles()
	reset_baseline()
	var/list/export = export_copy()
	export["toggles"] = -5
	export["chat_toggles"] = 2.7
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file with toggles was refused: [result["error"]]")
	var/list/tree = result["tree"]
	TEST_ASSERT(!("toggles" in tree), "Toggles below zero were imported")
	TEST_ASSERT_EQUAL(tree["chat_toggles"], 2, "Chat toggles that aren't a whole number weren't brought down to one")

	export["chat_toggles"] = 1e30
	result = parse(json_encode(export))
	TEST_ASSERT(!("chat_toggles" in result["tree"]), "Chat toggles far above the possible bits were imported")

/datum/unit_test/preferences_import/proc/check_alt_titles()
	var/datum/job/titled
	var/datum/job/other
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(!titled && length(job.alt_titles))
			titled = job
		else if(!other)
			other = job
	TEST_ASSERT_NOTNULL(titled, "There is no job with alternative titles")
	TEST_ASSERT_NOTNULL(other, "There is no second job")
	var/valid_title = titled.alt_titles[1]

	reset_baseline()
	var/list/export = export_copy()
	var/list/character = character_named("Titled Person")
	character["alt_job_titles"] = list(
		"[titled.title]" = valid_title,
		"Not A Job" = valid_title,
		"[other.title]" = "Definitely Not A Title",
	)
	export["character1"] = character
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file with alternative job titles was refused: [result["error"]]")
	var/list/titles = result["tree"]["character1"]["alt_job_titles"]
	TEST_ASSERT_EQUAL(titles?[titled.title], valid_title, "A valid alternative job title was removed")
	TEST_ASSERT_EQUAL(length(titles), 1, "An alternative job title the job doesn't have was imported")

/datum/unit_test/preferences_import/proc/check_volumes()
	reset_baseline()
	var/list/export = export_copy()
	export["channel_volume"] = list("1005" = 500, "1018" = "loud", "1019" = -5, "1020" = list(1), "1021" = 0.5, "abc" = 50, "1022" = 40)
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file with volumes was refused: [result["error"]]")
	var/list/volumes = result["tree"]["channel_volume"]
	TEST_ASSERT_EQUAL(volumes["1005"], 100, "A volume above the slider wasn't capped")
	TEST_ASSERT_EQUAL(volumes["1019"], 0, "A volume below zero wasn't raised to zero")
	TEST_ASSERT_EQUAL(volumes["1021"], 0.5, "A volume between whole numbers was changed")
	TEST_ASSERT_EQUAL(volumes["1022"], 40, "A normal volume was changed")
	TEST_ASSERT_EQUAL(length(volumes), 4, "A volume that isn't a number, or isn't for a channel, was imported")

/datum/unit_test/preferences_import/proc/check_keybinds()
	reset_baseline()
	var/list/export = export_copy()
	var/first = GLOB.keybindings_by_name[1]
	var/second = GLOB.keybindings_by_name[2]
	export["key_bindings"] = list(
		"bogus" = list("A"),
		"[first]" = "notalist",
		"[second]" = list("W", 5, list("x"), "CtrlQ"),
	)
	var/list/result = parse(json_encode(export))
	TEST_ASSERT_NULL(result["error"], "A file with key bindings was refused: [result["error"]]")
	var/list/binds = result["tree"]["key_bindings"]
	TEST_ASSERT(!("bogus" in binds), "A key binding that doesn't exist was imported")
	TEST_ASSERT(!(first in binds), "A key binding that isn't a list of keys was imported")
	TEST_ASSERT_EQUAL(jointext(binds[second], ","), "W,CtrlQ", "A key that isn't text was imported")

/datum/unit_test/preferences_import/proc/check_round_trip()
	reset_baseline()
	var/list/export = export_copy()
	export -= "character1"
	export["character2"] = character_named("Second Person")
	export["character3"] = character_named("Third Person")
	export["default_slot"] = 1
	export["default_character"] = 1
	export["enabled_characters"] = list(1, 3)
	var/datum/preferences/fresh = import_and_reload(export)
	if(!fresh)
		return
	TEST_ASSERT(fresh.loaded, "The imported preferences didn't load")
	TEST_ASSERT_EQUAL(fresh.read_preference(/datum/preference/name/real_name), "Second Person", "The first imported character isn't the one that loaded")
	TEST_ASSERT_EQUAL(fresh.default_character, 2, "The default character isn't one of the imported ones")
	TEST_ASSERT_EQUAL(jointext(fresh.enabled_characters, ","), "3", "The enabled characters aren't the imported ones")

/datum/unit_test/preferences_import/proc/check_hostile_load()
	reset_baseline()
	var/list/export = export_copy()
	var/list/junk = list(list("a" = list()), 5, "x", list(list(list())), null)
	export["be_special"] = junk
	export["ignoring"] = junk
	export["favorite_outfits"] = junk
	export["enabled_characters"] = junk
	export["job_preferences_overall"] = junk
	export["key_bindings"] = junk
	export["channel_volume"] = junk
	var/list/character = character_named("Hostile Person")
	character["randomise"] = "yes"
	character["job_preferences"] = junk
	character["all_quirks"] = junk
	character["loadout_list"] = junk
	character["special_loadout_list"] = junk
	character["alt_job_titles"] = junk
	character["species"] = 5
	character["hair_color"] = list()
	export["character1"] = character
	var/datum/preferences/fresh = import_and_reload(export)
	if(!fresh)
		return
	TEST_ASSERT(fresh.loaded, "A file full of junk stopped the preferences from loading")
	TEST_ASSERT_EQUAL(fresh.read_preference(/datum/preference/name/real_name), "Hostile Person", "The character from a file full of junk wasn't loaded")
	for(var/channel in fresh.channel_volume)
		TEST_ASSERT(isnum(fresh.channel_volume[channel]), "A volume that isn't a number was loaded")
	for(var/job_name in fresh.alt_job_titles)
		TEST_ASSERT(istext(fresh.alt_job_titles[job_name]), "An alternative job title that isn't text was loaded")

/// Gives the file to the same proc the verb calls once the player picked it, a refused file must change nothing
/datum/unit_test/preferences_import/proc/assert_refused_and_untouched(text, message)
	var/before = rustg_file_read(save_path)
	var/error = target.stage_preferences_import(upload(text))
	TEST_ASSERT_NOTNULL(error, message)
	TEST_ASSERT(!fexists(preferences_import_pending_path(test_ckey)), "[message] (a refused file was left waiting to be imported)")
	TEST_ASSERT_EQUAL(rustg_file_read(save_path), before, "[message] (a refused file changed the saved preferences)")

/// 1) A valid preferences file
/datum/unit_test/preferences_import/proc/check_valid_file()
	reset_baseline()
	target.antag_rep = 33
	target.save_preferences()
	var/list/export = export_copy()
	export["character1"] = character_named("First Person")
	export["character2"] = character_named("Second Person")
	var/datum/preferences/fresh = import_and_reload(export)
	if(!fresh)
		return
	TEST_ASSERT(fresh.loaded, "A valid file didn't load")
	TEST_ASSERT_EQUAL(fresh.read_preference(/datum/preference/name/real_name), "First Person", "The first character of a valid file isn't the one that loaded")
	var/list/second = fresh.savefile.get_entry("character2")
	TEST_ASSERT_EQUAL(second?["real_name"], "Second Person", "The second character of a valid file wasn't imported")
	TEST_ASSERT_EQUAL(fresh.antag_rep, 33, "A valid import changed the player's antag rep")

/// 2) Random gibberish
/datum/unit_test/preferences_import/proc/check_gibberish()
	reset_baseline()
	var/list/noise = list()
	for(var/i in 1 to 4000)
		noise += ascii2text(rand(1, 255))
	assert_refused_and_untouched(noise.Join(), "Random characters were accepted")
	assert_refused_and_untouched("the quick brown fox jumps over the lazy dog", "A sentence was accepted")
	assert_refused_and_untouched("{\"version\": [version], \"character1\": {", "Json that was cut off was accepted")
	assert_refused_and_untouched("{{{{}}}}", "Braces were accepted")
	assert_refused_and_untouched("\[\[\[\[", "Brackets were accepted")
	assert_refused_and_untouched("   \n\t   ", "A file of whitespace was accepted")

/// 3) Valid json that isn't preferences
/datum/unit_test/preferences_import/proc/check_wrong_json()
	reset_baseline()
	assert_refused_and_untouched("\[1, 2, 3]", "A json list was accepted")
	assert_refused_and_untouched("\"just some text\"", "A json string was accepted")
	assert_refused_and_untouched("42", "A json number was accepted")
	assert_refused_and_untouched("null", "Json null was accepted")
	assert_refused_and_untouched("{}", "An empty json object was accepted")
	assert_refused_and_untouched("{\"hello\": \"world\", \"items\": \[1, 2, 3], \"ok\": true}", "Json that isn't preferences was accepted")
	assert_refused_and_untouched("{\"version\": [version]}", "Preferences without any character were accepted")
	assert_refused_and_untouched("{\"version\": [version], \"character1\": \"not a character\"}", "A character that is text was accepted")
	assert_refused_and_untouched("{\"version\": [version], \"character1\": \[1, 2]}", "A character that is a list was accepted")

/// 4) A file made to do harm
/datum/unit_test/preferences_import/proc/check_malicious_file()
	var/datum/loadout_item/donator
	for(var/path in GLOB.all_loadout_datums)
		var/datum/loadout_item/item = GLOB.all_loadout_datums[path]
		if(item.donator_only)
			donator = item
			break
	TEST_ASSERT_NOTNULL(donator, "There is no donator loadout item")

	// the file that is too deep or too big is refused and changes nothing
	reset_baseline()
	assert_refused_and_untouched(nested(5000), "A file nested far too deep was accepted")
	assert_refused_and_untouched("{\"version\": [version], \"character1\": {}, \"filler\": \"[jointext(new /list(PREFERENCES_IMPORT_MAX_SIZE), "x")]\"}", "A file that is too big was accepted")

	// a file that looks fine but tries to give the player what only the server gives
	reset_baseline()
	var/datum/persistent_client/persistent = target.parent.persistent_client
	persistent.patreon.owned_rank = NO_RANK
	persistent.twitch.owned_rank = NO_TWITCH_SUB
	target.antag_rep = 77
	target.saved_tokens["high_threat"] = 4
	target.extra_stat_inventory["unusual"] = list(list("unusual_type" = "/obj/item/pen"))
	target.job_xp_list["import_test_job"] = 123
	target.save_preferences()

	var/datum/job/titled = SSjob.joinable_occupations[1]

	var/list/export = export_copy()
	export["antag_rep"] = 999999
	export["saved_tokens"] = list("high_threat" = 999, "donator" = 999)
	export["job_xp_list"] = list("import_test_job" = 99999999)
	export["extra_stat_inventory"] = list("unusual" = list(list("unusual_type" = "/obj/item/gun/ballistic/rifle")))
	export["hearted_until"] = 1e11
	export["toggles"] = -1
	export["chat_toggles"] = 1e30
	export["evil"] = "x"
	export["../../../config/admins.txt"] = "x"
	export["__proto__"] = list("admin" = 1)
	var/list/character = character_named("Evil Person")
	character["loadout_list"] = list("[donator.item_path]" = list(), "/obj/item/gun/ballistic/rifle" = list())
	character["special_loadout_list"] = list("unusual" = list("1", "2", "3"))
	character["alt_job_titles"] = list("[titled.title]" = "Definitely Not A Title", "Captain" = "Dictator")
	export["character1"] = character
	var/datum/preferences/fresh = import_and_reload(export)
	if(!fresh)
		return
	TEST_ASSERT(fresh.loaded, "A malicious file stopped the preferences from loading")
	TEST_ASSERT_EQUAL(fresh.antag_rep, 77, "A malicious file gave the player antag rep")
	TEST_ASSERT_EQUAL(fresh.saved_tokens["high_threat"], 4, "A malicious file gave the player antag tokens")
	TEST_ASSERT_EQUAL(fresh.job_xp_list["import_test_job"], 123, "A malicious file gave the player job xp")
	var/list/owned = fresh.extra_stat_inventory["unusual"]
	TEST_ASSERT_EQUAL(length(owned), 1, "A malicious file gave the player unusual items")
	TEST_ASSERT(!fresh.hearted_until && !fresh.hearted, "A malicious file made the player look commended")
	TEST_ASSERT(!(donator.item_path in fresh.loadout_list), "A malicious file gave a non donator a donator item")
	TEST_ASSERT_EQUAL(length(fresh.loadout_list), 0, "A malicious file gave the player loadout items that don't exist")
	TEST_ASSERT_EQUAL(length(fresh.alt_job_titles), 0, "A malicious file gave the player job titles their jobs don't have")
	TEST_ASSERT(fresh.toggles >= 0 && fresh.toggles < SHORT_REAL_LIMIT, "A malicious file set toggles that can't exist")
	TEST_ASSERT(fresh.chat_toggles >= 0 && fresh.chat_toggles < SHORT_REAL_LIMIT, "A malicious file set chat toggles that can't exist")

	// what ended up in the saved file is only what the game saves itself
	var/list/saved = preferences_import_read(save_path)
	TEST_ASSERT_NOTNULL(saved, "The preferences saved after a malicious file can't be read")
	for(var/key in saved)
		TEST_ASSERT(!(key in list("evil", "../../../config/admins.txt", "__proto__")), "[key] from a malicious file ended up in the saved preferences")

/// An export from an older version of the game goes through the same updates as an old saved file
/datum/unit_test/preferences_import/proc/check_older_file()
	reset_baseline()
	var/list/export = export_copy()
	var/list/character = character_named("Older Person")
	character["version"] = version - 1
	character["modular_version"] = 3
	export["character1"] = character
	export["version"] = version - 1
	export["modular_version"] = 3
	var/datum/preferences/fresh = import_and_reload(export)
	if(!fresh)
		return
	TEST_ASSERT(fresh.loaded, "A file from an older version didn't load")
	TEST_ASSERT_EQUAL(fresh.read_preference(/datum/preference/name/real_name), "Older Person", "The character of a file from an older version isn't the one that loaded")

/datum/unit_test/preferences_import/proc/write_pending(list/staged)
	var/pending_path = preferences_import_pending_path(test_ckey)
	fdel(pending_path)
	text2file(json_encode(staged), pending_path)
	return pending_path

/datum/unit_test/preferences_import/proc/check_apply()
	reset_baseline()
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
