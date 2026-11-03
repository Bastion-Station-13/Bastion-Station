/obj/vehicle/sealed/mecha/odysseus
	desc = "A nimble DeForest Odysseus exosuit, designed and outfitted for frontline medical support and rapid response."
	name = "\improper Odysseus"
	icon = 'icons/mob/rideables/mecha.dmi'
	icon_state = "odysseus"
	base_icon_state = "odysseus"
	movedelay = 2
	encumbrance_gap = 1
	max_temperature = 15000
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	mech_type = EXOSUIT_MODULE_ODYSSEUS
	step_energy_drain = 6
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_MEDICAL)
	pivot_step = TRUE
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 5,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)

/obj/vehicle/sealed/mecha/odysseus/moved_inside(mob/living/carbon/human/human)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(human, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)

/obj/vehicle/sealed/mecha/odysseus/remove_occupant(mob/living/carbon/human/human)
	REMOVE_TRAIT(human, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)
	return ..()

/obj/vehicle/sealed/mecha/odysseus/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(!. || isnull(MMI.brainmob))
		return
	ADD_TRAIT(MMI.brainmob, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)
