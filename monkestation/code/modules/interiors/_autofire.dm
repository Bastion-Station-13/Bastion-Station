/obj/structure/chair/turret_gunner/proc/fire_auto()
	if(!linked_turret || !autofiring || !has_buckled_mobs())
		return

	if(QDELETED(target) || get_turf(target) != target_loc)
		target = target_loc

	var/atom/valid_target = target || target_loc
	if(!valid_target)
		return

	linked_turret.turret_action(buckled_mobs[1], valid_target, mouse_parameters)
	COOLDOWN_START(src, fire_cooldown, linked_turret.fire_delay)
	addtimer(CALLBACK(src, PROC_REF(fire_auto)), linked_turret.fire_delay)

/obj/structure/chair/turret_gunner/proc/mouse_up(client/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER

	autofiring = FALSE
	if(has_buckled_mobs() && buckled_mobs[1].client)
		var/client/gunner_client = buckled_mobs[1].client
		UnregisterSignal(gunner_client, list(COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
		gunner_client.mouse_override_icon = null
		gunner_client.mouse_pointer_icon = gunner_client.mouse_override_icon

/obj/structure/chair/turret_gunner/proc/mouse_down(client/source, atom/_target, turf/location, control, params)
	SIGNAL_HANDLER

	if(!linked_turret || autofiring || !has_buckled_mobs())
		return

	if(isnull(location))
		if(_target.plane != CLICKCATCHER_PLANE)
			return
		_target = parse_caught_click_modifiers(params2list(params), get_turf(source.eye), source)
		if(!_target)
			return
		location = get_turf(_target)

	source.mouse_override_icon = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	source.mouse_pointer_icon = source.mouse_override_icon
	autofiring = TRUE
	RegisterSignal(source, COMSIG_CLIENT_MOUSEUP, PROC_REF(mouse_up), override = TRUE)
	RegisterSignal(source, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(on_mouse_drag), override = TRUE)
	target_loc = location
	target = _target
	mouse_parameters = params
	INVOKE_ASYNC(src, PROC_REF(fire_auto))

/obj/structure/chair/turret_gunner/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER

	mouse_parameters = params
	if(isnull(over_location))
		var/new_target = parse_caught_click_modifiers(params2list(params), get_turf(source.eye), source)
		if(!new_target)
			if(QDELETED(target))
				autofiring = FALSE
				return
			target = get_turf(target)
			target_loc = target
			return
		target = new_target
		target_loc = new_target
		return

	target_loc = over_location
	target = over_object
