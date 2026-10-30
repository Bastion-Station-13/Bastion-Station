//////////////////////////////////////////////////////////////////////////
//------------------------------Grown items-----------------------------//
//////////////////////////////////////////////////////////////////////////
/**
 * Base for the powers that grow an item into the active hand. Using the power again or pressing the drop key makes it crumble.
 * Items with charges keep them here on the power, not on the item, so putting the item away and growing it again doesn't refill it.
 */
/datum/action/cooldown/arcfiend/grown_item
	shop_listed = FALSE
	cooldown_time = 1 SECONDS
	var/obj/item/grown_type
	/// What one charge is called in messages, for items that have charges
	var/charge_name = "charge"
	var/recharge_sound
	/// The charges the item has right now. It starts out full, see get_charges().
	var/charges
	var/charge_timer

/datum/action/cooldown/arcfiend/grown_item/Destroy()
	if(charge_timer)
		deltimer(charge_timer)
		charge_timer = null
	return ..()

/datum/action/cooldown/arcfiend/grown_item/Remove(mob/remove_from)
	if(remove_from)
		put_away(remove_from)
	return ..()

/datum/action/cooldown/arcfiend/grown_item/proc/get_max_charges()
	return 0

/datum/action/cooldown/arcfiend/grown_item/proc/get_charge_time()
	return 0

/datum/action/cooldown/arcfiend/grown_item/proc/get_charges()
	if(isnull(charges))
		charges = get_max_charges()
	return charges

/// Takes a charge, and starts bringing one back. Returns FALSE if there were none left.
/datum/action/cooldown/arcfiend/grown_item/proc/use_charge()
	if(get_charges() < 1)
		return FALSE
	charges--
	start_charge_timer()
	return TRUE

/datum/action/cooldown/arcfiend/grown_item/proc/start_charge_timer()
	if(charge_timer || get_charges() >= get_max_charges())
		return
	charge_timer = addtimer(CALLBACK(src, PROC_REF(charge_recharged)), get_charge_time(), TIMER_STOPPABLE)

/datum/action/cooldown/arcfiend/grown_item/proc/charge_recharged()
	charge_timer = null
	charges = min(get_charges() + 1, get_max_charges())
	on_charge_regained()
	start_charge_timer()

/datum/action/cooldown/arcfiend/grown_item/proc/on_charge_regained()
	if(!get_held_item(owner))
		return
	owner.balloon_alert(owner, "[charge_name] rebuilt ([charges]/[get_max_charges()])")
	playsound(owner, recharge_sound, 20, TRUE)

/// A bigger magazine or a faster recharge may mean there is room to bring a charge back now
/datum/action/cooldown/arcfiend/grown_item/on_upgraded()
	start_charge_timer()

/datum/action/cooldown/arcfiend/grown_item/proc/get_held_item(mob/user)
	if(!user)
		return null
	return locate(grown_type) in user.held_items

/// Gets rid of the item if we are holding it. Returns TRUE if there was one.
/datum/action/cooldown/arcfiend/grown_item/proc/put_away(mob/user)
	var/found = FALSE
	for(var/obj/item/held as anything in user.held_items)
		if(!istype(held, grown_type))
			continue
		user.temporarilyRemoveItemFromInventory(held, TRUE) // DROPDEL deletes it
		found = TRUE
	if(found)
		user.update_held_items()
	return found

/// Lets the item crumble away, with the sound and messages that go with it. Returns TRUE if there was one.
/datum/action/cooldown/arcfiend/grown_item/proc/dismiss(mob/living/user)
	if(!put_away(user))
		return FALSE
	playsound(user, ARCFIEND_SOUND_ITEM_CRUMBLE, 30, TRUE)
	user.visible_message(span_notice("[user]'s [initial(grown_type.name)] crumbles away."), span_notice("You let the [initial(grown_type.name)] crumble away."))
	StartCooldown()
	return TRUE

/// Pressing the drop key while holding the item dismisses it instead of trying to drop it
/datum/action/cooldown/arcfiend/grown_item/on_drop_key(mob/user, obj/item/held)
	if(istype(held, grown_type) && isliving(user))
		return dismiss(user)
	return ..()

