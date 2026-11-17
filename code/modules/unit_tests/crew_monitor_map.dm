/// The station map of the crew monitor is made from the holomaps
/datum/unit_test/crew_monitor_map

/datum/unit_test/crew_monitor_map/Run()
	var/datum/crewmonitor/monitor = allocate(/datum/crewmonitor)
	var/z
	for(var/mapped_z in SSholomaps.valid_map_indexes)
		if(SSholomaps.holomap_bounds["[mapped_z]"])
			z = mapped_z
			break
	TEST_ASSERT(z, "No z level has holomap bounds")
	var/list/bounds = SSholomaps.holomap_bounds["[z]"]
	TEST_ASSERT(bounds[1] >= 1 && bounds[1] <= bounds[3] && bounds[3] <= world.maxx, "The x bounds [bounds[1]] to [bounds[3]] are not in the world")
	TEST_ASSERT(bounds[2] >= 1 && bounds[2] <= bounds[4] && bounds[4] <= world.maxy, "The y bounds [bounds[2]] to [bounds[4]] are not in the world")

	var/list/map_data = monitor.get_map_data(z)
	TEST_ASSERT_NOTNULL(map_data, "No map for z level [z], which has holomap bounds")
	TEST_ASSERT_EQUAL(map_data["z"], z, "The map is of the wrong z level")
	TEST_ASSERT_EQUAL(map_data["min_x"], bounds[1], "The map starts at the wrong x")
	TEST_ASSERT_EQUAL(map_data["min_y"], bounds[2], "The map starts at the wrong y")
	TEST_ASSERT_EQUAL(map_data["width"], bounds[3] - bounds[1] + 1, "The map has the wrong width")
	TEST_ASSERT_EQUAL(map_data["height"], bounds[4] - bounds[2] + 1, "The map has the wrong height")
	TEST_ASSERT(findtext(map_data["image"], "data:image/png;base64,") == 1 && length(map_data["image"]) > 100, "The map image is not a png data url")

	TEST_ASSERT(monitor.get_map_data(z) == map_data, "The map was made again instead of coming from the cache")
	TEST_ASSERT_NULL(monitor.get_map_data(world.maxz + 1), "A z level that does not exist has a map")

	check_pixels(monitor, z, bounds)
	check_areas(monitor, map_data, z, bounds)

/// One pixel is one tile, and the tiles are where they are on the map
/datum/unit_test/crew_monitor_map/proc/check_pixels(datum/crewmonitor/monitor, z, list/bounds)
	var/icon/map_icon = monitor.build_map_icon("[z]", bounds)
	TEST_ASSERT_EQUAL(map_icon.Width(), bounds[3] - bounds[1] + 1, "The map icon has the wrong width")
	TEST_ASSERT_EQUAL(map_icon.Height(), bounds[4] - bounds[2] + 1, "The map icon has the wrong height")

	// a tile has something on the map exactly when it has something on the holomap
	var/icon/canvas = SSholomaps.holomaps["[z]"]
	var/icon/area_canvas = SSholomaps.extra_holomaps["[HOLOMAP_EXTRA_STATIONMAPAREAS]_[z]"]
	var/drawn_tiles = 0
	for(var/x in bounds[1] to bounds[3])
		for(var/y in bounds[2] to bounds[4])
			var/holomap_x = HOLOMAP_CENTER_X + x
			var/holomap_y = HOLOMAP_CENTER_Y + y
			var/expected = canvas.GetPixel(holomap_x, holomap_y) || area_canvas.GetPixel(holomap_x, holomap_y)
			var/actual = map_icon.GetPixel(x - bounds[1] + 1, y - bounds[2] + 1)
			TEST_ASSERT(!expected == !actual, "The tile at [x], [y] is [actual ? "drawn" : "empty"] on the map but [expected ? "drawn" : "empty"] on the holomap")
			if(actual)
				drawn_tiles++
	TEST_ASSERT(drawn_tiles, "Nothing is drawn on the map")

	var/turf/floor_tile
	var/turf/wall_tile
	var/turf/empty_tile
	for(var/turf/tile as anything in block(bounds[1], bounds[2], z, bounds[3], bounds[4], z))
		var/area/tile_area = tile.loc
		if(!tile_area.holomap_should_draw)
			continue
		if(!floor_tile && istype(tile, /turf/open/floor))
			floor_tile = tile
		else if(!wall_tile && istype(tile, /turf/closed/wall))
			wall_tile = tile
		else if(!empty_tile && isspaceturf(tile) && !tile_area.holomap_color && !(locate(/obj/structure/lattice) in tile) && !(locate(/obj/structure/grille) in tile) && !(locate(/obj/structure/window) in tile))
			empty_tile = tile
		if(floor_tile && wall_tile && empty_tile)
			break

	TEST_ASSERT_NOTNULL(floor_tile, "No floor on the map to look for")
	TEST_ASSERT_NOTNULL(wall_tile, "No wall on the map to look for")
	TEST_ASSERT_NOTNULL(map_icon.GetPixel(floor_tile.x - bounds[1] + 1, floor_tile.y - bounds[2] + 1), "The floor at [floor_tile.x], [floor_tile.y] is not drawn where it should be")
	TEST_ASSERT_NOTNULL(map_icon.GetPixel(wall_tile.x - bounds[1] + 1, wall_tile.y - bounds[2] + 1), "The wall at [wall_tile.x], [wall_tile.y] is not drawn where it should be")
	if(empty_tile)
		TEST_ASSERT_NULL(map_icon.GetPixel(empty_tile.x - bounds[1] + 1, empty_tile.y - bounds[2] + 1), "The empty space at [empty_tile.x], [empty_tile.y] has something drawn on it")

