/// Check that every meteor wave list has a weight for each meteor
/datum/unit_test/meteor_wave_weights

/datum/unit_test/meteor_wave_weights/Run()
	var/list/wave_lists = list(
		"meteors_normal" = GLOB.meteors_normal,
		"meteors_threatening" = GLOB.meteors_threatening,
		"meteors_catastrophic" = GLOB.meteors_catastrophic,
		"meateors" = GLOB.meateors,
		"meteors_dust" = GLOB.meteors_dust,
		"meteors_stray" = GLOB.meteors_stray,
		"meteors_sandstorm" = GLOB.meteors_sandstorm,
		"meteorsSPOOKY" = GLOB.meteorsSPOOKY,
	)
	for(var/list_name in wave_lists)
		var/list/wave = wave_lists[list_name]
		for(var/meteor_type in wave)
			TEST_ASSERT(isnum(wave[meteor_type]), "[list_name] has no weight for [meteor_type]")
