// These are objects in the mob's vis_contents so the mob's hitbox isn't changed, and so the water covers
// everything the mob wears and holds instead of only the pixels of the body.

/obj/effect/water_overlay_effect
	name = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_INSET_OVERLAY
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	appearance_flags = RESET_COLOR
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER

/obj/effect/water_overlay_effect/proc/update_wateroverlay(turf/open/water_turf, mob/living/overlaid_mob, datum/water_overlay_config/config)
	overlays.Cut()

	var/is_resting = overlaid_mob.body_position == LYING_DOWN
	var/suffix = ""
	if(config.should_immerse(is_resting, water_turf.get_water_depth()))
		suffix = "_immersed"
	else if(is_resting)
		suffix = "_[config.icon_state_key]_resting_[config.resting_direction(overlaid_mob)]"

	var/icon/water_icon = SSwater_overlays.get_overlay_icon(water_turf, suffix)
	if(!water_icon)
		return
	var/mutable_appearance/final_texture = mutable_appearance(water_icon)
	final_texture.color = water_turf.color
	overlays += final_texture

/// The foam and ripples at the waterline
/obj/effect/water_overlay_splash
	name = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_ALPHA | KEEP_APART
	vis_flags = VIS_INHERIT_DIR
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER

/obj/effect/water_overlay_splash/proc/update_wateroverlay(turf/open/water_turf, mob/living/affected_mob, datum/water_overlay_config/config)
	icon = null
	icon_state = null
	if(!config.use_splash)
		return

	var/depth = water_turf.get_water_depth()
	var/is_resting = affected_mob.body_position == LYING_DOWN
	var/splash_state
	if(config.should_immerse(is_resting, depth))
		splash_state = affected_mob.stat == DEAD ? "empty" : "bubbles"
	else if(is_resting)
		splash_state = "[config.icon_state_key]_resting_[depth >= WATER_DEPTH_COAST_INTERMEDIATE ? "coast" : "deep"]_[config.resting_direction(affected_mob)]"
	else if(depth >= WATER_DEPTH_COAST_SHALLOW)
		splash_state = "coast_shallow"
	else if(depth >= WATER_DEPTH_COAST_INTERMEDIATE)
		splash_state = "coast_deep"
	else if(depth >= WATER_DEPTH_SHALLOW)
		splash_state = "shallow"
	else if(depth >= WATER_DEPTH_INTERMEDIATE)
		splash_state = "intermediate"
	else
		splash_state = "deep"
	icon = SSwater_overlays.overlay_file
	icon_state = splash_state
