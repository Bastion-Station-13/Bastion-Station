#define CALIBER_SSO_BONER "SSO 7.12x82mm"
#define CALIBER_SSO_HERSTAL "SSO 6.2mm"
#define CALIBER_SSO_MACARONI "SSO 9x20mm"
#define CALIBER_SSO_WEBLEY "SSO .455 Webley"

/obj/projectile/bullet/sso_boner
	name = "7.12x82mm bullet"
	damage = 20
	armour_penetration = 10
	armour_ignorance = 10
	wound_bonus = -60
	bare_wound_bonus = 0
	wound_falloff_tile = 0

/obj/projectile/bullet/sso_herstal
	name = "6.2mm bullet"
	damage = 30
	armour_penetration = 5
	armour_ignorance = 5
	wound_bonus = 10
	bare_wound_bonus = 10
	embed_falloff_tile = -4

/obj/projectile/bullet/sso_macaroni
	name = "9x20mm bullet"
	damage = 10.5
	wound_bonus = 0
	bare_wound_bonus = 5

/obj/projectile/bullet/sso_webley
	name = ".455 Webley bullet"
	damage = 35
	wound_bonus = -20
	bare_wound_bonus = 10

/obj/item/ammo_casing/sso_boner
	name = "7.12x82mm bullet casing"
	desc = "A custom 7.12x82mm bullet casing for the Boner LMG."
	icon_state = "762-casing"
	caliber = CALIBER_SSO_BONER
	projectile_type = /obj/projectile/bullet/sso_boner

/obj/item/ammo_casing/sso_herstal
	name = "6.2mm bullet casing"
	desc = "A custom 6.2mm bullet casing for the HERSTAL-62."
	icon_state = "762-casing"
	caliber = CALIBER_SSO_HERSTAL
	projectile_type = /obj/projectile/bullet/sso_herstal

/obj/item/ammo_casing/sso_macaroni
	name = "9x20mm bullet casing"
	desc = "A custom 9x20mm bullet casing for the Macaroni-20."
	icon_state = "s-casing"
	caliber = CALIBER_SSO_MACARONI
	projectile_type = /obj/projectile/bullet/sso_macaroni

/obj/item/ammo_casing/sso_webley
	name = ".455 Webley bullet casing"
	desc = "A custom .455 Webley bullet casing."
	icon_state = "762-casing"
	caliber = CALIBER_SSO_WEBLEY
	projectile_type = /obj/projectile/bullet/sso_webley

/obj/item/ammo_box/magazine/mm712x82/security_special_operative
	name = "Boner LMG box magazine"
	icon = 'bastionstation/icons/security_special_operative/weapon/ssoammo.dmi'
	icon_state = "ssolmg_mag"
	base_icon_state = "ssolmg_mag"
	ammo_type = /obj/item/ammo_casing/sso_boner
	caliber = CALIBER_SSO_BONER
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/mm712x82/security_special_operative/update_icon_state()
	. = ..()
	icon_state = "ssolmg_mag"

/obj/item/ammo_box/magazine/m556/security_special_operative
	name = "HERSTAL-62 magazine (6.2mm)"
	desc = "A 20-round custom magazine for the HERSTAL-62."
	icon = 'bastionstation/icons/security_special_operative/weapon/ssoammo.dmi'
	icon_state = "herstalmag"
	base_icon_state = "herstalmag"
	ammo_type = /obj/item/ammo_casing/sso_herstal
	caliber = CALIBER_SSO_HERSTAL
	max_ammo = 20
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/smgm45/security_special_operative
	name = "Macaroni-20 magazine (9x20mm)"
	desc = "A 32-round custom magazine for the Macaroni-20."
	icon = 'bastionstation/icons/security_special_operative/weapon/ssoammo.dmi'
	icon_state = "mac20"
	ammo_type = /obj/item/ammo_casing/sso_macaroni
	caliber = CALIBER_SSO_MACARONI
	max_ammo = 32
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/ammo_box/magazine/smgm45/security_special_operative/update_icon_state()
	. = ..()
	icon_state = "mac20"

