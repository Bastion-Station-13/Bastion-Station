/datum/species/shadekin
	name = "\improper Shadekin"
	plural_form = "Shadekin"
	id = SPECIES_SHADEKIN
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutantbrain = /obj/item/organ/internal/brain/shadekin
	mutanteyes = /obj/item/organ/internal/eyes/shadekin
	eyes_icon = 'icons/mob/species/shadekin/shadekin_eyes.dmi' // i dont know how else to do this son

	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_LITERATE,
		TRAIT_MUTANT_COLORS,
		TRAIT_NIGHT_VISION,
		TRAIT_NOBREATH,
	)


	// later
	mutant_bodyparts = list(
		"ears" = "Shadekin",
		"tail" = "Shadekin",
	)

	external_organs = list(
	)

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT


	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadekin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadekin,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadekin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadekin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadekin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadekin,
	)

/datum/species/shadekin/randomize_features()
	var/list/features = ..()
	// empty for now
	return features

/datum/species/shadekin/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "lightbulb",
		SPECIES_PERK_NAME = "Dark Regeneration",
		SPECIES_PERK_DESC = "Shadekin slowly regenerate their physical wounds while in the darkness.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "wind",
		SPECIES_PERK_NAME = "Auto Respiration",
		SPECIES_PERK_DESC = "Shadekin do not need to breathe, but this does not protect them from the dangers of space.",
	),
	list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "band-aid",
		SPECIES_PERK_NAME = "Damage Vulnerability",
		SPECIES_PERK_DESC = "Shadekin are more vulnerable to physical injury, and will take 20% more brute and burn damage.",
	),
	)
	return to_add

/datum/species/shadekin/get_species_description()
	return "Shadekin first came about like dust bunnies under a bed, in a collective consciousness that whispered \
		\"Welcome, sibling,\" and guided them toward their first connection. They do not respirate, and their bodies \
		are reformed in the darkness, though they are fragile and vulnerable to the light."

/obj/item/organ/internal/brain/shadekin
	name = "shadekin brain"
	desc = "bla bla bla placeholder text here"
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "brain-x-d"

/obj/item/organ/internal/brain/shadekin/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/turf/owner_turf = owner.loc
	if(!isturf(owner_turf))
		return

	if(GET_SIMPLE_LUMCOUNT(owner_turf) < SHADOW_SPECIES_DIM_LIGHT)
		owner.apply_status_effect(/datum/status_effect/shadekin_regeneration)

/datum/status_effect/shadekin_regeneration
	id = "shadekin_regeneration"
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/shadekin_regeneration/on_apply()
	. = ..()
	if(!.)
		return FALSE
	heal_owner()
	return TRUE

/datum/status_effect/shadekin_regeneration/refresh(effect)
	. = ..()
	heal_owner()

/datum/status_effect/shadekin_regeneration/proc/heal_owner()
	owner.heal_overall_damage(brute = 0.5, burn = 0.5, required_bodytype = BODYTYPE_ORGANIC)
