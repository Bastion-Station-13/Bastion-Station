/datum/unit_test/water_overlay
	var/water_spot_type
	var/sinking_spot_type
	var/turf/open/water/water_spot
	var/turf/open/water/sinking_spot

/datum/unit_test/water_overlay/New()
	..()
	water_spot_type = run_loc_floor_bottom_left.type
	water_spot = run_loc_floor_bottom_left.ChangeTurf(/turf/open/water)
	var/turf/east_spot = get_step(water_spot, EAST)
	sinking_spot_type = east_spot.type
	sinking_spot = east_spot.ChangeTurf(/turf/open/water/beach/biodome/sinking)

/datum/unit_test/water_overlay/Destroy()
	water_spot.ChangeTurf(water_spot_type)
	sinking_spot.ChangeTurf(sinking_spot_type)
	return ..()

/datum/unit_test/water_overlay/Run()
	for(var/suffix in list("", "_immersed", "_human_resting_e", "_human_resting_w"))
		TEST_ASSERT_NOTNULL(SSwater_overlays.get_overlay_icon(water_spot, suffix), "No water overlay was made for the \"[suffix]\" variant")

	TEST_ASSERT(water_spot.has_water_overlay(), "Plain water doesn't have the water overlay")
	TEST_ASSERT(!sinking_spot.has_water_overlay(), "Sinking water has the water overlay on top of sinking")

	var/mob/living/carbon/human/wader = allocate(/mob/living/carbon/human/consistent, get_step(water_spot, NORTH))
	TEST_ASSERT_NULL(wader.GetComponent(/datum/component/water_overlay_effect), "A human on dry land has the water overlay")

	wader.forceMove(water_spot)
	sleep(1 SECONDS)
	var/datum/component/water_overlay_effect/effect = wader.GetComponent(/datum/component/water_overlay_effect)
	TEST_ASSERT_NOTNULL(effect, "A human walking into water didn't get the water overlay")
	TEST_ASSERT_EQUAL(wader.pixel_z, WATER_DEPTH_SHALLOW, "The human wasn't moved down into the water")
	TEST_ASSERT(length(effect.the_water.overlays), "The water has no texture")
	TEST_ASSERT(wader.vis_contents.Find(effect.the_water), "The water isn't shown on the human")
	TEST_ASSERT_EQUAL(effect.the_splash.icon_state, "shallow", "The wrong splash is shown for a standing human")

	wader.set_body_position(LYING_DOWN)
	wader.set_lying_angle(90)
	TEST_ASSERT_EQUAL(effect.the_splash.icon_state, "human_resting_deep_w", "The wrong splash is shown for a human lying down facing west")
	wader.set_lying_angle(270)
	TEST_ASSERT_EQUAL(effect.the_splash.icon_state, "human_resting_deep_e", "The wrong splash is shown for a human lying down facing east")
	wader.set_body_position(STANDING_UP)
	wader.set_lying_angle(0)
	TEST_ASSERT_EQUAL(effect.the_splash.icon_state, "shallow", "The wrong splash is shown after the human stands back up")

	var/obj/structure/chair/seat = allocate(/obj/structure/chair, water_spot)
	seat.buckle_mob(wader, force = TRUE)
	TEST_ASSERT_EQUAL(wader.pixel_z, 0, "A buckled human is still moved down into the water")
	seat.unbuckle_mob(wader, force = TRUE)
	TEST_ASSERT_EQUAL(wader.pixel_z, WATER_DEPTH_SHALLOW, "The human isn't moved back down into the water after unbuckling")

	wader.forceMove(get_step(water_spot, NORTH))
	TEST_ASSERT_NULL(wader.GetComponent(/datum/component/water_overlay_effect), "The water overlay stayed on a human that left the water")
	TEST_ASSERT_EQUAL(wader.pixel_z, 0, "The human wasn't moved back up out of the water")
	TEST_ASSERT(!wader.vis_contents.Find(effect.the_water), "The water is still shown on a human that left the water")

	wader.forceMove(sinking_spot)
	sleep(1 SECONDS)
	TEST_ASSERT_NULL(wader.GetComponent(/datum/component/water_overlay_effect), "A human in sinking water got the water overlay")
	wader.forceMove(get_step(water_spot, NORTH))
