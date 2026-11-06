#define BAB_HAYMAKER "HH"
#define BAB_GUTCHECK "HD"
#define BAB_SKULLCRACK "GH"
#define BAB_EYEGOUGE "GD"
#define BAB_STRIPSHOVE "DD"
#define COOLDOWN_STRIP_SHOVE "strip_shove"
#define STRIP_SHOVE_COOLDOWN (10 SECONDS)

/datum/martial_art/back_alley_brawling
	name = "Back Alley Brawling"
	id = MARTIALART_BACKALLEY
	help_verb = /mob/living/proc/back_alley_help
	display_combos = TRUE

/datum/martial_art/back_alley_brawling/teach(mob/living/holder_living, make_temporary = FALSE)
	. = ..()
	if(.)
		to_chat(holder_living, span_userdanger("You know the arts of [name]!"))
		to_chat(holder_living, span_danger("Use Remember The Basics in the [name] tab to see what you can do."))

/datum/martial_art/back_alley_brawling/on_remove(mob/living/holder_living)
	to_chat(holder_living, span_userdanger("You suddenly forget the arts of [name]..."))
	return ..()

/datum/martial_art/back_alley_brawling/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	// Only the last two inputs count, so a stale input can't finish a combo later on.
	switch(copytext(streak, -2))
		if(BAB_HAYMAKER)
			reset_streak()
			return haymaker(attacker, defender)
		if(BAB_GUTCHECK)
			reset_streak()
			return gut_check(attacker, defender)
		if(BAB_SKULLCRACK)
			reset_streak()
			return skull_crack(attacker, defender)
		if(BAB_EYEGOUGE)
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				return FALSE
			reset_streak()
			return eye_gouge(attacker, defender)
		if(BAB_STRIPSHOVE)
			if(!strip_shove(attacker, defender))
				return FALSE
			reset_streak()
			return TRUE
	return FALSE

/// Marks the victim for a Wombo Combo, if a brother landed the combo and the victim isn't on cooldown.
/datum/martial_art/back_alley_brawling/proc/mark_for_wombo(mob/living/attacker, mob/living/defender)
	var/datum/antagonist/brother/bond = attacker.mind?.has_antag_datum(/datum/antagonist/brother)
	if(isnull(bond) || defender.has_status_effect(/datum/status_effect/wombo_cooldown))
		return
	defender.apply_status_effect(/datum/status_effect/wombo_mark, bond.get_team(), attacker)