/obj/item/ammo_box/magazine/internal/shot/com/compact/security_special_operative
	name = "Heavy Combat Shotgun internal shell storage"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 10

/obj/item/ammo_box/magazine/internal/cylinder/security_special_operative
	name = "Webley MK VI cylinder"
	ammo_type = /obj/item/ammo_casing/sso_webley
	caliber = CALIBER_SSO_WEBLEY
	max_ammo = 6
	multiload = TRUE

/obj/item/ammo_box/security_special_operative_webley
	name = "Webley speedloader (.455)"
	desc = "A six-round speedloader for the Webley MK VI."
	icon = 'bastionstation/icons/security_special_operative/weapon/ssoammo.dmi'
	icon_state = "webley_speedloader"
	ammo_type = /obj/item/ammo_casing/sso_webley
	caliber = CALIBER_SSO_WEBLEY
	max_ammo = 6
	multiple_sprites = AMMO_BOX_ONE_SPRITE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gun/ballistic/shotgun/automatic/combat/security_special_operative
	name = "\improper Heavy Combat Shotgun"
	desc = "A compact 12-gauge combat shotgun with a ten-shell capacity. It must be fired with both hands."
	icon = 'bastionstation/icons/security_special_operative/weapon/ballistic.dmi'
	icon_state = "heavyshot"
	base_icon_state = "heavyshot"
	inhand_icon_state = "heavyshotgun"
	lefthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand64 _left.dmi'
	righthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand64_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_SUITSTORE
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/com/compact/security_special_operative
	spawn_magazine_type = /obj/item/ammo_box/magazine/internal/shot/com/compact/security_special_operative
	projectile_damage_multiplier = 1.05
	weapon_weight = WEAPON_HEAVY
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/security_special_operative_lmg
	name = "\improper Boner LMG"
	desc = "A two-handed light machine gun chambered in a custom, reduced-power 7.12x82mm cartridge."
	icon = 'bastionstation/icons/security_special_operative/weapon/ballistic.dmi'
	icon_state = "ssoLMG"
	base_icon_state = "ssoLMG"
	inhand_icon_state = "l6closedmag"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	accepted_magazine_type = /obj/item/ammo_box/magazine/mm712x82/security_special_operative
	spawn_magazine_type = /obj/item/ammo_box/magazine/mm712x82/security_special_operative
	mag_display = FALSE
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	tac_reloads = TRUE
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	wield_recoil = 0.9
	actions_types = list()
	can_suppress = FALSE
	spread = 7
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/security_special_operative_lmg/update_overlays()
	. = ..()
	if(magazine)
		. += "ssoLMGmag"

/obj/item/gun/ballistic/automatic/security_special_operative_lmg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/security_special_operative_lmg/can_shoot()
	return HAS_TRAIT(src, TRAIT_WIELDED) && ..()

/obj/item/gun/ballistic/automatic/security_special_operative_lmg/shoot_with_empty_chamber(mob/living/user as mob|obj)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		if(ismob(user))
			to_chat(user, span_warning("You have to wield [src] to use it."))
		return
	return ..()

