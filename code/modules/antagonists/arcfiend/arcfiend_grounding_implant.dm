/obj/item/organ/internal/cyberimp/chest/arcfiend_grounding
	name = "arcfiend grounding implant"
	desc = "This implant soaks up any current built up in the body and earths it harmlessly. Most people will never notice it's there, \
		but an arcfiend with one inside them can do little more than sap power."
	icon = 'bastionstation/icons/obj/antags/arcfiend/arcfiend_grounding_implant.dmi'
	icon_state = "arcfiend_grounding_implant"
	implant_overlay = null
	slot = ORGAN_SLOT_ARCFIEND_GROUNDING
	organ_traits = list(TRAIT_ARCFIEND_GROUNDED)

/datum/supply_pack/security/armory/arcfiend_grounding
	name = "Arcfiend Grounding Implants Crate"
	desc = "Keep your arcfiends grounded with two chest-installed grounding implants. Surgery not included."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/organ/internal/cyberimp/chest/arcfiend_grounding = 2)
	crate_name = "arcfiend grounding implant crate"
