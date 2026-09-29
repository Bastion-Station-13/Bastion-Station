/datum/design/rubber_c35
	name = ".35 Rubber Ammo Box (Less Lethal)"
	id = "rubber_c35"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*10)
	build_path = /obj/item/ammo_box/c35/rubber
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/lethal_c35
	name = ".35 Ammo Box (Lethal)"
	id = "lethal_c35"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*20)
	build_path = /obj/item/ammo_box/c35
	category = list(
		RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle
	name = "WT-550 Autorifle Magazine (4.6x30mm) (Lethal)"
	desc = "A 20 round magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*6)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/laser_mag
	name = "WT-550 Autorifle Laser Magazine (4.6x30mm IC) (Lethal/Highly Destructive)"
	desc = "A 20 round laser magazine for the WT-550 Autorifle."
	id = "mag_autorifle_laser"
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT*15, /datum/material/silver = SHEET_MATERIAL_AMOUNT*0.3, /datum/material/glass = SHEET_MATERIAL_AMOUNT*0.5)
	build_path = /obj/item/ammo_box/magazine/wt550m9/laser
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY

/datum/design/mag_autorifle/sting_mag
	name = "WT-550 Autorifle Stingball Magazine (4.6x30mm R) (Lethal)"
	desc = "A 20 round stingball magazine for the out of date WT-550 Autorifle."
	id = "mag_autorifle_sting"
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3)
	build_path = /obj/item/ammo_box/magazine/wt550m9/stingball
	category = list(
					RND_CATEGORY_WEAPONS + RND_SUBCATEGORY_WEAPONS_AMMO
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY
