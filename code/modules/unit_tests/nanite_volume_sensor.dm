/// Check that the nanite volume sensor can compare against a percentage or an amount of nanites
/datum/unit_test/nanite_volume_sensor

/datum/unit_test/nanite_volume_sensor/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human/consistent)
	host.AddComponent(/datum/component/nanites, 300)
	var/datum/component/nanites/nanites = host.GetComponent(/datum/component/nanites)
	var/datum/nanite_program/sensor/nanite_volume/sensor = allocate(/datum/nanite_program/sensor/nanite_volume)
	var/datum/nanite_program/regenerative/target = allocate(/datum/nanite_program/regenerative)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, sensor)
	SEND_SIGNAL(host, COMSIG_NANITE_ADD_PROGRAM, target)
	var/datum/nanite_extra_setting/mode = sensor.extra_settings[NES_MODE]
	var/datum/nanite_extra_setting/percent = sensor.extra_settings[NES_NANITE_PERCENT]
	var/datum/nanite_extra_setting/amount = sensor.extra_settings[NES_NANITE_AMOUNT]
	var/datum/nanite_extra_setting/direction = sensor.extra_settings[NES_DIRECTION]

	// the percentage counts from the safety threshold, 300 of 500 with a threshold of 50 is about 56%
	percent.set_value(50)
	TEST_ASSERT(sensor.check_event(), "The sensor didn't see about 56% as above 50%")
	percent.set_value(60)
	TEST_ASSERT(!sensor.check_event(), "The sensor saw about 56% as above 60%")

	mode.set_value(FALSE)
	amount.set_value(250)
	TEST_ASSERT(sensor.check_event(), "The sensor didn't see 300 nanites as above 250")
	nanites.nanite_volume = 200
	TEST_ASSERT(!sensor.check_event(), "The sensor saw 200 nanites as above 250")
	direction.set_value(FALSE)
	TEST_ASSERT(sensor.check_event(), "The sensor didn't see 200 nanites as below 250")

	var/datum/nanite_rule/nanites/rule = sensor.make_rule(target)
	var/rule_below = rule.check_rule()
	nanites.nanite_volume = 300
	var/rule_above = rule.check_rule()
	var/rule_threshold = rule.threshold
	var/rule_uses_amount = rule.use_amount
	rule.remove()
	TEST_ASSERT(rule_uses_amount, "The rule didn't get the amount mode")
	TEST_ASSERT_EQUAL(rule_threshold, 250, "The rule didn't get the amount")
	TEST_ASSERT(rule_below, "The rule didn't see 200 nanites as below 250")
	TEST_ASSERT(!rule_above, "The rule saw 300 nanites as below 250")
