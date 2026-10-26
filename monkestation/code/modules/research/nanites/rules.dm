/datum/nanite_rule
	var/name = "Generic Condition"
	var/desc = "When triggered, the program is active"
	var/datum/nanite_program/program
	/// Rules in the same group are combined with the opposite logic of the program's first, 0 for no group
	var/group = 0

/datum/nanite_rule/New(datum/nanite_program/new_program)
	program = new_program
	if(LAZYLEN(new_program.rules) <= 5) //Avoid infinite stacking rules
		new_program.rules += src
	else
		qdel(src)

/datum/nanite_rule/proc/remove()
	program.rules -= src
	program = null
	qdel(src)

/datum/nanite_rule/proc/check_rule()
	return TRUE

/datum/nanite_rule/proc/display()
	return name

/datum/nanite_rule/proc/copy_to(datum/nanite_program/new_program)
	new type(new_program)

/datum/nanite_rule/health
	name = "Health"
	desc = "Checks the host's health status."

	var/threshold = 50
	var/above = TRUE

/datum/nanite_rule/health/check_rule()
	var/health_percent = program.host_mob.health / program.host_mob.maxHealth * 100

	return above == health_percent >= threshold

/datum/nanite_rule/health/display()
	return "[name] [above ? ">" : "<"] [threshold]%"

/datum/nanite_rule/health/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/health/rule = new(new_program)
	rule.above = above
	rule.threshold = threshold

/datum/nanite_rule/crit
	name = "Crit"
	desc = "Checks if the host is in critical condition."

	var/when_crit = TRUE

/datum/nanite_rule/crit/check_rule()
	return when_crit == HAS_TRAIT(program.host_mob, TRAIT_CRITICAL_CONDITION)

/datum/nanite_rule/crit/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/crit/rule = new(new_program)
	rule.when_crit = when_crit

/datum/nanite_rule/crit/display()
	return when_crit ? name : "Not [name]"

/datum/nanite_rule/death
	name = "Death"
	desc = "Checks if the host is dead."

	var/when_dead = TRUE

/datum/nanite_rule/death/check_rule()
	return when_dead == (program.host_mob.stat == DEAD)

/datum/nanite_rule/death/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/death/rule = new(new_program)
	rule.when_dead = when_dead

/datum/nanite_rule/death/display()
	return when_dead ? "Dead" : "Not Dead"

/datum/nanite_rule/cloud_sync
	name = "Cloud Sync"
	desc = "Checks if the nanites have cloud sync enabled or disabled."
	var/check_type = "Enabled"

/datum/nanite_rule/cloud_sync/check_rule()
	return (check_type == "Enabled") == program.nanites.cloud_active

/datum/nanite_rule/cloud_sync/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/cloud_sync/rule = new(new_program)
	rule.check_type = check_type

/datum/nanite_rule/cloud_sync/display()
	return "[name]:[check_type]"

/datum/nanite_rule/nanites
	name = "Nanite Volume"
	desc = "Checks the host's nanite volume."

	var/threshold = 50
	var/above = TRUE
	///Whether the threshold is an amount of nanites instead of a percentage
	var/use_amount = FALSE

/datum/nanite_rule/nanites/check_rule()
	var/nanite_level
	if(use_amount)
		nanite_level = program.nanites.nanite_volume
	else
		nanite_level = (program.nanites.nanite_volume - program.nanites.safety_threshold)/(program.nanites.max_nanites - program.nanites.safety_threshold)*100

	return above == nanite_level >= threshold

/datum/nanite_rule/nanites/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/nanites/rule = new(new_program)
	rule.above = above
	rule.threshold = threshold
	rule.use_amount = use_amount

/datum/nanite_rule/nanites/display()
	return "[name] [above ? ">" : "<"] [threshold][use_amount ? " nanites" : "%"]"

/datum/nanite_rule/damage
	name = "Damage"
	desc = "Checks the host's damage."

	var/threshold = 50
	var/above = TRUE
	var/damage_type = BRUTE

/datum/nanite_rule/damage/check_rule()
	var/damage_amt = 0

	switch(LOWER_TEXT(damage_type))
		if(BRUTE)
			damage_amt = program.host_mob.getBruteLoss()
		if(BURN)
			damage_amt = program.host_mob.getFireLoss()
		if(TOX)
			damage_amt = program.host_mob.getToxLoss()
		if(OXY)
			damage_amt = program.host_mob.getOxyLoss()
		if(CLONE)
			damage_amt = program.host_mob.getCloneLoss()
		if(BRAIN)
			damage_amt = program.host_mob.get_organ_loss(ORGAN_SLOT_BRAIN)

	return above == damage_amt >= threshold

