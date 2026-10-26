/// Check that the voiced emotes have a sound for humans of either gender and none for a tongue without a human voice
/datum/unit_test/voiced_emotes

/datum/unit_test/voiced_emotes/Run()
	var/mob/living/carbon/human/man = allocate(/mob/living/carbon/human/consistent)
	man.gender = MALE
	var/mob/living/carbon/human/woman = allocate(/mob/living/carbon/human/consistent)
	woman.gender = FEMALE
	var/mob/living/carbon/human/synth = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/internal/tongue/synth/voicebox = allocate(/obj/item/organ/internal/tongue/synth)
	voicebox.Insert(synth, special = TRUE, drop_if_replaced = FALSE)

	for(var/emote_key in list("cry", "cough", "sigh", "sneeze", "sniff", "snore", "gag", "gasp", "whistle", "hiccup"))
		var/list/emotes = GLOB.emote_list[emote_key]
		TEST_ASSERT(length(emotes), "There is no [emote_key] emote")
		var/datum/emote/emote = emotes[1]
		TEST_ASSERT_NOTNULL(emote.get_sound(man), "The [emote_key] emote has no sound for a man")
		TEST_ASSERT_NOTNULL(emote.get_sound(woman), "The [emote_key] emote has no sound for a woman")
		TEST_ASSERT_NULL(emote.get_sound(synth), "The [emote_key] emote has a human sound for a synthetic voicebox")
