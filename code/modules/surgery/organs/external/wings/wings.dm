///Wing base type. doesn't really do anything
/obj/item/organ/external/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

///Checks if the wings can soften short falls
/obj/item/organ/external/wings/proc/can_soften_fall()
	return TRUE

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = ALL_EXTERNAL_OVERLAYS
	feature_key = "wings"
<<<<<<< HEAD
=======
	overlay_flags = parent_type::overlay_flags | LIMB_OVERLAY_WIDE_ICON | LIMB_OVERLAY_TALL_ICON
	color_source = ORGAN_COLOR_OVERRIDE
>>>>>>> 3cc181a17 ([PORT] Ceruleans and the Siren Shimai pirates (#12801))

/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if(human.w_uniform?.flags_inv & HIDEMUTWINGS)
		return FALSE
	if(!human.wear_suit)
		return TRUE
	if(!(human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return TRUE
	if(human.wear_suit.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/wings/override_color(obj/item/bodypart/bodypart_owner)
	if(bodypart_owner.owner?.get_organ_by_type(/obj/item/organ/external/tail/fish/cerulean))
		return bodypart_owner.owner.dna.features["fish_tail_color"]
	return bodypart_owner.draw_color