/datum/martial_art/back_alley_brawling/proc/haymaker(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(span_danger("[attacker] winds up and lands a massive haymaker on [defender]!"), \
					span_userdanger("[attacker] lands a massive haymaker on you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You wind up and land a massive haymaker on [defender]!"))
	playsound(get_turf(defender), 'sound/items/weapons/cqchit2.ogg', 50, TRUE, -1)
	defender.apply_damage(20, BRUTE, attacker.zone_selected, wound_bonus = 10)
	log_combat(attacker, defender, "haymakered (Back Alley Brawling)")
	mark_for_wombo(attacker, defender)
	return TRUE

/datum/martial_art/back_alley_brawling/proc/gut_check(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(span_danger("[attacker] drives a fist into [defender]'s gut!"), \
					span_userdanger("[attacker] drives a fist into your gut, knocking the wind out of you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You drive a fist into [defender]'s gut!"))
	playsound(get_turf(defender), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	defender.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
	defender.stamina.adjust(-40)
	log_combat(attacker, defender, "gut checked (Back Alley Brawling)")
	mark_for_wombo(attacker, defender)
	return TRUE

/datum/martial_art/back_alley_brawling/proc/skull_crack(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(span_danger("[attacker] smashes [defender]'s head with a plated fist!"), \
					span_userdanger("[attacker] smashes your head with a plated fist!"), span_hear("You hear a sickening crack!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You smash [defender]'s head with your plated fist!"))
	playsound(get_turf(defender), 'sound/effects/wounds/crack1.ogg', 50, TRUE, -1)
	defender.apply_damage(25, BRUTE, BODY_ZONE_HEAD, wound_bonus = 15)
	defender.Knockdown(3 SECONDS)
	log_combat(attacker, defender, "skull cracked (Back Alley Brawling)")
	mark_for_wombo(attacker, defender)
	return TRUE

/datum/martial_art/back_alley_brawling/proc/eye_gouge(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender)
	playsound(get_turf(defender), 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
	defender.apply_damage(8, BRUTE, BODY_ZONE_HEAD)
	mark_for_wombo(attacker, defender)

	var/obj/item/headgear = defender.get_item_by_slot(ITEM_SLOT_HEAD)
	if(headgear)
		if(istype(headgear, /obj/item/clothing/head/mod) || HAS_TRAIT(headgear, TRAIT_NODROP))
			defender.visible_message(span_danger("[attacker] claws uselessly at [defender]'s [headgear.name]!"), \
							span_userdanger("[attacker] claws uselessly at your [headgear.name]!"), span_hear("You hear scratching!"), COMBAT_MESSAGE_RANGE, attacker)
			to_chat(attacker, span_danger("You claw uselessly at [defender]'s [headgear.name]!"))
			log_combat(attacker, defender, "clawed at the headgear of (Back Alley Brawling)")
		else
			defender.dropItemToGround(headgear)
			defender.visible_message(span_danger("[attacker] rips [headgear] off of [defender]'s head!"), \
							span_userdanger("[attacker] rips [headgear] off of your head!"), span_hear("You hear a scuffle!"), COMBAT_MESSAGE_RANGE, attacker)
			to_chat(attacker, span_danger("You rip [headgear] off of [defender]'s head!"))
			log_combat(attacker, defender, "ripped the headgear off of (Back Alley Brawling)")
		return TRUE

	var/obj/item/glasses = defender.get_item_by_slot(ITEM_SLOT_EYES)
	if(glasses)
		defender.dropItemToGround(glasses)

	var/obj/item/organ/internal/eyes/eyes = defender.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes && eyes.damage >= eyes.high_threshold && !IS_ORGAN_UNREMOVABLE(eyes))
		eyes.Remove(defender)
		eyes.forceMove(defender.drop_location())
		defender.visible_message(span_bolddanger("[attacker] tears [defender]'s eyes right out of [defender.p_their()] skull!"), \
						span_userdanger("[attacker] tears your eyes right out of your skull!"), span_hear("You hear a horrible wet pop!"), null, attacker)
		to_chat(attacker, span_bolddanger("You tear [defender]'s eyes right out of [defender.p_their()] skull!"))
		playsound(get_turf(defender), 'sound/effects/wounds/pierce1.ogg', 50, TRUE, -1)
		defender.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		defender.emote("scream")
		log_combat(attacker, defender, "ripped the eyes out of (Back Alley Brawling)")
	else
		eyes?.apply_organ_damage(15)
		defender.visible_message(span_danger("[attacker] digs [attacker.p_their()] thumbs into [defender]'s eyes!"), \
						span_userdanger("[attacker] digs [attacker.p_their()] thumbs into your eyes!"), span_hear("You hear a wet squelch!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_danger("You dig your thumbs into [defender]'s eyes!"))
		log_combat(attacker, defender, "eye gouged (Back Alley Brawling)")
	defender.adjust_confusion(5 SECONDS)
	defender.adjust_dizzy(10 SECONDS)
	defender.adjust_eye_blur(10 SECONDS)
	return TRUE

/datum/martial_art/back_alley_brawling/grab_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker) || attacker == defender)
		return MARTIAL_ATTACK_FAIL
	add_to_streak("G", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	return MARTIAL_ATTACK_FAIL // Lets the normal grab go through

/datum/martial_art/back_alley_brawling/harm_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker) || attacker == defender)
		return MARTIAL_ATTACK_FAIL
	// This replaces the normal punch, so it never sends the signal the mark listens for.
	var/datum/status_effect/wombo_mark/mark = defender.has_status_effect(/datum/status_effect/wombo_mark)
	mark?.try_wombo(attacker)
	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	var/damage = rand(10, 15)
	if(defender.body_position == LYING_DOWN)
		damage += 5
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	var/blocked = defender.run_armor_check(affecting, MELEE)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(span_danger("[attacker] punches [defender] with a plated fist!"), \
					span_userdanger("[attacker] punches you with a plated fist!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You punch [defender] with your plated fist!"))
	playsound(get_turf(defender), 'sound/items/weapons/punch1.ogg', 50, TRUE, -1)
	defender.apply_damage(damage, BRUTE, affecting, blocked = blocked)
	log_combat(attacker, defender, "punched (Back Alley Brawling)")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/back_alley_brawling/disarm_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker) || attacker == defender)
		return MARTIAL_ATTACK_FAIL
	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	return MARTIAL_ATTACK_FAIL // Lets the normal shove go through

/// Rips the item out of the defender's hand. If there's nothing it can take, the shove stays a normal one.
/datum/martial_art/back_alley_brawling/proc/strip_shove(mob/living/attacker, mob/living/defender)
	var/obj/item/held_item = defender.get_active_held_item()
	if(!held_item || (held_item.item_flags & (ABSTRACT|HAND_ITEM|DROPDEL)))
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(attacker, COOLDOWN_STRIP_SHOVE))
		attacker.balloon_alert(attacker, "can't strip yet!")
		return FALSE
	if(!defender.temporarilyRemoveItemFromInventory(held_item))
		return FALSE
	TIMER_COOLDOWN_START(attacker, COOLDOWN_STRIP_SHOVE, STRIP_SHOVE_COOLDOWN)
	attacker.put_in_hands(held_item)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_DISARM)
	defender.visible_message(span_danger("[attacker] rips [held_item] out of [defender]'s hand!"), \
					span_userdanger("[attacker] rips [held_item] out of your hand!"), span_hear("You hear a scuffle!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You rip [held_item] out of [defender]'s hand!"))
	playsound(get_turf(defender), 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
	log_combat(attacker, defender, "strip shoved", addition = "taking [held_item] (Back Alley Brawling)")
	mark_for_wombo(attacker, defender)
	return TRUE

GAME_VERB_PROC_DESC(/mob/living, back_alley_help, "Remember The Basics", "You try to remember some of the basics of Back Alley Brawling.", "Back Alley Brawling")
	to_chat(usr, "<b><i>You try to remember some of the basics of Back Alley Brawling.</i></b>")

	to_chat(usr, "[span_notice("Plated Knuckles")]: Your punches hit harder.")
	to_chat(usr, "[span_notice("Ground and Pound")]: Extra damage to people on the floor.")
	to_chat(usr, "[span_notice("Strip Shove")]: Shove Shove. Rip the item out of their hand and into yours. Has a cooldown of 10 seconds.")
	to_chat(usr, "[span_notice("Haymaker")]: Punch Punch. A heavy blow that can break bones.")
	to_chat(usr, "[span_notice("Gut Check")]: Punch Shove. Knocks the wind out of them.")
	to_chat(usr, "[span_notice("Skull Crack")]: Grab Punch. Smash their head and drop them.")
	to_chat(usr, "[span_notice("Eye Gouge")]: Grab Shove. Blind and disorient them. Rips off hats and knocks off glasses. Keep at it and the eyes come out.")

	to_chat(usr, "<b><i>Blood brothers also get the Wombo Combo: any combo you land marks them for 30 seconds. If your brother hits them in that time, they suffer. Each victim can only be Wombo'd once every 20 seconds.</i></b>")

/// Invisible mark from a brother landing a combo. The first hit from another brother on the team consumes it for a big payoff.
/datum/status_effect/wombo_mark
	id = "wombo_mark"
	duration = 30 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// The brother team that can pay this mark off.
	var/datum/weakref/team_ref
	/// The brother who landed the combo, who can't pay off their own mark.
	var/datum/weakref/marker_ref

/datum/status_effect/wombo_mark/on_creation(mob/living/new_owner, datum/team/brother_team/team, mob/living/marker)
	team_ref = WEAKREF(team)
	marker_ref = WEAKREF(marker)
	return ..()

/datum/status_effect/wombo_mark/refresh(effect, datum/team/brother_team/team, mob/living/marker)
	. = ..()
	team_ref = WEAKREF(team)
	marker_ref = WEAKREF(marker)

/datum/status_effect/wombo_mark/on_apply()
	RegisterSignal(owner, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(on_attacked_by_item))
	RegisterSignal(owner, COMSIG_HUMAN_GOT_PUNCHED, PROC_REF(on_punched))
	return TRUE

/datum/status_effect/wombo_mark/on_remove()
	UnregisterSignal(owner, list(COMSIG_ATOM_AFTER_ATTACKEDBY, COMSIG_HUMAN_GOT_PUNCHED))

/datum/status_effect/wombo_mark/proc/on_attacked_by_item(mob/living/source, obj/item/weapon, mob/living/attacker)
	SIGNAL_HANDLER

	if(weapon.force > 0)
		try_wombo(attacker)

/datum/status_effect/wombo_mark/proc/on_punched(mob/living/source, mob/living/attacker)
	SIGNAL_HANDLER

	try_wombo(attacker)

/// Pays off the mark if this hit came from another brother on the marking team.
/datum/status_effect/wombo_mark/proc/try_wombo(mob/living/attacker)
	if(attacker == owner || attacker == marker_ref?.resolve())
		return
	var/datum/antagonist/brother/bond = attacker.mind?.has_antag_datum(/datum/antagonist/brother)
	if(isnull(bond) || bond.get_team() != team_ref?.resolve())
		return

	INVOKE_ASYNC(attacker, TYPE_PROC_REF(/atom/movable, say), "WOMBO COMBO!!", forced = "wombo combo")
	owner.visible_message(span_bolddanger("[attacker] follows up on [owner] with a brutal WOMBO COMBO!"), \
					span_userdanger("[attacker] follows up on you with a brutal WOMBO COMBO!"), span_hear("You hear a sickening crunch!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_bolddanger("You follow up on [owner] with a brutal WOMBO COMBO!"))
	playsound(get_turf(owner), 'sound/effects/hit_kick.ogg', 75, TRUE, -1)
	owner.apply_damage(25, BRUTE, attacker.zone_selected, wound_bonus = 20)
	owner.stamina.adjust(-30)
	owner.Knockdown(4 SECONDS)
	log_combat(attacker, owner, "WOMBO COMBO (Back Alley Brawling)")
	owner.apply_status_effect(/datum/status_effect/wombo_cooldown)
	qdel(src)

/// Stops a victim from being marked for another Wombo Combo for a while.
/datum/status_effect/wombo_cooldown
	id = "wombo_cooldown"
	duration = 20 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null

#undef BAB_HAYMAKER
#undef BAB_GUTCHECK
#undef BAB_SKULLCRACK
#undef BAB_EYEGOUGE
#undef BAB_STRIPSHOVE
#undef COOLDOWN_STRIP_SHOVE
#undef STRIP_SHOVE_COOLDOWN
