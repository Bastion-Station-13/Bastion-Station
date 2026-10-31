#define TAIL_LASH_COMBO "DH"
#define ASH_IN_THE_EYES_COMBO "GH"
#define DRAKES_BITE_COMBO "HHH"
#define PIN_THE_PREY_COMBO "DDG"
#define SKIN_THE_HUNT_COMBO "GDH"
#define EMBER_BREATH_COMBO "HDH"

#define EMBER_SETTING_FAUNA "fauna"
#define EMBER_SETTING_WILDS "wilds"
#define EMBER_SETTING_STATION "station"

#define EMBER_DRAKE_ASH_AGE 3

// Setting multipliers
#define EMBER_FAUNA_DAMAGE_MULTIPLIER 2
#define EMBER_STATION_DAMAGE_MULTIPLIER 0.8
#define EMBER_STATION_STUN_MULTIPLIER 0.5
#define EMBER_MEGAFAUNA_STUN_MULTIPLIER 0.25

// Passives
#define THICK_HIDE_DAMAGE_MULTIPLIER 0.7
#define HUNTERS_GUARD_BLOCK_CHANCE 50
#define HUNTERS_GUARD_STATION_BLOCK_CHANCE 30
#define HUNTERS_GUARD_COUNTER_STUN (4 SECONDS)
#define SCALE_DEFLECTION_CHANCE 25

// Combos, before the setting multipliers
#define TAIL_LASH_FAUNA_DAMAGE 20
#define TAIL_LASH_FAUNA_STUN (2 SECONDS)
#define TAIL_LASH_STAMINA_DAMAGE 30
#define TAIL_LASH_KNOCKBACK 2
#define ASH_IN_THE_EYES_FAUNA_DURATION (4 SECONDS)
#define ASH_IN_THE_EYES_BLINDNESS (3 SECONDS)
#define ASH_IN_THE_EYES_BLUR (8 SECONDS)
#define DRAKES_BITE_DAMAGE 25
#define DRAKES_BITE_FAUNA_HEAL 10
#define PIN_THE_PREY_DURATION (4 SECONDS)
#define SKIN_THE_HUNT_DAMAGE 12
#define SKIN_THE_HUNT_HEAL 6
#define SKIN_THE_HUNT_KILL_BELOW 0.25
#define SKIN_THE_HUNT_MEGAFAUNA_KILL_BELOW 0.1
#define CINDER_SNAP_DAMAGE 12
#define CINDER_SNAP_FIRE_STACKS 2

/proc/ember_drake_age_ready(mob/living/carbon/human/learner)
	if(!istype(learner.dna?.species, /datum/species/lizard/ashwalker))
		return TRUE
	var/datum/component/ash_age/age = learner.GetComponent(/datum/component/ash_age)
	return age?.current_stage >= EMBER_DRAKE_ASH_AGE

/datum/martial_art/ember_drake
	name = "Ember Drake"
	id = MARTIALART_EMBERDRAKE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/ember_drake_help
	smashes_tables = TRUE
	display_combos = TRUE
	ignores_martial_arts_immunity = TRUE
	var/list/ember_traits = list(TRAIT_HARDLY_WOUNDED, TRAIT_HARD_SOLES, TRAIT_TENTACLE_IMMUNE)
	/// world.time of the last time a fauna went for us in melee, so the damage it deals that tick can be cut
	var/fauna_attack_time = 0

/datum/martial_art/ember_drake/teach(mob/living/holder_living, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	holder_living.add_traits(ember_traits, REF(src))
	RegisterSignal(holder_living, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(thick_hide_note_attack))
	RegisterSignal(holder_living, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(thick_hide_reduce_damage))
	RegisterSignal(holder_living, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))

/datum/martial_art/ember_drake/on_remove(mob/living/holder_living)
	UnregisterSignal(holder_living, list(COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, COMSIG_SPECIES_GAIN))
	holder_living.remove_traits(ember_traits, REF(src))
	return ..()

