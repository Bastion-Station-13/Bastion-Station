// .45 (M1911 & C20r)

/obj/projectile/bullet/c45
	name = ".45 bullet"
	damage = 30
	wound_bonus = 20 ///monke -10 -> 20
	wound_falloff_tile = -10

/obj/projectile/bullet/c45/rubber
	name = ".45 rubber bullet"
	damage = 15
	stamina = 22.5
	weak_against_armour = TRUE
	ricochets_max = 3
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 1
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c45/ap
	name = ".45 armor-piercing bullet"
	armour_penetration = 75

/obj/projectile/bullet/incendiary/c45
	name = ".45 incendiary bullet"
	damage = 15
	fire_stacks = 2

/obj/projectile/bullet/c45/hp
	name = ".45 hollow-point bullet"
	damage = 40
	weak_against_armour = TRUE

/obj/projectile/bullet/c45/caseless
	damage = 26 //parent damage var is 30


// 4.6x30mm (Autorifles)

/obj/projectile/bullet/c46x30mm
	name = "4.6x30mm bullet"
	damage = 15
	wound_bonus = 0
	bare_wound_bonus = 5
	embed_falloff_tile = -4
	armour_penetration = 50
	armour_penetration_falloff_tile = -7.5

/obj/projectile/bullet/c46x30mm/stingball
	name = "4.6x30mm stingball bullet"
	damage = 4
	stamina = 15
	damage_falloff_tile = -0.5
	ricochets_max = 4
	ricochet_chance = 75
	ricochet_decay_chance = 1
	ricochet_decay_damage = 0.9
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 2
	ricochet_incidence_leeway = 0
	embed_falloff_tile = -2
	shrapnel_type = /obj/item/shrapnel/stingball
	embed_type = /datum/embedding/stingball


// .27-54 Cesarzowa
// Low-caliber crew SMG round

/obj/projectile/bullet/c27_54cesarzowa
	name = ".27-54 Cesarzowa piercing bullet"
	damage = 15
	armour_penetration = 30
	wound_bonus = -10

/obj/projectile/bullet/c27_54cesarzowa/rubber
	name = ".27-54 Cesarzowa rubber bullet"
	stamina = 15
	damage = 6
	weak_against_armour = TRUE
	wound_bonus = -30
	bare_wound_bonus = -10
