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

<<<<<<< HEAD
=======
/obj/item/organ/internal/butt/atomic/On_Fart(mob/user)
	var/mob/living/carbon/human/Person = user
	var/turf/Location = get_turf(user)

	if(!cooling_down)
		cooling_down = TRUE
		user.audible_message("[user] <font color='green'>farts.</font>")
		if(prob(fart_instability))
			playsound(user, "sound/announcer/alarm/nuke_alarm.ogg", 100, FALSE, 50, ignore_walls=TRUE, mixer_channel = CHANNEL_MOB_SOUNDS)
			minor_announce("The detonation of a nuclear posterior has been detected in your area. All crew are required to exit the blast radius.", "Nanotrasen Atomics")
			Person.Paralyze(12 SECONDS)
			Person.electrocution_animation(12 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(kaboom), Person), 12 SECONDS)
		else
			playsound(user, pick(sound_effect), 50, TRUE, mixer_channel = CHANNEL_MOB_SOUNDS)
			Location.atmos_spawn_air(atmos_gas)
			addtimer(VARSET_CALLBACK(src, cooling_down, FALSE), 2 SECONDS)
	//Do NOT call parent on this.
	//Unique functionality.

>>>>>>> 607bcdae (port tg's icon and sound reorganization (#12826))
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
<<<<<<< HEAD
=======
	sound_effect = list('sound/machines/buzz/buzz-sigh.ogg', 'sound/machines/buzz/buzz-two.ogg', 'sound/machines/terminal/terminal_error.ogg', 'sound/items/weapons/ring.ogg')
>>>>>>> 607bcdae (port tg's icon and sound reorganization (#12826))
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
<<<<<<< HEAD
=======
	sound_effect = list("sound/mobs/humanoids/skeleton/skeleton_laugh.ogg")
>>>>>>> 607bcdae (port tg's icon and sound reorganization (#12826))
	icon_state =  "skeleass"

//PLASMAMAN ASS
/obj/item/organ/internal/butt/plasma
	name = "Plasmaman Butt"
	desc = "You REALLY don't understand how this works!"
<<<<<<< HEAD
=======
	sound_effect = list("sound/mobs/humanoids/skeleton/skeleton_laugh.ogg")
	fart_instability = 5
>>>>>>> 607bcdae (port tg's icon and sound reorganization (#12826))
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
