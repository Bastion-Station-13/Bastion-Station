/obj/item/smithed_part/weapon_part/rapier_blade
	icon_state = "rapier_blade"
	base_name = "rapier blade"
	weapon_name = "rapier"

	hilt_icon = 'monkestation/code/modules/smithing/icons/forge_items.dmi'
	hilt_icon_state = "rapier-hilt"

/obj/item/smithed_part/weapon_part/rapier_blade/finish_weapon()
	sharpness = SHARP_POINTY
<<<<<<< HEAD:monkestation/code/modules/smithing/anvil/smithed_parts/rapier_blade.dm
	wound_bonus = 10
	bare_wound_bonus = 25
	armour_penetration = 75 * (smithed_quality / 100)
=======
	wound_bonus = 5
	bare_wound_bonus = 10
	armour_penetration = 55 * (smithed_quality / 100)
>>>>>>> e3564302 (Forge Clamps, Artifacts and a really old bug for some reason. (#12996)):code/modules/smithing/anvil/smithed_parts/rapier_blade.dm
	AddComponent(/datum/component/multi_hit, icon_state = "stab", height = 2)

	attack_speed = CLICK_CD_LIGHT_WEAPON

<<<<<<< HEAD:monkestation/code/modules/smithing/anvil/smithed_parts/rapier_blade.dm
	force = round(((material_stats.density + material_stats.hardness) / 9.75) * (smithed_quality * 0.01))
=======
	force = floor(((material_stats.density + material_stats.hardness) / 12.75) * (smithed_quality * 0.01))
>>>>>>> e3564302 (Forge Clamps, Artifacts and a really old bug for some reason. (#12996)):code/modules/smithing/anvil/smithed_parts/rapier_blade.dm
	throwforce = force * 0.9
	w_class = WEIGHT_CLASS_NORMAL
	..()
