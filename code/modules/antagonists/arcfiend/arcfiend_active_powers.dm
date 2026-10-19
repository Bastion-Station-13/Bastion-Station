/// Trait source for what Overdrive Sprint gives, so it can be taken away without touching anything else
#define ARCFIEND_OVERDRIVE_TRAIT "arcfiend_overdrive"

//////////////////////////////////////////////////////////////////////////
//------------------------------Toggled powers--------------------------//
//////////////////////////////////////////////////////////////////////////
/**
 * A power that is switched on and off, and drains power every second while it is on.
 * Switching it off is always possible. It switches itself off when the power runs out.
 */
/datum/action/cooldown/arcfiend/toggle
	shop_listed = FALSE
	cooldown_time = 1 SECONDS
	/// The least power we need to have to switch this on
	var/minimum_power_to_start = 20
	/// Whether we are on
	var/active = FALSE
	/// Timer that drains power each second while we are on
	var/upkeep_timer
	/// The sprites that show this is on, if it has them: the icon file and the base state. Each needs a "_on" and "_off" version too, which play once.
	var/effect_icon
	var/effect_state
	/// How long the "_on" and "_off" sprites play for, in ticks
	var/effect_on_time = 0
	var/effect_off_time = 0
	/// The timer that switches from the "_on" sprite to the looping one
	var/effect_timer

/// How much power this costs every second while on. Override this.
/datum/action/cooldown/arcfiend/toggle/proc/get_upkeep()
	return 1

/// Applies our effects to the owner. Override this.
/datum/action/cooldown/arcfiend/toggle/proc/apply_effect(mob/living/user)
	return

/// Removes everything apply_effect did. Override this.
/datum/action/cooldown/arcfiend/toggle/proc/remove_effect(mob/living/user)
	return

/// What everyone nearby sees when this is switched on, if anything. Override this.
/datum/action/cooldown/arcfiend/toggle/proc/get_on_message(mob/living/user)
	return null

/// What everyone nearby sees when this is switched off, if anything. Override this.
/datum/action/cooldown/arcfiend/toggle/proc/get_off_message(mob/living/user)
	return null

/// Shows that the user is charged up: this power's own sprites if it has them, otherwise a faint pulsing yellow glow
/datum/action/cooldown/arcfiend/toggle/proc/add_glow(mob/living/user, glow_name)
	if(effect_icon)
		add_visual(user, "body", effect_icon, "[effect_state]_on", effect_on_time)
		if(effect_timer)
			deltimer(effect_timer)
		effect_timer = addtimer(CALLBACK(src, PROC_REF(loop_body_effect), user), effect_on_time, TIMER_STOPPABLE)
		return
	user.add_filter(glow_name, 2, list("type" = "outline", "color" = "#ffe94d", "alpha" = 30, "size" = 1))
	var/filter = user.get_filter(glow_name)
	animate(filter, alpha = 120, time = 0.6 SECONDS, loop = -1)
	animate(alpha = 30, time = 0.6 SECONDS)

/// Once the "_on" sprite has played, the looping one takes over for as long as this stays on
/datum/action/cooldown/arcfiend/toggle/proc/loop_body_effect(mob/living/user)
	effect_timer = null
	if(active)
		add_visual(user, "body", effect_icon, effect_state)

/datum/action/cooldown/arcfiend/toggle/proc/remove_glow(mob/living/user, glow_name)
	if(effect_icon)
		if(effect_timer)
			deltimer(effect_timer)
			effect_timer = null
		// The "_off" sprite plays once and then takes itself off
		add_visual(user, "body", effect_icon, "[effect_state]_off", effect_off_time)
		return
	var/filter = user.get_filter(glow_name)
	if(filter)
		animate(filter)
		user.remove_filter(glow_name)

/datum/action/cooldown/arcfiend/toggle/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return active

/// A toggle that is on shows its "_on" icon, if its icon file has one. A power with no sprite of its own yet keeps its placeholder.
/datum/action/cooldown/arcfiend/toggle/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(QDELETED(current_button) || !button_icon || !button_icon_state)
		return
	var/shown_state = button_icon_state
	if(active && (("[button_icon_state]_on") in icon_states(button_icon)))
		shown_state = "[button_icon_state]_on"
	if(current_button.icon_state == shown_state && current_button.icon == button_icon && !force)
		return
	current_button.icon = button_icon
	current_button.icon_state = shown_state

/datum/action/cooldown/arcfiend/toggle/Activate(atom/target)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !isliving(owner))
		return FALSE
	if(active)
		switch_off()
		StartCooldown()
		return TRUE
	if(!arcfiend.has_power(minimum_power_to_start))
		owner.balloon_alert(owner, "not enough power!")
		to_chat(owner, span_warning("You need at least [minimum_power_to_start] power to switch on [name]."))
		return FALSE
	switch_on()
	StartCooldown()
	return TRUE

/datum/action/cooldown/arcfiend/toggle/proc/switch_on()
	active = TRUE
	owner.balloon_alert(owner, "[name] on")
	to_chat(owner, span_notice("You switch on [name]. It drains [get_upkeep()] power every second."))
	var/on_message = get_on_message(owner)
	if(on_message)
		owner.visible_message(span_warning(on_message), ignored_mobs = list(owner))
	do_sparks(2, FALSE, owner)
	playsound(owner, ARCFIEND_SOUND_TOGGLE_ON, 30, TRUE)
	apply_effect(owner)
	upkeep_timer = addtimer(CALLBACK(src, PROC_REF(upkeep_tick)), 1 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)
	build_all_button_icons(UPDATE_BUTTON_STATUS | UPDATE_BUTTON_ICON)

/datum/action/cooldown/arcfiend/toggle/proc/switch_off()
	active = FALSE
	deltimer(upkeep_timer)
	upkeep_timer = null
	if(owner)
		owner.balloon_alert(owner, "[name] off")
		to_chat(owner, span_notice("You switch off [name]."))
		playsound(owner, ARCFIEND_SOUND_TOGGLE_OFF, 30, TRUE)
		var/off_message = get_off_message(owner)
		if(off_message)
			owner.visible_message(span_notice(off_message), ignored_mobs = list(owner))
		remove_effect(owner)
	build_all_button_icons(UPDATE_BUTTON_STATUS | UPDATE_BUTTON_ICON)