/datum/action/cooldown/arcfiend/grown_item/Activate(atom/target)
	if(!get_arcfiend() || !isliving(owner))
		return FALSE
	var/mob/living/user = owner
	if(dismiss(user))
		return TRUE
	if(!free_active_hand(user))
		return FALSE
	var/obj/item/grown = new grown_type(user)
	if(!give_item(user, grown))
		return FALSE
	do_sparks(2, FALSE, user)
	playsound(user, ARCFIEND_SOUND_ITEM_GROW, 30, TRUE)
	on_grown(user, grown)
	StartCooldown()
	return TRUE

/// Announces the item once it is in the arcfiend's hand. Override this to describe each item.
/datum/action/cooldown/arcfiend/grown_item/proc/on_grown(mob/living/user, obj/item/grown)
	user.visible_message(span_warning("Something made of biometal grows out of [user]'s hand!"), span_notice("You grow \a [grown]."))

/// Base for the grown guns. Every shot costs power and a charge.
/datum/action/cooldown/arcfiend/grown_item/gun

/datum/action/cooldown/arcfiend/grown_item/gun/proc/get_shot_cost()
	return 0

/datum/action/cooldown/arcfiend/grown_item/gun/get_cost_text()
	return "[get_shot_cost()] power per shot"

/datum/action/cooldown/arcfiend/grown_item/gun/get_cost_label()
	return "[get_shot_cost()]"

/datum/action/cooldown/arcfiend/grown_item/gun/proc/setup_projectile(obj/projectile/projectile)
	return

/// No cell. Each shot is paid for in power and a charge by the power that grew it, see handle_chamber().
/obj/item/gun/energy/arcfiend
	name = "biometal gun"
	desc = "A lump of biometal shaped like a gun. It runs on its owner's electricity."
	item_flags = ABSTRACT | DROPDEL
	can_select = FALSE
	can_charge = FALSE
	automatic_charge_overlays = FALSE
	display_empty = FALSE
	pinless = TRUE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	/// The power that grows this gun, which holds its magazine and decides what a shot costs
	var/datum/action/cooldown/arcfiend/grown_item/gun/power_type

/obj/item/gun/energy/arcfiend/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ARCFIEND_TRAIT)

/obj/item/gun/energy/arcfiend/get_cell(atom/movable/interface, mob/user)
	return null

/obj/item/gun/energy/arcfiend/proc/get_holder_antag()
	if(!ismob(loc))
		return null
	var/mob/holder = loc
	return holder.mind?.has_antag_datum(/datum/antagonist/arcfiend)

/obj/item/gun/energy/arcfiend/proc/get_holder_power()
	var/datum/antagonist/arcfiend/arcfiend = get_holder_antag()
	return arcfiend?.get_power_instance(power_type)

/obj/item/gun/energy/arcfiend/can_shoot()
	var/datum/antagonist/arcfiend/arcfiend = get_holder_antag()
	var/datum/action/cooldown/arcfiend/grown_item/gun/gun_power = get_holder_power()
	if(!arcfiend || !gun_power)
		return FALSE
	return arcfiend.has_power(gun_power.get_shot_cost()) && gun_power.get_charges() >= 1

/obj/item/gun/energy/arcfiend/shoot_with_empty_chamber(mob/living/user as mob|obj)
	var/datum/action/cooldown/arcfiend/grown_item/gun/gun_power = get_holder_power()
	if(gun_power && gun_power.get_charges() < 1)
		balloon_alert_to_viewers("out of [gun_power.charge_name]s!")
	else if(gun_power)
		balloon_alert_to_viewers("need [gun_power.get_shot_cost()] power!")
	else
		balloon_alert_to_viewers("*click*")
	playsound(src, dry_fire_sound, dry_fire_sound_volume, TRUE)

