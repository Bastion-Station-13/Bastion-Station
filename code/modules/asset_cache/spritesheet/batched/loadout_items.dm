/datum/asset/spritesheet_batched/loadout_items
	name = "loadout_items"

/datum/asset/spritesheet_batched/loadout_items/create_spritesheets()
	var/list/id_list = list()
	for(var/obj/item/item_type as anything in GLOB.all_loadout_datums)
		if(!loadout_icon_needs_spritesheet(item_type))
			continue
		var/id = sanitize_css_class_name("[item_type]")
		if(id_list[id])
			continue
		insert_icon(id, gags_to_universal_icon(item_type))
		id_list[id] = TRUE

/// Greyscale items have no icon state to show as is, their icon has to be drawn into the spritesheet
/proc/loadout_icon_needs_spritesheet(obj/item/item_type)
	if(item_type::icon_preview && item_type::icon_state_preview)
		return FALSE
	return !!(item_type::greyscale_config && item_type::greyscale_colors)

/// Adds what the loadout menu needs to draw the icon of [item_type] to [formatted_item]
/proc/add_loadout_icon_data(list/formatted_item, obj/item/item_type)
	if(loadout_icon_needs_spritesheet(item_type))
		formatted_item["icon"] = sanitize_css_class_name("[item_type]")
		return
	var/use_preview = item_type::icon_preview && item_type::icon_state_preview
	var/state = use_preview ? item_type::icon_state_preview : item_type::icon_state
	if(!state)
		return
	formatted_item["icon"] = use_preview ? item_type::icon_preview : item_type::icon
	formatted_item["icon_state"] = state
