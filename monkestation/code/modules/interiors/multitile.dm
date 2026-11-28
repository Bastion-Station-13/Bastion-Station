/// Moves a vehicle whose bounds span more than one tile, swapping its bounds when it turns between horizontal and vertical.
/obj/vehicle/proc/multitile_move(new_direction = null)
	// Validate that new_direction is actually a direction constant
	if(!(new_direction in GLOB.alldirs))
		new_direction = dir

	// Only swap bounds if orientation changes (horizontal <-> vertical)
	var/current_is_horizontal = (dir == EAST || dir == WEST)
	var/new_is_horizontal = (new_direction == EAST || new_direction == WEST)
	var/swap_bounds = (current_is_horizontal != new_is_horizontal)

	//store the current bounds and pixel offsets
	var/old_bound_width = bound_width
	var/old_bound_height = bound_height
	var/old_bound_x = bound_x
	var/old_bound_y = bound_y
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y
	if(swap_bounds)
		bound_width = old_bound_height
		bound_height = old_bound_width
		bound_x = old_bound_y
		bound_y = old_bound_x
		pixel_x = old_pixel_y
		pixel_y = old_pixel_x

	var/list/blockers = list()
	if(!multitile_can_move(get_step(loc, new_direction), new_direction, blockers))
		// Bump everything in the way at once, so a wide vehicle can open a whole row of doors in one go
		for(var/atom/blocker as anything in blockers)
			INVOKE_ASYNC(src, PROC_REF(multitile_bump), blocker)
		// Revert bounds if we swapped them
		if(swap_bounds)
			bound_width = old_bound_width
			bound_height = old_bound_height
			bound_x = old_bound_x
			bound_y = old_bound_y
			pixel_x = old_pixel_x
			pixel_y = old_pixel_y
		return FALSE

	// All checks passed, perform the movement
	setDir(new_direction)
	forceMove(get_step(loc, new_direction))
	return TRUE

/// Checks whether every tile this vehicle would occupy at target_turf is free to move into.
/// If a list is passed as blockers, every blocking atom is added to it instead of stopping at the first one.
/obj/vehicle/proc/multitile_can_move(turf/target_turf, new_direction, list/blockers)
	if(!target_turf)
		return FALSE

	var/width_tiles = CEILING(bound_width / world.icon_size, 1)
	var/height_tiles = CEILING(bound_height / world.icon_size, 1)
	var/x_offset = FLOOR(bound_x / world.icon_size, 1)
	var/y_offset = FLOOR(bound_y / world.icon_size, 1)

	. = TRUE
	for(var/x in 0 to (width_tiles - 1))
		for(var/y in 0 to (height_tiles - 1))
			var/turf/check_turf = locate(target_turf.x + x + x_offset, target_turf.y + y + y_offset, target_turf.z)
			if(!check_turf)
				return FALSE
			if(check_turf.density || !check_turf.CanPass(src, new_direction))
				if(isnull(blockers))
					return FALSE
				blockers |= check_turf
				. = FALSE
			// Check for objects that block passage in each tile
			for(var/atom/movable/obstacle in check_turf)
				if(obstacle == src || obstacle.CanPass(src, new_direction))
					continue
				if(isnull(blockers))
					return FALSE
				blockers |= obstacle
				. = FALSE

/// Bumps something blocking a multitile move. Sealed vehicles use this to open doors with their driver's access.
/obj/vehicle/proc/multitile_bump(atom/blocker)
	Bump(blocker)
