/area/misc/vehicle_interior
	name = "Vehicle Interior"
	icon = 'icons/area/areas_misc.dmi'
	icon_state = "shuttle"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	static_lighting = FALSE
	base_lighting_alpha = 255
	// Not unique, so the map loader makes a separate area for every vehicle's interior
	area_flags = NOTELEPORT | HIDDEN_AREA

/datum/armor/interior_spawner
	melee = 50
	bullet = 30
	laser = 30
	bomb = 20
	bio = 100
	fire = 60
	acid = 60

/obj/vehicle/sealed/interior_spawner
	name = "interior pod"
	desc = "A sealed pod that can transport you to interior spaces. Enter it to activate the interior generation system."
	icon = 'monkestation/code/modules/interiors/icons/apc.dmi'
	icon_state = "apc"
	max_integrity = 200
	armor_type = /datum/armor/interior_spawner
	enter_delay = 1 SECONDS
	max_occupants = 8
	anchored = TRUE

	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -32
	base_pixel_x = -32
	base_pixel_y = -32
	appearance_flags = NONE // Remove TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_ICON
	layer = LARGE_MOB_LAYER

	movedelay = 1 SECONDS

	/// The map template to spawn
	var/map_path = "_maps/templates/interiors/base.dmm"
	/// The turf reservation holding the created interior (if any)
	var/datum/turf_reservation/created_interior
	/// This vehicle's own copy of the interior area
	var/area/misc/vehicle_interior/interior_area
	/// The center turf of the created interior OR the hatch turf
	var/turf/interior_spawn_point
	///the turret to spawn
	var/obj/interior_turret/our_turret = /obj/interior_turret/weapon

/obj/vehicle/sealed/interior_spawner/Initialize(mapload)
	. = ..()
	become_hearing_sensitive()
	if(our_turret)
		our_turret = new our_turret(loc)
		our_turret.linked_vehicle = src

/obj/vehicle/sealed/interior_spawner/CanPass(atom/movable/mover, border_dir)
	if(isliving(mover))
		var/mob/living/moving_atom = mover
		if(moving_atom.body_position == LYING_DOWN)
			return TRUE
	return ..()

/obj/vehicle/sealed/interior_spawner/vehicle_move(direction)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, movedelay)
	after_move(direction)
	if(bound_width > world.icon_size || bound_height > world.icon_size)
		return multitile_move(direction)
	return step(src, direction)

/obj/vehicle/sealed/interior_spawner/mob_enter(mob/enterer, silent = FALSE)
	if(!istype(enterer))
		return FALSE

	if(!created_interior && !create_new_interior())
		to_chat(enterer, span_warning("[src] malfunctions!"))
		return FALSE

	if(!interior_spawn_point)
		return FALSE

	if(!silent)
		enterer.visible_message(span_notice("[enterer] enters [src] and is transported to the interior space!"))
	enterer.forceMove(interior_spawn_point)
	return TRUE

/obj/vehicle/sealed/interior_spawner/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	return FALSE

/obj/vehicle/sealed/interior_spawner/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	our_turret?.follow_vehicle_movement()

/obj/vehicle/sealed/interior_spawner/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range = 0)
	. = ..()
	if(!created_interior)
		return

	for(var/turf/interior_turf as anything in created_interior.reserved_turfs)
		for(var/mob/living/interior_mob in interior_turf)
			if(!interior_mob.client)
				continue
			interior_mob.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mods, message_range)
			// Operators looking through the vehicle get runechat over the speaker too
			if(interior_mob.client.eye == src)
				interior_mob.create_chat_message(speaker, message_language, raw_message, spans)

/// Loads the interior map into a fresh turf reservation and links up its hatch, pilot seat and gunner seat.
/obj/vehicle/sealed/interior_spawner/proc/create_new_interior()
	var/datum/map_template/template = new(path = map_path)
	if(!template.width || !template.height)
		return FALSE

	var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(template.width, template.height)
	if(!reservation)
		return FALSE

	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	if(!template.load(bottom_left))
		qdel(reservation)
		return FALSE

	created_interior = reservation

	var/obj/structure/entry_hatch/hatch
	for(var/turf/interior_turf as anything in reservation.reserved_turfs)
		if(!interior_area && istype(interior_turf.loc, /area/misc/vehicle_interior))
			interior_area = interior_turf.loc
			interior_area.name = "[name] interior"
		for(var/atom/movable/thing as anything in interior_turf)
			if(istype(thing, /obj/structure/entry_hatch))
				hatch = thing
				hatch.linked_spawner = src
			else if(istype(thing, /obj/structure/chair/vehicle_pilot))
				var/obj/structure/chair/vehicle_pilot/pilot_chair = thing
				pilot_chair.linked_vehicle = src
			else if(istype(thing, /obj/structure/chair/turret_gunner) && our_turret)
				var/obj/structure/chair/turret_gunner/gunner_chair = thing
				gunner_chair.linked_turret = our_turret

	if(hatch)
		interior_spawn_point = get_turf(hatch)
	else
		interior_spawn_point = locate(bottom_left.x + round(template.width / 2), bottom_left.y + round(template.height / 2), bottom_left.z)

	return TRUE

