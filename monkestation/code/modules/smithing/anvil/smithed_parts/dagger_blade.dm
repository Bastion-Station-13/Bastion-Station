/obj/item/smithed_part/weapon_part/dagger_blade
	icon_state = "daggerblade"
	base_name = "dagger blade"
	weapon_name = "dagger"

	weapon_inhand_icon_state = "dagger"
	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "dagger-hilt"

/obj/item/smithed_part/weapon_part/dagger_blade/finish_weapon()
	tool_behaviour = TOOL_KNIFE
	sharpness = SHARP_POINTY
	embed_type = /datum/embedding/dagger_blade
	armour_penetration = 25 * (smithed_quality / 100)

	attack_speed = CLICK_CD_FAST_MELEE

<<<<<<< HEAD:monkestation/code/modules/smithing/anvil/smithed_parts/dagger_blade.dm
	throwforce = round(((material_stats.density + material_stats.hardness) / 9) * (smithed_quality * 0.01))
	force = throwforce * 0.25
=======
	wound_bonus = -5 //aint cutting shit
	bare_wound_bonus = 20 //Unless you are unarmored.

	throwforce = floor(((material_stats.density + material_stats.hardness) / 9) * (smithed_quality * 0.01))
	force = floor(throwforce * 0.2)
>>>>>>> e3564302 (Forge Clamps, Artifacts and a really old bug for some reason. (#12996)):code/modules/smithing/anvil/smithed_parts/dagger_blade.dm
	w_class = WEIGHT_CLASS_SMALL
	..()

/datum/embedding/dagger_blade
	embed_chance = 65
	pain_mult = 4
	fall_chance = 10
	ignore_throwspeed_threshold = TRUE
