// JUSTICE SKILLCHIP. Allows you to beat that pesky shitcurity and criminals with the LAW
/obj/item/skillchip/job/security
	name = "JU571C3 2.0 skillchip"
	desc = "Unleash your inner JUDGE."
	auto_traits = list(TRAIT_JUSTICE)
	skill_name = "Advanced Judicial Techniques"
	skill_description = "Acknowledge all of the Space Law and learn on how to apply it, physically."
	skill_icon = "scale-balanced"
	activate_message = span_notice("Your mind fills with all intricates of Space Law.")
	deactivate_message = span_notice("What's a Space Law? A suggestion!")
	actions_types = list(/datum/action/item_action/justice)

/obj/item/skillchip/job/security/on_activate(mob/living/carbon/user, silent)
	. = ..()
	for(var/datum/action/skillchip_action as anything in actions)
		skillchip_action.Grant(user)

/obj/item/skillchip/job/security/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	for(var/datum/action/skillchip_action as anything in actions)
		skillchip_action.Remove(user)

// Weak version only allowing to access the Space Law
/obj/item/skillchip/job/security/weak
	name = "JU571C3 1.0 skillchip"
	desc = "Understand all of the Space Law."
	auto_traits = null
	skill_name = "Judicial Knowledge"
	skill_description = "Acknowledge all of the Space Law and learn on how to apply it."
