/// Check that pressing the sprint key again before releasing it doesn't runtime
/datum/unit_test/carbon_sprint_key_repeat

/datum/unit_test/carbon_sprint_key_repeat/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/datum/component/carbon_sprint/sprint = dummy.AddComponent(/datum/component/carbon_sprint)
	sprint.keyDown()
	sprint.keyDown()
	sprint.keyUp()
