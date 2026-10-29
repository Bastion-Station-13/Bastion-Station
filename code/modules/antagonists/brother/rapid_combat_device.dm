/**
 * Rapid combat device for Blood Brothers.
 *
 * An RCD rewired into a gun. It isn't a BB modular gun or a real RCD, so it takes neither gun parts nor RCD upgrades.
 */

#define RCD_GUN_MAX_MATTER 160
#define RCD_GUN_BALL_COST 10
#define RCD_GUN_BREACH_COST 20
#define RCD_GUN_BARRICADE_COST 40
#define RCD_BARRICADE_DURATION (30 SECONDS)

/obj/item/gun/energy/rapid_combat_device
	name = "rapid combat device"
	desc = "Somebody ripped the building smarts out of an RCD and taught it to shoot instead. Still eats matter like the real thing."
	icon = 'bastionstation/icons/obj/weapons/guns/rcd_gun.dmi'
	icon_state = "rcd_gun"
	inhand_icon_state = "rcd_gun"
	lefthand_file = 'bastionstation/icons/mob/inhands/weapons/rcd_gun_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/weapons/rcd_gun_righthand.dmi'
	ammo_type = list(
		/obj/item/ammo_casing/energy/rcd_gun/ball,
		/obj/item/ammo_casing/energy/rcd_gun/breach,
		/obj/item/ammo_casing/energy/rcd_gun/barricade,
	)
	w_class = WEIGHT_CLASS_NORMAL
	automatic_charge_overlays = FALSE
	charge_sections = 9
	can_charge = FALSE
	dead_cell = TRUE
	pinless = TRUE

/obj/item/gun/energy/rapid_combat_device/Initialize(mapload)
	. = ..()
	// The cell is only a matter counter, so EMPs and chargers can't touch it.
	cell.maxcharge = RCD_GUN_MAX_MATTER
	cell.charge = 0
	chambered = null
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS)
	update_appearance()

/obj/item/gun/energy/rapid_combat_device/get_cell(atom/movable/interface, mob/user)
	return null

/obj/item/gun/energy/rapid_combat_device/examine(mob/user)
	. = ..()
	. += span_notice("It's got [cell.charge]/[cell.maxcharge] matter in it. Feed it <b>matter cartridges</b> or <b>sheets</b>, same as an RCD.")
	. += span_notice("<b>Use it in hand</b> to swap modes: ball ([RCD_GUN_BALL_COST] matter), breach ([RCD_GUN_BREACH_COST]) or barricade ([RCD_GUN_BARRICADE_COST]).")

/obj/item/gun/energy/rapid_combat_device/update_overlays()
	. = ..()
	. += get_ammo_overlay()

/obj/item/gun/energy/rapid_combat_device/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		. += mutable_appearance(icon_file, get_ammo_overlay())

/// Returns the icon state of the ammo bar for the selected mode, or the empty light if it can't fire.
/obj/item/gun/energy/rapid_combat_device/proc/get_ammo_overlay()
	var/ratio = get_charge_ratio()
	if(!ratio)
		return "[initial(icon_state)]_empty"
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return "[initial(icon_state)]_[shot.select_name]_[ratio]"

/obj/item/gun/energy/rapid_combat_device/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/rcd_upgrade))
		balloon_alert(user, "not a real RCD!")
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stack/sheets = tool
	if(!istype(tool, /obj/item/rcd_ammo) && !(istype(sheets) && sheets.matter_amount > 0))
		return ..()
	load_matter(tool, user)
	return ITEM_INTERACT_SUCCESS

