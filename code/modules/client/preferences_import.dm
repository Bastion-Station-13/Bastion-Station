// Players can import a preferences file they exported earlier. The file is checked and sanitized when it is uploaded and put
// next to their preferences, then they are disconnected. The change is made when they reconnect, before their preferences
// load, so nothing that is still connected can save over it.

#define PREFERENCES_IMPORT_NUM "num"
#define PREFERENCES_IMPORT_TEXT "text"
#define PREFERENCES_IMPORT_LIST "list"

/// Entries of the preferences file that only the server may change. An import keeps what the player has now, otherwise
/// the exported file could be edited to hand out tokens, rep, job levels or items.
GLOBAL_LIST_INIT(preferences_import_kept_keys, list(
	"saved_tokens",
	"antag_rep",
	"extra_stat_inventory",
	"job_xp_list",
	"job_level_list",
	"job_rewards_claimed",
	"job_rewards_per_round",
	"hearted_until",
))

/// The other top level entries an import accepts, with what they have to be. Player preferences and characters are checked separately.
GLOBAL_LIST_INIT(preferences_import_key_types, list(
	"version" = PREFERENCES_IMPORT_NUM,
	"modular_version" = PREFERENCES_IMPORT_NUM,
	"lastchangelog" = PREFERENCES_IMPORT_TEXT,
	"default_slot" = PREFERENCES_IMPORT_NUM,
	"default_character" = PREFERENCES_IMPORT_NUM,
	"toggles" = PREFERENCES_IMPORT_NUM,
	"chat_toggles" = PREFERENCES_IMPORT_NUM,
	"be_special" = PREFERENCES_IMPORT_LIST,
	"ignoring" = PREFERENCES_IMPORT_LIST,
	"key_bindings" = PREFERENCES_IMPORT_LIST,
	"favorite_outfits" = PREFERENCES_IMPORT_LIST,
	"enabled_characters" = PREFERENCES_IMPORT_LIST,
	"job_preferences_overall" = PREFERENCES_IMPORT_LIST,
	"channel_volume" = PREFERENCES_IMPORT_LIST,
))

/datum/preferences
	/// When this player can try another import
	COOLDOWN_DECLARE(import_cooldown)

/proc/preferences_import_pending_path(ckey)
	return "data/player_saves/[ckey[1]]/[ckey]/[PREFERENCES_IMPORT_PENDING_FILE]"

/proc/preferences_import_type_ok(value, type)
	switch(type)
		if(PREFERENCES_IMPORT_NUM)
			return isnum(value)
		if(PREFERENCES_IMPORT_TEXT)
			return istext(value)
		if(PREFERENCES_IMPORT_LIST)
			return islist(value)
	return FALSE

/// Reads a json file into a list, null if it isn't one
/proc/preferences_import_read(path)
	if(!fexists(path))
		return null
	var/list/result
	try
		result = json_decode(rustg_file_read(path))
	catch
		return null
	return islist(result) ? result : null

/// Asks for the file, checks it and stages it. The player is disconnected and the change is made when they reconnect
/datum/preferences/proc/start_preferences_import(mob/user)
	if(CONFIG_GET(flag/forbid_preferences_import))
		tgui_alert(user, "Importing preferences is turned off on this server.", "Import Preferences")
		return
	if(!load_and_save || !path || !parent)
		tgui_alert(user, "Guests can't import preferences, nothing is saved for them.", "Import Preferences")
		return
	if(!COOLDOWN_FINISHED(src, import_cooldown))
		tgui_alert(user, "You must wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, import_cooldown))] before importing your preferences again!", "Import Preferences")
		return

	var/warning = "This replaces all of your characters and preferences with the ones in the file. Your antag tokens, antag rep, job xp and owned items are kept. You will be disconnected, then you reconnect to finish the import. Continue?"
	if(tgui_alert(user, warning, "Import Preferences", list("Cancel", "Continue")) != "Continue")
		return
	COOLDOWN_START(src, import_cooldown, (CONFIG_GET(number/seconds_cooldown_for_preferences_import) * (1 SECONDS)))

	var/upload = input(user, "Pick the .json file you got from Export Preferences.", "Import Preferences") as null|file
	if(!upload)
		return
	var/error = stage_preferences_import(upload)
	if(error)
		log_game("[key_name(user)] tried to import preferences but the file was refused: [error]")
		tgui_alert(user, "Your preferences were not changed. [error]", "Import Preferences")
		return

	log_game("[key_name(user)] staged a preferences import")
	tgui_alert(user, "The file is fine. You will be disconnected now, reconnect to finish the import.", "Import Preferences", list("Disconnect"))
	qdel(parent)

