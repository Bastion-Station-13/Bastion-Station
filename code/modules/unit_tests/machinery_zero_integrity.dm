/// Check that every machine gets deleted when its integrity reaches zero
/datum/unit_test/machinery_zero_integrity

/datum/unit_test/machinery_zero_integrity/Run()
	var/turf/spawn_at = run_loc_floor_bottom_left
	var/list/cached_contents = spawn_at.contents.Copy()
	var/datum/gas_mixture/original_air = spawn_at.return_air().copy()

	var/list/ignore = list(
		// abstract, there is no pipe item to drop
		/obj/machinery/atmospherics/pipe,
		/obj/machinery/atmospherics/pipe/heat_exchanging,
	)
	// needs the refill canister of its circuit board
	ignore += typesof(/obj/machinery/vending/custom)
	// armed, blows up the room when broken
	ignore += typesof(/obj/machinery/syndicatebomb/shuttle_loan)

	for(var/obj/machinery/machine_type as anything in subtypesof(/obj/machinery) - uncreatables - ignore)
		if(!initial(machine_type.uses_integrity) || initial(machine_type.max_integrity) <= 0)
			continue
		if((initial(machine_type.resistance_flags) & INDESTRUCTIBLE) || (initial(machine_type.flags_1) & NODECONSTRUCT_1))
			continue

		var/obj/machinery/machine = new machine_type(spawn_at)
		if(QDELETED(machine))
			continue

		machine.take_damage(machine.max_integrity, BRUTE)
		if(!QDELETED(machine))
			TEST_FAIL("[machine_type] survived hitting zero integrity")
			qdel(machine, force = TRUE)

		for(var/atom/to_kill in spawn_at.contents - cached_contents)
			qdel(to_kill, force = TRUE)
		// gas leaking from a machine could be set alight by the sparks of the next one breaking
		spawn_at.return_air().copy_from(original_air)

	// canisters rupture with an explosion, don't leave it for the next test to run into
	UNTIL_OR_TIMEOUT(!SSexplosions.is_exploding(), 10 SECONDS)
