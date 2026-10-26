/// Check that combat boots have the same noisemaker as jackboots
/datum/unit_test/combat_boots_noisemaker

/datum/unit_test/combat_boots_noisemaker/Run()
	for(var/boots_type in typesof(/obj/item/clothing/shoes/combat))
		var/obj/item/clothing/shoes/combat/boots = allocate(boots_type)
		TEST_ASSERT_NOTNULL(boots.GetComponent(/datum/component/shoesteps/combine_boot_sounds), "[boots_type] has no noisemaker")