/datum/action/cooldown/arcfiend/toggle/proc/upkeep_tick()
	if(!active)
		return
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!owner || owner.stat == DEAD || !arcfiend)
		switch_off()
		return
	if(!arcfiend.spend_power(get_upkeep()))
		to_chat(owner, span_warning("You run out of power and [name] shuts off."))
		switch_off()

/datum/action/cooldown/arcfiend/toggle/on_upgraded()
	if(active && owner)
		remove_effect(owner)
		apply_effect(owner)

/datum/action/cooldown/arcfiend/toggle/Remove(mob/remove_from)
	if(active)
		switch_off()
	return ..()

/datum/action/cooldown/arcfiend/toggle/Destroy()
	if(upkeep_timer)
		deltimer(upkeep_timer)
		upkeep_timer = null
	if(effect_timer)
		deltimer(effect_timer)
		effect_timer = null
	return ..()

//////////////////////////////////////////////////////////////////////////
//----------------------------Overdrive Sprint--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/movespeed_modifier/arcfiend_overdrive
	variable = TRUE

/datum/action/cooldown/arcfiend/toggle/overdrive_sprint
	name = "Overdrive Sprint"
	desc = "Current surges through your legs, letting you run far faster and ignore wet floors. Drains power every second."
	shop_desc = "Grants you Overdrive Sprint, a toggle that lets you run much faster and ignore slipping on wet floors. Drains power every second while active."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_overdrive_sprint.dmi'
	button_icon_state = "overdrive_sprint"
	shop_listed = TRUE
	shop_tier = 1
	unlock_cost = 250
	upgrade_costs = list(250, 500)
	upgrade_descriptions = list(
		"Faster and cheaper to run.",
		"Faster still, cheaper still.",
	)
	effect_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_overdrive.dmi'
	effect_state = "overdrive_legs"
	effect_on_time = 7
	effect_off_time = 9

/datum/action/cooldown/arcfiend/toggle/overdrive_sprint/get_upkeep()
	return by_level(list(3, 2.5, 2))

/datum/action/cooldown/arcfiend/toggle/overdrive_sprint/apply_effect(mob/living/user)
	var/speed_bonus = by_level(list(0.35, 0.5, 0.65))
	user.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/arcfiend_overdrive, multiplicative_slowdown = -speed_bonus)
	ADD_TRAIT(user, TRAIT_NO_SLIP_ALL, ARCFIEND_OVERDRIVE_TRAIT)
	add_glow(user, "arcfiend_overdrive_glow")
	add_visual(user, "activate", effect_icon, "overdrive_activate", 6)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_overdrive_move))

/datum/action/cooldown/arcfiend/toggle/overdrive_sprint/remove_effect(mob/living/user)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/arcfiend_overdrive)
	REMOVE_TRAIT(user, TRAIT_NO_SLIP_ALL, ARCFIEND_OVERDRIVE_TRAIT)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	remove_glow(user, "arcfiend_overdrive_glow")

/// Leaves a trail of sparks on the tile they just left
/datum/action/cooldown/arcfiend/toggle/overdrive_sprint/proc/on_overdrive_move(mob/living/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(isturf(old_loc) && movement_dir)
		new /obj/effect/temp_visual/arcfiend_flash(old_loc, effect_icon, "overdrive_trail", 9, movement_dir)

/datum/action/cooldown/arcfiend/toggle/overdrive_sprint/get_on_message(mob/living/user)
	return "[user] crackles with energy, sparks trailing behind [user.p_them()]!"

/datum/action/cooldown/arcfiend/toggle/overdrive_sprint/get_off_message(mob/living/user)
	return "The energy around [user] dies down."

//////////////////////////////////////////////////////////////////////////
//-----------------------------Brain Scramble---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/arcfiend/brain_scramble
	name = "Brain Scramble"
	desc = "Send a surge through a target's skull, scrambling their mind."
	shop_desc = "Grants you Brain Scramble, a touch power that burns the target, drains their stamina and damages their brain. For 8 seconds they are confused, dizzy, slurring and clumsy."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_brain_scramble.dmi'
	button_icon_state = "brain_scramble"
	click_to_activate = TRUE
	needs_mob_target = TRUE
	shows_hand = TRUE
	hand_message = "Your hand is charged. Touch someone next to you, or use the power again to cancel."
	cooldown_time = 12 SECONDS
	power_cost = 40
	shop_tier = 1
	unlock_cost = 250
	upgrade_costs = list(200, 450)
	upgrade_descriptions = list(
		"Lasts 12 seconds, hurts a bit more.",
		"Lasts 16 seconds, hurts a bit more.",
	)

/datum/action/cooldown/arcfiend/brain_scramble/Activate(atom/target)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !isliving(target) || target == owner)
		return FALSE
	if(!owner.Adjacent(target))
		owner.balloon_alert(owner, "too far away!")
		return FALSE
	if(!arcfiend.spend_power(power_cost))
		return FALSE
	var/mob/living/victim = target
	var/duration = by_level(list(8 SECONDS, 12 SECONDS, 16 SECONDS))
	victim.adjust_confusion(duration)
	victim.adjust_slurring(duration)
	victim.set_dizzy_if_lower(duration)
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, by_level(list(10, 15, 20)))
	victim.apply_status_effect(/datum/status_effect/arcfiend_scrambled, duration)
	if(!HAS_TRAIT(victim, TRAIT_SHOCKIMMUNE))
		var/level = get_level()
		victim.apply_damage(list(3, 4, 5)[level], BURN)
		victim.apply_damage(list(40, 50, 60)[level], STAMINA)
	if(victim.client)
		shake_camera(victim, duration, 3)
	do_sparks(2, FALSE, victim)
	playsound(victim, ARCFIEND_SOUND_BRAIN_SCRAMBLE, 60, TRUE)
	owner.visible_message(
		span_danger("[owner] touches [victim], and [victim.p_their()] whole body jolts with static!"),
		span_notice("You scramble [victim]'s nerves."),
	)
	to_chat(victim, span_userdanger("Static roars through your head and you can't think straight!"))
	StartCooldown()
	return TRUE