/obj/item/gun/energy/arcfiend/examine(mob/user)
	. = ..()
	var/datum/action/cooldown/arcfiend/grown_item/gun/gun_power = get_holder_power()
	if(gun_power)
		. += span_notice("Its magazine holds [gun_power.get_charges()] of [gun_power.get_max_charges()] [gun_power.charge_name]s. It rebuilds one every [gun_power.get_charge_time() / 10] seconds.")

/// Always has a round ready, set up for the power's upgrade level. The cost is only paid when it is fired.
/obj/item/gun/energy/arcfiend/recharge_newshot(no_cyborg_drain)
	if(!ammo_type || chambered)
		return
	chambered = ammo_type[select]
	if(!chambered.loaded_projectile)
		chambered.newshot()
	var/datum/action/cooldown/arcfiend/grown_item/gun/gun_power = get_holder_power()
	if(gun_power && chambered.loaded_projectile)
		gun_power.setup_projectile(chambered.loaded_projectile)

/obj/item/gun/energy/arcfiend/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	// A spent round means the shot was fired, so that is when it is paid for, in power and in a charge.
	// The game doesn't always pass the shooter in here (a single shot doesn't), so whoever is holding the gun is used instead.
	if(chambered && !chambered.loaded_projectile)
		var/datum/antagonist/arcfiend/arcfiend = get_holder_antag()
		var/datum/action/cooldown/arcfiend/grown_item/gun/gun_power = get_holder_power()
		if(arcfiend && gun_power)
			arcfiend.spend_power(gun_power.get_shot_cost())
			if(gun_power.use_charge() && ismob(loc))
				var/mob/shooter = loc
				var/left = gun_power.get_charges()
				shooter.balloon_alert(shooter, "[left] [gun_power.charge_name][left == 1 ? "" : "s"] left")
	chambered = null
	recharge_newshot()

//////////////////////////////////////////////////////////////////////////
//------------------------------Manifest Coilgun-------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/projectile/bullet/arcfiend_slug
	name = "biometal slug"
	icon = 'bastionstation/icons/obj/antags/arcfiend/arcfiend_coilgun_projectile.dmi'
	icon_state = "biometal_slug"
	damage = 20
	embed_type = null
	shrapnel_type = null

/obj/item/ammo_casing/energy/arcfiend_slug
	projectile_type = /obj/projectile/bullet/arcfiend_slug
	fire_sound = ARCFIEND_SOUND_COILGUN_FIRE
	select_name = "slug"
	e_cost = 0
	delay = 0.8 SECONDS

/// Biometal gun that doesn't use gunpowder, the electricity propels the bullets.
/obj/item/gun/energy/arcfiend/coilgun
	name = "biometal coilgun"
	desc = "A lumpy biometal gun that grew out of an arcfiend's hand. Runs on its owner's electricity."
	icon = 'bastionstation/icons/obj/antags/arcfiend/arcfiend_coilgun.dmi'
	icon_state = "arcfiend_coilgun"
	inhand_icon_state = "arcfiend_coilgun"
	lefthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_coilgun_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_coilgun_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/arcfiend_slug)
	power_type = /datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun

/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun
	name = "Manifest Coilgun"
	desc = "Your nanites weave a crude coilgun out of biometal in your hand."
	shop_desc = "Grants you Manifest Coilgun, which grows a biometal coilgun in your hand. It is free to summon and put away, but each shot costs power and a slug. It holds 4 slugs and regrows one every 8 seconds, even while put away."
	button_icon = 'bastionstation/icons/mob/actions/arcfiend/action_manifest_coilgun.dmi'
	button_icon_state = "manifest_coilgun"
	shop_listed = TRUE
	shop_tier = 2
	unlock_cost = 600
	upgrade_costs = list(500, 900)
	upgrade_descriptions = list(
		"Hits harder, cheaper shots. Holds 5, regrows every 6 seconds.",
		"Hits harder, cheaper shots. Holds 6, regrows every 4 seconds.",
	)
	grown_type = /obj/item/gun/energy/arcfiend/coilgun
	charge_name = "slug"
	recharge_sound = ARCFIEND_SOUND_COILGUN_RELOAD

/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/get_max_charges()
	return by_level(list(4, 5, 6))

