/obj/item/organ/internal/butt
	name = "butt"
	desc = "extremely treasured body part"
	worn_icon = 'icons/obj/worn_butts.dmi' //Wearable on the head
	icon = 'icons/obj/butts.dmi'
	icon_state = "ass"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_BUTT
	throw_speed = 1
	force = 4
	embed_type = /datum/embedding/butt
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	var/atmos_gas = "miasma=0.25;TEMP=310.15" //310.15 is body temperature
	var/cooling_down = FALSE
	var/superfart_armed = FALSE

/datum/embedding/butt
	pain_mult = 0
	jostle_pain_mult = 0
	ignore_throwspeed_threshold = TRUE
	embed_chance = 20

//ADMIN ONLY ATOMIC ASS
/obj/item/organ/internal/butt/atomic
	name = "Atomic Ass"
	desc = "A highly radioactive and unstable posterior. Anyone with this is a walking war crime."
	atmos_gas = "tritium=5;TEMP=600"
	icon_state = "atomicass"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/organ/internal/butt/atomic/proc/kaboom(mob/living/carbon/human/user)
	dyn_explosion(get_turf(user), 20, 10)
	cooling_down = FALSE

//BLUESPACE ASS
/obj/item/organ/internal/butt/bluespace
	name = "Bluespace Posterior"
	desc = "Science isn't about why, it's about why not!"
	atmos_gas = "water_vapor=0.75;TEMP=50"
	icon_state = "blueass"

//IPC ASS
/obj/item/organ/internal/butt/cyber
	name = "Flatulence Simulator"
	desc = "Designed from the ground up to create advanced humor."
	icon_state = "roboass"
	organ_flags = ORGAN_ROBOTIC
	atmos_gas = "co2=0.25;TEMP=310.15"

//CLOWN ASS
/obj/item/organ/internal/butt/clown
	name = "Clown Butt"
	desc = "A poor clown has been separated with their most funny organ."
	atmos_gas = "n2o=0.25;TEMP=310.15"
	icon_state = "clownass"

/obj/item/organ/internal/butt/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 40)

//PROSTHETIC ASS
/obj/item/organ/internal/butt/iron
	name = "The Iron Butt"
	desc = "A prosthetic replacement posterior."
	icon_state = "ironass"

//SKELETAL ASS
/obj/item/organ/internal/butt/skeletal
	name = "Skeletal Butt"
	desc = "You don't understand how this works!"
	atmos_gas = "o2=0.25;TEMP=310.15"
	icon_state =  "skeleass"

//PLASMAMAN ASS
/obj/item/organ/internal/butt/plasma
	name = "Plasmaman Butt"
	desc = "You REALLY don't understand how this works!"
	atmos_gas = "plasma=0.25;TEMP=310.15"
	icon_state = "plasmaass"

//XENOMORPH ASS
/obj/item/organ/internal/butt/xeno
	name = "Xenomorph Butt"
	desc = "Truly, the trophy of champions."
	icon_state = "xenoass"

//IMMOVABLE ASS
/obj/effect/immovablerod/butt
	name = "immovable butt"
	desc = "No, really, what the fuck is that?"
	icon = 'icons/obj/butts.dmi'
	icon_state = "ass"

/obj/effect/immovablerod/butt/Initialize(mapload)
	. = ..()
	src.SpinAnimation(5, -1)

/mob/living/carbon/human/proc/dagoth_kill_smite(obj/item/organ/internal/butt/butt, explode = TRUE)
	if(!QDELETED(butt))
		butt.cooling_down = TRUE
	var/turf/lighting_start = get_step(get_step(src, NORTH), NORTH)
	to_chat(src, span_ratvar("What a grand and intoxicating innocence. Perish."))
	lighting_start.Beam(src, icon_state = "lightning[rand(1,12)]", time = 1.5 SECONDS)
	unequip_everything()
	Paralyze(1.5 SECONDS)
	playsound(src, 'sound/effects/magic/lightningshock.ogg', vol = 50, vary = TRUE)
	playsound(src, 'sound/misc/dagothgod.ogg', vol = 80)
	electrocution_animation(1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_kill_smite), butt, explode), 1.5 SECONDS)

/mob/living/carbon/human/proc/finish_kill_smite(obj/item/organ/internal/butt/butt, explode = TRUE)
	var/turf/turf = get_turf(src)
	playsound(turf, 'sound/effects/explosion/explosion3.ogg', vol = 75, vary = TRUE)
	gib()
	if(explode)
		dyn_explosion(turf, 1, 0)
	if(!QDELETED(butt))
		butt.cooling_down = FALSE
<<<<<<< HEAD
=======