/// What a scrambled brain does to someone: they are clumsy for as long as it lasts. Scrambling them again starts the time over.
/datum/status_effect/arcfiend_scrambled
	id = "arcfiend_scrambled"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 8 SECONDS

/datum/status_effect/arcfiend_scrambled/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/arcfiend_scrambled/on_apply()
	ADD_TRAIT(owner, TRAIT_CLUMSY, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/arcfiend_scrambled/on_remove()
	REMOVE_TRAIT(owner, TRAIT_CLUMSY, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/arcfiend_scrambled/refresh(effect, set_duration)
	if(isnum(set_duration))
		duration = world.time + set_duration

//////////////////////////////////////////////////////////////////////////
//-----------------------------Arc Discharge----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/arcfiend/arc_discharge
	name = "Arc Discharge"
	desc = "Hurl a bolt of lightning from your hand at a target."
	shop_desc = "Grants you Arc Discharge, a ranged power that fires a bolt of lightning at a target you can see. It burns them, drains their stamina and briefly blinds them, then jumps to anyone standing near them. Shock immune targets are unaffected."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_arc_discharge.dmi'
	button_icon_state = "arc_discharge"
	click_to_activate = TRUE
	needs_mob_target = TRUE
	shows_hand = TRUE
	hand_message = "Your hand is charged. Click someone you can see to fire, or use the power again to cancel."
	cooldown_time = 8 SECONDS
	power_cost = 60
	shop_tier = 1
	unlock_cost = 300
	upgrade_costs = list(300, 600)
	upgrade_descriptions = list(
		"Hits harder, jumps to a second target.",
		"Hits harder, jumps to a third target.",
	)
	/// How far away we can fire
	var/bolt_range = 7
	/// How far each arc can jump to a new target
	var/chain_range = 3

/datum/action/cooldown/arcfiend/arc_discharge/Activate(atom/target)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !isliving(target) || target == owner)
		return FALSE
	if(!can_see(owner, target, bolt_range))
		owner.balloon_alert(owner, "can't reach that!")
		return FALSE
	if(!arcfiend.spend_power(power_cost))
		return FALSE

	var/level = get_level()
	var/damage = list(15, 20, 25)[level]
	var/arcs_left = level
	var/mob/living/victim = isliving(target) ? target : locate(/mob/living) in get_turf(target)
	if(victim == owner)
		victim = null

	playsound(owner, ARCFIEND_SOUND_ARC_DISCHARGE, 50, TRUE)
	owner.Beam(victim || target, icon_state = "lightning[rand(1, 12)]", time = 5)
	owner.visible_message(
		span_danger("[owner] flings a bolt of lightning at [victim || target]!"),
		span_notice("You fling a bolt of lightning at [victim || target]."),
	)
	if(!victim)
		StartCooldown()
		return TRUE

	var/list/already_hit = list(owner)
	var/atom/source = owner
	while(victim)
		already_hit += victim
		zap(source, victim, damage)
		damage = round(damage * 0.6)
		source = victim
		victim = (arcs_left-- > 0) ? find_next_victim(source, already_hit) : null
		if(victim)
			source.Beam(victim, icon_state = "lightning[rand(1, 12)]", time = 5)
	StartCooldown()
	return TRUE

/// The nearest living thing the arc can jump to from this one
/datum/action/cooldown/arcfiend/arc_discharge/proc/find_next_victim(atom/source, list/already_hit)
	var/mob/living/closest
	var/closest_dist = INFINITY
	for(var/mob/living/candidate in oview(chain_range, source))
		if(candidate in already_hit)
			continue
		if(candidate.stat == DEAD || !can_see(source, candidate, chain_range))
			continue
		var/candidate_dist = get_dist(source, candidate)
		if(candidate_dist < closest_dist)
			closest = candidate
			closest_dist = candidate_dist
	return closest

/// Hits someone with the arc
/datum/action/cooldown/arcfiend/arc_discharge/proc/zap(atom/source, mob/living/victim, damage)
	if(HAS_TRAIT(victim, TRAIT_SHOCKIMMUNE))
		victim.visible_message(span_warning("The lightning washes harmlessly over [victim]!"))
		return
	victim.apply_damage(damage, BURN, spread_damage = TRUE)
	victim.apply_damage(damage, STAMINA)
	victim.adjust_temp_blindness(3 SECONDS)
	victim.flash_act(1, visual = TRUE)
	to_chat(victim, span_userdanger("A bolt of lightning slams into you!"))
	do_sparks(2, FALSE, victim)

#undef ARCFIEND_OVERDRIVE_TRAIT

//////////////////////////////////////////////////////////////////////////
//-------------------------------Thunderclap----------------------------//
//////////////////////////////////////////////////////////////////////////

/// A burst of electricity around the arcfiend after a windup. It has no hand, using the power just starts it.
/datum/action/cooldown/arcfiend/thunderclap
	name = "Thunderclap"
	desc = "Gather charge in your body, then release it all at once in a shockwave."
	shop_desc = "Grants you Thunderclap. After a charge-up that everyone nearby can see, you release a shockwave that burns, drains the stamina of and flashes everyone in range, weaker the further they are from you. Anyone within 2 tiles is also thrown back."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_thunderclap.dmi'
	button_icon_state = "thunderclap"
	cooldown_time = 30 SECONDS
	power_cost = 120
	shop_tier = 2
	unlock_cost = 550
	upgrade_costs = list(450, 850)
	upgrade_descriptions = list(
		"Throws 4 tiles, reaches 8. Hits harder, charges faster, 25 second cooldown.",
		"Throws 5 tiles, reaches 9. Hits harder, charges faster, 20 second cooldown.",
	)
	/// Whether we are in the middle of the windup, so it can't be started twice
	var/winding_up = FALSE

/// How long the windup takes
/datum/action/cooldown/arcfiend/thunderclap/proc/get_windup()
	return by_level(list(1.5 SECONDS, 1.25 SECONDS, 1 SECONDS))

/// How far people within 2 tiles are thrown
/datum/action/cooldown/arcfiend/thunderclap/proc/get_throw_distance()
	return by_level(list(3, 4, 5))

/// How far away the burn, stamina damage and flash reach
/datum/action/cooldown/arcfiend/thunderclap/proc/get_outer_range()
	return by_level(list(7, 8, 9))

/// The burn damage right next to the edge of the throwing range, before falloff
/datum/action/cooldown/arcfiend/thunderclap/proc/get_burn()
	return by_level(list(4, 5, 6))

/// The stamina damage right next to the edge of the throwing range, before falloff
/datum/action/cooldown/arcfiend/thunderclap/proc/get_stamina()
	return by_level(list(30, 40, 50))

/// How long it takes to recharge
/datum/action/cooldown/arcfiend/thunderclap/proc/get_recharge_time()
	return by_level(list(30 SECONDS, 25 SECONDS, 20 SECONDS))

/// How much of the full effect someone this many tiles away gets. It never drops to nothing within range.
/datum/action/cooldown/arcfiend/thunderclap/proc/get_falloff(distance)
	return max(1 - (distance - 1) / get_outer_range(), 0.15)

/datum/action/cooldown/arcfiend/thunderclap/Activate(atom/target)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !isliving(owner) || winding_up)
		return FALSE
	var/mob/living/user = owner
	winding_up = TRUE
	user.visible_message(
		span_danger("[user] starts glowing brighter and brighter, the air around [user.p_them()] crackling and tightening!"),
		span_notice("You gather the charge in your body. Anyone close will be thrown, and everyone nearby will feel it."),
	)
	user.balloon_alert_to_viewers("charging!")
	playsound(user, ARCFIEND_SOUND_THUNDERCLAP_WINDUP, 80, TRUE, extrarange = 8)
	add_visual(user, "charge", 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_thunderclap.dmi', "thunderclap_charge")
	// Moving doesn't interrupt it, being stunned or knocked out does
	var/finished = do_after(user, get_windup(), progress = FALSE, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_HELD_ITEM, interaction_key = "arcfiend_thunderclap")
	remove_visual("charge")
	winding_up = FALSE
	if(!finished)
		user.balloon_alert(user, "interrupted!")
		return FALSE
	if(!arcfiend.spend_power(power_cost))
		return FALSE
	burst(user)
	StartCooldown(get_recharge_time())
	return TRUE

/datum/action/cooldown/arcfiend/thunderclap/proc/burst(mob/living/user)
	new /obj/effect/temp_visual/arcfiend_thunderclap(get_turf(user), get_outer_range())
	do_sparks(6, FALSE, user)
	playsound(user, ARCFIEND_SOUND_THUNDERCLAP_BOOM, 100, TRUE, extrarange = 15)
	user.flash_lighting_fx(7, 5, "#ffe94d", 1 SECONDS)
	user.visible_message(span_danger("[user] releases a burst of electricity!"), span_notice("You release the charge."))
	// One look around for both the people and the lights it reaches
	for(var/atom/movable/nearby in view(get_outer_range(), user))
		if(isliving(nearby))
			var/mob/living/victim = nearby
			if(victim != user && victim.stat != DEAD)
				hit_victim(user, victim, get_dist(user, victim))
		else if(istype(nearby, /obj/machinery/light) && prob(50))
			INVOKE_ASYNC(nearby, TYPE_PROC_REF(/obj/machinery/light, flicker), rand(2, 4))

/// What the burst does to one person, depending on how far away they are
/datum/action/cooldown/arcfiend/thunderclap/proc/hit_victim(mob/living/user, mob/living/victim, distance)
	var/falloff = get_falloff(distance)
	new /obj/effect/temp_visual/arcfiend_flash(get_turf(victim), 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_thunderclap_struck.dmi', "thunderclap_struck", 5)
	if(!HAS_TRAIT(victim, TRAIT_SHOCKIMMUNE))
		victim.apply_damage(get_burn() * falloff, BURN)
		victim.apply_damage(get_stamina() * falloff, STAMINA)
	victim.flash_act(1, visual = TRUE, length = 2.5 SECONDS * falloff)
	if(victim.client)
		shake_camera(victim, 3, 1)
	if(distance > 2)
		to_chat(victim, span_userdanger("A burst of electricity from [user] washes over you!"))
		return
	to_chat(victim, span_userdanger("A shockwave of electricity throws you away from [user]!"))
	if(!victim.anchored)
		var/turf/away = get_edge_target_turf(victim, get_dir(user, victim) || victim.dir)
		victim.throw_at(away, get_throw_distance(), 2, user, spin = FALSE)


/// The ring of lightning that spreads out from an arcfiend when Thunderclap goes off. The sprite is 160x160 and is scaled up to the range of the burst.
/obj/effect/temp_visual/arcfiend_thunderclap
	icon = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_thunderclap_160.dmi'
	icon_state = "thunderclap_release"
	duration = 1 SECONDS // The frames add up to this
	randomdir = FALSE
	plane = ABOVE_LIGHTING_PLANE
	layer = FLY_LAYER
	// Centers the 160x160 sprite on the tile
	pixel_x = -64
	pixel_y = -64

/obj/effect/temp_visual/arcfiend_thunderclap/Initialize(mapload, outer_range = 7)
	. = ..()
	// The ring is about 150 pixels across, and should reach the edge of the burst
	var/ring_scale = (outer_range * 2 * 32) / 150
	transform = transform.Scale(ring_scale, ring_scale)

//////////////////////////////////////////////////////////////////////////
//---------------------------Electrokinetic Smash-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash
	name = "Electrokinetic Smash"
	desc = "Current runs through your fists and weapons, making every blow hit harder and shock."
	shop_desc = "Grants you Electrokinetic Smash, a toggle that makes your unarmed attacks and weapons hit harder. In combat mode, every hit also burns and can arc to people nearby. Drains power every second, and a little more with each hit."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_electrokinetic_smash.dmi'
	button_icon_state = "electrokinetic_smash"
	shop_listed = TRUE
	shop_tier = 2
	unlock_cost = 500
	upgrade_costs = list(400, 800)
	upgrade_descriptions = list(
		"Hits 30% harder, more burn, arcs more often.",
		"Hits 40% harder, more burn, arcs can reach two others.",
	)
	effect_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_electrokinetic_smash.dmi'
	effect_state = "smash_arms"
	effect_on_time = 7
	effect_off_time = 9
	/// Power each hit costs, on top of the upkeep
	var/hit_cost = 8
	/// How far an arc can jump
	var/chain_range = 2
	/// The arms we have boosted, each with how much we added to its low and high punch damage, so we can take exactly that away again
	var/list/boosted_arms = list()

/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/get_upkeep()
	return 1

/// How much harder the weapons we swing and our punches hit
/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/proc/get_hit_multiplier()
	return by_level(list(1.2, 1.3, 1.4))

/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/apply_effect(mob/living/user)
	RegisterSignal(user, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_item_attack))
	RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	add_glow(user, "arcfiend_smash_glow")
	// Punch damage is rolled from the damage range of the arm doing the punching, so that is what gets boosted
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		for(var/obj/item/bodypart/arm/arm in carbon_user.bodyparts)
			var/low_bonus = round(arm.unarmed_damage_low * (get_hit_multiplier() - 1), 1)
			var/high_bonus = round(arm.unarmed_damage_high * (get_hit_multiplier() - 1), 1)
			arm.unarmed_damage_low += low_bonus
			arm.unarmed_damage_high += high_bonus
			boosted_arms[arm] = list(low_bonus, high_bonus)

/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/remove_effect(mob/living/user)
	UnregisterSignal(user, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_HUMAN_MELEE_UNARMED_ATTACK))
	remove_glow(user, "arcfiend_smash_glow")
	for(var/obj/item/bodypart/arm/arm as anything in boosted_arms)
		if(QDELETED(arm))
			continue
		arm.unarmed_damage_low -= boosted_arms[arm][1]
		arm.unarmed_damage_high -= boosted_arms[arm][2]
	boosted_arms.Cut()