/// Checks the uploaded file and puts it next to the player's preferences. Returns why it was refused, null if it is staged.
/datum/preferences/proc/stage_preferences_import(upload)
	var/list/result = parse_preferences_import(upload, src)
	if(result["error"])
		return result["error"]

	// what the server keeps is read from the saved file when the import is applied, so make sure it is current
	parent.client_token_holder?.convert_tokens_to_list()
	save_preferences()

	var/pending_path = preferences_import_pending_path(parent_ckey)
	fdel(pending_path)
	rustg_file_write(json_encode(result["tree"]), pending_path)
	if(!fexists(pending_path) || !rustg_json_is_valid(rustg_file_read(pending_path)))
		fdel(pending_path)
		return "The import couldn't be saved, try again later."
	return null

/// Reads an uploaded preferences file. Returns list("tree" = the entries that are safe to import) or list("error" = why it was refused)
/proc/parse_preferences_import(upload, datum/preferences/target)
	if(!isfile(upload))
		return list("error" = "No file was uploaded.")
	var/size = length(upload)
	if(!size)
		return list("error" = "That file is empty.")
	if(size > PREFERENCES_IMPORT_MAX_SIZE)
		return list("error" = "That file is too big, it can be at most [PREFERENCES_IMPORT_MAX_SIZE / 1024] KB.")

	var/text = file2text(upload)
	if(!istext(text) || !length(text) || length(text) > PREFERENCES_IMPORT_MAX_SIZE)
		return list("error" = "That file couldn't be read as text.")
	// rust-g refuses json that is nested too deep, so this also stops a file built to eat the server
	if(copytext(trim(text), 1, 2) != "{" || !rustg_json_is_valid(text))
		return list("error" = "That isn't a preferences file, it has to be the json you got from Export Preferences.")

	var/list/tree
	try
		tree = json_decode(text)
	catch
		return list("error" = "That file couldn't be read.")
	if(!islist(tree) || length(tree) > PREFERENCES_IMPORT_MAX_KEYS)
		return list("error" = "That isn't a preferences file.")

	if(!isnum(tree["version"]))
		return list("error" = "That file has no version, it doesn't look like exported preferences.")
	if(!isnull(tree["modular_version"]) && !isnum(tree["modular_version"]))
		tree -= "modular_version"
	if(target.save_data_needs_update(tree) == -2 || target.save_data_needs_update_monkestation(tree) == -2)
		return list("error" = "That file is too old to import.")

	var/list/clean = list()
	var/characters = 0
	for(var/key in tree)
		if(!istext(key) || length(key) > 64 || (key in GLOB.preferences_import_kept_keys))
			continue
		var/value = tree[key]
		if(isnull(value))
			continue

		if(key in GLOB.preferences_import_key_types)
			if(preferences_import_type_ok(value, GLOB.preferences_import_key_types[key]))
				clean[key] = value
			continue

		if(copytext(key, 1, 10) == "character")
			var/slot_text = copytext(key, 10)
			var/slot = text2num(slot_text)
			if("[slot]" != slot_text || slot != round(slot) || slot < 1 || slot > target.max_save_slots || !islist(value))
				continue
			sanitize_imported_character(value, target)
			clean[key] = value
			characters++
			continue

		var/datum/preference/preference = GLOB.preference_entries_by_key[key]
		if(preference?.savefile_identifier == PREFERENCE_PLAYER)
			clean[key] = value

	if(!characters)
		return list("error" = "That file has no characters in it.")
	return list("tree" = clean)