/// Every tile has the same area name in the rows as in the holomap
/datum/unit_test/crew_monitor_map/proc/check_areas(datum/crewmonitor/monitor, list/map_data, z, list/bounds)
	var/list/position_to_name = SSholomaps.holomap_position_to_name["[z]"]
	var/list/rows = map_data["area_rows"]
	var/list/names = map_data["area_names"]
	TEST_ASSERT_EQUAL(length(rows), map_data["height"], "There is not a row of areas for each y")
	TEST_ASSERT_EQUAL(length(names), length(unique_list(names)), "An area name is in the list more than once")

	var/named_tiles = 0
	for(var/row_index in 1 to length(rows))
		var/y = bounds[2] + row_index - 1
		var/list/row = rows[row_index]
		var/x = bounds[1]
		for(var/pair in 1 to length(row) step 2)
			var/area_id = row[pair]
			var/run_length = row[pair + 1]
			TEST_ASSERT(run_length > 0 && area_id >= 0 && area_id <= length(names), "Row [row_index] has a bad run of [run_length] tiles with area [area_id]")
			var/actual = area_id ? names[area_id] : null
			for(var/offset in 0 to run_length - 1)
				var/expected = position_to_name["[HOLOMAP_CENTER_X + x + offset]:[HOLOMAP_CENTER_Y + y]"]
				TEST_ASSERT(expected == actual, "The area at [x + offset], [y] is [actual || "nothing"] but the holomap has [expected || "nothing"]")
			if(actual)
				named_tiles += run_length
			x += run_length
		TEST_ASSERT_EQUAL(x, bounds[3] + 1, "Row [row_index] does not cover the width of the map")

	TEST_ASSERT(named_tiles, "No tile has the name of an area")

	// and it is the real area of a tile
	var/turf/known
	for(var/turf/tile as anything in block(bounds[1], bounds[2], z, bounds[3], bounds[4], z))
		var/area/tile_area = tile.loc
		if(tile_area.holomap_color && tile_area.holomap_should_draw)
			known = tile
			break
	TEST_ASSERT_NOTNULL(known, "No tile on the map has an area with a holomap color")
	var/area/known_area = known.loc
	var/list/row = rows[known.y - bounds[2] + 1]
	var/left = known.x - bounds[1]
	var/found
	for(var/pair in 1 to length(row) step 2)
		if(left < row[pair + 1])
			found = row[pair] ? names[row[pair]] : null
			break
		left -= row[pair + 1]
	TEST_ASSERT_EQUAL(found, known_area.holomap_color == HOLOMAP_AREACOLOR_MAINTENANCE ? "Maintenance" : known_area.name, "The area of the tile at [known.x], [known.y] is wrong")

/// People on the crew monitor have a position on the map and a job icon
/datum/unit_test/crew_monitor_sensors
	var/datum/crewmonitor/monitor
	var/mob/living/carbon/human/crew