/obj/item/gun/ballistic/automatic/security_special_operative_herstal_62
	name = "\improper HERSTAL-62"
	desc = "A 20-round battle rifle chambered in custom 6.2mm ammunition. Its heavy recoil makes it difficult to control one-handed."
	icon = 'bastionstation/icons/security_special_operative/weapon/ballistic.dmi'
	icon_state = "herstal"
	base_icon_state = "herstal"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE
	accepted_magazine_type = /obj/item/ammo_box/magazine/m556/security_special_operative
	spawn_magazine_type = /obj/item/ammo_box/magazine/m556/security_special_operative
	bolt_type = BOLT_TYPE_STANDARD
	burst_size = 1
	actions_types = list()
	fire_delay = 1
	recoil = 5
	wield_recoil = 1.3
	spread = 10
	mag_display = TRUE
	mag_display_ammo = FALSE
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/security_special_operative_macaroni_20
	name = "\improper Macaroni-20"
	desc = "A fully automatic machine pistol with a 32-round custom 9x20mm magazine. Its high recoil is greatly reduced when wielded with both hands."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "miniuzi"
	base_icon_state = "miniuzi"
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	rack_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	mag_display = TRUE
	mag_display_ammo = FALSE
	empty_indicator = FALSE
	selector_switch_icon = FALSE
	accepted_magazine_type = /obj/item/ammo_box/magazine/smgm45/security_special_operative
	spawn_magazine_type = /obj/item/ammo_box/magazine/smgm45/security_special_operative
	burst_size = 1
	actions_types = list()
	fire_delay = 0.1 SECONDS
	recoil = 5
	wield_recoil = 0.7
	spread = 12
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/security_special_operative_macaroni_20/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, fire_delay)

/obj/item/gun/ballistic/revolver/security_special_operative
	name = "\improper Webley MK VI"
	desc = "A six-shot service revolver chambered in custom .455 Webley ammunition."
	icon = 'bastionstation/icons/security_special_operative/weapon/ballistic.dmi'
	icon_state = "webley"
	base_icon_state = "webley"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/security_special_operative
	pin = /obj/item/firing_pin

/obj/item/melee/energy/blade/security_special_operative
	name = "Energy Hausewhr"
	desc = "A compact energy blade with less striking power than a standard energy sword."
	icon = 'bastionstation/icons/security_special_operative/weapon/ssosword.dmi'
	icon_state = "hauswehr"
	base_icon_state = "hauswehr"
	inhand_icon_state = "hauswehr"
	lefthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand_left.dmi'
	righthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand_right.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 24
	throwforce = 16

/obj/item/storage/toolbox/guncase/security_special_operative
	name = "SSO weapon case"
	desc = "A rugged weapon case containing a firearm and its ammunition."

/obj/item/storage/toolbox/guncase/security_special_operative/boner_lmg
	name = "Boner LMG weapon case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/security_special_operative_lmg
	extra_to_spawn = /obj/item/ammo_box/magazine/mm712x82/security_special_operative

/obj/item/storage/toolbox/guncase/security_special_operative/herstal_62
	name = "HERSTAL-62 weapon case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/security_special_operative_herstal_62
	extra_to_spawn = /obj/item/ammo_box/magazine/m556/security_special_operative

/obj/item/storage/toolbox/guncase/security_special_operative/macaroni_20
	name = "Macaroni-20 weapon case"
	weapon_to_spawn = /obj/item/gun/ballistic/automatic/security_special_operative_macaroni_20
	extra_to_spawn = /obj/item/ammo_box/magazine/smgm45/security_special_operative

/obj/item/storage/toolbox/guncase/security_special_operative/webley_mk6
	name = "Webley MK VI weapon case"
	weapon_to_spawn = /obj/item/gun/ballistic/revolver/security_special_operative
	extra_to_spawn = /obj/item/ammo_box/security_special_operative_webley

/obj/item/storage/toolbox/guncase/security_special_operative/heavy_combat_shotgun
	name = "Heavy Combat Shotgun case"

/obj/item/storage/toolbox/guncase/security_special_operative/heavy_combat_shotgun/PopulateContents()
	new /obj/item/gun/ballistic/shotgun/automatic/combat/security_special_operative(src)
	new /obj/item/ammo_box/advanced/s12gauge/buckshot(src)

/obj/item/melee/baton/security/security_special_operative
	name = "advanced stun baton"
	desc = "An always-on stun baton tuned to incapacitate in three hits. Press Z to overclock it for a brief knockdown strike."
	icon = 'bastionstation/icons/security_special_operative/weapon/baton.dmi'
	base_icon_state = "qrfbaton"
	active = TRUE
	preload_cell_type = /obj/item/stock_parts/power_store/cell/infinite
	can_remove_cell = FALSE
	stamina_damage = 45
	knockdown_time = 0

	var/overclock_active = FALSE
	var/datum/weakref/overclock_user
	var/overclock_timer
	COOLDOWN_DECLARE(overclock_cooldown)