/obj/vehicle/sealed/interior_spawner/mouse_drop_receive(atom/movable/target, mob/user, params)
	if(!istype(target) || !istype(user) || target == user)
		return ..()

	if(!Adjacent(user))
		to_chat(user, span_warning("You need to be next to [src] to use it!"))
		return

	if(target.anchored)
		to_chat(user, span_warning("[target] is anchored and cannot be moved!"))
		return

	if(!created_interior || !interior_spawn_point)
		to_chat(user, span_warning("You need to enter [src] first to create an interior space!"))
		return

	to_chat(user, span_notice("You begin loading [target] into [src]..."))
	if(do_after(user, enter_delay, target = src))
		transport_object_to_interior(target, user)

/obj/vehicle/sealed/interior_spawner/proc/transport_object_to_interior(atom/movable/thing, mob/user)
	thing.forceMove(interior_spawn_point)
	to_chat(user, span_notice("You successfully load [thing] into the interior space."))

/obj/vehicle/sealed/interior_spawner/Destroy(force)
	QDEL_NULL(our_turret)
	if(created_interior)
		evacuate_interior()
	return ..()

/// Dumps everything inside the interior out onto the vehicle's turf, then releases the reservation.
/obj/vehicle/sealed/interior_spawner/proc/evacuate_interior()
	if(!created_interior)
		return

	var/turf/exit_location = get_turf(src)
	var/list/evacuated_items = list()
	var/list/evacuated_mobs = list()

	for(var/turf/interior_turf as anything in created_interior.reserved_turfs)
		for(var/atom/movable/evaced_obj as anything in interior_turf)
			if(ismob(evaced_obj))
				evacuated_mobs += evaced_obj
			else if(!istype(evaced_obj, /obj/structure/entry_hatch) && !istype(evaced_obj, /obj/structure/chair/vehicle_pilot) && !istype(evaced_obj, /obj/structure/chair/turret_gunner) && !evaced_obj.anchored)
				evacuated_items += evaced_obj

	for(var/mob/actual_mob as anything in evacuated_mobs)
		actual_mob.buckled?.unbuckle_mob(actual_mob, force = TRUE)
		if(actual_mob.client && actual_mob.client.eye != actual_mob)
			actual_mob.client.eye = actual_mob
			actual_mob.client.perspective = MOB_PERSPECTIVE
			to_chat(actual_mob, span_boldnotice("Your viewpoint snaps back to normal as the connection is severed!"))

		if(exit_location)
			actual_mob.forceMove(exit_location)
		if(isliving(actual_mob))
			var/mob/living/living_mob = actual_mob
			living_mob.Sleeping(10 SECONDS)
			to_chat(living_mob, span_boldannounce("You are violently ejected as the interior space collapses!"))

	if(exit_location)
		for(var/atom/movable/item as anything in evacuated_items)
			item.forceMove(exit_location)

	// Hand the turfs back to the global area ourselves, since the reservation only does it asynchronously
	// and the area has to be empty before it can be deleted
	if(interior_area)
		var/area/global_area = GLOB.areas_by_type[world.area]
		for(var/turf/interior_turf as anything in created_interior.reserved_turfs)
			if(interior_turf.loc == interior_area)
				interior_turf.change_area(interior_area, global_area)
	QDEL_NULL(created_interior)
	if(interior_area && !interior_area.has_contained_turfs())
		qdel(interior_area)
	interior_area = null
	interior_spawn_point = null

	if(length(evacuated_mobs) || length(evacuated_items))
		visible_message(span_danger("[src] violently ejects its contents as it collapses!"))

/obj/structure/entry_hatch
	name = "entry hatch"
	desc = "A hatch that marks the entry point for interior spaces. Drag yourself onto it to exit, or drag objects onto it to move them outside."
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	icon_state = "closed"
	density = FALSE
	anchored = TRUE
	/// Reference to the interior spawner that created this interior
	var/obj/vehicle/sealed/interior_spawner/linked_spawner

/obj/structure/entry_hatch/Destroy()
	linked_spawner = null
	return ..()

/obj/structure/entry_hatch/mouse_drop_receive(atom/movable/target, mob/user, params)
	. = ..()
	if(!istype(target) || !istype(user))
		return

	if(!Adjacent(user))
		to_chat(user, span_warning("You need to be next to [src] to use it!"))
		return

	if(!linked_spawner)
		to_chat(user, span_warning("[src] is not connected to an exit point!"))
		return

	if(target == user)
		to_chat(user, span_notice("You begin climbing through [src] to exit the interior space..."))
		if(do_after(user, linked_spawner.enter_delay, target = src))
			transport_to_exterior(user, user)
		return

	if(target.anchored)
		to_chat(user, span_warning("[target] is anchored and cannot be moved!"))
		return

	to_chat(user, span_notice("You begin moving [target] through [src] to the exterior..."))
	if(do_after(user, linked_spawner.enter_delay, target = src))
		transport_to_exterior(target, user)

/obj/structure/entry_hatch/proc/transport_to_exterior(atom/movable/thing, mob/user)
	if(!linked_spawner)
		to_chat(user, span_warning("Connection to exit point has been lost!"))
		return

	var/turf/exit_location = get_turf(linked_spawner)
	if(!exit_location)
		to_chat(user, span_warning("Cannot find a suitable exit location!"))
		return

	thing.forceMove(exit_location)
	if(thing == user)
		to_chat(user, span_notice("You climb through the hatch and emerge outside."))
	else
		to_chat(user, span_notice("You successfully move [thing] through the hatch to the exterior."))
