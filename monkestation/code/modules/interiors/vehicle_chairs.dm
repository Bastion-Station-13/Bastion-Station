/obj/structure/chair/vehicle_pilot
	name = "pilot seat"
	desc = "A specialized chair that connects to the vehicle's control systems. Buckle yourself in to pilot the vehicle."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 0
	item_chair = null
	var/obj/vehicle/sealed/interior_spawner/linked_vehicle

/obj/structure/chair/vehicle_pilot/Destroy()
	linked_vehicle = null
	return ..()

/obj/structure/chair/vehicle_pilot/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	if(!linked_vehicle || !buckled_mob)
		return
	linked_vehicle.add_occupant(buckled_mob, VEHICLE_CONTROL_DRIVE)

	if(buckled_mob.client)
		buckled_mob.client.eye = linked_vehicle
		buckled_mob.client.perspective = EYE_PERSPECTIVE

	to_chat(buckled_mob, span_notice("You take control of the vehicle's piloting systems. Use movement keys to drive."))
	to_chat(buckled_mob, span_boldnotice("Your viewpoint shifts to the vehicle's exterior view!"))

/obj/structure/chair/vehicle_pilot/post_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	if(!linked_vehicle || !buckled_mob)
		return
	linked_vehicle.remove_occupant(buckled_mob)

	if(buckled_mob.client)
		buckled_mob.client.eye = buckled_mob
		buckled_mob.client.perspective = MOB_PERSPECTIVE

	to_chat(buckled_mob, span_notice("You release control of the vehicle's piloting systems."))
	to_chat(buckled_mob, span_boldnotice("Your viewpoint returns to normal."))

/obj/structure/chair/vehicle_pilot/relaymove(mob/living/user, direction)
	if(linked_vehicle && (user in buckled_mobs))
		return linked_vehicle.relaymove(user, direction)
	return FALSE

/obj/structure/chair/vehicle_pilot/examine(mob/user)
	. = ..()
	if(linked_vehicle)
		. += span_notice("It is connected to [linked_vehicle] and ready for piloting.")
		if(has_buckled_mobs())
			. += span_info("Someone is currently piloting the vehicle.")
	else
		. += span_warning("It is not connected to any vehicle.")

/obj/structure/chair/turret_gunner
	name = "gunner seat"
	desc = "A specialized chair that connects to the vehicle's turret systems. Buckle yourself in to operate the turret."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 0
	item_chair = null

	var/obj/interior_turret/linked_turret

	COOLDOWN_DECLARE(fire_cooldown)
	var/autofiring = FALSE
	var/atom/target
	/// For dealing with locking on targets due to BYOND engine limitations (the mouse input only happening when mouse moves).
	var/turf/target_loc
	var/mouse_parameters

/obj/structure/chair/turret_gunner/Destroy()
	linked_turret = null
	target = null
	target_loc = null
	return ..()

/obj/structure/chair/turret_gunner/post_buckle_mob(mob/living/buckled_mob)
	. = ..()
	if(!linked_turret || !buckled_mob)
		return
	if(buckled_mob.client)
		buckled_mob.client.eye = linked_turret
		buckled_mob.client.perspective = EYE_PERSPECTIVE
		buckled_mob.client.click_intercept = src
		linked_turret.manned = TRUE
		if(linked_turret.automatic_fire)
			RegisterSignal(buckled_mob.client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(mouse_down))

	to_chat(buckled_mob, span_notice("You take control of the turret systems. Click on targets to operate the turret."))
	to_chat(buckled_mob, span_boldnotice("Your viewpoint shifts to the turret's view!"))

/obj/structure/chair/turret_gunner/post_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	if(!linked_turret || !buckled_mob)
		return
	if(buckled_mob.client)
		buckled_mob.client.eye = buckled_mob
		buckled_mob.client.perspective = MOB_PERSPECTIVE
		buckled_mob.client.click_intercept = null
		linked_turret.manned = FALSE
		if(linked_turret.automatic_fire)
			UnregisterSignal(buckled_mob.client, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
			autofiring = FALSE
			buckled_mob.client.mouse_override_icon = null
			buckled_mob.client.mouse_pointer_icon = buckled_mob.client.mouse_override_icon

	to_chat(buckled_mob, span_notice("You release control of the turret systems."))
	to_chat(buckled_mob, span_boldnotice("Your viewpoint returns to normal."))

/obj/structure/chair/turret_gunner/proc/InterceptClickOn(mob/living/user, params, atom/clicked_on)
	if(!linked_turret || !(user in buckled_mobs))
		return FALSE

	if(!linked_turret.automatic_fire && isatom(clicked_on))
		INVOKE_ASYNC(linked_turret, TYPE_PROC_REF(/obj/interior_turret, turret_action), user, clicked_on, params)
		return TRUE

	return FALSE

/obj/structure/chair/turret_gunner/examine(mob/user)
	. = ..()
	if(linked_turret)
		. += span_notice("It is connected to [linked_turret] and ready for turret operation.")
		if(has_buckled_mobs())
			. += span_info("Someone is currently operating the turret.")
	else
		. += span_warning("It is not connected to any turret.")
