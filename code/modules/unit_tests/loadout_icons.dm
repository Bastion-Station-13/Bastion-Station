/datum/unit_test/loadout_icons
	priority = TEST_DEFAULT

/datum/unit_test/loadout_icons/Run()
	var/datum/asset/json/loadout_items/loadout_items_json = load_asset_datum(/datum/asset/json/loadout_items)
	var/list/loadout_tabs = loadout_items_json.generate()
	var/list/sprite_classes = list()

	for(var/tab in loadout_tabs)
		for(var/item in tab["contents"])
			check_icon(item, sprite_classes)

/datum/unit_test/loadout_icons/proc/check_icon(list/item, list/sprite_classes)
	var/item_name = "[item["name"]] ([item["path"]])"
	if(item["icon_state"])
		if(!icon_exists(item["icon"], item["icon_state"]))
			TEST_FAIL("Loadout item [item_name] uses icon state \"[item["icon_state"]]\" which is not in [item["icon"]]")
		return

	if(!istext(item["icon"]))
		return

	// greyscale items are drawn from the spritesheet, so two of them sharing a class would show the same icon
	var/class_owner = sprite_classes[item["icon"]]
	if(class_owner && class_owner != item["path"])
		TEST_FAIL("Loadout items [class_owner] and [item["path"]] share the icon class [item["icon"]]")
	sprite_classes[item["icon"]] = item["path"]
