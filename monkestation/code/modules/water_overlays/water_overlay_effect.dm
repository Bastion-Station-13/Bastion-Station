/// Makes a mob look like it is standing in the water of the turf it is on, removes itself when it leaves the water
/datum/component/water_overlay_effect
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/obj/effect/water_overlay_effect/the_water
	var/obj/effect/water_overlay_splash/the_splash
	var/datum/water_overlay_config/config
	/// The mob is kept out of the water visually, like when it is buckled or in the air
	var/hidden = FALSE
	/// Things that can change how the mob has to be drawn
	var/static/list/refresh_signals = list(
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
		COMSIG_MOVABLE_POST_THROW,
		COMSIG_MOVABLE_THROW_LANDED,
		COMSIG_LIVING_DEATH,
	)

/datum/component/water_overlay_effect/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/living_parent = parent
	config = living_parent.get_water_overlay_config()
	if(!config)
		return COMPONENT_INCOMPATIBLE

	the_water = new
	the_splash = new
	update_hidden(living_parent.buckled)
	// we want to show up halfway through the step into the water
	var/step_delay = max(world.tick_lag, world.icon_size / max(living_parent.glide_size, 1) * world.tick_lag)
	addtimer(CALLBACK(src, PROC_REF(update_visuals)), step_delay * 0.6, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

/datum/component/water_overlay_effect/Destroy()
	if(parent)
		var/atom/movable/movable_parent = parent
		movable_parent.vis_contents -= list(the_water, the_splash)
	QDEL_NULL(the_water)
	QDEL_NULL(the_splash)
	config = null
	return ..()

/datum/component/water_overlay_effect/InheritComponent(datum/component/component, i_am_original)
	refresh()

/datum/component/water_overlay_effect/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_LIVING_SET_BUCKLED, PROC_REF(on_buckled))
	RegisterSignals(parent, refresh_signals, PROC_REF(on_refresh))

/datum/component/water_overlay_effect/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BUCKLED) + refresh_signals)

/datum/component/water_overlay_effect/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	var/turf/open/water_turf = get_turf(source)
	if(!istype(water_turf) || !water_turf.has_water_overlay())
		qdel(src)

/datum/component/water_overlay_effect/proc/on_refresh(datum/source)
	SIGNAL_HANDLER
	refresh()

/datum/component/water_overlay_effect/proc/refresh()
	var/mob/living/living_parent = parent
	update_hidden(living_parent.buckled)
	update_visuals()

/// The signal is sent before the mob's buckled var changes
/datum/component/water_overlay_effect/proc/on_buckled(mob/living/source, atom/movable/new_buckled)
	SIGNAL_HANDLER
	update_hidden(new_buckled)
	update_visuals()

/datum/component/water_overlay_effect/proc/update_hidden(atom/movable/buckled_to)
	var/mob/living/living_parent = parent
	hidden = !!(buckled_to || living_parent.throwing || (living_parent.movement_type & (FLYING|FLOATING)))

/datum/component/water_overlay_effect/proc/update_visuals()
	if(!isliving(parent))
		return
	var/mob/living/living_parent = parent
	var/turf/open/water_turf = get_turf(living_parent)
	if(!istype(water_turf) || !water_turf.has_water_overlay())
		qdel(src)
		return

	if(hidden)
		the_water.overlays.Cut()
		the_splash.icon = null
		the_splash.icon_state = null
		return

	the_water.update_wateroverlay(water_turf, living_parent, config)
	the_splash.update_wateroverlay(water_turf, living_parent, config)
	living_parent.vis_contents |= list(the_water, the_splash)
