/// Check that a shield generator breaks first and gets deleted at zero integrity
/datum/unit_test/shieldgen_integrity

/datum/unit_test/shieldgen_integrity/Run()
	var/obj/machinery/shieldgen/shieldgen = allocate(/obj/machinery/shieldgen)
	shieldgen.take_damage(shieldgen.max_integrity * (1 - shieldgen.integrity_failure) + 1, BRUTE)
	TEST_ASSERT(shieldgen.machine_stat & BROKEN, "The shield generator didn't break at its failure point")
	TEST_ASSERT(!QDELETED(shieldgen), "The shield generator got deleted before hitting zero integrity")
	shieldgen.take_damage(shieldgen.max_integrity, BRUTE)
	TEST_ASSERT(QDELETED(shieldgen), "The shield generator survived hitting zero integrity")