/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/get_charge_time()
	return by_level(list(8 SECONDS, 6 SECONDS, 4 SECONDS))

/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/get_shot_cost()
	return by_level(list(15, 12, 9))

/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/setup_projectile(obj/projectile/projectile)
	projectile.damage = by_level(list(20, 25, 30))

/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/on_grown(mob/living/user, obj/item/grown)
	user.visible_message(span_warning("A crude gun of lumpy biometal grows out of [user]'s hand!"), span_notice("You grow a biometal coilgun."))

//////////////////////////////////////////////////////////////////////////
//------------------------------Biometal Tether-------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/arcfiend/biometal_tether
	name = "Biometal Tether"
	desc = "You fire a hook of biometal and reel yourself in to wherever it lands."
	shop_desc = "Grants you Biometal Tether, which fires a hook that pulls you to wherever it lands. It costs power with each use."
	button_icon = 'bastionstation/icons/mob/actions/arcfiend/action_biometal_tether.dmi'
	button_icon_state = "biometal_tether"
	click_to_activate = TRUE
	shows_hand = TRUE
	hand_message = "Your hand is charged. Click where you want to go, or use the power again to cancel."
	hand_icon = 'bastionstation/icons/obj/antags/arcfiend/arcfiend_tether.dmi'
	hand_icon_state = "biometal_tether"
	hand_inhand_state = "biometal_tether"
	hand_lefthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_tether_lefthand.dmi'
	hand_righthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_tether_righthand.dmi'
	cooldown_time = 6 SECONDS
	power_cost = 50
	shop_tier = 2
	unlock_cost = 450
	upgrade_costs = list(350, 700)
	upgrade_descriptions = list(
		"Reaches 8 tiles, recharges faster, and can pull light items to you.",
		"Reaches 10 tiles, faster recharging.",
	)

/datum/action/cooldown/arcfiend/biometal_tether/Activate(atom/target)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !isliving(owner) || target == owner)
		return FALSE
	var/mob/living/user = owner
	var/level = get_level()
	var/tether_range = list(6, 8, 10)[level]
	if(!can_see(user, target, tether_range))
		user.balloon_alert(user, "can't reach that!")
		return FALSE

	// Upgraded, a light item is yanked to us instead of us going to it
	var/pull_item = FALSE
	if(level >= 2 && isitem(target))
		var/obj/item/item_target = target
		pull_item = !item_target.anchored && item_target.w_class <= WEIGHT_CLASS_NORMAL && isturf(item_target.loc)

	var/turf/landing
	if(!pull_item)
		landing = get_turf(target)
		if(!isturf(target) || landing.is_blocked_turf(TRUE))
			// Solid things and people stop the hook, so we land in front of them
			landing = get_step_towards(get_turf(target), user)
		if(!landing || landing == get_turf(user) || landing.is_blocked_turf(TRUE))
			user.balloon_alert(user, "no room to land!")
			return FALSE

	if(!arcfiend.spend_power(power_cost))
		return FALSE

	playsound(user, ARCFIEND_SOUND_TETHER_FIRE, 40, TRUE)
	user.Beam(target, icon = 'bastionstation/icons/obj/antags/arcfiend/arcfiend_tether.dmi', icon_state = "biometal_tether_beam", time = 5)
	new /obj/effect/temp_visual/arcfiend_flash(get_turf(target), 'bastionstation/icons/obj/antags/arcfiend/arcfiend_tether.dmi', "biometal_tether_hook", 5, get_dir(user, target))
	new /obj/effect/temp_visual/arcfiend_flash(get_turf(user), 'bastionstation/icons/effects/arcfiend/arcfiend_tether_hook.dmi', "hook", 14, get_dir(user, target))
	user.visible_message(
		span_danger("[user] flings a crackling hook of biometal at [target] and [pull_item ? "yanks it back" : "is reeled through the air"]!"),
		span_notice("You fling a biometal hook at [target]."),
	)
	if(pull_item)
		var/atom/movable/pulled = target
		pulled.throw_at(get_turf(user), tether_range, 2, user, spin = FALSE)
	else
		user.throw_at(landing, get_dist(user, landing), 2, user, spin = FALSE)
	StartCooldown(list(6 SECONDS, 5 SECONDS, 4 SECONDS)[level])
	return TRUE