/datum/unit_test/crew_monitor_sensors/Run()
	monitor = allocate(/datum/crewmonitor)
	crew = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/clothing/under/uniform = allocate(/obj/item/clothing/under/color/black)
	var/obj/item/card/id/advanced/id_card = allocate(/obj/item/card/id/advanced)
	SSid_access.apply_trim_to_card(id_card, /datum/id_trim/job/station_engineer)
	crew.equip_to_slot(uniform, ITEM_SLOT_ICLOTHING)
	crew.equip_to_slot(id_card, ITEM_SLOT_ID)
	uniform.has_sensor = HAS_SENSORS
	uniform.sensor_mode = SENSOR_COORDS
	crew.update_sensor_list()

	check_position()
	check_job_icon()
	check_other_level()
	check_static_data()

/datum/unit_test/crew_monitor_sensors/Destroy()
	monitor = null
	crew = null
	return ..()

/datum/unit_test/crew_monitor_sensors/proc/home_z()
	var/turf/spot = get_turf(crew)
	return spot.z

/datum/unit_test/crew_monitor_sensors/proc/find_entry(z)
	for(var/list/entry as anything in monitor.update_data(z))
		if(entry["ref"] == REF(crew))
			return entry
	return null

/datum/unit_test/crew_monitor_sensors/proc/check_position()
	var/turf/spot = get_turf(crew)
	var/list/entry = find_entry(spot.z)
	TEST_ASSERT_NOTNULL(entry, "The person with sensors is not on the crew monitor")
	TEST_ASSERT_EQUAL(entry["x"], spot.x, "The x position is wrong")
	TEST_ASSERT_EQUAL(entry["y"], spot.y, "The y position is wrong")

/datum/unit_test/crew_monitor_sensors/proc/check_job_icon()
	var/list/entry = find_entry(home_z())
	TEST_ASSERT_NOTNULL(entry, "The person with sensors is not on the crew monitor")
	TEST_ASSERT(findtext(entry["job_icon"], "job_icons") && findtext(entry["job_icon"], "engineer"), "The job icon [entry["job_icon"] || "(none)"] is not the one of an engineer")

/// Someone who is only seen from another level has no place on its map
/datum/unit_test/crew_monitor_sensors/proc/check_other_level()
	var/own_z = home_z()
	var/other_z
	for(var/z_level in 1 to world.maxz)
		if(z_level != own_z)
			other_z = z_level
			break
	TEST_ASSERT(other_z, "There is only one z level")
	ADD_TRAIT(crew, TRAIT_MULTIZ_SUIT_SENSORS, TRAIT_SOURCE_UNIT_TESTS)
	var/list/entry = find_entry(other_z)
	REMOVE_TRAIT(crew, TRAIT_MULTIZ_SUIT_SENSORS, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_NOTNULL(entry, "The person with multi z sensors is not seen from z level [other_z]")
	TEST_ASSERT_NULL(entry["x"], "The person on z level [own_z] has an x position on the map of z level [other_z]")
	TEST_ASSERT_NULL(entry["y"], "The person on z level [own_z] has a y position on the map of z level [other_z]")

/// Only the windows that should have the map get it, and only on a level that has one
/datum/unit_test/crew_monitor_sensors/proc/check_static_data()
	var/mapped_z
	for(var/z_level in SSholomaps.valid_map_indexes)
		if(SSholomaps.holomap_bounds["[z_level]"])
			mapped_z = z_level
			break
	TEST_ASSERT(mapped_z, "No z level has holomap bounds")
	var/list/bounds = SSholomaps.holomap_bounds["[mapped_z]"]
	var/turf/open/floor/destination
	for(var/turf/open/floor/tile in block(bounds[1], bounds[2], mapped_z, bounds[3], bounds[4], mapped_z))
		destination = tile
		break
	TEST_ASSERT_NOTNULL(destination, "No floor on z level [mapped_z]")
	crew.forceMove(destination)
	TEST_ASSERT_EQUAL(crew.z, mapped_z, "The person was not moved to z level [mapped_z]")
	monitor.ui_has_map[WEAKREF(crew)] = TRUE
	TEST_ASSERT_NOTNULL(monitor.ui_static_data(crew)["map"], "A user who gets the map does not have it in the static data")
	monitor.ui_has_map[WEAKREF(crew)] = FALSE
	TEST_ASSERT_NULL(monitor.ui_static_data(crew)["map"], "A user who does not get the map has it in the static data")