/datum/nanite_rule/damage/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/damage/rule = new(new_program)

	rule.above = above
	rule.threshold = threshold
	rule.damage_type = damage_type

/datum/nanite_rule/damage/display()
	return "[damage_type] [above ? ">" : "<"] [threshold]"

/datum/nanite_rule/blood
	name = "Blood"
	desc = "Checks the host's blood volume."

	var/threshold = 90
	var/above = TRUE

/datum/nanite_rule/blood/check_rule()
	var/host_blood_percent = program.host_mob.blood_volume / BLOOD_VOLUME_NORMAL * 100

	return above == host_blood_percent >= threshold

/datum/nanite_rule/blood/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/blood/rule = new(new_program)

	rule.threshold = threshold
	rule.above = above

/datum/nanite_rule/blood/display()
	return "[name] [above ? ">" : "<"] [threshold]%"

/datum/nanite_rule/nutrition
	name = "Nutrition"
	desc = "Checks the host's nutrition level."

	var/threshold = 90
	var/above = TRUE

/datum/nanite_rule/nutrition/check_rule()
	var/host_nutrition_percent = program.host_mob.nutrition / NUTRITION_LEVEL_FED * 100

	return above == host_nutrition_percent >= threshold

/datum/nanite_rule/nutrition/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/nutrition/rule = new(new_program)
	rule.threshold = threshold
	rule.above = above

/datum/nanite_rule/nutrition/display()
	return "[name] [above ? ">" : "<"] [threshold]%"

/datum/nanite_rule/species
	name = "Species"
	desc = "Checks the host's species."

	var/when_is_species
	var/list/species_list
	var/species_name

/datum/nanite_rule/species/check_rule()
	var/species_type = species_list[species_name]

	if (!species_type) // "Other" check
		for (var/name in species_list)
			if (is_species(program.host_mob, species_type))
				return !when_is_species
		return when_is_species

	return when_is_species == is_species(program.host_mob, species_type)

/datum/nanite_rule/species/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/species/rule = new(new_program)

	rule.when_is_species = when_is_species
	rule.species_list = species_list
	rule.species_name = species_name

	return rule

/datum/nanite_rule/species/display()
	return "[name] [when_is_species ? "Is" : "Isn't"] [species_name]"

/datum/nanite_rule/consciousness
	name = "Consciousness"
	desc = "Checks if the host is conscious."

	var/when_conscious = TRUE

/datum/nanite_rule/consciousness/check_rule()
	return when_conscious == nanite_host_conscious(program.host_mob)

/datum/nanite_rule/consciousness/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/consciousness/rule = new(new_program)
	rule.when_conscious = when_conscious

	return rule

/datum/nanite_rule/consciousness/display()
	return "[name] [when_conscious ? "Conscious" : "Not Conscious"]"

/datum/nanite_rule/organ_health
	name = "Organ Health"
	desc = "Checks how healthy one of the host's organs is, a missing organ counts as 0%."

	var/organ_name = "Lungs"
	var/organ_slot = ORGAN_SLOT_LUNGS
	var/threshold = 50
	var/above = TRUE

/datum/nanite_rule/organ_health/check_rule()
	return above == nanite_organ_health_percent(program.host_mob, organ_slot) >= threshold

/datum/nanite_rule/organ_health/copy_to(datum/nanite_program/new_program)
	var/datum/nanite_rule/organ_health/rule = new(new_program)
	rule.organ_name = organ_name
	rule.organ_slot = organ_slot
	rule.threshold = threshold
	rule.above = above

	return rule

/datum/nanite_rule/organ_health/display()
	return "[organ_name] Health [above ? ">" : "<"] [threshold]%"

/// SOFT_CRIT can still move and talk, so only a worse stat than that counts as not conscious
/proc/nanite_host_conscious(mob/living/host)
	return host.stat < UNCONSCIOUS

/// How healthy this organ of the host is in percent, a missing organ is 0
/proc/nanite_organ_health_percent(mob/living/host, organ_slot)
	var/obj/item/organ/organ = host.get_organ_slot(organ_slot)
	if(!organ)
		return 0
	return 100 - (organ.damage / max(organ.maxHealth, 1) * 100)