//Buttbot Production
/obj/item/organ/internal/butt/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/bodypart/arm/left/robot) || istype(attacking_item, /obj/item/bodypart/arm/right/robot))
		var/mob/living/basic/bot/buttbot/new_butt = new(get_turf(src))
		qdel(attacking_item)
		switch(src.type) //A BUTTBOT FOR EVERYONE!
			if(/obj/item/organ/internal/butt/atomic)
				new_butt.name = "Atomic Buttbot"
				new_butt.desc = "Science has gone too far."
				new_butt.icon_state = "buttbot_atomic"
			if(/obj/item/organ/internal/butt/bluespace)
				new_butt.name = "Bluespace Buttbot"
				new_butt.desc = "The peak of Nanotrasen design."
				new_butt.icon_state = "buttbot_bluespace"
			if(/obj/item/organ/internal/butt/clown)
				new_butt.name = "Bananium Buttbot"
				new_butt.desc = "Didn't you know clown asses were made out of Bananium?"
				new_butt.icon_state = "buttbot_clown"
				new_butt.AddComponent(/datum/component/slippery, 40)
			if(/obj/item/organ/internal/butt/cyber)
				new_butt.name = "Cybernetic Buttbot"
				new_butt.desc = "LAW ONE: BUTT"
				new_butt.icon_state = "buttbot_cyber"
			if(/obj/item/organ/internal/butt/iron)
				new_butt.name = "Iron Buttbot"
				new_butt.desc = "We can rebutt him, we have the technology."
				new_butt.icon_state = "buttbot_iron"
			if(/obj/item/organ/internal/butt/plasma)
				new_butt.name = "Plasma Buttbot"
				new_butt.desc = "Safer here than on it's owner."
				new_butt.icon_state = "buttbot_plasma"
			if(/obj/item/organ/internal/butt/skeletal)
				new_butt.name = "Skeletal Buttbot"
				new_butt.desc = "Rattle Me Booty!"
				new_butt.icon_state = "buttbot_skeleton"
			if(/obj/item/organ/internal/butt/xeno)
				new_butt.name = "Xenomorph Buttbot"
				new_butt.desc = "hiss!"
				new_butt.icon_state = "buttbot_xeno"

		playsound(src, pick('sound/misc/fart1.ogg', 'sound/effects/fart2.ogg', 'sound/effects/fart3.ogg', 'sound/effects/fart4.ogg'), 25 ,use_reverb = TRUE, mixer_channel = CHANNEL_PRUDE)
		qdel(src)


/mob/living/basic/bot/buttbot
	name = "\improper buttbot"
	desc = "butts"
	icon = 'icons/obj/butts.dmi'
	icon_state = "buttbot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	bot_type = BUTT_BOT
	pass_flags = PASSMOB
	var/butt_probability = 15
	var/listen_probability = 30
	COOLDOWN_DECLARE(repeat_cooldown)

/mob/living/basic/bot/buttbot/Initialize(mapload)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_SILICON_ACCESS, INNATE_TRAIT)

/mob/living/basic/bot/buttbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		visible_message(span_warning("[user] swipes a card through \the [src]'s crack!"), span_notice("You swipe a card through \the [src]'s crack."))
		listen_probability = 75
		butt_probability = 30
		bot_access_flags |= BOT_COVER_EMAGGED
		var/turf/butt = get_turf(src)
		butt.atmos_spawn_air("miasma=5;TEMP=310.15")
		playsound(src, pick('sound/misc/fart1.ogg', 'sound/effects/fart2.ogg', 'sound/effects/fart3.ogg', 'sound/effects/fart4.ogg'), 100 ,use_reverb = TRUE, mixer_channel = CHANNEL_PRUDE)
		return TRUE
	return FALSE

/mob/living/basic/bot/buttbot/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	. = ..()
	if(COOLDOWN_FINISHED(src, repeat_cooldown) && prob(listen_probability))
		COOLDOWN_START(src, repeat_cooldown, 2 SECONDS)
		var/list/split_message = splittext_char(html_decode(raw_message), " ")
		for (var/i in 1 to length(split_message))
			if(prob(butt_probability))
				split_message[i] = pick("butt", "butts")
		if((bot_access_flags & BOT_COVER_EMAGGED))
			var/turf/butt = get_turf(src)
			butt.atmos_spawn_air("miasma=5;TEMP=310.15")
		var/joined_text = jointext(split_message, " ")
		if(!findtext_char(joined_text, "butt")) //We must butt, or else.
			COOLDOWN_RESET(src, repeat_cooldown)
			return
		say(joined_text)
		playsound(src, pick('sound/misc/fart1.ogg', 'sound/effects/fart2.ogg', 'sound/effects/fart3.ogg', 'sound/effects/fart4.ogg'), 25 , use_reverb = TRUE, mixer_channel = CHANNEL_PRUDE)
>>>>>>> 01b29f44 ([PORT] Behavior trees and more basic mobs (#12982))
