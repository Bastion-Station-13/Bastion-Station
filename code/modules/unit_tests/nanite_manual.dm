/// Check that the nanite programmer prints the nanite handbook and doesn't print a pile of them
/datum/unit_test/nanite_manual

/datum/unit_test/nanite_manual/proc/count_manuals(turf/spot)
	var/count = 0
	for(var/obj/item/book/manual/nanites/found in spot)
		count++
	return count

/datum/unit_test/nanite_manual/Run()
	var/obj/machinery/computer/nanite_cloud_controller/programmer = allocate(/obj/machinery/computer/nanite_cloud_controller)
	var/turf/spot = programmer.drop_location()

	TEST_ASSERT(programmer.print_manual(), "The programmer didn't print the handbook")
	TEST_ASSERT_EQUAL(count_manuals(spot), 1, "The programmer didn't leave exactly one handbook")
	var/obj/item/book/manual/nanites/manual = locate() in spot
	TEST_ASSERT(findtext(manual.book_data.get_content(), "sent signal"), "The handbook doesn't explain what a sent signal is")

	TEST_ASSERT(!programmer.print_manual(), "The programmer printed a second handbook right away")
	TEST_ASSERT_EQUAL(count_manuals(spot), 1, "The programmer left more than one handbook during the cooldown")

	programmer.manual_cooldown = 0
	TEST_ASSERT(programmer.print_manual(), "The programmer didn't print another handbook once the cooldown was over")
	TEST_ASSERT_EQUAL(count_manuals(spot), 2, "The programmer didn't leave the second handbook")
