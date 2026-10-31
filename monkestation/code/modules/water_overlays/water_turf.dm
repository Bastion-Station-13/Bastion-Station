/// Gives mobs that enter the turf the water overlay and makes them splash around when running
/datum/element/water_turf
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/static/list/shallow_wading_sounds = list(
		'sound/effects/water/shallowwading1.ogg',
		'sound/effects/water/shallowwading2.ogg',
		'sound/effects/water/shallowwading3.ogg',
		'sound/effects/water/shallowwading4.ogg',
		'sound/effects/water/shallowwading5.ogg',
		'sound/effects/water/shallowwading6.ogg',
	)
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
	if(!isopenturf(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_entered))

/datum/element/water_turf/Detach(datum/source, ...)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	return ..()

/datum/element/water_turf/proc/on_entered(turf/source, atom/movable/arrived)
	SIGNAL_HANDLER
	// signals follow the turf when it gets changed into something else
	var/turf/open/water_turf = source
	if(!isopenturf(source) || !water_turf.has_water_overlay())
		source.RemoveElement(/datum/element/water_turf)
		return
	if(!isliving(arrived))
		return
	var/mob/living/wader = arrived
	if((wader.movement_type & (FLYING|FLOATING)) || !wader.get_water_overlay_config())
		return
	wader.AddComponent(/datum/component/water_overlay_effect)
	if(wader.m_intent == MOVE_INTENT_RUN)
		playsound(water_turf, pick(get_wading_sounds(water_turf.get_water_depth())), 10, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/datum/element/water_turf/proc/get_wading_sounds(depth)
	if(depth >= WATER_DEPTH_COAST_INTERMEDIATE)
		return shallow_wading_sounds
	if(depth >= WATER_DEPTH_SHALLOW)
		return wading_sounds
	return deep_wading_sounds

/// How many pixels deep the water here is, WATER_DEPTH_LAND for turfs that aren't water
/turf/open/proc/get_water_depth()
	return WATER_DEPTH_LAND

/// The icon and icon state the water overlay takes its texture from
/turf/open/proc/get_water_texture()
	return list(icon, icon_state)

/// Whether mobs standing here get the water overlay
/turf/open/proc/has_water_overlay()
	return get_water_depth() < WATER_DEPTH_LAND

/turf/open/water/get_water_depth()
	return sinking ? WATER_DEPTH_LAND : depth

// The holodeck beach and the real one, the coastlines are shallow water with sand mixed in so they take the texture of the water next to them

/turf/open/floor/holofloor/beach/Initialize(mapload)
	. = ..()
	if(has_water_overlay())
		AddElement(/datum/element/water_turf)

/turf/open/floor/holofloor/beach/water/get_water_depth()
	return WATER_DEPTH_SHALLOW

/turf/open/floor/holofloor/beach/coast_t/get_water_depth()
	return WATER_DEPTH_COAST_SHALLOW

/turf/open/floor/holofloor/beach/coast_t/get_water_texture()
	return list(icon, "water")

/turf/open/floor/holofloor/beach/coast_b/get_water_depth()
	return WATER_DEPTH_COAST_SHALLOW

/turf/open/floor/holofloor/beach/coast_b/get_water_texture()
	return list(icon, "water")

/turf/open/misc/beach/Initialize(mapload)
	. = ..()
	if(has_water_overlay())
		AddElement(/datum/element/water_turf)

/turf/open/misc/beach/coastline_t/get_water_depth()
	return WATER_DEPTH_COAST_SHALLOW

/turf/open/misc/beach/coastline_t/get_water_texture()
	return list(icon, "water")

/turf/open/misc/beach/coastline_b/get_water_depth()
	return WATER_DEPTH_COAST_SHALLOW

/turf/open/misc/beach/coastline_b/get_water_texture()
	return list(icon, "water")
