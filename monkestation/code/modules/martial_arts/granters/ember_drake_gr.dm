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
		"Strike the beast where its hide is thinnest...",
		"Ash in the eyes blinds even a drake...",
		"Pin the prey before it can turn on you...",
		"Breathe your fire when the moment is right...",
		"I don't think this would combine with other martial arts...",
		"Hsss...",
	)

/// Ashwalkers have primitive brains and can't read, but the scroll has drawings, so lizards can follow it anyway
/obj/item/book/granter/martial/ember_drake/attack_self(mob/living/user)
	if(!islizard(user) || HAS_TRAIT(user, TRAIT_LITERATE))
		return ..()
	ADD_TRAIT(user, TRAIT_LITERATE, REF(src))
	. = ..()
	REMOVE_TRAIT(user, TRAIT_LITERATE, REF(src))

/obj/item/book/granter/martial/ember_drake/on_reading_start(mob/user)
	if(user.has_language(/datum/language/draconic, UNDERSTOOD_LANGUAGE))
		return ..()
	to_chat(user, span_notice("You can't read a word of Draconic, but you don't need to. Your body follows the drawings of the hunt on its own."))

/obj/item/book/granter/martial/ember_drake/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/ember_drake/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "scorched scroll"
		desc = "A scroll of scorched hide. Whatever was drawn on it has flaked away to ash."
		icon_state = "emberscroll_blank"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)

/obj/item/book/granter/martial/ember_drake/can_learn(mob/user)
	if(!islizard(user))
		if(user.has_language(/datum/language/draconic, UNDERSTOOD_LANGUAGE))
			to_chat(user, span_warning("You can read Draconic just fine. The movements are the problem: half of them need a tail, and the rest need scales."))
		else
			to_chat(user, span_warning("The markings are draconic, and they mean nothing to you."))
		return FALSE
	if(!ember_drake_age_ready(user))
		to_chat(user, span_warning("The movements blur before your eyes. Your body is too young for this. Age further before you return to it."))
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
