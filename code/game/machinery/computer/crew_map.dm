/datum/crewmonitor
	/// Z level (as text) -> list(holomap canvas it was drawn from, map data), shared by every crew monitor
	var/static/list/map_cache = list()

/datum/crewmonitor/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet_batched/job_icons))

/datum/crewmonitor/ui_static_data(mob/user)
	var/list/map_data
	if(ui_has_map[WEAKREF(user)])
		map_data = get_map_data(get_user_z(user))
	return list("map" = map_data)

/datum/crewmonitor/proc/get_user_z(mob/user)
	if(user.z)
		return user.z
	var/turf/user_turf = get_turf(user)
	return user_turf?.z

/// Returns the spritesheet class of the icon for the job with this title, or null if it has none
/datum/crewmonitor/proc/get_job_icon_class(job_title)
	var/static/list/class_cache = list()
	if(!istext(job_title))
		return null
	if(job_title in class_cache)
		return class_cache[job_title]
	var/datum/job/job = SSjob.GetJob(job_title)
	var/icon_class
	if(job)
		var/datum/asset/spritesheet_batched/job_icons/sheet = get_asset_datum(/datum/asset/spritesheet_batched/job_icons)
		icon_class = sheet.icon_class_name(sanitize_css_class_name(LOWER_TEXT(job.config_tag || job.title)))
	class_cache[job_title] = icon_class
	return icon_class

/// Returns the map of a z level for the ui, or null if it has no holomap
/datum/crewmonitor/proc/get_map_data(z)
	var/z_key = "[z]"
	var/icon/canvas = SSholomaps.holomaps[z_key]
	var/list/bounds = SSholomaps.holomap_bounds[z_key]
	if(!canvas || !bounds)
		return null
	var/list/cached = map_cache[z_key]
	// the holomaps can be made again midround
	if(cached?[1] == canvas)
		return cached[2]
	var/list/map_data = build_map_data(z_key, bounds)
	map_cache[z_key] = list(canvas, map_data)
	return map_data

/datum/crewmonitor/proc/build_map_data(z_key, list/bounds)
	var/icon/map_icon = build_map_icon(z_key, bounds)
	var/list/area_names = list()
	var/list/area_rows = build_area_rows(z_key, bounds, area_names)
	return list(
		"image" = "data:image/png;base64,[icon2base64(map_icon)]",
		"z" = text2num(z_key),
		"min_x" = bounds[1],
		"min_y" = bounds[2],
		"width" = bounds[3] - bounds[1] + 1,
		"height" = bounds[4] - bounds[2] + 1,
		"area_names" = area_names,
		"area_rows" = area_rows,
	)

/// Draws the holomap of a z level with its areas, cut down to the bounds. One pixel is one tile.
/datum/crewmonitor/proc/build_map_icon(z_key, list/bounds)
	var/icon/map_icon = icon(SSholomaps.holomaps[z_key])
	map_icon.Blend(HOLOMAP_HOLOFIER, ICON_MULTIPLY)
	var/icon/area_canvas = SSholomaps.extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[z_key]"]
	if(area_canvas)
		map_icon.Blend(area_canvas, ICON_OVERLAY)
	var/offset_x = HOLOMAP_CENTER_X
	var/offset_y = HOLOMAP_CENTER_Y
	map_icon.Crop(offset_x + bounds[1], offset_y + bounds[2], offset_x + bounds[3], offset_y + bounds[4])
	return map_icon

/// Packs the area name of every tile of the bounds into one row per y, from the bottom. A row is pairs of
/// (index in area_names, how many tiles in a row have it), index 0 is a tile with no name. Fills area_names.
/datum/crewmonitor/proc/build_area_rows(z_key, list/bounds, list/area_names)
	var/list/position_to_name = SSholomaps.holomap_position_to_name[z_key] || list()
	var/list/area_ids = list()
	var/list/rows = list()
	var/offset_x = HOLOMAP_CENTER_X
	var/offset_y = HOLOMAP_CENTER_Y
	for(var/y in bounds[2] to bounds[4])
		var/list/row = list()
		var/run_id = -1
		var/run_length = 0
		for(var/x in bounds[1] to bounds[3])
			var/area_id = 0
			var/area_name = position_to_name["[offset_x + x]:[offset_y + y]"]
			if(area_name)
				area_id = area_ids[area_name]
				if(!area_id)
					area_names += area_name
					area_id = length(area_names)
					area_ids[area_name] = area_id
			if(area_id == run_id)
				run_length++
				continue
			if(run_length)
				row += list(run_id, run_length)
			run_id = area_id
			run_length = 1
		row += list(run_id, run_length)
		rows += list(row)
	return rows