//////////////////////////////////////////////////////////////////////////
//------------------------------Lateral Laser---------------------------//
//////////////////////////////////////////////////////////////////////////
/obj/effect/projectile/tracer/arcfiend_lateral
	name = "lateral beam"
	icon = 'bastionstation/icons/effects/arcfiend/arcfiend_lateral_laser_fx.dmi'
	icon_state = "lateral_laser_beam"

/obj/effect/projectile/muzzle/arcfiend_lateral
	icon = 'bastionstation/icons/effects/arcfiend/arcfiend_lateral_laser_fx.dmi'
	icon_state = "lateral_laser_muzzle"

/// Shown at the end of the beam on every shot
/obj/effect/projectile/impact/arcfiend_lateral
	name = "ruptured nanites"
	icon = 'bastionstation/icons/effects/arcfiend/arcfiend_lateral_laser_fx.dmi'
	icon_state = "lateral_laser_rupture"

/// The flash on everything the beam passes through before the end of its range
/obj/effect/temp_visual/impact_effect/arcfiend_lateral
	icon = 'bastionstation/icons/effects/arcfiend/arcfiend_lateral_laser_fx.dmi'
	icon_state = "lateral_laser_impact"
	duration = 3

/obj/projectile/beam/laser/hitscan/arcfiend_lateral
	name = "lateral beam"
	icon = 'bastionstation/icons/effects/arcfiend/arcfiend_lateral_laser_fx.dmi'
	icon_state = "lateral_laser_projectile"
	damage = 6
	damage_type = BURN
	hitscan_light_color_override = "#ffe94d"
	tracer_type = /obj/effect/projectile/tracer/arcfiend_lateral
	muzzle_type = /obj/effect/projectile/muzzle/arcfiend_lateral
	muzzle_flash_color_override = "#ffe94d"
	impact_type = /obj/effect/projectile/impact/arcfiend_lateral
	impact_light_color_override = "#ffe94d"
	hit_prone_targets = TRUE
	ignore_range_hit_prone_targets = TRUE
	/// How far the beam reaches, in tiles. This is also the one distance it does its full damage at.
	var/travel_range = 4
	/// The damage done to everything that isn't at the very end of the beam
	var/weak_damage = 6
	/// The damage done to whatever is at exactly the end of the beam
	var/power_damage = 45

/obj/projectile/beam/laser/hitscan/arcfiend_lateral/proc/set_up(range_in_tiles, weak, strong)
	travel_range = range_in_tiles
	range = range_in_tiles
	weak_damage = weak
	power_damage = strong
	damage = weak

/obj/projectile/beam/laser/hitscan/arcfiend_lateral/proc/damage_at_distance(distance)
	if(distance > travel_range)
		return 0
	return (distance == travel_range) ? power_damage : weak_damage

/// Goes through absolutely everything, but still hurts it. The one thing it skips is the one who fired it.
/obj/projectile/beam/laser/hitscan/arcfiend_lateral/prehit_pierce(atom/target)
	if(target == firer)
		return PROJECTILE_PIERCE_PHASE
	return PROJECTILE_PIERCE_HIT

/// Every living thing in the way is hit, whatever it is doing and whatever it is wearing
/obj/projectile/beam/laser/hitscan/arcfiend_lateral/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if(isliving(target))
		if(QDELETED(target) || impacted[target.weak_reference] || target == firer)
			return FALSE
		if(!ignore_loc && loc != target.loc)
			return FALSE
		return TRUE
	return ..()

/obj/projectile/beam/laser/hitscan/arcfiend_lateral/on_hit(atom/target, blocked = 0, pierce_hit)
	var/distance = get_dist(starting, get_turf(target))
	damage = damage_at_distance(distance)
	if(distance < travel_range)
		new /obj/effect/temp_visual/impact_effect/arcfiend_lateral(get_turf(target))
	if(distance == travel_range && isliving(target))
		do_sparks(4, FALSE, target)
		target.visible_message(span_danger("The nanites in the beam rupture violently against [target]!"), span_userdanger("The superheated nanites in the beam rupture inside you!"))
	return ..()

