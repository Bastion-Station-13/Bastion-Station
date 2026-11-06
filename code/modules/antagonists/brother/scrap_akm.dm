/**
 * Oh my god, AKMs in ss13? Also it jams really often.
 */

/// Percent chance that the gun will jam when firing. Yes, the travesty, an AKM jamming.
#define SCRAP_AKM_JAM_CHANCE 11
/// How long racking out a jam takes. The do-after also cannot be done while moving so you gotta stand still
#define SCRAP_AKM_UNJAM_TIME 1.5 SECONDS

/obj/projectile/bullet/a762x39
	name = "7.62x39 scrap bullet"
	damage = 32
	armour_penetration = 40
	wound_bonus = 10

/obj/item/ammo_casing/a762x39
	name = "7.62x39 scrap round"
	desc = "A 7.62x39 round that somebody made by hand. Hopefully they knew what they were doing."
	icon = 'bastionstation/icons/obj/weapons/guns/scrap_akm_ammo.dmi'
	icon_state = "762x39-casing"
	caliber = CALIBER_A762x39
	projectile_type = /obj/projectile/bullet/a762x39
	harmful = TRUE
	advanced_print_req = TRUE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.5)

/obj/item/ammo_box/a762x39
	name = "7.62x39 ammo box"
	desc = "A box of loose 7.62x39 scrap rounds."
	icon = 'bastionstation/icons/obj/weapons/guns/scrap_akm_ammo.dmi'
	icon_state = "762x39box"
	ammo_type = /obj/item/ammo_casing/a762x39
	max_ammo = 60
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/akm
	name = "AKM magazine"
	desc = "Because you'll have to reload eventually. It holds 7.62x39 scrap rounds."
	icon = 'bastionstation/icons/obj/weapons/guns/scrap_akm_ammo.dmi'
	icon_state = "akm_mag"
	base_icon_state = "akm_mag"
	ammo_type = /obj/item/ammo_casing/a762x39
	caliber = CALIBER_A762x39
	max_ammo = 30

/obj/item/ammo_box/magazine/akm/update_icon_state()
	icon_state = "[base_icon_state][LAZYLEN(stored_ammo) ? "" : "-0"]"
	return ..()

/obj/item/gun/ballistic/automatic/scrap_akm
	name = "scrap AKM"
	desc = "A classic russian assault rifle, great firepower and armor penetration... but it jams all the time."
	icon = 'bastionstation/icons/obj/weapons/guns/scrap_akm.dmi'
	icon_state = "scrap_akm"
	inhand_icon_state = "scrap_akm"
	worn_icon = 'bastionstation/icons/mob/clothing/scrap_akm_worn.dmi'
	worn_icon_state = "scrap_akm"
	lefthand_file = 'bastionstation/icons/mob/inhands/weapons/scrap_akm_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/weapons/scrap_akm_righthand.dmi'
	SET_BASE_PIXEL(-8, 0)
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	accepted_magazine_type = /obj/item/ammo_box/magazine/akm
	spawnwithmagazine = FALSE
	fire_sound = 'monkestation/code/modules/blueshift/sounds/rifle_heavy.ogg'
	burst_size = 1
	fire_delay = 6
	spread = 5
	recoil = 1
	can_suppress = FALSE
	mag_display = TRUE
	pinless = TRUE
	actions_types = list()
	/// Whether the gun is jammed, and won't fire until it's racked.
	var/jammed = FALSE

/obj/item/gun/ballistic/automatic/scrap_akm/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/blood_brother_gun, \
		weapon_family = BB_GUN_BALLISTIC, \
		part_slots = list(BB_GUN_PART_RECEIVER, BB_GUN_PART_BARREL, BB_GUN_PART_UNDERBARREL), \
		default_parts = list(/obj/item/blood_brother_gun_part/receiver/automatic), \
	)

/obj/item/gun/ballistic/automatic/scrap_akm/examine(mob/user)
	. = ..()
	if(jammed)
		. += span_warning("It's jammed! Use it in hand to rack out the jam.")

/obj/item/gun/ballistic/automatic/scrap_akm/can_shoot()
	if(jammed)
		return FALSE
	return ..()

/obj/item/gun/ballistic/automatic/scrap_akm/shoot_with_empty_chamber(mob/living/user)
	if(!jammed)
		return ..()
	balloon_alert_to_viewers("jammed!")
	playsound(src, 'sound/items/weapons/jammed.ogg', 75, TRUE)

/obj/item/gun/ballistic/automatic/scrap_akm/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(. && prob(SCRAP_AKM_JAM_CHANCE))
		jammed = TRUE

/obj/item/gun/ballistic/automatic/scrap_akm/attack_self(mob/living/user)
	if(!jammed)
		return ..()
	balloon_alert(user, "clearing jam...")
	if(!do_after(user, SCRAP_AKM_UNJAM_TIME, target = src, interaction_key = REF(src)))
		return
	jammed = FALSE
	rack(user)

#undef SCRAP_AKM_JAM_CHANCE
#undef SCRAP_AKM_UNJAM_TIME