/obj/item/melee/baton/security/security_special_operative/update_icon_state()
	. = ..()
	icon_state = overclock_active ? "qrfbaton_overclock" : "qrfbaton"

/obj/item/melee/baton/security/security_special_operative/attack_self(mob/user)
	if(overclock_active)
		balloon_alert(user, "already overclocked")
		return TRUE

	if(!COOLDOWN_FINISHED(src, overclock_cooldown))
		balloon_alert(user, "overclock recharging")
		return TRUE

	overclock_active = TRUE
	overclock_user = WEAKREF(user)
	COOLDOWN_START(src, overclock_cooldown, 10 SECONDS)
	update_appearance()
	balloon_alert(user, "overclocked")
	overclock_timer = addtimer(CALLBACK(src, PROC_REF(overclock_expired), overclock_user), 3 SECONDS, TIMER_STOPPABLE)
	return TRUE

/obj/item/melee/baton/security/security_special_operative/proc/overclock_expired(datum/weakref/user_reference)
	if(!overclock_active)
		return

	overclock_active = FALSE
	overclock_timer = null
	overclock_user = null
	update_appearance()
	var/mob/living/user = user_reference?.resolve()
	if(!user)
		return

	playsound(user, 'sound/effects/contractorbatonhit.ogg', 75, TRUE, -1)
	user.visible_message(span_warning("[src] backfires, stunning [user]!"))
	user.Paralyze(3 SECONDS)

/obj/item/melee/baton/security/security_special_operative/finalize_baton_attack(mob/living/target, mob/living/user, modifiers, in_attack_chain = TRUE)
	var/previous_stun_sound = on_stun_sound
	if(overclock_active && overclock_user?.resolve() == user)
		on_stun_sound = 'sound/effects/contractorbatonhit.ogg'
	. = ..()
	on_stun_sound = previous_stun_sound

/obj/item/melee/baton/security/security_special_operative/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	. = ..()
	if(!. || !overclock_active || overclock_user?.resolve() != user)
		return

	overclock_active = FALSE
	if(overclock_timer)
		deltimer(overclock_timer)
	overclock_timer = null
	overclock_user = null
	update_appearance()
	target.Knockdown(1.5 SECONDS)

/obj/item/gun/energy/recharge/security_special_operative/wavegun
	name = "wavegun"
	desc = "A self-recharging energy weapon with three non-lethal wave modes."
	icon = 'bastionstation/icons/security_special_operative/weapon/energy.dmi'
	icon_state = "wavegun"
	base_icon_state = "wavegun"
	inhand_icon_state = "wavegun_debilitate"
	lefthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand_left.dmi'
	righthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand_right.dmi'
	w_class = WEIGHT_CLASS_SMALL
	cell_type = /obj/item/stock_parts/power_store/cell/security_special_operative_wavegun
	holds_charge = TRUE
	recharge_time = 3 SECONDS
	recoil = 0.15
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/security_special_operative/debilitating,
		/obj/item/ammo_casing/energy/disabler/security_special_operative/transverse,
		/obj/item/ammo_casing/energy/disabler/security_special_operative/reflection,
	)
	modifystate = FALSE
	can_select = TRUE

/obj/item/gun/energy/recharge/security_special_operative/wavegun/update_icon_state()
	. = ..()
	icon_state = "wavegun"
	switch(select)
		if(1)
			inhand_icon_state = "wavegun_debilitate"
		if(2)
			inhand_icon_state = "wavegun_transfusion"
		if(3)
			inhand_icon_state = "wavegun_reflection"

/obj/item/gun/energy/recharge/security_special_operative/wavegun/update_overlays()
	. = ..()
	switch(select)
		if(1)
			. += "wavegundebilitate"
		if(2)
			. += "waveguntransverse"
		if(3)
			. += "wavegunreflection"