/obj/item/ammo_casing/energy/arcfiend_lateral_beam
	projectile_type = /obj/projectile/beam/laser/hitscan/arcfiend_lateral
	fire_sound = ARCFIEND_SOUND_LASER_FIRE
	select_name = "lateral beam"
	firing_effect_type = null
	e_cost = 0
	delay = 1.2 SECONDS

/// If you can spot the reference to the gun I based this lateral laser off of, you deserve a cookie
/obj/item/gun/energy/arcfiend/lateral_laser
	name = "lateral laser"
	desc = "A thin biometal lance full of boiling nanites. Use it in hand to set the range."
	icon = 'bastionstation/icons/obj/antags/arcfiend/arcfiend_lateral_laser.dmi'
	icon_state = "lateral_laser"
	inhand_icon_state = "lateral_laser"
	lefthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_lateral_laser_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_lateral_laser_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/arcfiend_lateral_beam)
	power_type = /datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser

/obj/item/gun/energy/arcfiend/lateral_laser/attack_self(mob/living/user)
	. = ..()
	var/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/settings = get_holder_power()
	if(!settings)
		return
	settings.cycle_range(user)
	// The round that is ready was set up for the old range
	chambered = null
	recharge_newshot()

/obj/item/gun/energy/arcfiend/lateral_laser/examine(mob/user)
	. = ..()
	var/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/settings = get_holder_power()
	if(settings)
		. += span_notice("It is set to [settings.get_selected_range()] tile[settings.get_selected_range() == 1 ? "" : "s"]. The beam does [settings.get_weak_damage()] damage along the way and [settings.get_power_damage()] to whatever is at the very end of it.")

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser
	name = "Lateral Laser"
	desc = "Your nanites boil inside a thin lance of biometal, then fire out of it as a beam."
	shop_desc = "Grants you Lateral Laser, which grows a lance that fires a beam of boiling nanites through everything, including walls. The beam does little damage along its path, but the nanites burst at the range you set (4 tiles at most, use it in hand to change it) and deal heavy damage there. It is free to summon and put away, but each shot costs power and a charge. It holds 3 charges and regrows one every 10 seconds, even while put away."
	button_icon = 'bastionstation/icons/mob/actions/arcfiend/action_lateral_laser.dmi'
	button_icon_state = "lateral_laser"
	shop_listed = TRUE
	shop_tier = 2
	unlock_cost = 650
	upgrade_costs = list(500, 900)
	upgrade_descriptions = list(
		"5 tiles. 8 damage on the way, 60 at the end. Cheaper shots. Holds 4, regrows every 8 seconds.",
		"6 tiles. 10 damage on the way, 80 at the end. Cheaper shots. Holds 5, regrows every 6 seconds.",
	)
	grown_type = /obj/item/gun/energy/arcfiend/lateral_laser
	recharge_sound = ARCFIEND_SOUND_LASER_RELOAD
	/// The range the arcfiend has chosen. This lives here, so putting the gun away doesn't reset it. Null means as far as it can go.
	var/selected_range

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/get_max_charges()
	return by_level(list(3, 4, 5))

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/get_charge_time()
	return by_level(list(10 SECONDS, 8 SECONDS, 6 SECONDS))

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/get_shot_cost()
	return by_level(list(30, 25, 20))

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/setup_projectile(obj/projectile/projectile)
	var/obj/projectile/beam/laser/hitscan/arcfiend_lateral/beam = projectile
	if(istype(beam))
		beam.set_up(get_selected_range(), get_weak_damage(), get_power_damage())

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/proc/get_max_range()
	return by_level(list(4, 5, 6))

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/proc/get_selected_range()
	selected_range = clamp(selected_range || get_max_range(), 1, get_max_range())
	return selected_range

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/proc/get_weak_damage()
	return by_level(list(6, 8, 10))

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/proc/get_power_damage()
	return by_level(list(45, 60, 80))

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/proc/cycle_range(mob/user)
	selected_range = (get_selected_range() % get_max_range()) + 1
	to_chat(user, span_notice("You set the lateral laser to [selected_range] tile[selected_range == 1 ? "" : "s"]. Only what is exactly [selected_range] tile[selected_range == 1 ? "" : "s"] away takes its full damage."))
	user.balloon_alert(user, "range: [selected_range]")
	playsound(user, ARCFIEND_SOUND_LASER_MODE, 40, TRUE)

