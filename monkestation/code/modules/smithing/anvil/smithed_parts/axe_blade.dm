/obj/item/smithed_part/weapon_part/axe_blade
	icon_state = "axehead"
	base_name = "axe blade"
	weapon_name = "axe"

	weapon_inhand_icon_state = "axe"
	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "axe-hilt"

/obj/item/smithed_part/weapon_part/axe_blade/finish_weapon()
	sharpness = SHARP_EDGED
	embed_type = /datum/embedding/axe_blade
<<<<<<< HEAD:monkestation/code/modules/smithing/anvil/smithed_parts/axe_blade.dm
	armour_penetration = 50 * (smithed_quality / 100)

	tool_behaviour = TOOL_SAW

	force = round(((material_stats.density + material_stats.hardness) / 8.9) * (smithed_quality * 0.01))
	throwforce = force * 1.75
=======
	armour_penetration = 25 * (smithed_quality / 100)

	tool_behaviour = TOOL_SAW

	wound_bonus = 2
	bare_wound_bonus = 10

	force = floor(((material_stats.density + material_stats.hardness) / 10.5) * (smithed_quality * 0.01))
	throwforce = floor(force * 1.75)
>>>>>>> e3564302 (Forge Clamps, Artifacts and a really old bug for some reason. (#12996)):code/modules/smithing/anvil/smithed_parts/axe_blade.dm
	w_class = WEIGHT_CLASS_SMALL
	..()

/datum/embedding/axe_blade
	embed_chance = 35
	pain_mult = 4
	fall_chance = 10
	ignore_throwspeed_threshold = TRUE
