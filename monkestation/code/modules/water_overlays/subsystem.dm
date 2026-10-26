#define ADDITIONAL_DEPTH_OFFSET 3

SUBSYSTEM_DEF(water_overlays)
	name = "Water Overlays"
	flags = SS_NO_FIRE

	/// Config instances by type, made when first needed
	var/list/configs = list()
	/// Generated water textures, keyed by "[turf type]_[depth]" and the variant suffix
	var/list/water_overlay_icons = list()
	var/overlay_file = 'icons/effects/water_overlay_effects/_32.dmi'

/datum/controller/subsystem/water_overlays/Initialize()
	for(var/turf/open/water/water_type as anything in typesof(/turf/open/water))
		if(initial(water_type.depth) < WATER_DEPTH_LAND && !initial(water_type.sinking))
			generate_water_overlay(water_type, initial(water_type.depth))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/water_overlays/proc/get_config(config_type)
	if(!configs[config_type])
		configs[config_type] = new config_type
	return configs[config_type]

/// The overlay icon for a variant of this turf's water, suffix is "", "_immersed" or "_[icon_state_key]_resting_[e/w]"
/datum/controller/subsystem/water_overlays/proc/get_overlay_icon(turf/open/water/water_turf, suffix = "")
	var/key = "[water_turf.type]_[water_turf.depth]"
	if(!water_overlay_icons[key])
		generate_water_overlay(water_turf.type, water_turf.depth)
	return water_overlay_icons[key + suffix]

/**
 * Builds every overlay a mob can need in this kind of water: the one cut off at the waterline, the one covering the
 * whole mob and one for each way a mob can lie down.
 * The turf's own texture is used so the water looks like the turf it is standing in.
 */
/datum/controller/subsystem/water_overlays/proc/generate_water_overlay(turf/open/water/water_type, depth)
	var/key = "[water_type]_[depth]"
	if(water_overlay_icons[key])
		return
	var/icon/water_texture = icon(overlay_file, "empty")
	water_texture.Blend(icon(initial(water_type.icon), initial(water_type.icon_state)), ICON_OVERLAY, 1, 1)

	water_overlay_icons[key + "_immersed"] = icon(water_texture)

	var/icon/culling_mask = icon(overlay_file, "culling_mask")
	culling_mask.Shift(SOUTH, water_texture.Height() + depth - ADDITIONAL_DEPTH_OFFSET, FALSE)
	var/icon/culled_water = icon(water_texture)
	culled_water.AddAlphaMask(culling_mask)
	water_overlay_icons[key] = culled_water

	for(var/config_type in subtypesof(/datum/water_overlay_config))
		var/datum/water_overlay_config/config = get_config(config_type)
		if(!config.icon_state_key)
			continue
		for(var/direction in list("e", "w"))
			var/icon/resting_water = icon(water_texture)
			resting_water.AddAlphaMask(icon(overlay_file, "culling_[config.icon_state_key]_resting_deep_[direction]"))
			water_overlay_icons["[key]_[config.icon_state_key]_resting_[direction]"] = resting_water

#undef ADDITIONAL_DEPTH_OFFSET
