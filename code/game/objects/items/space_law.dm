/*
* SPACE LAW BOOK
* Special code for swearing in and beating people
*/
/obj/item/book/manual/wiki/security_space_law
	name = "Space Law"
	desc = "A set of Nanotrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	starting_author = "Nanotrasen"
	starting_title = "Space Law"
	page_link = "Space_law"
	attack_verb_continuous = list("prosecutes", "disciplines", "sues")
	attack_verb_simple = list("prosecute", "discipline", "sue")
	grind_results = list(/datum/reagent/cellulose = 15, /datum/reagent/the_law = 2)
	/// The law that gets beamed into the criminal's mind
	var/law = "211 Insubordination! To knowingly disobey a lawful order from a superior."
	/// Used interally, you don't want to modify
	var/cooldown_check = 0
	/// Default wait time until can stun again.
	var/cooldown = (5.2 SECONDS)

/obj/item/book/manual/wiki/security_space_law/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_JUSTICE))
		. += span_notice("Use <b>Help</b> intent to swear someone in with the oath of security.")
		. += span_notice("Use <b>Harm</b> intent to beat some sense into Security personnel. <b>Alt-Click</b> the book to change what page to beat into their mind.")

/obj/item/book/manual/wiki/security_space_law/click_alt(mob/user)
	if(!HAS_TRAIT(user, TRAIT_JUSTICE))
		return
	law = tgui_input_text(user, "What page to prime for attack?", src, law, CHAT_MESSAGE_MAX_LENGTH)

/obj/item/book/manual/wiki/security_space_law/afterattack(mob/living/carbon/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!iscarbon(target))
		return FALSE
	if(!HAS_TRAIT(user, TRAIT_JUSTICE))
		return FALSE
	if(cooldown_check > world.time)
		to_chat(user, span_danger("Skillchip is still charging!"))
	if(user.istate & ISTATE_HARM)
		discipline(target, user)
	else
		swear_in(target, user)

/obj/item/book/manual/wiki/security_space_law/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/living/thrower = throwingdatum.thrower
	if(prob(50))
		if(HAS_TRAIT(thrower, TRAIT_JUSTICE))
			var/mob/living/carbon/hit_carbon = hit_atom
			if(hit_carbon && iscarbon(hit_carbon))
				discipline(hit_carbon, thrower)
	return ..()

