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
	attack_speed = CLICK_CD_STUN
	/// The law that gets beamed into the criminal's mind
	var/law = "211 Insubordination! To knowingly disobey a lawful order from a superior."

/obj/item/book/manual/wiki/security_space_law/examine(mob/user)
	. = ..()
	var/obj/item/organ/internal/liver/liver = user.get_organ_slot(ORGAN_SLOT_LIVER)
	if(HAS_TRAIT(liver, TRAIT_ROYAL_METABOLISM))
		. += span_notice("Use <b>Help</b> intent to propose someone to swear on it.")
	if(HAS_TRAIT(user, TRAIT_JUSTICE))
		. += span_notice("Use <b>Harm</b> to beat sense into Security personnel. <b>Alt-Click</b> the book to change what law to beat into their mind.")

/obj/item/book/manual/wiki/security_space_law/click_alt(mob/user)
	if(!HAS_TRAIT(user, TRAIT_JUSTICE))
		return
	law = tgui_input_text(user, "What law page to prime for attack?", "Space Law", law, CHAT_MESSAGE_MAX_LENGTH)

/obj/item/book/manual/wiki/security_space_law/afterattack(mob/living/carbon/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!iscarbon(target))
		return FALSE
	if(user.istate == ISTATE_HARM)
		discipline(target, user)
	else
		swear_in(target, user)

/obj/item/book/manual/wiki/security_space_law/proc/swear_in(mob/living/carbon/target, mob/user)
	// Only Heads of Staff and Lawyers can offer a swear-in
	if(!(target.mind.assigned_role?.job_flags & JOB_HEAD_OF_STAFF) || user.job != JOB_LAWYER)
		return

	// Lawyers cannot swear on the Space Law
	if(target.job == JOB_LAWYER)
		return

	var/obj/item/organ/internal/liver/liver = target.get_organ_slot(ORGAN_SLOT_LIVER)
	// Security and Command cannot double swear on the Space Law
	if(HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM) || HAS_TRAIT(liver, TRAIT_ROYAL_METABOLISM) || HAS_TRAIT(liver, TRAIT_PRETENDER_ROYAL_METABOLISM))
		return

	var/failText = span_warning("You hesitate and retract your hand from the Space Law! Maybe harmbatoning is not that evil?")
	to_chat(target, span_notice("You put your hand down on the book and start reading the Security oath..."))
	if(do_after(target, 4 SECONDS, target = user))
		target.say("I [target] swear by the Corporate that I will honestly and effectively serve the Nanotrasen and [GLOB.station_name] according to the law", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	if(do_after(target, 3 SECONDS, target = user))
		target.say("That I will obey the Space Law of Nanotrasen and I will execute the powers and duties of my office honestly without fear or ill-malice.", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	if(do_after(target, 3 SECONDS, target = user))
		target.say("And that I will obey all lawful orders of my higher-ups.", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	if(do_after(target, 1 SECONDS, target = user))
		target.say("So help me Corporate.", forced = "Space Law")
	else
		to_chat(target, failText)
		return
	to_chat(target, span_notice("After finishing the oath you feel extreme hunger for donuts..."))
	liver.add_organ_trait(TRAIT_LAW_ENFORCEMENT_METABOLISM)

/obj/item/book/manual/wiki/security_space_law/proc/discipline(mob/living/carbon/target, mob/user)
	if(!HAS_TRAIT(user, TRAIT_JUSTICE))
		return FALSE

	var/obj/item/organ/internal/liver/liver = target.get_organ_slot(ORGAN_SLOT_LIVER)
	// Only Captain or CentCom high-ranks can beat command members
	if(HAS_TRAIT(liver, TRAIT_ROYAL_METABOLISM) && user.job != (JOB_CAPTAIN|JOB_CENTCOM_ADMIRAL|JOB_CENTCOM_COMMANDER))
		to_chat(user, span_warning("[target]'s authority is too powerful for you!"))
		return FALSE

	// Applying the law to Security members is the most painful
	if(HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		target.Paralyze(1 SECONDS)
		target.Knockdown(3 SECONDS)
		target.set_confusion_if_lower(5 SECONDS)

	target.set_eye_blur_if_lower(3 SECONDS)
	target.set_confusion_if_lower(1.5 SECONDS)
	target.playsound_local(target, 'sound/items/gavel.ogg', 100, TRUE)
	target.visible_message(span_danger("[target] looks extremely guilty!"))

	to_chat(target, span_userdanger(law))
	playsound(target, SFX_PUNCH, 25, TRUE, -1)
	return FALSE

/obj/item/book/manual/wiki/security_space_law/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] pretends to read \the [src] intently... then promptly dies of laughter!"))
	user.emote("laugh")
	return OXYLOSS
