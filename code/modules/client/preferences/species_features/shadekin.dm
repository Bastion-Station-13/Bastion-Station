/datum/preference/choiced/shadekin_tail
	savefile_key = "feature_shadekin_tail"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_external_organ = /obj/item/organ/external/tail/shadekin

/datum/preference/choiced/shadekin_tail/init_possible_values()
	return assoc_to_keys_features(GLOB.tails_list_shadekin)

/datum/preference/choiced/shadekin_tail/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tail_shadekin"] = value

/datum/preference/choiced/shadekin_tail/create_default_value()
	return "Shadekin"