/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/get_on_message(mob/living/user)
	return "[user]'s hands start crackling with electricity!"

/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/get_off_message(mob/living/user)
	return "The electricity around [user]'s hands fades."

/// Signal proc for COMSIG_MOB_ITEM_ATTACK. Returning anything here would cancel the attack, so we never do.
/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/proc/on_item_attack(mob/living/source, mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers, obj/item/weapon)
	SIGNAL_HANDLER
	if((source.istate & ISTATE_HARM) && isliving(target))
		// The weapon hits harder, on top of the burn from discharge()
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, get_hit_multiplier())
		discharge(target)
	return NONE

/// Signal proc for COMSIG_HUMAN_MELEE_UNARMED_ATTACK
/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/proc/on_unarmed_attack(mob/living/source, atom/target, proximity)
	SIGNAL_HANDLER
	if(proximity && (source.istate & ISTATE_HARM) && isliving(target))
		discharge(target)

/// Burns whoever we hit, and maybe arcs on to others
/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/proc/discharge(mob/living/victim)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || victim == owner || victim.stat == DEAD)
		return
	if(!arcfiend.spend_power(hit_cost))
		return
	new /obj/effect/temp_visual/arcfiend_flash(get_turf(victim), effect_icon, "smash_hit", 7)
	var/level = get_level()
	var/damage = list(8, 12, 16)[level]
	shock(victim, damage, "[owner]'s electrified blow shocks you!")
	if(!prob(list(25, 40, 55)[level]))
		return
	var/arcs_left = (level == 3) ? 2 : 1
	var/list/already_hit = list(owner, victim)
	var/atom/source = victim
	while(arcs_left-- > 0)
		var/list/candidates = list()
		for(var/mob/living/candidate in oview(chain_range, source))
			if(!(candidate in already_hit) && candidate.stat != DEAD)
				candidates += candidate
		if(!length(candidates))
			return
		var/mob/living/next_victim = pick(candidates)
		already_hit += next_victim
		source.Beam(next_victim, icon = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_electrokinetic_smash.dmi', icon_state = "smash_chain", time = 5)
		damage = round(damage * 0.6)
		shock(next_victim, damage, "A stray arc of electricity shocks you!")
		source = next_victim

/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/proc/shock(mob/living/victim, damage, victim_message)
	if(HAS_TRAIT(victim, TRAIT_SHOCKIMMUNE))
		return
	victim.apply_damage(damage, BURN, spread_damage = TRUE)
	do_sparks(2, FALSE, victim)
	playsound(victim, ARCFIEND_SOUND_SMASH_HIT, 40, TRUE)
	to_chat(victim, span_userdanger(victim_message))

//////////////////////////////////////////////////////////////////////////
//--------------------------Myoelectric Stimulation---------------------//
//////////////////////////////////////////////////////////////////////////
/// Makes everything done with the hands take less time
/datum/actionspeed_modifier/arcfiend_stimulation
	variable = TRUE

/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation
	name = "Myoelectric Stimulation"
	desc = "Current drives your arm muscles far past their normal limits, letting you work, attack and shoot faster."
	shop_desc = "Grants you Myoelectric Stimulation, a toggle that lets you work, attack, shoot and click faster. Drains power every second while active."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_myoelectric_stimulation.dmi'
	button_icon_state = "myoelectric_stimulation"
	shop_listed = TRUE
	shop_tier = 2
	unlock_cost = 500
	upgrade_costs = list(400, 800)
	upgrade_descriptions = list(
		"Work 35% quicker, attack 30% faster. Cheaper to run.",
		"Work 45% quicker, attack 40% faster. Cheaper still.",
	)
	effect_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_myoelectric.dmi'
	effect_state = "myoelectric_arms"
	effect_on_time = 7
	effect_off_time = 12
	/// What the click and gun delay multipliers were multiplied by when this was switched on, so we can divide it out exactly
	var/applied_speed_factor = 1

/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation/get_upkeep()
	return by_level(list(2, 1.5, 1))

/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation/apply_effect(mob/living/user)
	var/level = get_level()
	user.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/arcfiend_stimulation, multiplicative_slowdown = -list(0.25, 0.35, 0.45)[level])
	applied_speed_factor = list(0.8, 0.7, 0.6)[level]
	user.next_move_modifier *= applied_speed_factor
	user.gun_fire_delay_modifier *= applied_speed_factor
	add_glow(user, "arcfiend_stimulation_glow")

