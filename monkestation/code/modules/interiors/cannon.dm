/obj/interior_turret
	name = "turret"
	desc = "You should not be seeing this."
	icon = 'monkestation/code/modules/interiors/icons/apc.dmi'
	icon_state = "cupola_2"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GAME_PLANE_FOV_HIDDEN
	layer = ABOVE_ALL_MOB_LAYER
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -32
	base_pixel_x = -32
	base_pixel_y = -32
	var/obj/vehicle/sealed/interior_spawner/linked_vehicle
	///we change this to like cupola+dir
	var/default_icon = "cupola"
	///is it manned (used only 4 icons)
	var/manned = FALSE
	///Is it automatic?
	var/automatic_fire = FALSE
	///Fire delay in deciseconds
	var/fire_delay = 3
	///Last time this turret fired
	var/last_fired = 0
	///Sound to play when firing
	var/fire_sound = 'sound/weapons/gun/rifle/shot.ogg'

/obj/interior_turret/Destroy()
	linked_vehicle = null
	return ..()

/obj/interior_turret/proc/follow_vehicle_movement()
	if(!linked_vehicle)
		return
	forceMove(get_turf(linked_vehicle))
	icon_state = "[default_icon]_[linked_vehicle.dir]"
	if(!manned)
		setDir(linked_vehicle.dir)

/obj/interior_turret/proc/turret_action(mob/user, atom/target, params)
	if(!target)
		return
	var/turf/our_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(!our_turf || !target_turf)
		return
	var/angle_to_target = get_angle(our_turf, target_turf)
	if(angle_to_target >= 315 || angle_to_target < 45)
		setDir(NORTH)
	else if(angle_to_target < 135)
		setDir(EAST)
	else if(angle_to_target < 225)
		setDir(SOUTH)
	else
		setDir(WEST)

/obj/interior_turret/weapon
	name = "turret weapon"
	desc = "Da weapon"
	var/proj_type = /obj/projectile/bullet

/obj/interior_turret/weapon/turret_action(mob/user, atom/target, params)
	. = ..()
	if(world.time < last_fired + fire_delay)
		return

	if(!isatom(target))
		return

	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return

	var/obj/projectile/shot = new proj_type(our_turf)
	shot.firer = user
	shot.fired_from = src
	shot.original = target

	if(linked_vehicle)
		shot.impacted[WEAKREF(linked_vehicle)] = TRUE

	shot.aim_projectile(target, our_turf, params2list(params))

	playsound(src, fire_sound, 75, TRUE)
	shot.fire()

	last_fired = world.time