/obj/item/ammo_casing/energy/disabler/security_special_operative/debilitating
	select_name = "Debilitate"
	projectile_type = /obj/projectile/energy/security_special_operative/debilitating
	firing_effect_type = null
	e_cost = STANDARD_CELL_CHARGE * 0.25
	harmful = FALSE

/obj/item/ammo_casing/energy/disabler/security_special_operative/transverse
	select_name = "Transverse Wave"
	projectile_type = /obj/projectile/energy/security_special_operative/transverse
	firing_effect_type = null
	e_cost = STANDARD_CELL_CHARGE * 0.15
	harmful = FALSE

/obj/item/ammo_casing/energy/disabler/security_special_operative/reflection
	select_name = "Reflection Wave"
	projectile_type = /obj/projectile/energy/security_special_operative/reflection
	firing_effect_type = null
	e_cost = STANDARD_CELL_CHARGE * 0.12
	harmful = FALSE

/obj/projectile/energy/security_special_operative
	icon = 'bastionstation/icons/security_special_operative/weapon/projectiles.dmi'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/security_special_operative/Initialize(mapload)
	. = ..()
	transform = matrix() * 0.65

/obj/projectile/energy/security_special_operative/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(. == BULLET_ACT_HIT && isliving(target) && blocked < 100 && impact_effect_type)
		new impact_effect_type(get_turf(target), impact_x, impact_y)

/obj/projectile/energy/security_special_operative/debilitating
	name = "debilitating wave"
	icon_state = "wave_debilitate"
	speed = 0.65
	stamina = 55

/obj/projectile/energy/security_special_operative/debilitating/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(. == BULLET_ACT_HIT && isliving(target) && blocked < 100)
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/incapacitating/disoriented, 2 SECONDS)

/obj/projectile/energy/security_special_operative/transverse
	name = "transverse wave"
	icon_state = "wave_transverse"
	stamina = 35
	range = 4
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF
	projectile_phasing = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser

/obj/projectile/energy/security_special_operative/reflection
	name = "reflection wave"
	icon_state = "wave_reflection"
	stamina = 15
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	ricochets_max = 4
	ricochet_chance = 140
	ricochet_auto_aim_angle = 35
	ricochet_auto_aim_range = 7
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1
	ricochet_shoots_firer = FALSE
	reflectable = TRUE

/obj/projectile/energy/security_special_operative/reflection/on_ricochet(atom/target)
	. = ..()
	stamina += 10

/obj/projectile/energy/security_special_operative/reflection/check_ricochet_flag(atom/reflecting_atom)
	if((reflecting_atom.flags_ricochet & RICOCHET_HARD) || (reflecting_atom.flags_ricochet & RICOCHET_SHINY))
		return TRUE
	return FALSE

/obj/item/gun/energy/taser/security_special_operative/xm05
	name = "XM-05 stun shotgun"
	icon = 'bastionstation/icons/security_special_operative/weapon/energy.dmi'
	icon_state = "stunshotgun"
	base_icon_state = "stunshotgun"
	inhand_icon_state = "stunshotgun"
	lefthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand64 _left.dmi'
	righthand_file = 'bastionstation/icons/security_special_operative/weapon/ssoinhand64_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_SMALL
	cell_type = /obj/item/stock_parts/power_store/cell/security_special_operative_xm05
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/security_special_operative)
	modifystate = FALSE
	automatic_charge_overlays = FALSE
	desc = "A compact taser that fires four electrodes in a spreading volley."

/obj/item/gun/energy/taser/security_special_operative/xm05/update_icon_state()
	. = ..()
	icon_state = can_shoot() ? "stunshotgun" : "stunshotgunempty"

/obj/item/ammo_casing/energy/electrode/security_special_operative
	projectile_type = /obj/projectile/energy/electrode
	e_cost = LASER_SHOTS(7, STANDARD_CELL_CHARGE)
	pellets = 4
	variance = 24

/obj/item/stock_parts/power_store/cell/security_special_operative_xm05
	name = "XM-05 power cell"
	maxcharge = STANDARD_CELL_CHARGE * 0.6

