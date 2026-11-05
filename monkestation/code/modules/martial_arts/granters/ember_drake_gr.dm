/obj/item/book/granter/martial/ember_drake
	martial = /datum/martial_art/ember_drake
	name = "hide scroll"
	martial_name = "the Ember Drake"
	desc = "A scroll of scorched hide, covered in draconic markings of hunters and their prey."
	greet = span_sciradio("You have learned the hunting art of the Ember Drake! You fight best against the beasts of the wastes. \
	Check the combos you are now able to perform using the Recall Teachings verb in the Ember Drake tab.")
	icon = 'bastionstation/icons/obj/wizard.dmi'
	icon_state = "emberscroll"
	remarks = list(
		"I must prove myself worthy of the elders of the tribe...",
		"I should pin and blind prey so my fellow tribemates can finish them off.",
		"So you CAN kill megafauna with your bare hands, but it takes a lot of skill and patience.",
		"Why do i suddenly become weaker when i leave the wastes? I don't get it.",
		"I don't think this would combine with other martial arts...",
		"This will be helpful against those invaders.",
	)

/// Ashwalkers can't read, but the scroll is mostly drawings, so lizards can follow it anyway
/obj/item/book/granter/martial/ember_drake/get_reading_checks(mob/living/user)
	if(islizard(user))
		return READING_CHECK_LIGHT
	return ..()

/obj/item/book/granter/martial/ember_drake/on_reading_start(mob/user)
	if(user.has_language(/datum/language/draconic, UNDERSTOOD_LANGUAGE))
		return ..()
	to_chat(user, span_notice("You can't understand a word of Draconic, but the drawings are easy enough to follow."))

/obj/item/book/granter/martial/ember_drake/on_reading_finished(mob/living/carbon/user)
	. = ..()
	if(uses > 0)
		return
	visible_message(span_notice("[src] crumbles into ash."))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/book/granter/martial/ember_drake/can_learn(mob/user)
	if(!islizard(user))
		if(user.has_language(/datum/language/draconic, UNDERSTOOD_LANGUAGE))
			to_chat(user, span_warning("You can read Draconic just fine. The movements are the problem: half of them need a tail, and the rest need scales."))
		else
			to_chat(user, span_warning("It's just a few sentences in draconic and crude doodles of lizards beating up animals."))
		return FALSE
	if(!ember_drake_age_ready(user))
		to_chat(user, span_warning("You try to read the scroll, but you're not old enough for this yet. Come back after you've evolved some more."))
		return FALSE
	return ..()

/datum/ash_ritual/rite_of_the_elder
	name = "Rite of the Elder"
	desc = "Passes the hunting art of the Ember Drake to the kin standing north of the rune. If nobody there is ready to learn it, the teachings are left behind on a scroll."
	required_components = list(
		"south" = /obj/item/stack/sheet/animalhide/goliath_hide,
		"east" = /obj/item/stack/sheet/sinew,
		"west" = /obj/item/organ/internal/monster_core/regenerative_core,
	)
	consumed_components = list(
		/obj/item/stack/sheet/animalhide/goliath_hide,
		/obj/item/stack/sheet/sinew,
		/obj/item/organ/internal/monster_core/regenerative_core,
	)

/datum/ash_ritual/rite_of_the_elder/ritual_success(obj/effect/ash_rune/success_rune)
	. = ..()
	for(var/mob/living/carbon/human/student in get_step(success_rune, NORTH))
		if(!can_be_taught(student))
			continue
		var/datum/martial_art/ember_drake/style = new
		if(!style.teach(student))
			continue
		to_chat(student, span_sciradio("The elders' hands guide yours through every hunt of the Ember Drake, until your body remembers on its own. \
		Check the combos you are now able to perform using the Recall Teachings verb in the Ember Drake tab."))
		student.log_message("learned the martial art Ember Drake from the Rite of the Elder", LOG_ATTACK, color = "orange")
		return
	new /obj/item/book/granter/martial/ember_drake(get_turf(success_rune))
	success_rune.balloon_alert_to_viewers("no student... the teachings are scratched onto a scroll")

/datum/ash_ritual/rite_of_the_elder/proc/can_be_taught(mob/living/carbon/human/student)
	if(student.stat == DEAD || !student.mind || !islizard(student))
		return FALSE
	if(student.mind.has_martialart(MARTIALART_EMBERDRAKE))
		return FALSE
	return ember_drake_age_ready(student)
