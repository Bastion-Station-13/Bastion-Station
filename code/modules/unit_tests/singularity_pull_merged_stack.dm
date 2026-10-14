/// Check that a stack merged by singularity_pull doesn't get thrown after it's deleted
/datum/unit_test/singularity_pull_merged_stack

/datum/unit_test/singularity_pull_merged_stack/Run()
	var/turf/target_turf = run_loc_floor_bottom_left
	var/obj/item/stack/rods/target_stack = allocate(/obj/item/stack/rods, target_turf)
	var/obj/item/stack/rods/pulled_stack = allocate(/obj/item/stack/rods, get_step(target_turf, EAST))

	pulled_stack.singularity_pull(target_stack, STAGE_FIVE)

	TEST_ASSERT(QDELETED(pulled_stack) || QDELETED(target_stack), "The stacks didn't merge")
