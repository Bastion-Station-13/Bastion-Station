/// A rule that always gives the answer it is told to, so the rule logic can be tested without a host
/datum/nanite_rule/unit_test_fixed
	name = "Fixed"
	var/result = TRUE

/datum/nanite_rule/unit_test_fixed/check_rule()
	return result

/// Check the consciousness and organ health sensors and rules, rule groups, the repeater's false code and that sensors send their signal codes
/datum/unit_test/nanite_sensors
	var/list/sent_codes = list()

/datum/unit_test/nanite_sensors/proc/catch_signal(datum/source, code, signal_source)
	SIGNAL_HANDLER
	sent_codes += code

/datum/unit_test/nanite_sensors/proc/set_rules(datum/nanite_program/program, all_required, list/rule_specs)
	for(var/datum/nanite_rule/old_rule as anything in program.rules.Copy())
		old_rule.remove()
	program.all_rules_required = all_required
	for(var/list/spec as anything in rule_specs)
		var/datum/nanite_rule/unit_test_fixed/rule = new(program)
		rule.result = spec[1]
		rule.group = spec[2]

/datum/unit_test/nanite_sensors/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	host.AddComponent(/datum/component/nanites, 300)
	var/datum/nanite_program/regenerative/target = allocate(/datum/nanite_program/regenerative)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, target)

	// consciousness
	var/datum/nanite_program/sensor/consciousness/awake_sensor = allocate(/datum/nanite_program/sensor/consciousness)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, awake_sensor)
	var/datum/nanite_extra_setting/awake_mode = awake_sensor.extra_settings[NES_MODE]
	TEST_ASSERT(awake_sensor.check_event(), "The consciousness sensor didn't see a conscious host as conscious")
	host.set_stat(SOFT_CRIT)
	TEST_ASSERT(awake_sensor.check_event(), "The consciousness sensor saw a host in soft crit as not conscious")
	host.set_stat(UNCONSCIOUS)
	TEST_ASSERT(!awake_sensor.check_event(), "The consciousness sensor saw an unconscious host as conscious")
	awake_mode.set_value(FALSE)
	TEST_ASSERT(awake_sensor.check_event(), "The consciousness sensor didn't see an unconscious host as not conscious")
	var/datum/nanite_rule/consciousness/awake_rule = awake_sensor.make_rule(target)
	var/awake_rule_asleep = awake_rule.check_rule()
	host.set_stat(CONSCIOUS)
	var/awake_rule_awake = awake_rule.check_rule()
	awake_rule.remove()
	TEST_ASSERT(awake_rule_asleep, "The not conscious rule didn't see an unconscious host")
	TEST_ASSERT(!awake_rule_awake, "The not conscious rule saw a conscious host as not conscious")

	// organ health
	var/datum/nanite_program/sensor/organ_health/organ_sensor = allocate(/datum/nanite_program/sensor/organ_health)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, organ_sensor)
	var/datum/nanite_extra_setting/organ_percent = organ_sensor.extra_settings[NES_ORGAN_PERCENT]
	var/datum/nanite_extra_setting/organ_direction = organ_sensor.extra_settings[NES_DIRECTION]
	var/obj/item/organ/internal/lungs/lungs = host.get_organ_slot(ORGAN_SLOT_LUNGS)
	TEST_ASSERT_NOTNULL(lungs, "The test human has no lungs")
	organ_percent.set_value(50)
	TEST_ASSERT(organ_sensor.check_event(), "The organ health sensor didn't see healthy lungs as above 50%")
	lungs.apply_organ_damage(60)
	TEST_ASSERT(!organ_sensor.check_event(), "The organ health sensor saw lungs at 40% as above 50%")
	organ_direction.set_value(FALSE)
	TEST_ASSERT(organ_sensor.check_event(), "The organ health sensor didn't see lungs at 40% as below 50%")
	var/datum/nanite_rule/organ_health/organ_rule = organ_sensor.make_rule(target)
	var/organ_rule_damaged = organ_rule.check_rule()
	lungs.set_organ_damage(0)
	var/organ_rule_healed = organ_rule.check_rule()
	lungs.Remove(host, special = TRUE)
	var/organ_rule_missing = organ_rule.check_rule()
	var/organ_rule_slot = organ_rule.organ_slot
	var/organ_rule_threshold = organ_rule.threshold
	organ_rule.remove()
	qdel(lungs)
	TEST_ASSERT_EQUAL(organ_rule_slot, ORGAN_SLOT_LUNGS, "The organ health rule didn't get the organ")
	TEST_ASSERT_EQUAL(organ_rule_threshold, 50, "The organ health rule didn't get the percentage")
	TEST_ASSERT(organ_rule_damaged, "The organ health rule didn't see lungs at 40% as below 50%")
	TEST_ASSERT(!organ_rule_healed, "The organ health rule saw healthy lungs as below 50%")
	TEST_ASSERT(organ_rule_missing, "The organ health rule didn't count missing lungs as 0%")

	// rule groups, (A and B) or C when meeting any and (A or B) and C when meeting all
	var/datum/nanite_program/repeat/grouped = allocate(/datum/nanite_program/repeat)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, grouped)
	set_rules(grouped, FALSE, list(list(TRUE, 0), list(FALSE, 0)))
	TEST_ASSERT(grouped.check_conditions(), "Meeting any without groups needed more than one rule")
	set_rules(grouped, FALSE, list(list(FALSE, 0), list(FALSE, 0)))
	TEST_ASSERT(!grouped.check_conditions(), "Meeting any without groups passed with no rule met")
	set_rules(grouped, TRUE, list(list(TRUE, 0), list(FALSE, 0)))
	TEST_ASSERT(!grouped.check_conditions(), "Meeting all without groups passed with a rule not met")
	set_rules(grouped, TRUE, list(list(TRUE, 0), list(TRUE, 0)))
	TEST_ASSERT(grouped.check_conditions(), "Meeting all without groups failed with every rule met")

	set_rules(grouped, FALSE, list(list(TRUE, 1), list(FALSE, 1), list(FALSE, 0)))
	TEST_ASSERT(!grouped.check_conditions(), "(true and false) or false passed")
	set_rules(grouped, FALSE, list(list(TRUE, 1), list(TRUE, 1), list(FALSE, 0)))
	TEST_ASSERT(grouped.check_conditions(), "(true and true) or false failed")
	set_rules(grouped, FALSE, list(list(FALSE, 1), list(FALSE, 1), list(TRUE, 0)))
	TEST_ASSERT(grouped.check_conditions(), "(false and false) or true failed")
	set_rules(grouped, FALSE, list(list(FALSE, 1), list(TRUE, 1), list(FALSE, 0)))
	TEST_ASSERT(!grouped.check_conditions(), "(false and true) or false passed")
	set_rules(grouped, FALSE, list(list(TRUE, 1), list(TRUE, 1), list(FALSE, 2), list(TRUE, 2)))
	TEST_ASSERT(grouped.check_conditions(), "(true and true) or (false and true) failed")
	set_rules(grouped, FALSE, list(list(TRUE, 1), list(FALSE, 1), list(FALSE, 2), list(TRUE, 2)))
	TEST_ASSERT(!grouped.check_conditions(), "(true and false) or (false and true) passed")

	set_rules(grouped, TRUE, list(list(FALSE, 1), list(TRUE, 1), list(TRUE, 0)))
	TEST_ASSERT(grouped.check_conditions(), "(false or true) and true failed")
	set_rules(grouped, TRUE, list(list(FALSE, 1), list(FALSE, 1), list(TRUE, 0)))
	TEST_ASSERT(!grouped.check_conditions(), "(false or false) and true passed")
	set_rules(grouped, TRUE, list(list(TRUE, 1), list(TRUE, 1), list(FALSE, 0)))
	TEST_ASSERT(!grouped.check_conditions(), "(true or true) and false passed")

	// the summary shows how the rules are combined
	set_rules(grouped, FALSE, list())
	TEST_ASSERT_EQUAL(grouped.get_rule_summary(), "", "A program without rules has a rule summary")
	set_rules(grouped, FALSE, list(list(TRUE, 1), list(FALSE, 1), list(FALSE, 0)))
	TEST_ASSERT_EQUAL(grouped.get_rule_summary(), "(Fixed AND Fixed) OR Fixed", "The summary of (A and B) or C is wrong")
	set_rules(grouped, TRUE, list(list(FALSE, 1), list(TRUE, 1), list(TRUE, 0)))
	TEST_ASSERT_EQUAL(grouped.get_rule_summary(), "(Fixed OR Fixed) AND Fixed", "The summary of (A or B) and C is wrong")
	set_rules(grouped, FALSE, list(list(TRUE, 0), list(TRUE, 0), list(TRUE, 2)))
	TEST_ASSERT_EQUAL(grouped.get_rule_summary(), "Fixed OR Fixed OR Fixed", "The summary of loose rules or a group of one is wrong")

	// the groups survive copying a program
	set_rules(grouped, FALSE, list(list(TRUE, 1), list(FALSE, 1), list(FALSE, 0)))
	var/datum/nanite_program/repeat/copy = allocate(/datum/nanite_program/repeat)
	grouped.copy_programming(copy)
	TEST_ASSERT_EQUAL(length(copy.rules), 3, "The copy didn't get every rule")
	var/datum/nanite_rule/first_copy = copy.rules[1]
	var/datum/nanite_rule/second_copy = copy.rules[2]
	var/datum/nanite_rule/third_copy = copy.rules[3]
	TEST_ASSERT_EQUAL(first_copy.group, 1, "The first rule lost its group when copied")
	TEST_ASSERT_EQUAL(second_copy.group, 1, "The second rule lost its group when copied")
	TEST_ASSERT_EQUAL(third_copy.group, 0, "The third rule got a group when copied")
	set_rules(grouped, FALSE, list())
	set_rules(copy, FALSE, list())

	// sensors send their own signal codes when the check changes
	RegisterSignal(host, COMSIG_NANITE_SIGNAL, PROC_REF(catch_signal))
	var/datum/nanite_program/sensor/consciousness/signal_sensor = allocate(/datum/nanite_program/sensor/consciousness)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, signal_sensor)
	var/datum/nanite_extra_setting/signal_code = signal_sensor.extra_settings[NES_SENT_CODE_SIGNAL]
	var/datum/nanite_extra_setting/inverted_code = signal_sensor.extra_settings[NES_SENT_CODE_SIGNAL_INVERTED]
	signal_code.set_value(31)
	inverted_code.set_value(32)
	signal_sensor.active_effect()
	TEST_ASSERT(31 in sent_codes, "The sensor didn't send its signal code when the check became true")
	TEST_ASSERT(!(32 in sent_codes), "The sensor sent its inverted code while the check was true")
	host.set_stat(UNCONSCIOUS)
	signal_sensor.active_effect()
	TEST_ASSERT(32 in sent_codes, "The sensor didn't send its inverted signal code when the check became false")
	host.set_stat(CONSCIOUS)

	// the repeater sends its true code, or its false code when its rules don't allow the trigger
	var/datum/nanite_program/repeat/repeater = allocate(/datum/nanite_program/repeat)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, repeater)
	var/datum/nanite_extra_setting/true_code = repeater.extra_settings[NES_SENT_CODE]
	var/datum/nanite_extra_setting/false_code = repeater.extra_settings[NES_SENT_CODE_FALSE]
	true_code.set_value(41)
	false_code.set_value(42)
	sent_codes.Cut()
	repeater.trigger()
	sleep(0.5 SECONDS)
	TEST_ASSERT(41 in sent_codes, "The repeater didn't send its code when triggered")
	TEST_ASSERT(!(42 in sent_codes), "The repeater sent its false code when its rules allowed the trigger")
	set_rules(repeater, TRUE, list(list(FALSE, 0)))
	repeater.next_trigger = 0
	sent_codes.Cut()
	repeater.trigger()
	sleep(0.5 SECONDS)
	TEST_ASSERT(42 in sent_codes, "The repeater didn't send its false code when its rules didn't allow the trigger")
	TEST_ASSERT(!(41 in sent_codes), "The repeater sent its true code when its rules didn't allow the trigger")
	set_rules(repeater, TRUE, list())

	UnregisterSignal(host, COMSIG_NANITE_SIGNAL)