/datum/martial_art/ember_drake/proc/on_species_gain(mob/living/carbon/human/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	if(istype(new_species, /datum/species/lizard))
		return
	to_chat(source, span_warning("The hunts of the Ember Drake slip away. This body was never made to move like that."))
	remove(source)

/datum/martial_art/ember_drake/proc/is_fauna(mob/living/target)
	return istype(target) && (ismining(target) || ismegafauna(target))

// Setting
/datum/martial_art/ember_drake/proc/get_setting(mob/living/user, mob/living/target)
	if(is_fauna(target))
		return EMBER_SETTING_FAUNA
	var/turf/user_turf = get_turf(user)
	if(user_turf && is_mining_level(user_turf.z))
		return EMBER_SETTING_WILDS
	return EMBER_SETTING_STATION

/datum/martial_art/ember_drake/proc/scale_damage(setting, damage)
	switch(setting)
		if(EMBER_SETTING_FAUNA)
			return damage * EMBER_FAUNA_DAMAGE_MULTIPLIER
		if(EMBER_SETTING_STATION)
			return damage * EMBER_STATION_DAMAGE_MULTIPLIER
	return damage

/datum/martial_art/ember_drake/proc/scale_stun(setting, mob/living/target, duration)
	if(ismegafauna(target))
		return duration * EMBER_MEGAFAUNA_STUN_MULTIPLIER
	if(setting == EMBER_SETTING_STATION)
		return duration * EMBER_STATION_STUN_MULTIPLIER
	return duration

// Passives
/datum/martial_art/ember_drake/proc/thick_hide_note_attack(mob/living/source, mob/living/attacker)
	SIGNAL_HANDLER
	if(is_fauna(attacker))
		fauna_attack_time = world.time

/datum/martial_art/ember_drake/proc/thick_hide_reduce_damage(mob/living/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER
	if(fauna_attack_time != world.time)
		return
	fauna_attack_time = 0
	damage_mods += THICK_HIDE_DAMAGE_MULTIPLIER

/datum/martial_art/ember_drake/check_block(mob/living/user, atom/movable/hitby, damage, attack_text, attack_type, ...)
	if(!can_use(user) || !user.throw_mode || user.incapacitated(IGNORE_GRAB))
		return NONE
	if(attack_type == PROJECTILE_ATTACK)
		return scale_deflection(user, hitby)
	return hunters_guard(user, hitby, attack_text)

/datum/martial_art/ember_drake/proc/scale_deflection(mob/living/user, atom/movable/hitby)
	var/turf/user_turf = get_turf(user)
	if(!istype(hitby, /obj/projectile/kinetic) || !user_turf || !is_mining_level(user_turf.z) || !prob(SCALE_DEFLECTION_CHANCE))
		return NONE
	user.visible_message(
		span_danger("[user] deflects [hitby] off [user.p_their()] scales!"),
		span_userdanger("You deflect [hitby] off your scales!"),
	)
	return SUCCESSFUL_BLOCK

/datum/martial_art/ember_drake/proc/hunters_guard(mob/living/user, atom/movable/hitby, attack_text)
	var/mob/living/attacker = GET_ASSAILANT(hitby)
	var/setting = get_setting(user, istype(attacker) ? attacker : null)
	if(!prob(setting == EMBER_SETTING_STATION ? HUNTERS_GUARD_STATION_BLOCK_CHANCE : HUNTERS_GUARD_BLOCK_CHANCE))
		return NONE
	if(istype(attacker) && user.Adjacent(attacker))
		user.visible_message(
			span_danger("[user] blocks [attack_text] and knocks [attacker] off balance!"),
			span_userdanger("You block [attack_text]!"),
		)
		attacker.Stun(scale_stun(setting, attacker, HUNTERS_GUARD_COUNTER_STUN))
	else
		user.visible_message(
			span_danger("[user] blocks [attack_text]!"),
			span_userdanger("You block [attack_text]!"),
		)
	return SUCCESSFUL_BLOCK

// Combos
/datum/martial_art/ember_drake/harm_act(mob/living/attacker, mob/living/defender)
	add_to_streak("H", defender)
	return check_streak(attacker, defender)

/datum/martial_art/ember_drake/disarm_act(mob/living/attacker, mob/living/defender)
	add_to_streak("D", defender)
	return check_streak(attacker, defender)

/datum/martial_art/ember_drake/grab_act(mob/living/attacker, mob/living/defender)
	add_to_streak("G", defender)
	return check_streak(attacker, defender)

/// The three hit combos are checked first, since Tail Lash (D, H) is the end of both Ember Breath and Skin the Hunt
/datum/martial_art/ember_drake/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, EMBER_BREATH_COMBO))
		reset_streak()
		ember_breath(attacker, defender)
		return TRUE
	if(findtext(streak, DRAKES_BITE_COMBO))
		reset_streak()
		drakes_bite(attacker, defender)
		return TRUE
	if(findtext(streak, PIN_THE_PREY_COMBO))
		reset_streak()
		pin_the_prey(attacker, defender)
		return TRUE
	if(findtext(streak, SKIN_THE_HUNT_COMBO))
		reset_streak()
		skin_the_hunt(attacker, defender)
		return TRUE
	if(findtext(streak, TAIL_LASH_COMBO))
		reset_streak()
		tail_lash(attacker, defender)
		return TRUE
	if(findtext(streak, ASH_IN_THE_EYES_COMBO))
		reset_streak()
		ash_in_the_eyes(attacker, defender)
		return TRUE
	return FALSE