/// Removes what the player couldn't pick themselves from an imported character, the loadout is only checked when it is picked
/proc/sanitize_imported_character(list/character, datum/preferences/target)
	var/list/clean_loadout = list()
	var/list/loadout = character["loadout_list"]
	if(islist(loadout))
		var/datum/preference_middleware/loadout/loadout_rules
		for(var/datum/preference_middleware/loadout/middleware in target.middleware)
			loadout_rules = middleware
		for(var/path_text in loadout)
			if(!istext(path_text) || length(clean_loadout) >= PREFERENCES_IMPORT_MAX_LOADOUT)
				continue
			var/path = text2path(path_text)
			var/datum/loadout_item/item = ispath(path) ? GLOB.all_loadout_datums[path] : null
			if(!item || !loadout_rules?.is_item_allowed(item))
				continue
			var/info = loadout[path_text]
			clean_loadout[path_text] = islist(info) ? info : list()
	character["loadout_list"] = clean_loadout

	// these are positions in the inventory the player owns, which an import never changes
	var/list/clean_special = list()
	var/list/special = character["special_loadout_list"]
	if(islist(special))
		for(var/header in target.extra_stat_inventory)
			var/list/owned = target.extra_stat_inventory[header]
			var/list/clean_numbers = list()
			var/list/numbers = special[header]
			if(islist(numbers))
				for(var/number in numbers)
					var/index = text2num("[number]")
					if(!isnum(index) || index != round(index) || index < 1 || index > length(owned))
						continue
					clean_numbers |= "[index]"
			clean_special[header] = clean_numbers
	character["special_loadout_list"] = clean_special

/// Applies the import this player staged, called before their preferences load. Returns what to tell them, null if nothing was waiting.
/// The old preferences are copied to preferences.json.importbak first and put back if the new ones can't be saved.
/proc/apply_pending_preferences_import(ckey)
	if(!ckey || is_guest_key(ckey))
		return null
	var/pending_path = preferences_import_pending_path(ckey)
	if(!fexists(pending_path))
		return null

	var/save_path = "data/player_saves/[ckey[1]]/[ckey]/preferences.json"
	var/backup_path = "[save_path].importbak"
	var/temp_path = "[save_path].importing"
	var/imported = FALSE
	try
		var/list/staged = preferences_import_read(pending_path)
		if(!staged)
			CRASH("the import waiting for [ckey] isn't a list")
		var/list/current = preferences_import_read(save_path) || list()
		for(var/key in GLOB.preferences_import_kept_keys)
			if(key in current)
				staged[key] = current[key]
			else
				staged -= key

		fdel(temp_path)
		rustg_file_write(json_encode(staged, JSON_PRETTY_PRINT), temp_path)
		var/new_text = rustg_file_read(temp_path)
		if(!length(new_text) || !rustg_json_is_valid(new_text))
			CRASH("the import for [ckey] couldn't be written")

		if(fexists(save_path))
			var/old_text = rustg_file_read(save_path)
			fdel(backup_path)
			fcopy(save_path, backup_path)
			if(rustg_file_read(backup_path) != old_text)
				CRASH("couldn't back up the preferences of [ckey]")
			fdel(save_path)
		fcopy(temp_path, save_path)
		if(rustg_file_read(save_path) != new_text)
			CRASH("couldn't save the imported preferences of [ckey]")
		imported = TRUE
	catch(var/exception/error)
		log_game("PREFERENCES IMPORT: applying the import of [ckey] failed: [error]")
		if(fexists(backup_path) && !fexists(save_path))
			fcopy(backup_path, save_path)
	fdel(pending_path)
	fdel(temp_path)

	if(!imported)
		return span_warning("Importing your preferences failed, your old preferences were kept.")

	// the old datum still has the old values and would save them over the import
	var/datum/preferences/stale = GLOB.preferences_datums[ckey]
	GLOB.preferences_datums -= ckey
	if(stale)
		qdel(stale)
	log_game("PREFERENCES IMPORT: the imported preferences of [ckey] were applied")
	return span_notice("Your preferences were imported.")

#undef PREFERENCES_IMPORT_NUM
#undef PREFERENCES_IMPORT_TEXT
#undef PREFERENCES_IMPORT_LIST