/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation/remove_effect(mob/living/user)
	user.remove_actionspeed_modifier(/datum/actionspeed_modifier/arcfiend_stimulation)
	user.next_move_modifier /= applied_speed_factor
	user.gun_fire_delay_modifier /= applied_speed_factor
	applied_speed_factor = 1
	remove_glow(user, "arcfiend_stimulation_glow")

/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation/get_on_message(mob/living/user)
	return "[user]'s arms start twitching with electricity!"

/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation/get_off_message(mob/living/user)
	return "The electricity in [user]'s arms dies down."

//////////////////////////////////////////////////////////////////////////
//------------------------------Jamming Field---------------------------//
//////////////////////////////////////////////////////////////////////////
/// The jammer an arcfiend carries inside of themselves while their jamming field is on
/obj/item/jammer/arcfiend
	name = "jamming field"
	item_flags = ABSTRACT
	range = 6

/datum/action/cooldown/arcfiend/toggle/jamming_field
	name = "Jamming Field"
	desc = "A field of electrical interference radiates from your body, killing nearby radios, PDAs and sensors."
	shop_desc = "Grants you Jamming Field, a toggle that disables radios, PDAs, GPS and suit sensors near you. You glow while it is active, making it obvious who is responsible. Drains power every second."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_jamming_field.dmi'
	button_icon_state = "jamming_field"
	shop_listed = TRUE
	shop_tier = 2
	unlock_cost = 450
	upgrade_costs = list(300, 600)
	upgrade_descriptions = list(
		"Reaches 9 tiles. Cheaper to run.",
		"Reaches 12 tiles. Cheaper still.",
	)
	/// The jammer we carry while on
	var/obj/item/jammer/arcfiend/field
	/// The aura's name
	var/aura_name = "arcfiend_jamming_aura"
	effect_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_jamming.dmi'
	effect_state = "jamming_aura"
	effect_on_time = 8
	effect_off_time = 5

