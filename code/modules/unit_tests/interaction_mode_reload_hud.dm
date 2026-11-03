/// Check that reload_hud deletes the old button
/datum/unit_test/interaction_mode_reload_hud

/datum/unit_test/interaction_mode_reload_hud/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/datum/hud/test_hud = allocate(/datum/hud, dummy)
	test_hud.has_interaction_ui = TRUE
	dummy.hud_used = test_hud

	var/datum/client_interface/mock_client = allocate(/datum/client_interface)
	mock_client.mob = dummy

	var/datum/interaction_mode/combat_mode/mode = allocate(/datum/interaction_mode/combat_mode, mock_client)
	var/atom/movable/screen/old_button = mode.UI
	TEST_ASSERT(old_button, "The interaction mode didn't create a button")

	mode.reload_hud(dummy)

	TEST_ASSERT(QDELETED(old_button), "reload_hud left the old interaction button alive")
	TEST_ASSERT(mode.UI && mode.UI != old_button, "reload_hud didn't create a new interaction button")

	mock_client.mob = null