/// Loads matter the same way an RCD does: as much of a cartridge as fits, or as many whole sheets as fit.
/obj/item/gun/energy/rapid_combat_device/proc/load_matter(obj/item/source, mob/living/user)
	var/space = cell.maxcharge - cell.charge
	var/loaded = 0
	if(istype(source, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/cartridge = source
		loaded = min(cartridge.ammoamt, space)
		cartridge.ammoamt -= loaded
		if(cartridge.ammoamt <= 0)
			qdel(cartridge)
	else
		var/obj/item/stack/sheets = source
		var/sheets_used = min(sheets.amount, round(space / sheets.matter_amount))
		loaded = sheets_used * sheets.matter_amount
		sheets.use(sheets_used)
	if(loaded <= 0)
		balloon_alert(user, "storage full!")
		return
	cell.give(loaded)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	balloon_alert(user, "loaded [loaded] matter")
	recharge_newshot(TRUE)
	update_appearance()

/obj/item/ammo_casing/energy/rcd_gun
	harmful = TRUE

/obj/item/ammo_casing/energy/rcd_gun/ball
	projectile_type = /obj/projectile/bullet/rcd_ball
	select_name = "ball"
	e_cost = RCD_GUN_BALL_COST
	fire_sound = 'bastionstation/sound/items/weapons/gun/rcd_gun/rcd_ball_shot.ogg'

/obj/item/ammo_casing/energy/rcd_gun/breach
	projectile_type = /obj/projectile/rcd_breach
	select_name = "breach"
	e_cost = RCD_GUN_BREACH_COST
	fire_sound = 'bastionstation/sound/items/weapons/gun/rcd_gun/rcd_breach_shot.ogg'

/obj/item/ammo_casing/energy/rcd_gun/barricade
	projectile_type = /obj/projectile/rcd_barricade
	select_name = "barricade"
	e_cost = RCD_GUN_BARRICADE_COST
	fire_sound = 'bastionstation/sound/items/weapons/gun/rcd_gun/rcd_barricade_shot.ogg'
	harmful = FALSE

/// Blunt, so it breaks bones instead of making people bleed.
/obj/projectile/bullet/rcd_ball
	name = "matter ball"
	icon = 'bastionstation/icons/obj/weapons/guns/rcd_projectiles.dmi'
	icon_state = "rcd_ball"
	damage = 25
	sharpness = NONE
	wound_bonus = 30
	bare_wound_bonus = 15
	shrapnel_type = null
	embed_type = null

/obj/projectile/rcd_breach
	name = "breaching blast"
	icon = 'bastionstation/icons/obj/weapons/guns/rcd_projectiles.dmi'
	icon_state = "rcd_breach"
	damage = 10
	damage_type = BURN
	armor_flag = LASER
	demolition_mod = 8
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

/// Deploys a barricade where it lands: the clicked tile, or the last clear tile before whatever it hit.
/obj/projectile/rcd_barricade
	name = "matter bolt"
	icon = 'bastionstation/icons/obj/weapons/guns/rcd_projectiles.dmi'
	icon_state = "rcd_barricade"
	damage = 0
	range = 10
	var/turf/last_clear_turf
	var/deployed = FALSE

/obj/projectile/rcd_barricade/reduce_range()
	var/turf/current = get_turf(src)
	if(current && !current.is_blocked_turf())
		last_clear_turf = current
	if(current && current == get_turf(original))
		range = 1
	return ..()

/obj/projectile/rcd_barricade/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	deploy()

/obj/projectile/rcd_barricade/on_range()
	deploy()
	return ..()

/obj/projectile/rcd_barricade/proc/deploy()
	if(deployed)
		return
	deployed = TRUE
	if(!last_clear_turf || last_clear_turf.is_blocked_turf())
		return
	new /obj/structure/rcd_barricade(last_clear_turf)

/obj/structure/rcd_barricade
	name = "matter barricade"
	desc = "A slab of compressed matter. Solid as a wall for now, but it'll crumble on its own soon enough."
	icon = 'bastionstation/icons/obj/antags/rcd_barricade.dmi'
	icon_state = "rcd_barricade"
	density = TRUE
	anchored = TRUE
	max_integrity = 150

/obj/structure/rcd_barricade/Initialize(mapload)
	. = ..()
	flick("rcd_barricade_spawn", src)
	QDEL_IN(src, RCD_BARRICADE_DURATION)

/obj/structure/rcd_barricade/Destroy()
	if(loc)
		new /obj/effect/temp_visual/rcd_barricade_fade(loc)
	return ..()

/obj/structure/rcd_barricade/on_integrity_update(new_value)
	update_appearance()

/obj/structure/rcd_barricade/update_icon_state()
	icon_state = atom_integrity < max_integrity / 2 ? "rcd_barricade_damaged" : "rcd_barricade"
	return ..()

/obj/effect/temp_visual/rcd_barricade_fade
	icon = 'bastionstation/icons/obj/antags/rcd_barricade.dmi'
	icon_state = "rcd_barricade_fade"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/rcd_barricade_fade/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration)

#undef RCD_GUN_MAX_MATTER
#undef RCD_GUN_BALL_COST
#undef RCD_GUN_BREACH_COST
#undef RCD_GUN_BARRICADE_COST
#undef RCD_BARRICADE_DURATION