/datum/action/cooldown/arcfiend/toggle/jamming_field/get_upkeep()
	return by_level(list(2, 1.5, 1))

/datum/action/cooldown/arcfiend/toggle/jamming_field/get_on_message(mob/living/user)
	return "[user] is wrapped in a pulsing field of static!"

/datum/action/cooldown/arcfiend/toggle/jamming_field/get_off_message(mob/living/user)
	return "The field of static around [user] collapses."

/datum/action/cooldown/arcfiend/toggle/jamming_field/apply_effect(mob/living/user)
	field = new(user)
	field.range = by_level(list(6, 9, 12))
	field.active = TRUE
	GLOB.active_jammers |= field
	add_glow(user, aura_name)
	user.set_light_range_power_color(3, 1.5, "#ffe94d")
	user.set_light_on(TRUE)

/datum/action/cooldown/arcfiend/toggle/jamming_field/remove_effect(mob/living/user)
	if(field)
		GLOB.active_jammers -= field
		QDEL_NULL(field)
	remove_glow(user, aura_name)
	user.set_light_on(FALSE)

//////////////////////////////////////////////////////////////////////////
//------------------------------Electric Emag---------------------------//
//////////////////////////////////////////////////////////////////////////
/// A card of crackling biometal an arcfiend grows from their hand. Using it costs power, depending on what it is used on.
/obj/item/card/emag/arcfiend
	name = "electric emag"
	desc = "A card of biometal grown out of an arcfiend's hand. It hacks whatever it touches, expending power."
	icon = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_emag.dmi'
	icon_state = "arcfiend_emag"
	inhand_icon_state = "arcfiend_emag"
	lefthand_file = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_emag_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/antagonists/arcfiend/icons/arcfiend_emag_righthand.dmi'
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON | ABSTRACT | DROPDEL
	slot_flags = NONE
	microwaveable = FALSE

/obj/item/card/emag/arcfiend/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ARCFIEND_TRAIT)
	// Being electric, this works on doors too
	type_blacklist = null

/// How much power it costs to emag this
/obj/item/card/emag/arcfiend/proc/get_emag_cost(atom/target, datum/antagonist/arcfiend/arcfiend)
	var/cost = 50
	if(issilicon(target))
		cost = 1500
	else if(istype(target, /obj/machinery/computer))
		cost = 150
	else if(istype(target, /obj/machinery/door))
		cost = 60
	else if(ismachinery(target))
		cost = 100
	else if(isobj(target))
		cost = 40
	var/level = arcfiend.get_power_level(/datum/action/cooldown/arcfiend/grown_item/electric_emag)
	return round(cost * list(1, 0.75, 0.5)[clamp(level, 1, 3)])