/obj/item/book/manual/wiki/security_space_law/proc/swear_in(mob/living/carbon/target, mob/user)
	if(!HAS_TRAIT(user, TRAIT_JUSTICE))
		return

	balloon_alert(user, "swearing-in...")
	var/obj/item/organ/internal/liver/liver = target.get_organ_slot(ORGAN_SLOT_LIVER)
	// Security and Command cannot swear on the Space Law
	if(!liver || HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM) || HAS_TRAIT(liver, TRAIT_ROYAL_METABOLISM) || HAS_TRAIT(liver, TRAIT_PRETENDER_ROYAL_METABOLISM))
		return

	var/failText = span_warning("You hesitate and retract your hand from the book! Maybe harmbatoning is not that evil?")
	to_chat(target, span_usernotice("You put your hand down on the book and start reading the Security oath..."))
	if(do_after(target, 6 SECONDS, target = user, hidden = TRUE)) // Hidden to prevent fake-sec checks
		target.say("I, [target], hereby swear by Corporate that I will honestly and effectively serve Nanotrasen and [GLOB.station_name] according to the Law.", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	if(do_after(target, 4 SECONDS, target = user))
		target.say("That I will obey the Space Law of Nanotrasen and I will execute the powers and duties of my office honestly without fear or ill-malice.", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	if(do_after(target, 4 SECONDS, target = user))
		target.say("And that I will obey all lawful orders of my higher-ups.", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	if(do_after(target, 3 SECONDS, target = user))
		target.say("So help me Corporate.", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	to_chat(target, span_notice("After finishing the oath you feel extreme hunger for justice and donuts..."))
	liver.add_traits(list(TRAIT_LAW_ENFORCEMENT_METABOLISM), SPACE_LAW_TRAIT)

/obj/item/book/manual/wiki/security_space_law/proc/discipline(mob/living/carbon/target, mob/user)
	if(!HAS_TRAIT(user, TRAIT_JUSTICE))
		return

	var/obj/item/organ/internal/liver/liver = target.get_organ_slot(ORGAN_SLOT_LIVER)
	if(HAS_TRAIT(liver, TRAIT_ROYAL_METABOLISM) && target != user)
		to_chat(user, span_warning("[target]'s authority is too powerful for you!"))
		return
	else if(HAS_TRAIT(liver, TRAIT_PRETENDER_ROYAL_METABOLISM)) // Lol
		target.visible_message(span_warning("[target] pretends to resist \the [src] hitting [target.p_their()] face."), span_warning("You uselessly pretend to resist getting hit by \the [src]!"))

	// Applying the law to Security members is painful to them
	if(HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		target.visible_message(span_danger("[target] looks extremely guilty!"), span_cultlarge(law))
		target.playsound_local(target, 'sound/items/gavel.ogg', 100, TRUE)
		law_stun(target, 1)
		to_chat(target, span_cultlarge(law))
	else
		user.visible_message(span_warning("\The [src]'s immense power has deflected back from [target] into [user]!"), span_cultlarge("WRONG JUDGEMENT"))
		target.visible_message(span_danger("[target] looks guilty!"), span_cultlarge(law))
		target.playsound_local(target, 'sound/items/gavel.ogg', 100, TRUE)
		target.playsound_local(user, 'sound/items/gavel.ogg', 100, TRUE)
		user.emote("scream")
		user.dropItemToGround(src)
		law_stun(user, 2)
		law_stun(target, 2)
	cooldown_check = world.time + cooldown
	playsound(target, SFX_PUNCH, 25, TRUE, -1)

/obj/item/book/manual/wiki/security_space_law/proc/law_stun(mob/living/carbon/target, type)
	if(!target || !iscarbon(target))
		return
	switch(type)
		if(1) // Full on paralyze and effects
			target.Paralyze(2 SECONDS)
			target.Knockdown(4 SECONDS)
			target.set_eye_blur_if_lower(12 SECONDS)
			target.set_confusion_if_lower(12 SECONDS)
			target.adjust_stutter(12 SECONDS)
			target.set_jitter_if_lower(12 SECONDS)
		if(2) // 8 seconds of confusion
			target.set_eye_blur_if_lower(8 SECONDS)
			target.set_confusion_if_lower(8 SECONDS)
			target.adjust_stutter(8 SECONDS)
			target.set_jitter_if_lower(8 SECONDS)

/obj/item/book/manual/wiki/security_space_law/burn_paper_product_attackby_check(obj/item/attacking_item, mob/living/user, bypass_clumsy)
	. = ..()
	// The skillchip prohibits you from disrepecting the law
	if(HAS_TRAIT(user, TRAIT_JUSTICE))
		user.playsound_local(user, 'sound/voice/beepsky/justice.ogg', 100)
		user.Paralyze(4 SECONDS)
		to_chat(user, span_cultlarge("DO NOT DISRESPECT THE LAW"))
		lightningbolt(user)
		extinguish() // Pretend you never lit it up in the first place
		return FALSE
	if(. && (resistance_flags & ON_FIRE))
		var/obj/item/organ/internal/liver/liver = user.get_organ_slot(ORGAN_SLOT_LIVER)
		if(!HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
			return
		// FUCK THE LAW, FUCK THE DONUTS
		to_chat(user, span_warning("You no longer feel like serving the law."))
		liver.remove_traits(list(TRAIT_LAW_ENFORCEMENT_METABOLISM), SPACE_LAW_TRAIT)

/obj/item/book/manual/wiki/security_space_law/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] pretends to read [src] intently... then promptly dies of laughter!"))
	user.emote("laugh")
	return OXYLOSS
