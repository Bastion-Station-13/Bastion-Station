/// Gets the voice sound of a human for a voiced emote, null if the user doesn't have a human voice
/proc/get_human_voice_sound(mob/living/user, list/male_sounds, list/female_sounds)
	if(!ishuman(user) || ismonkey(user))
		return
	var/mob/living/carbon/human/human_user = user
	var/obj/item/organ/internal/tongue/tongue = human_user.get_organ_slot(ORGAN_SLOT_TONGUE)
	return tongue?.get_voice_emote_sound(male_sounds, female_sounds)

/datum/emote/living/cough
	audio_cooldown = 3 SECONDS

/datum/emote/living/cough/get_sound(mob/living/user)
	var/static/list/male_sounds = list(
		'sound/voice/human/cough/male_cough1.ogg',
		'sound/voice/human/cough/male_cough2.ogg',
		'sound/voice/human/cough/male_cough3.ogg',
		'sound/voice/human/cough/male_cough4.ogg',
		'sound/voice/human/cough/male_cough5.ogg',
		'sound/voice/human/cough/male_cough6.ogg',
	)
	var/static/list/female_sounds = list(
		'sound/voice/human/cough/female_cough1.ogg',
		'sound/voice/human/cough/female_cough2.ogg',
		'sound/voice/human/cough/female_cough3.ogg',
		'sound/voice/human/cough/female_cough4.ogg',
		'sound/voice/human/cough/female_cough5.ogg',
		'sound/voice/human/cough/female_cough6.ogg',
	)
	return get_human_voice_sound(user, male_sounds, female_sounds)

/datum/emote/living/sigh
	audio_cooldown = 3 SECONDS

/datum/emote/living/sigh/get_sound(mob/living/user)
	var/static/list/male_sounds = list(
		'sound/voice/human/sigh/male_sigh1.ogg',
		'sound/voice/human/sigh/male_sigh2.ogg',
		'sound/voice/human/sigh/male_sigh3.ogg',
	)
	var/static/list/female_sounds = list(
		'sound/voice/human/sigh/female_sigh1.ogg',
		'sound/voice/human/sigh/female_sigh2.ogg',
		'sound/voice/human/sigh/female_sigh3.ogg',
	)
	return get_human_voice_sound(user, male_sounds, female_sounds)

/datum/emote/living/sneeze
	audio_cooldown = 3 SECONDS

/datum/emote/living/sneeze/get_sound(mob/living/user)
	var/static/list/male_sounds = list('sound/voice/human/sneeze/male_sneeze1.ogg')
	var/static/list/female_sounds = list('sound/voice/human/sneeze/female_sneeze1.ogg')
	return get_human_voice_sound(user, male_sounds, female_sounds)

/datum/emote/living/sniff
	audio_cooldown = 3 SECONDS

/datum/emote/living/sniff/get_sound(mob/living/user)
	var/static/list/male_sounds = list('sound/voice/human/sniff/male_sniff.ogg')
	var/static/list/female_sounds = list('sound/voice/human/sniff/female_sniff.ogg')
	return get_human_voice_sound(user, male_sounds, female_sounds)

/datum/emote/living/snore
	audio_cooldown = 8 SECONDS

/datum/emote/living/snore/get_sound(mob/living/user)
	var/static/list/male_sounds = list(
		'sound/voice/human/snore/snore_male1.ogg',
		'sound/voice/human/snore/snore_male2.ogg',
		'sound/voice/human/snore/snore_male3.ogg',
		'sound/voice/human/snore/snore_male4.ogg',
		'sound/voice/human/snore/snore_male5.ogg',
	)
	var/static/list/female_sounds = list(
		'sound/voice/human/snore/snore_female1.ogg',
		'sound/voice/human/snore/snore_female2.ogg',
		'sound/voice/human/snore/snore_female3.ogg',
	)
	return get_human_voice_sound(user, male_sounds, female_sounds)

/datum/emote/living/gag
	audio_cooldown = 3 SECONDS

/datum/emote/living/gag/get_sound(mob/living/user)
	var/static/list/gag_sounds = list(
		'sound/voice/human/gag_vomit/gag1.ogg',
		'sound/voice/human/gag_vomit/gag2.ogg',
		'sound/voice/human/gag_vomit/gag3.ogg',
		'sound/voice/human/gag_vomit/gag4.ogg',
		'sound/voice/human/gag_vomit/gag5.ogg',
	)
	return get_human_voice_sound(user, gag_sounds, gag_sounds)

/datum/emote/living/gasp
	audio_cooldown = 3 SECONDS

/datum/emote/living/gasp/get_sound(mob/living/user)
	var/static/list/male_sounds = list(
		'goon/sounds/voice/gasp/male_gasp_1.ogg',
		'goon/sounds/voice/gasp/male_gasp_2.ogg',
		'goon/sounds/voice/gasp/male_gasp_3.ogg',
		'goon/sounds/voice/gasp/male_gasp_4.ogg',
		'goon/sounds/voice/gasp/male_gasp_5.ogg',
	)
	var/static/list/female_sounds = list(
		'goon/sounds/voice/gasp/female_gasp_1.ogg',
		'goon/sounds/voice/gasp/female_gasp_2.ogg',
		'goon/sounds/voice/gasp/female_gasp_3.ogg',
		'goon/sounds/voice/gasp/female_gasp_4.ogg',
		'goon/sounds/voice/gasp/female_gasp_5.ogg',
	)
	return get_human_voice_sound(user, male_sounds, female_sounds)

/datum/emote/living/carbon/human/cry
	audio_cooldown = 5 SECONDS

/datum/emote/living/carbon/human/cry/get_sound(mob/living/user)
	var/static/list/male_sounds = list(
		'sound/voice/human/cry/male_cry1.ogg',
		'sound/voice/human/cry/male_cry2.ogg',
		'sound/voice/human/cry/male_cry3.ogg',
	)
	var/static/list/female_sounds = list(
		'sound/voice/human/cry/female_cry1.ogg',
		'sound/voice/human/cry/female_cry2.ogg',
	)
	return get_human_voice_sound(user, male_sounds, female_sounds)

/datum/emote/living/whistle/get_sound(mob/living/user)
	var/static/list/whistle_sounds = list('sound/voice/human/whistle/whistle1.ogg')
	return get_human_voice_sound(user, whistle_sounds, whistle_sounds)

/datum/emote/living/hiccup
	key = "hiccup"
	key_third_person = "hiccups"
	message = "hiccups."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	audio_cooldown = 5 SECONDS

/datum/emote/living/hiccup/get_sound(mob/living/user)
	var/static/list/hiccup_sounds = list('sound/voice/human/hiccup/sf_hiccup_male_01.ogg')
	return get_human_voice_sound(user, hiccup_sounds, hiccup_sounds)