/obj/item/stock_parts/power_store/cell/security_special_operative_wavegun
	name = "Wavegun power cell"
	maxcharge = STANDARD_CELL_CHARGE * 2

/obj/item/storage/box/security_special_operative
	icon_state = "secbox"

/obj/item/storage/box/security_special_operative/primary_ammunition
	name = "SSO primary ammunition box"

/obj/item/storage/box/security_special_operative/primary_ammunition/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = WEIGHT_CLASS_BULKY * 2
	atom_storage.set_holdable(list(
		/obj/item/ammo_box/advanced/s12gauge/buckshot,
		/obj/item/ammo_box/magazine/mm712x82/security_special_operative,
		/obj/item/ammo_box/magazine/m556/security_special_operative,
	))

/obj/item/storage/box/security_special_operative/primary_ammunition/shotgun
	name = "SSO shotgun ammunition box"
	desc = "Two spare boxes of buckshot for the Heavy Combat Shotgun."

/obj/item/storage/box/security_special_operative/primary_ammunition/shotgun/PopulateContents()
	new /obj/item/ammo_box/advanced/s12gauge/buckshot(src)
	new /obj/item/ammo_box/advanced/s12gauge/buckshot(src)

/obj/item/storage/box/security_special_operative/primary_ammunition/boner_lmg
	name = "SSO Boner LMG ammunition box"
	desc = "Two spare 50-round magazines for the Boner LMG."

/obj/item/storage/box/security_special_operative/primary_ammunition/boner_lmg/PopulateContents()
	new /obj/item/ammo_box/magazine/mm712x82/security_special_operative(src)
	new /obj/item/ammo_box/magazine/mm712x82/security_special_operative(src)

/obj/item/storage/box/security_special_operative/primary_ammunition/herstal_62
	name = "SSO HERSTAL-62 ammunition box"
	desc = "Two spare magazines for the HERSTAL-62."

/obj/item/storage/box/security_special_operative/primary_ammunition/herstal_62/PopulateContents()
	new /obj/item/ammo_box/magazine/m556/security_special_operative(src)
	new /obj/item/ammo_box/magazine/m556/security_special_operative(src)

/obj/item/storage/box/security_special_operative/engineer
	name = "SSO engineer kit"
	desc = "A rapid-construction device and two bluespace matter cartridges."

/obj/item/storage/box/security_special_operative/engineer/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = WEIGHT_CLASS_BULKY * 2
	atom_storage.set_holdable(list(
		/obj/item/construction/rcd,
		/obj/item/rcd_ammo/ultra_large,
	))

/obj/item/storage/box/security_special_operative/engineer/PopulateContents()
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/rcd_ammo/ultra_large(src)
	new /obj/item/rcd_ammo/ultra_large(src)

/obj/item/storage/box/security_special_operative/akimbo_disablers
	name = "akimbo disabler bundle"
	desc = "A secure equipment box containing two standard disablers."

/obj/item/storage/box/security_special_operative/akimbo_disablers/PopulateContents()
	new /obj/item/gun/energy/disabler(src)
	new /obj/item/gun/energy/disabler(src)

/obj/item/storage/medkit/tactical/security_special_operative
	name = "SSO tactical medkit"
	desc = "A tactical medical kit with patches, a hypospray, and a mixed bluespace chemical canister."