/obj/item/card/emag/arcfiend/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(SHOULD_SKIP_INTERACTION(interacting_with, src, user))
		return NONE
	var/datum/antagonist/arcfiend/arcfiend = user.mind?.has_antag_datum(/datum/antagonist/arcfiend)
	if(!arcfiend)
		return ..()
	var/cost = get_emag_cost(interacting_with, arcfiend)
	if(!arcfiend.has_power(cost))
		user.balloon_alert(user, "need [cost] power!")
		return ITEM_INTERACT_BLOCKING
	if(!can_emag(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	log_combat(user, interacting_with, "attempted to emag")
	if(interacting_with.emag_act(user, src))
		arcfiend.spend_power(cost)
		SSblackbox.record_feedback("tally", "atom_emagged", 1, interacting_with.type)
		return ITEM_INTERACT_SUCCESS
	return NONE

/datum/action/cooldown/arcfiend/grown_item/electric_emag
	name = "Electric Emag"
	desc = "Your nanites shape a card of biometal in your hand that hacks whatever it touches."
	shop_desc = "Grants you Electric Emag, which grows an emag in your hand. It is free to summon and put away, but every hack costs power. Doors are cheap, consoles cost more, and cyborgs cost a great deal."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_electric_emag.dmi'
	button_icon_state = "electric_emag"
	shop_listed = TRUE
	shop_tier = 2
	unlock_cost = 500
	upgrade_costs = list(400, 800)
	upgrade_descriptions = list(
		"Hacking is 25% cheaper.",
		"Hacking is 50% cheaper.",
	)
	grown_type = /obj/item/card/emag/arcfiend

/datum/action/cooldown/arcfiend/grown_item/electric_emag/on_grown(mob/living/user, obj/item/grown)
	user.visible_message(span_warning("A card of crackling biometal grows out of [user]'s hand!"), span_notice("You grow an electric emag."))

//////////////////////////////////////////////////////////////////////////
//--------------------------------EMP Burst-----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/arcfiend/emp_burst
	name = "EMP Burst"
	desc = "You discharge your stored power in a single pulse of electromagnetic interference."
	shop_desc = "Grants you EMP Burst, which converts a third of your stored power into an EMP. The more power you had, the larger the radius. You and your belongings are unaffected, but other arcfiends are not."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_emp_burst.dmi'
	button_icon_state = "emp_burst"
	cooldown_time = 30 SECONDS
	power_cost = 100
	shop_tier = 3
	unlock_cost = 900
	upgrade_costs = list(600, 1000)
	upgrade_descriptions = list(
		"Bigger pulse for the same power.",
		"Bigger still, same power.",
	)
	/// The fraction of our stored power the pulse takes
	var/power_fraction = 0.33

/datum/action/cooldown/arcfiend/emp_burst/Activate(atom/target)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !isliving(owner))
		return FALSE
	var/spent = round(arcfiend.power * power_fraction)
	if(spent < power_cost || !arcfiend.spend_power(spent))
		return FALSE
	// 120 power buys a tile of radius, and upgrades make that go further
	var/power_per_tile = 120 * (1 - 0.15 * (get_level() - 1))
	var/heavy_range = clamp(round(spent / power_per_tile), 1, 7)
	var/light_range = heavy_range + 2
	owner.visible_message(span_danger("[owner] releases a thunderous electromagnetic pulse!"), span_notice("You release an electromagnetic pulse, spending [spent] power."))
	playsound(owner, ARCFIEND_SOUND_EMP_BURST, 70, TRUE)
	// Our own pulse never hurts us, but it does hurt anyone else, including other arcfiends
	arcfiend.emitting_emp = TRUE
	empulse(get_turf(owner), heavy_range, light_range, TRUE)
	arcfiend.emitting_emp = FALSE
	StartCooldown()
	return TRUE

//////////////////////////////////////////////////////////////////////////
//----------------------------------Jolt--------------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/arcfiend/jolt
	name = "Jolt"
	desc = "Build up a lethal charge, then release it into the person you are touching."
	shop_desc = "Grants you Jolt. After a long charge-up, you shock the person you are touching. In combat mode this stops their heart and burns them badly. Otherwise it acts as a defibrillator, and can even revive the dead. If it fails you still pay the cost, but you will sense why."
	button_icon = 'monkestation/code/modules/antagonists/arcfiend/icons/action_jolt.dmi'
	button_icon_state = "jolt"
	click_to_activate = TRUE
	needs_mob_target = TRUE
	shows_hand = TRUE
	hand_message = "Your hand is charged. Click someone next to you to jolt them, or use the power again to cancel. In combat mode it stops their heart, otherwise it restarts it."
	cooldown_time = 45 SECONDS
	power_cost = 200
	shop_tier = 3
	unlock_cost = 1000
	upgrade_costs = list(700, 1200)
	upgrade_descriptions = list(
		"Faster charge and cooldown, more burn.",
		"Faster still, even more burn.",
	)

/datum/action/cooldown/arcfiend/jolt/Activate(atom/target)
	var/datum/antagonist/arcfiend/arcfiend = get_arcfiend()
	if(!arcfiend || !iscarbon(target) || target == owner)
		return FALSE
	if(!owner.Adjacent(target))
		owner.balloon_alert(owner, "too far away!")
		return FALSE
	var/mob/living/carbon/victim = target
	var/mob/living/user = owner
	var/lethal = !!(user.istate & ISTATE_HARM)
	if(lethal)
		if(HAS_TRAIT(victim, TRAIT_SHOCKIMMUNE))
			user.balloon_alert(user, "they're immune!")
			return FALSE
	else if(victim.stat != DEAD && !victim.undergoing_cardiac_arrest())
		user.balloon_alert(user, "they don't need it!")
		return FALSE
	// Anyone who is dead can be tried, whether or not there is a soul in them and whether or not it will work.
	// You only find out why it didn't after the charge is spent, as your intuition tells you.

	var/level = get_level()
	user.visible_message(
		span_danger("[user] grips [victim] as a huge charge begins to build between them!"),
		span_notice("You gather a massive charge, ready to [lethal ? "stop [victim]'s heart" : "restart [victim]'s heart"]."),
	)
	playsound(user, ARCFIEND_SOUND_JOLT_WINDUP, 60, TRUE)
	var/datum/callback/still_valid = CALLBACK(src, PROC_REF(still_valid), victim, lethal)
	if(!do_after(user, list(6 SECONDS, 5 SECONDS, 4 SECONDS)[level], victim, extra_checks = still_valid))
		user.balloon_alert(user, "interrupted!")
		return FALSE
	if(!arcfiend.spend_power(power_cost))
		return FALSE

	do_sparks(5, FALSE, victim)
	playsound(victim, lethal ? ARCFIEND_SOUND_JOLT_STOP : ARCFIEND_SOUND_JOLT_RESTART, 70, TRUE)
	user.Beam(victim, icon_state = "lightning[rand(1, 12)]", time = 5)
	if(lethal)
		stop_heart(victim, list(40, 50, 60)[level])
	else
		restart_heart(victim)
	StartCooldown(list(45 SECONDS, 35 SECONDS, 25 SECONDS)[level])
	return TRUE

/// Whether the jolt can still go ahead, checked throughout the windup
/datum/action/cooldown/arcfiend/jolt/proc/still_valid(mob/living/carbon/victim, was_lethal)
	return owner && !QDELETED(victim) && !!(owner.istate & ISTATE_HARM) == was_lethal

/datum/action/cooldown/arcfiend/jolt/proc/stop_heart(mob/living/carbon/victim, burn_damage)
	victim.apply_damage(burn_damage, BURN, spread_damage = TRUE)
	victim.set_jitter_if_lower(20 SECONDS)
	if(victim.needs_heart() && !victim.undergoing_cardiac_arrest())
		victim.set_heartattack(TRUE)
	// Another arcfiend's heart can't be stopped, so all they get is the burns
	if(HAS_TRAIT(victim, TRAIT_HEART_ATTACK_IMMUNE) && !victim.undergoing_cardiac_arrest())
		victim.visible_message(span_danger("[victim] convulses violently, but [victim.p_their()] heart keeps beating through the jolt!"), span_userdanger("A jolt of lightning tears through your chest, but your heart keeps beating!"))
		return
	victim.visible_message(span_danger("[victim] convulses violently, [victim.p_their()] heart giving out!"), span_userdanger("A jolt of lightning tears through your chest, and your heart stops!"))

/// What the arcfiend's intuition tells them about why a body can't be revived. Null means it can be.
/datum/action/cooldown/arcfiend/jolt/proc/get_failure_feeling(defib_result)
	switch(defib_result)
		if(DEFIB_FAIL_SUICIDE)
			return "You reach for their spark and find nothing to catch. They let go of it themselves, and nothing you do will pull it back."
		if(DEFIB_FAIL_HUSK)
			return "There is nothing left in this body for the current to hold on to. It is dried out, a husk, and the charge just bleeds away. It would need mending before anything could wake in it."
		if(DEFIB_FAIL_BLACKLISTED)
			return "Something has sealed them away. The current finds no way in, and you sense that it never will."
		if(DEFIB_FAIL_TISSUE_DAMAGE)
			return "The flesh is too ravaged to carry the current. It scatters through torn muscle and leaks away. Mend the worst of the damage and try again."
		if(DEFIB_FAIL_NO_HEART)
			return "You feel for a heartbeat to restart and find only emptiness where a heart should be."
		if(DEFIB_FAIL_FAILING_HEART)
			return "Their heart is too damaged to take the beat. It quivers under the current and falls still. Mend it and try again."
		if(DEFIB_FAIL_NO_BRAIN)
			return "The current runs all the way through them and finds nobody home. There is nothing in the skull that could wake."
		if(DEFIB_FAIL_FAILING_BRAIN)
			return "Their mind is too damaged to wake. You sense it flicker under the current and fade. Mend it and try again."
		if(DEFIB_FAIL_NO_INTELLIGENCE)
			return "You sense no spark of a mind left to call back. Whatever lived here is long gone."
	return null

/// Tells the arcfiend what their intuition says, as a quiet thought and not an announcement
/datum/action/cooldown/arcfiend/jolt/proc/intuit(message)
	to_chat(owner, span_notice("<i>[message]</i>"))

/// Restarts a stopped heart, or brings back the dead like a defibrillator would. The power has already been spent by now.
/datum/action/cooldown/arcfiend/jolt/proc/restart_heart(mob/living/carbon/victim)
	if(victim.stat != DEAD)
		// Alive, but in cardiac arrest
		var/obj/item/organ/internal/heart/heart = victim.get_organ_by_type(/obj/item/organ/internal/heart)
		if(heart && (heart.organ_flags & ORGAN_FAILING))
			victim.visible_message(span_warning("The jolt rolls over [victim], but [victim.p_their()] heart will not take the beat."))
			intuit(get_failure_feeling(DEFIB_FAIL_FAILING_HEART))
			return FALSE
		victim.set_heartattack(FALSE)
		victim.emote("gasp")
		victim.visible_message(span_notice("[victim] jolts and gasps as [victim.p_their()] heart starts beating again!"), span_userdanger("A jolt of lightning restarts your heart!"))
		return TRUE

	var/defib_result = victim.can_defib()
	var/failure_feeling = get_failure_feeling(defib_result)
	if(failure_feeling)
		victim.visible_message(span_warning("The jolt rolls over [victim]'s body, but nothing stirs."))
		intuit(failure_feeling)
		return FALSE

	// A body that is too damaged would just die again, so it is brought back to the edge of critical, the way a defibrillator does
	var/total_brute = victim.getBruteLoss()
	var/total_burn = victim.getFireLoss()
	var/halfway_to_death = (victim.crit_threshold + victim.dead_threshold) * 0.5
	if(victim.health > halfway_to_death)
		victim.adjustOxyLoss(victim.health - halfway_to_death, 0)
	else
		var/overall_damage = total_brute + total_burn + victim.getToxLoss() + victim.getOxyLoss()
		var/current_health = victim.health
		victim.adjustOxyLoss((current_health - halfway_to_death) * (victim.getOxyLoss() / overall_damage), 0)
		victim.adjustToxLoss((current_health - halfway_to_death) * (victim.getToxLoss() / overall_damage), 0, TRUE)
		victim.adjustFireLoss((current_health - halfway_to_death) * (total_burn / overall_damage), 0)
		victim.adjustBruteLoss((current_health - halfway_to_death) * (total_brute / overall_damage), 0)
	victim.updatehealth()

	victim.set_heartattack(FALSE)
	// Whoever used to live in there is called back if they are still around. If they aren't, the body wakes up anyway.
	if(defib_result == DEFIB_POSSIBLE)
		victim.grab_ghost()
	victim.revive()
	victim.emote("gasp")
	victim.set_jitter_if_lower(60 SECONDS)
	SEND_SIGNAL(victim, COMSIG_LIVING_MINOR_SHOCK)
	victim.visible_message(span_notice("[victim] jolts and gasps as [victim.p_their()] heart starts beating again!"), span_userdanger("A jolt of lightning restarts your heart!"))
	var/mob/living/saver = owner
	saver?.add_mood_event("saved_life", /datum/mood_event/saved_life)
	log_combat(saver, victim, "revived", "Jolt")
	if(!victim.client)
		intuit("The body breathes again, but there is nobody home behind its eyes.")
	return TRUE
