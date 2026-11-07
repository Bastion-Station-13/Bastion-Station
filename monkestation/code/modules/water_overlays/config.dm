/// Tells the water overlay code how to draw water on a mob, see /mob/living/proc/get_water_overlay_config
/datum/water_overlay_config
	/// Whether the foam at the waterline is drawn
	var/use_splash = TRUE
	/// Prefix of the culling_<key>_resting_* and <key>_resting_* states in the overlay icon, needed for mobs that lie down
	var/icon_state_key
	/// Lying down at this depth or deeper covers the mob completely, null to never
	var/immerse_resting_at_depth = WATER_DEPTH_DEEP

/datum/water_overlay_config/human
	icon_state_key = "human"

/datum/water_overlay_config/proc/should_immerse(is_resting, depth)
	return is_resting && !isnull(immerse_resting_at_depth) && depth <= immerse_resting_at_depth

/// Lying humans are drawn rotated, east and west need their own mask
/datum/water_overlay_config/proc/resting_direction(mob/living/lying_mob)
	return lying_mob.get_lying_angle() == 270 ? "e" : "w"

/// The config for this mob, null for mobs that don't get a water overlay
/mob/living/proc/get_water_overlay_config()
	return null

/mob/living/carbon/human/get_water_overlay_config()
	return SSwater_overlays.get_config(/datum/water_overlay_config/human)