/obj/item/storage/medkit/tactical/security_special_operative/PopulateContents()
	var/list/items_inside = list(
		/obj/item/reagent_containers/pill/patch/libital = 3,
		/obj/item/reagent_containers/pill/patch/aiuri = 3,
		/obj/item/reagent_containers/pill/patch/security_special_operative_omnizine = 2,
		/obj/item/hypospray = 1,
		/obj/item/reagent_containers/chemcanister/bluespace/security_special_operative = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/reagent_containers/pill/patch/security_special_operative_omnizine
	name = "omnizine patch"
	desc = "A patch containing 10 units of omnizine."
	list_reagents = list(/datum/reagent/medicine/omnizine = 10)

/obj/item/reagent_containers/chemcanister/bluespace/security_special_operative
	name = "bluespace chemical canister (SSO medical mix)"
	desc = "A bluespace canister containing 50 units each of salicylic acid and oxandrolone."
	list_reagents = list(/datum/reagent/medicine/sal_acid = 50, /datum/reagent/medicine/oxandrolone = 50)

/obj/item/storage/box/stingbangs/security_special_operative
	name = "box of 3 stingbangs"
	desc = "A box containing three stingbang grenades."

/obj/item/storage/box/stingbangs/security_special_operative/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/stingbang(src)

/obj/item/storage/box/security_special_operative/energy_bolas
	name = "box of energy bolas"
	desc = "A box containing five energy bolas."

/obj/item/storage/box/security_special_operative/energy_bolas/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/restraints/legcuffs/bola/energy(src)

/obj/item/reagent_containers/medipen/security_special_operative
	name = "SSO stimulant autoinjector"
	desc = "Contains 8 units of methamphetamine, 4 units of mannitol, and 3 units of ephedrine."
	list_reagents = list(
		/datum/reagent/drug/methamphetamine = 8,
		/datum/reagent/medicine/mannitol = 4,
		/datum/reagent/medicine/ephedrine = 3,
	)

/obj/item/storage/box/security_special_operative/stimulant_injectors
	name = "box of SSO stimulant autoinjectors"
	desc = "A box containing two stimulant autoinjectors."

/obj/item/storage/box/security_special_operative/stimulant_injectors/PopulateContents()
	new /obj/item/reagent_containers/medipen/security_special_operative(src)
	new /obj/item/reagent_containers/medipen/security_special_operative(src)

/obj/item/storage/box/security_special_operative/combat_medic
	name = "combat medic kit"
	desc = "A compact kit containing a medical beamgun, brute treatment kit, and burn treatment kit."

/obj/item/storage/box/security_special_operative/combat_medic/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY

/obj/item/storage/box/security_special_operative/combat_medic/PopulateContents()
	new /obj/item/gun/medbeam(src)
	new /obj/item/storage/medkit/brute(src)
	new /obj/item/storage/medkit/fire(src)

/obj/item/mod/module/energy_shield/security_special_operative
	name = "experimental energy shield module"
	desc = "A prototype MOD shield with two protective charges and a slower recharge cycle."
	max_charges = 2
	recharge_start_delay = 30 SECONDS

/datum/outfit/job/security_special_operative_support
	name = "Special Operative Support Unit"
	jobtype = /datum/job/security_officer
	id_trim = /datum/id_trim/job/security_officer
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest/alt/sec
	head = /obj/item/clothing/head/helmet/sec
	back = /obj/item/mod/control/pre_equipped/security
	belt = /obj/item/storage/belt/security
	ears = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/black/security
	shoes = /obj/item/clothing/shoes/jackboots/sec
	l_hand = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/restraints/legcuffs/bola
	r_pocket = /obj/item/restraints/handcuffs
	box = /obj/item/storage/box/survival/security

/obj/item/antag_spawner/loadout/security_special_operative_support
	name = "Special Operative Support Beacon"
	desc = "A single-use beacon that calls a ghost to the field as a security support officer."
	outfit = /datum/outfit/job/security_special_operative_support
	poll_role_check = ROLE_TRAITOR
	role_to_play = "Special Operative Support Unit"
	fail_text = "No eligible ghosts responded to the support call. The beacon is still available to try again."

/obj/item/antag_spawner/loadout/security_special_operative_support/do_special_things(mob/living/carbon/human/support_unit, mob/user)
	support_unit.mind.set_assigned_role(SSjob.GetJobType(/datum/job/security_officer))

#undef CALIBER_SSO_BONER
#undef CALIBER_SSO_HERSTAL
#undef CALIBER_SSO_MACARONI
#undef CALIBER_SSO_WEBLEY