/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/on_grown(mob/living/user, obj/item/grown)
	user.visible_message(span_warning("A thin lance of glowing biometal grows out of [user]'s hand!"), span_notice("You grow a lateral laser. It is set to [get_selected_range()] tile[get_selected_range() == 1 ? "" : "s"]. Use it in your hand to change that."))

//////////////////////////////////////////////////////////////////////////
//------------------------------Galvanic Prod---------------------------//
//////////////////////////////////////////////////////////////////////////
/// Emagged defib but shaped like a big shocky stick. Right-click to stun, left-click to beat for 15 burn.
/obj/item/melee/arcfiend_prod
	name = "galvanic prod"
	desc = "A biometal prod that grew out of an arcfiend's arm. Left-click to whack, right-click to zap."
	icon = 'bastionstation/icons/obj/antags/arcfiend/arcfiend_galvanic_prod.dmi'
	icon_state = "galvanic_prod"
	inhand_icon_state = "galvanic_prod"
	lefthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_galvanic_prod_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_galvanic_prod_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_BULKY
	// A plain hit is ordinary melee, so anything that reacts to melee hits, like Electrokinetic Smash, reacts to it
	force = 15
	damtype = BURN
	hitsound = ARCFIEND_SOUND_PROD_HIT
	throwforce = 0
	light_outer_range = 2
	light_power = 1
	light_color = "#ffe94d"

/obj/item/melee/arcfiend_prod/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ARCFIEND_TRAIT)
	set_light_on(TRUE)

/obj/item/melee/arcfiend_prod/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.istate & ISTATE_SECONDARY)
		var/datum/action/cooldown/arcfiend/grown_item/shock_prod/prod_action = locate() in user.actions
		prod_action?.try_zap(target_mob, user, src)
		user.changeNext_move(CLICK_CD_MELEE)
		return TRUE
	. = ..()
	if(!.)
		do_sparks(1, FALSE, target_mob)

/datum/action/cooldown/arcfiend/grown_item/shock_prod
	name = "Galvanic Prod"
	desc = "A prod of biometal grows out of your arm, crackling with current."
	shop_desc = "Grants you Galvanic Prod, which grows a prod out of your arm. It is free to summon and put away. Left-click hits for 15 burn at no cost, while right-click zaps like an emagged defibrillator, draining stamina, knocking the target down and making them drop what they are holding. Each zap costs power and one of its 4 charges, which regrow every 40 seconds, even while put away."
	button_icon = 'bastionstation/icons/mob/actions/arcfiend/action_galvanic_prod.dmi'
	button_icon_state = "galvanic_prod"
	shop_listed = TRUE
	shop_tier = 1
	unlock_cost = 0
	upgrade_costs = list(200, 450)
	upgrade_descriptions = list(
		"Cheaper zaps. Charges come back every 30 seconds.",
		"Cheaper zaps. Charges come back every 20 seconds.",
	)
	grown_type = /obj/item/melee/arcfiend_prod
	/// The time at which the prod can zap again. This only stops zaps being spammed. This lives here and not on the prod, so putting it away doesn't reset it.
	var/prod_ready_time = 0

/datum/action/cooldown/arcfiend/grown_item/shock_prod/get_max_charges()
	return ARCFIEND_PROD_MAX_CHARGES

/datum/action/cooldown/arcfiend/grown_item/shock_prod/get_charge_time()
	return by_level(list(40 SECONDS, 30 SECONDS, 20 SECONDS))

