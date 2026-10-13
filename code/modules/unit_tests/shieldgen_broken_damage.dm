/// Check that a broken shield generator can take more damage without runtiming
/datum/unit_test/shieldgen_broken_damage

/datum/unit_test/shieldgen_broken_damage/Run()
	var/obj/machinery/shieldgen/shieldgen = allocate(/obj/machinery/shieldgen)
	shieldgen.take_damage(shieldgen.max_integrity * 2, BRUTE)
	TEST_ASSERT(shieldgen.atom_integrity <= 0, "The shield generator didn't break")
	shieldgen.take_damage(10, BURN, FIRE)
