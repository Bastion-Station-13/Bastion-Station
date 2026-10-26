/// Gives mobs that enter the turf the water overlay and makes them splash around when running
/datum/element/water_turf
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/static/list/wading_sounds = list(
		'sound/effects/water/wading1.ogg',
		'sound/effects/water/wading2.ogg',
		'sound/effects/water/wading3.ogg',
	)
	var/static/list/deep_wading_sounds = list(
		'sound/effects/water/deepwading1.ogg',
		'sound/effects/water/deepwading2.ogg',
		'sound/effects/water/deepwading3.ogg',
		'sound/effects/water/deepwading4.ogg',
	)

/datum/element/water_turf/Attach(datum/target)
	. = ..()
	if(!istype(target, /turf/open/water))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_entered))

/datum/element/water_turf/Detach(datum/source, ...)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	return ..()

/datum/element/water_turf/proc/on_entered(turf/source, atom/movable/arrived)
	SIGNAL_HANDLER
	// signals follow the turf when it gets changed into something else
	var/turf/open/water/water_turf = source
	if(!istype(water_turf) || !water_turf.has_water_overlay())
		source.RemoveElement(/datum/element/water_turf)
		return
	if(!isliving(arrived))
		return
	var/mob/living/wader = arrived
	if((wader.movement_type & (FLYING|FLOATING)) || !wader.get_water_overlay_config())
		return
	wader.AddComponent(/datum/component/water_overlay_effect)
	if(wader.m_intent == MOVE_INTENT_RUN)
		playsound(water_turf, pick(water_turf.depth >= WATER_DEPTH_SHALLOW ? wading_sounds : deep_wading_sounds), 10, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/// Whether mobs standing here get the water overlay
/turf/open/water/proc/has_water_overlay()
	return depth < WATER_DEPTH_LAND && !sinking