/datum/action/cooldown/arcfiend/grown_item/shock_prod/proc/get_zap_cost()
	return by_level(list(40, 32, 25))

/datum/action/cooldown/arcfiend/grown_item/shock_prod/get_cost_text()
	return "[get_zap_cost()] power per zap. Hitting with it is free"

/datum/action/cooldown/arcfiend/grown_item/shock_prod/get_cost_label()
	return "[get_zap_cost()]"

/datum/action/cooldown/arcfiend/grown_item/shock_prod/on_charge_regained()
	update_prod_look()
	if(!get_held_item(owner))
		return
	owner.balloon_alert(owner, "prod charged ([charges]/[ARCFIEND_PROD_MAX_CHARGES])")
	playsound(owner, ARCFIEND_SOUND_PROD_RECHARGED, 30, TRUE)

/datum/action/cooldown/arcfiend/grown_item/shock_prod/proc/is_drained()
	return get_charges() < 1

/datum/action/cooldown/arcfiend/grown_item/shock_prod/proc/update_prod_look()
	var/look = is_drained() ? "galvanic_prod_drained" : "galvanic_prod"
	if(owner)
		for(var/obj/item/melee/arcfiend_prod/prod in owner.held_items)
			prod.icon_state = look
			prod.inhand_icon_state = look
		owner.update_held_items()
	build_all_button_icons(UPDATE_BUTTON_ICON)

/datum/action/cooldown/arcfiend/grown_item/shock_prod/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(QDELETED(current_button) || !button_icon || !button_icon_state)
		return
	var/shown_state = is_drained() ? "[button_icon_state]_drained" : button_icon_state
	if(current_button.icon_state == shown_state && current_button.icon == button_icon && !force)
		return
	current_button.icon = button_icon
	current_button.icon_state = shown_state

/datum/action/cooldown/arcfiend/grown_item/shock_prod/on_grown(mob/living/user, obj/item/grown)
	update_prod_look()
	user.visible_message(span_warning("A crackling prod of biometal grows out of [user]'s arm!"), span_notice("You grow a galvanic prod. Left-click to hit with it, or right-click someone to zap them."))

/// Zaps someone with the prod, using up one charge. Returns TRUE if they were zapped.
/datum/action/cooldown/arcfiend/grown_item/shock_prod/proc/try_zap(mob/living/target, mob/living/user, obj/item/melee/arcfiend_prod/prod)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !istype(target) || target == user)
		return FALSE
	if(prod_ready_time > world.time)
		return FALSE
	if(is_drained())
		user.balloon_alert(user, "no charge!")
		to_chat(user, span_warning("[prod] has no charge left. Another comes back in time."))
		return FALSE
	var/cost = get_zap_cost()
	if(!arcfiend.has_power(cost))
		user.balloon_alert(user, "need [cost] power!")
		return FALSE
	if(HAS_TRAIT(target, TRAIT_SHOCKIMMUNE))
		target.visible_message(span_warning("The electricity from [prod] washes harmlessly over [target]!"))
		return FALSE

	arcfiend.spend_power(cost)
	use_charge()
	prod_ready_time = world.time + ARCFIEND_PROD_ZAP_DELAY
	update_prod_look()
	user.balloon_alert(user, "[charges]/[ARCFIEND_PROD_MAX_CHARGES] charges left")

	// The same effect as the right-click of an emagged defibrillator
	target.visible_message(
		span_danger("[user] touches [target] with [prod]!"),
		span_userdanger("[user] touches you with [prod], and a huge jolt of electricity floods through your body!"),
	)
	target.stamina.adjust(-80)
	target.Knockdown(75)
	target.set_jitter_if_lower(100 SECONDS)
	target.apply_status_effect(/datum/status_effect/convulsing)
	playsound(user, ARCFIEND_SOUND_PROD_ZAP, 50, TRUE, -1)
	do_sparks(2, FALSE, target)
	if(target.mob_biotypes & MOB_ORGANIC)
		target.emote("gasp")
	log_combat(user, target, "zapped", prod)
	return TRUE
