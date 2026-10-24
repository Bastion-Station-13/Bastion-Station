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
	var/fauna_hit_time = 0

/datum/martial_art/ember_drake/teach(mob/living/holder_living, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	holder_living.add_traits(ember_traits, REF(src))
	RegisterSignal(holder_living, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(on_attacked_by_animal))
	RegisterSignal(holder_living, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(on_damage_modifiers))
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

/datum/martial_art/ember_drake/proc/on_attacked_by_animal(mob/living/source, mob/living/attacker)
	SIGNAL_HANDLER
	if(isliving(attacker) && (ismining(attacker) || ismegafauna(attacker)))
		fauna_hit_time = world.time

// 30% less damage from fauna
/datum/martial_art/ember_drake/proc/on_damage_modifiers(mob/living/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER
	if(fauna_hit_time != world.time)
		return
	fauna_hit_time = 0
	damage_mods += 0.7

/datum/martial_art/ember_drake/proc/get_setting(mob/living/user, mob/living/target)
	if(istype(target) && (ismining(target) || ismegafauna(target)))
		return EMBER_SETTING_FAUNA
	var/turf/user_turf = get_turf(user)
	if(user_turf && is_mining_level(user_turf.z))
		return EMBER_SETTING_WILDS
	return EMBER_SETTING_STATION

/datum/martial_art/ember_drake/proc/scale_damage(setting, damage)
	switch(setting)
		if(EMBER_SETTING_FAUNA)
			return damage * 2
		if(EMBER_SETTING_STATION)
			return damage * 0.8
	return damage

/datum/martial_art/ember_drake/proc/scale_stun(setting, mob/living/target, duration)
	if(ismegafauna(target))
		return duration * 0.25
	if(setting == EMBER_SETTING_STATION)
		return duration * 0.5
	return duration

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
		defender.apply_damage(scale_damage(setting, 20), BRUTE)
		defender.Stun(scale_stun(setting, defender, 2 SECONDS))
		return
	defender.stamina?.adjust(-scale_damage(setting, 30))
	defender.throw_at(get_edge_target_turf(defender, get_dir(attacker, defender)), 2, 2, attacker)

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
		defender.apply_status_effect(/datum/status_effect/ember_drake_ashed, scale_stun(setting, defender, 4 SECONDS))
		return
	defender.adjust_temp_blindness(3 SECONDS)
	defender.set_eye_blur_if_lower(8 SECONDS)

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
		defender.apply_damage(scale_damage(setting, 25), BRUTE)
		attacker.heal_bodypart_damage(brute = 10)
		return
	var/zone = attacker.zone_selected
	defender.apply_damage(scale_damage(setting, 25), BRUTE, zone, defender.run_armor_check(zone, MELEE))
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
		defender.Immobilize(scale_stun(setting, defender, 4 SECONDS))
		return
	defender.visible_message(
		span_danger("[attacker] slams [defender] down and pins [defender.p_them()]!"),
		span_userdanger("[attacker] slams you down and pins you!"),
	)
	defender.Knockdown(scale_stun(setting, defender, 4 SECONDS))
	defender.grabbedby(attacker, TRUE)
	if(attacker.pulling == defender)
		attacker.setGrabState(GRAB_AGGRESSIVE)

/datum/martial_art/ember_drake/proc/skin_the_hunt(mob/living/attacker, mob/living/defender)
	log_combat(attacker, defender, "skinned (Ember Drake)")
	var/setting = get_setting(attacker, defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
	playsound(defender, 'sound/weapons/slash.ogg', 50, TRUE, -1)
	if(setting == EMBER_SETTING_FAUNA)
		var/kill_below = ismegafauna(defender) ? 0.1 : 0.25
		if(defender.stat != DEAD && defender.health <= defender.maxHealth * kill_below)
			finish_the_hunt(attacker, defender)
			return
		defender.visible_message(
			span_danger("[attacker] tears a strip of hide off [defender]!"),
			span_userdanger("[attacker] tears a strip of hide off you!"),
		)
		defender.apply_damage(scale_damage(setting, 12), BRUTE)
		return
	defender.visible_message(
		span_danger("[attacker] tears a strip of skin off [defender]!"),
		span_userdanger("[attacker] tears a strip of skin off you!"),
	)
	var/zone = attacker.zone_selected
	defender.apply_damage(scale_damage(setting, 12), BRUTE, zone, defender.run_armor_check(zone, MELEE))
	defender.apply_status_effect(/datum/status_effect/ember_flayed)
	attacker.heal_bodypart_damage(brute = 6)

/datum/martial_art/ember_drake/proc/finish_the_hunt(mob/living/attacker, mob/living/defender)
	defender.visible_message(
		span_danger("[attacker] finishes off [defender] and skins it in one motion!"),
		span_userdanger("[attacker] finishes you off!"),
	)
	defender.adjustBruteLoss(defender.maxHealth * 2, forced = TRUE)
	if(defender.stat != DEAD)
		defender.death()
	var/turf/drop_turf = get_turf(defender)
	var/trophies
	if(istype(defender, /mob/living/basic/mining))
		var/mob/living/basic/mining/mining_mob = defender
		trophies = mining_mob.crusher_loot
	else if(ismegafauna(defender))
		var/mob/living/simple_animal/hostile/megafauna/megafauna = defender
		trophies = megafauna.crusher_loot
	defender.gib()
	for(var/trophy_type in islist(trophies) ? trophies : list(trophies))
		if(ispath(trophy_type, /obj/item/crusher_trophy))
			new trophy_type(drop_turf)

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
		defender.apply_damage(scale_damage(setting, 12), BRUTE)
		return
	defender.apply_damage(scale_damage(setting, 12), BURN, BODY_ZONE_HEAD, defender.run_armor_check(BODY_ZONE_HEAD, FIRE))
	defender.adjust_fire_stacks(2)
	defender.ignite_mob()

/datum/martial_art/ember_drake/check_block(mob/living/user, atom/movable/hitby, damage, attack_text, attack_type, ...)
	if(!can_use(user) || !user.throw_mode || user.incapacitated(IGNORE_GRAB))
		return NONE
	if(attack_type == PROJECTILE_ATTACK)
		var/turf/user_turf = get_turf(user)
		if(!istype(hitby, /obj/projectile/kinetic) || !user_turf || !is_mining_level(user_turf.z) || !prob(25))
			return NONE
		user.visible_message(
			span_danger("[user] deflects [hitby] off [user.p_their()] scales!"),
			span_userdanger("You deflect [hitby] off your scales!"),
		)
		return SUCCESSFUL_BLOCK

	var/mob/living/attacker = GET_ASSAILANT(hitby)
	var/setting = get_setting(user, istype(attacker) ? attacker : null)
	if(!prob(setting == EMBER_SETTING_STATION ? 30 : 50))
		return NONE
	if(istype(attacker) && user.Adjacent(attacker))
		user.visible_message(
			span_danger("[user] blocks [attack_text] and knocks [attacker] off balance!"),
			span_userdanger("You block [attack_text]!"),
		)
		attacker.Stun(scale_stun(setting, attacker, 4 SECONDS))
	else
		user.visible_message(
			span_danger("[user] blocks [attack_text]!"),
			span_userdanger("You block [attack_text]!"),
		)
	return SUCCESSFUL_BLOCK

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