/datum/martial_art/ember_drake/proc/tail_lash(mob/living/attacker, mob/living/defender)
	log_combat(attacker, defender, "tail lashed (Ember Drake)")
	var/setting = get_setting(attacker, defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_SMASH)
	playsound(defender, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	defender.visible_message(
		span_danger("[attacker] lashes [defender] with [attacker.p_their()] tail!"),
		span_userdanger("[attacker] lashes you with [attacker.p_their()] tail!"),
	)
	if(setting == EMBER_SETTING_FAUNA)
		defender.apply_damage(scale_damage(setting, TAIL_LASH_FAUNA_DAMAGE), BRUTE)
		defender.Stun(scale_stun(setting, defender, TAIL_LASH_FAUNA_STUN))
		return
	defender.stamina?.adjust(-scale_damage(setting, TAIL_LASH_STAMINA_DAMAGE))
	defender.throw_at(get_edge_target_turf(defender, get_dir(attacker, defender)), TAIL_LASH_KNOCKBACK, 2, attacker)

// POCKET SAND!!!
/datum/martial_art/ember_drake/proc/ash_in_the_eyes(mob/living/attacker, mob/living/defender)
	log_combat(attacker, defender, "threw ash in the eyes of (Ember Drake)")
	var/setting = get_setting(attacker, defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_DISARM)
	playsound(defender, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	defender.visible_message(
		span_danger("[attacker] throws a fistful of ash into [defender]'s eyes!"),
		span_userdanger("[attacker] throws a fistful of ash into your eyes!"),
	)
	if(setting == EMBER_SETTING_FAUNA)
		defender.apply_status_effect(/datum/status_effect/ember_drake_ashed, scale_stun(setting, defender, ASH_IN_THE_EYES_FAUNA_DURATION))
		return
	defender.adjust_temp_blindness(ASH_IN_THE_EYES_BLINDNESS)
	defender.set_eye_blur_if_lower(ASH_IN_THE_EYES_BLUR)

/datum/martial_art/ember_drake/proc/drakes_bite(mob/living/attacker, mob/living/defender)
	log_combat(attacker, defender, "drake bit (Ember Drake)")
	var/setting = get_setting(attacker, defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_BITE)
	playsound(defender, 'sound/weapons/bite.ogg', 50, TRUE, -1)
	defender.visible_message(
		span_danger("[attacker] sinks [attacker.p_their()] teeth into [defender]!"),
		span_userdanger("[attacker] sinks [attacker.p_their()] teeth into you!"),
	)
	if(setting == EMBER_SETTING_FAUNA)
		defender.apply_damage(scale_damage(setting, DRAKES_BITE_DAMAGE), BRUTE)
		attacker.heal_bodypart_damage(brute = DRAKES_BITE_FAUNA_HEAL)
		return
	var/zone = attacker.zone_selected
	defender.apply_damage(scale_damage(setting, DRAKES_BITE_DAMAGE), BRUTE, zone, defender.run_armor_check(zone, MELEE))
	if(!iscarbon(defender))
		return
	var/mob/living/carbon/carbon_defender = defender
	var/obj/item/bodypart/bitten = carbon_defender.get_bodypart(zone) || carbon_defender.get_bodypart(BODY_ZONE_CHEST)
	if(bitten)
		var/datum/wound/slash/flesh/moderate/bite_wound = new
		bite_wound.apply_wound(bitten)

/datum/martial_art/ember_drake/proc/pin_the_prey(mob/living/attacker, mob/living/defender)
	log_combat(attacker, defender, "pinned (Ember Drake)")
	var/setting = get_setting(attacker, defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_SMASH)
	playsound(defender, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	if(setting == EMBER_SETTING_FAUNA)
		defender.visible_message(
			span_danger("[attacker] pins [defender] in place!"),
			span_userdanger("[attacker] pins you in place!"),
		)
		defender.Immobilize(scale_stun(setting, defender, PIN_THE_PREY_DURATION))
		return
	defender.visible_message(
		span_danger("[attacker] slams [defender] down and pins [defender.p_them()]!"),
		span_userdanger("[attacker] slams you down and pins you!"),
	)
	defender.Knockdown(scale_stun(setting, defender, PIN_THE_PREY_DURATION))
	defender.grabbedby(attacker, TRUE)
	if(attacker.pulling == defender)
		attacker.setGrabState(GRAB_AGGRESSIVE)

/datum/martial_art/ember_drake/proc/skin_the_hunt(mob/living/attacker, mob/living/defender)
	log_combat(attacker, defender, "skinned (Ember Drake)")
	var/setting = get_setting(attacker, defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
	playsound(defender, 'sound/weapons/slash.ogg', 50, TRUE, -1)
	if(setting == EMBER_SETTING_FAUNA)
		var/kill_below = ismegafauna(defender) ? SKIN_THE_HUNT_MEGAFAUNA_KILL_BELOW : SKIN_THE_HUNT_KILL_BELOW
		if(defender.stat != DEAD && defender.health <= defender.maxHealth * kill_below)
			finish_the_hunt(attacker, defender)
			return
		defender.visible_message(
			span_danger("[attacker] tears a strip of hide off [defender]!"),
			span_userdanger("[attacker] tears a strip of hide off you!"),
		)
		defender.apply_damage(scale_damage(setting, SKIN_THE_HUNT_DAMAGE), BRUTE)
		return
	defender.visible_message(
		span_danger("[attacker] tears a strip of skin off [defender]!"),
		span_userdanger("[attacker] tears a strip of skin off you!"),
	)
	var/zone = attacker.zone_selected
	defender.apply_damage(scale_damage(setting, SKIN_THE_HUNT_DAMAGE), BRUTE, zone, defender.run_armor_check(zone, MELEE))
	defender.apply_status_effect(/datum/status_effect/ember_flayed)
	attacker.heal_bodypart_damage(brute = SKIN_THE_HUNT_HEAL)

/datum/martial_art/ember_drake/proc/finish_the_hunt(mob/living/attacker, mob/living/defender)
	defender.visible_message(
		span_danger("[attacker] finishes off [defender] and skins it in one motion!"),
		span_userdanger("[attacker] finishes you off!"),
	)
	defender.adjustBruteLoss(defender.maxHealth * 2, forced = TRUE)
	if(defender.stat != DEAD)
		defender.death()
	var/turf/drop_turf = get_turf(defender)
	var/list/trophies = get_crusher_trophies(defender)
	defender.gib()
	for(var/trophy_type in trophies)
		new trophy_type(drop_turf)

/// The crusher trophies this fauna would drop for a crusher kill, without the rest of its crusher loot
/datum/martial_art/ember_drake/proc/get_crusher_trophies(mob/living/defender)
	var/crusher_loot
	if(istype(defender, /mob/living/basic/mining))
		var/mob/living/basic/mining/mining_mob = defender
		crusher_loot = mining_mob.crusher_loot
	else if(ismegafauna(defender))
		var/mob/living/simple_animal/hostile/megafauna/megafauna = defender
		crusher_loot = megafauna.crusher_loot
	. = list()
	for(var/loot_type in islist(crusher_loot) ? crusher_loot : list(crusher_loot))
		if(ispath(loot_type, /obj/item/crusher_trophy))
			. += loot_type

/datum/martial_art/ember_drake/proc/ember_breath(mob/living/attacker, mob/living/defender)
	var/datum/action/cooldown/mob_cooldown/fire_breath/ash_breath = locate() in attacker.actions
	var/datum/action/cooldown/spell/cone/staggered/fire_breath/gene_breath = locate() in attacker.actions
	if(ash_breath?.IsAvailable())
		log_combat(attacker, defender, "ember breathed (Ember Drake)")
		ash_breath.Trigger(target = defender)
		return
	if(gene_breath?.IsAvailable())
		log_combat(attacker, defender, "ember breathed (Ember Drake)")
		attacker.setDir(get_dir(attacker, defender))
		gene_breath.Trigger()
		return
	cinder_snap(attacker, defender)

/datum/martial_art/ember_drake/proc/cinder_snap(mob/living/attacker, mob/living/defender)
	log_combat(attacker, defender, "cinder snapped (Ember Drake)")
	var/setting = get_setting(attacker, defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
	playsound(defender, 'sound/magic/fireball.ogg', 40, TRUE, -1)
	defender.visible_message(
		span_danger("[attacker] snaps a burst of embers into [defender]'s face!"),
		span_userdanger("[attacker] snaps a burst of embers into your face!"),
	)
	if(setting == EMBER_SETTING_FAUNA)
		defender.apply_damage(scale_damage(setting, CINDER_SNAP_DAMAGE), BRUTE)
		return
	defender.apply_damage(scale_damage(setting, CINDER_SNAP_DAMAGE), BURN, BODY_ZONE_HEAD, defender.run_armor_check(BODY_ZONE_HEAD, FIRE))
	defender.adjust_fire_stacks(CINDER_SNAP_FIRE_STACKS)
	defender.ignite_mob()

// Status effects
// Not giving this alert a sprite because it only ever applies to fauna... which are ai controlled and not player controlled.
/datum/status_effect/ember_drake_ashed
	id = "ember_drake_ashed"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 4 SECONDS
	var/mutable_appearance/ash_overlay

/datum/status_effect/ember_drake_ashed/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/ember_drake_ashed/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	owner.ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	var/mob/living/simple_animal/hostile/hostile_owner = owner
	if(istype(hostile_owner))
		hostile_owner.LoseTarget()
	var/list/owner_size = get_icon_dimensions(owner.icon)
	ash_overlay = mutable_appearance('bastionstation/icons/effects/effects.dmi', "ashed", ABOVE_MOB_LAYER)
	ash_overlay.pixel_x = (owner_size["width"] - ICON_SIZE_X) / 2
	ash_overlay.pixel_y = (owner_size["height"] - ICON_SIZE_Y) / 2
	owner.add_overlay(ash_overlay)
	return TRUE

/datum/status_effect/ember_drake_ashed/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	owner.cut_overlay(ash_overlay)

/datum/status_effect/ember_flayed
	id = "ember_flayed"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/ember_flayed
	duration = 8 SECONDS

/datum/status_effect/ember_flayed/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor = human_owner.physiology.armor.add_other_armor(/datum/armor/ember_flayed)
	return TRUE

/datum/status_effect/ember_flayed/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor = human_owner.physiology.armor.subtract_other_armor(/datum/armor/ember_flayed)

// Flay chappy, flay PBJ, flay melkuri and flay samson ritter.
/atom/movable/screen/alert/status_effect/ember_flayed
	name = "Flayed"
	desc = "A strip of your skin has been torn away. Every blow lands harder until it scabs over."
	icon = 'bastionstation/icons/hud/screen_alert.dmi'
	icon_state = "flayed_arm"

/datum/armor/ember_flayed
	melee = -15

GAME_VERB_PROC_DESC(/mob/living/carbon/human, ember_drake_help, "Recall Teachings", "Remember the hunting techniques of the Ember Drake", "Ember Drake")

	to_chat(usr, "<b><i>You close your eyes and remember the hunts of the Ember Drake...</i></b>")

	to_chat(usr, span_notice("Tail Lash</span>: Disarm Harm. Knocks people back and winds them. Hurts and stuns fauna."))
	to_chat(usr, span_notice("Ash in the Eyes</span>: Grab Harm. Blinds people. Fauna loses its target and can't attack for a few seconds."))
	to_chat(usr, span_notice("Drake's Bite</span>: Harm Harm Harm. A bite that always leaves a bleeding wound. On fauna it hits harder and heals you."))
	to_chat(usr, span_notice("Pin the Prey</span>: Disarm Disarm Grab. Knocks people down into an aggressive grab. Pins fauna in place."))
	to_chat(usr, span_notice("Skin the Hunt</span>: Grab Disarm Harm. Flays people, so melee hits them harder, and heals you a little. Finishes off badly wounded fauna and skins it on the spot."))
	to_chat(usr, span_notice("Ember Breath</span>: Harm Disarm Harm. Fires your fire breath, if you have one ready. If you don't, you snap a burst of embers at the target instead."))
	to_chat(usr, "<b><i>Your art is strongest against fauna, fair against people in the wilds, and weaker on the station.</i></b>")
	to_chat(usr, "<b><i>In throw mode you block melee attacks, and in the wilds you can deflect kinetic accelerator shots. Fauna can't bite as deep through your hide, goliath tentacles can't hold you, and your scales resist wounds.</i></b>")

#undef TAIL_LASH_COMBO
#undef ASH_IN_THE_EYES_COMBO
#undef DRAKES_BITE_COMBO
#undef PIN_THE_PREY_COMBO
#undef SKIN_THE_HUNT_COMBO
#undef EMBER_BREATH_COMBO
#undef EMBER_SETTING_FAUNA
#undef EMBER_SETTING_WILDS
#undef EMBER_SETTING_STATION
#undef EMBER_DRAKE_ASH_AGE
#undef EMBER_FAUNA_DAMAGE_MULTIPLIER
#undef EMBER_STATION_DAMAGE_MULTIPLIER
#undef EMBER_STATION_STUN_MULTIPLIER
#undef EMBER_MEGAFAUNA_STUN_MULTIPLIER
#undef THICK_HIDE_DAMAGE_MULTIPLIER
#undef HUNTERS_GUARD_BLOCK_CHANCE
#undef HUNTERS_GUARD_STATION_BLOCK_CHANCE
#undef HUNTERS_GUARD_COUNTER_STUN
#undef SCALE_DEFLECTION_CHANCE
#undef TAIL_LASH_FAUNA_DAMAGE
#undef TAIL_LASH_FAUNA_STUN
#undef TAIL_LASH_STAMINA_DAMAGE
#undef TAIL_LASH_KNOCKBACK
#undef ASH_IN_THE_EYES_FAUNA_DURATION
#undef ASH_IN_THE_EYES_BLINDNESS
#undef ASH_IN_THE_EYES_BLUR
#undef DRAKES_BITE_DAMAGE
#undef DRAKES_BITE_FAUNA_HEAL
#undef PIN_THE_PREY_DURATION
#undef SKIN_THE_HUNT_DAMAGE
#undef SKIN_THE_HUNT_HEAL
#undef SKIN_THE_HUNT_KILL_BELOW
#undef SKIN_THE_HUNT_MEGAFAUNA_KILL_BELOW
#undef CINDER_SNAP_DAMAGE
#undef CINDER_SNAP_FIRE_STACKS
