/**
 * Lever action gun for Blood Brothers. Despite it being a "lever action rifle", it is actually a semi-auto in disguise, as the lever works itself after every shot.
 */

/obj/item/ammo_box/magazine/internal/mares_leg
	name = "mare's leg tube magazine"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_357 // Protip, a bandolier allows you to hold .357 casings.
	max_ammo = 8
	start_empty = TRUE

/obj/item/gun/ballistic/mares_leg
	name = "Mare's Leg"
	desc = "All you need to do is find yourself a good horse (or piggy back ride on your blood brother) and figure out why this has a lever."
	icon = 'bastionstation/icons/obj/weapons/guns/mares_leg.dmi'
	icon_state = "mares_leg"
	inhand_icon_state = "mares_leg"
	worn_icon = 'bastionstation/icons/mob/clothing/mares_leg_belt.dmi'
	worn_icon_state = "mares_leg"
	lefthand_file = 'bastionstation/icons/mob/inhands/weapons/mares_leg_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/weapons/mares_leg_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/mares_leg
	internal_magazine = TRUE
	tac_reloads = FALSE
	bolt_wording = "lever"
	fire_sound = 'sound/items/weapons/gun/revolver/shot.ogg'
	rack_sound = 'sound/items/weapons/gun/shotgun/rack.ogg'
	fire_delay = 0.8 SECONDS // It's a semi auto but the lever works after every shot. The increased firing delay represents this.
	projectile_damage_multiplier = 40 / 60
	pinless = TRUE

/obj/item/gun/ballistic/mares_leg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.5)
	// No underbarrel slot because it conflicts with the scope
	AddComponent(/datum/component/blood_brother_gun, \
		weapon_family = BB_GUN_BALLISTIC, \
		part_slots = list(BB_GUN_PART_MAGAZINE, BB_GUN_PART_RECEIVER, BB_GUN_PART_BARREL), \
		default_parts = list(/obj/item/blood_brother_gun_part/receiver/semi_auto), \
	)

/obj/item/gun/ballistic/mares_leg/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(.)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/items/weapons/gun/shotgun/rack.ogg', 50, TRUE), 0.4 SECONDS) //.. plays the rack sound after a delay to simulate the lever action

/obj/item/gun/ballistic/mares_leg/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, female_uniform = NO_FEMALE_UNIFORM, override_state = null, override_file = null)
	if(default_layer == SUIT_STORE_LAYER)
		override_file = 'bastionstation/icons/mob/clothing/mares_leg_suitstorage.dmi'
	return ..(default_layer, default_icon_file, isinhands, female_uniform, override_state, override_file)
