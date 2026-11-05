/// Base for the arcfiend tests, makes a human arcfiend to poke at
/datum/unit_test/arcfiend
	abstract_type = /datum/unit_test/arcfiend
	test_flags = UNIT_TEST_MAP_TEST
	var/mob/living/carbon/human/user
	var/datum/antagonist/arcfiend/antag

/datum/unit_test/arcfiend/proc/make_arcfiend()
	user = allocate(/mob/living/carbon/human/consistent)
	user.mind_initialize()
	antag = user.mind.add_antag_datum(/datum/antagonist/arcfiend)
	if(!antag)
		TEST_FAIL("Could not give the test human the arcfiend antag datum")
		return FALSE
	return TRUE

/// Every sprite the arcfiend code points at has to exist in its file, or the item or button is invisible
/datum/unit_test/arcfiend/icons_exist/Run()
	for(var/power_type in subtypesof(/datum/action/cooldown/arcfiend))
		var/datum/action/cooldown/arcfiend/power = allocate(power_type)
		if(power.is_passive || ispath(power_type, /datum/action/cooldown/arcfiend/passive) || power_type == /datum/action/cooldown/arcfiend/toggle)
			continue
		if(power.button_icon_state == "lightning" && power.button_icon == 'icons/mob/actions/actions_spells.dmi')
			continue // still a placeholder
		TEST_ASSERT(power.button_icon_state in icon_states(power.button_icon), "[power_type] has no [power.button_icon_state] button icon")
		if(ispath(power_type, /datum/action/cooldown/arcfiend/toggle))
			TEST_ASSERT("[power.button_icon_state]_on" in icon_states(power.button_icon), "[power_type] has no [power.button_icon_state]_on button icon")
		TEST_ASSERT(power.background_icon_state in icon_states(power.background_icon), "[power_type] has no [power.background_icon_state] button background")

	var/obj/item/gun/energy/arcfiend/coilgun/coilgun = allocate(/obj/item/gun/energy/arcfiend/coilgun)
	var/obj/item/gun/energy/arcfiend/lateral_laser/laser = allocate(/obj/item/gun/energy/arcfiend/lateral_laser)
	var/obj/item/melee/arcfiend_prod/prod = allocate(/obj/item/melee/arcfiend_prod)
	var/obj/item/card/emag/arcfiend/emag = allocate(/obj/item/card/emag/arcfiend)
	for(var/obj/item/held as anything in list(coilgun, laser, prod, emag))
		TEST_ASSERT(held.inhand_icon_state in icon_states(held.lefthand_file), "[held.type] has no [held.inhand_icon_state] left-hand sprite")
		TEST_ASSERT(held.inhand_icon_state in icon_states(held.righthand_file), "[held.type] has no [held.inhand_icon_state] right-hand sprite")
	TEST_ASSERT("galvanic_prod_drained" in icon_states(prod.icon), "The prod has no drained sprite")
	TEST_ASSERT("biometal_slug" in icon_states(/obj/projectile/bullet/arcfiend_slug::icon), "The slug has no sprite")
	TEST_ASSERT("power_counter" in icon_states(/atom/movable/screen/arcfiend_power::icon), "The power counter has no sprite")
	TEST_ASSERT(/obj/effect/arcfiend_spark::icon_state in icon_states(/obj/effect/arcfiend_spark::icon), "The lightning ball has no sprite")
	TEST_ASSERT(/datum/antagonist/arcfiend::antag_hud_name in icon_states(/datum/antagonist/arcfiend::hud_icon), "The antag HUD marker has no sprite")
	TEST_ASSERT("thunderclap_release" in icon_states(/obj/effect/temp_visual/arcfiend_thunderclap::icon), "The Thunderclap shockwave has no sprite")

	// The sprites each power shows on the arcfiend and the people around them
	for(var/toggle_type in subtypesof(/datum/action/cooldown/arcfiend/toggle))
		var/datum/action/cooldown/arcfiend/toggle/toggle = allocate(toggle_type)
		if(!toggle.effect_icon)
			continue
		for(var/suffix in list("", "_on", "_off"))
			TEST_ASSERT("[toggle.effect_state][suffix]" in icon_states(toggle.effect_icon), "[toggle_type] has no [toggle.effect_state][suffix] sprite")
	var/list/effect_sprites = list(
		'bastionstation/icons/effects/arcfiend/arcfiend_overdrive.dmi' = list("overdrive_activate", "overdrive_trail"),
		'bastionstation/icons/effects/arcfiend/arcfiend_electrokinetic_smash.dmi' = list("smash_hit", "smash_chain"),
		'bastionstation/icons/effects/arcfiend/arcfiend_sap_power.dmi' = list("sap_power_aura", "sap_power_link", "sap_power_source"),
		'bastionstation/icons/effects/arcfiend/arcfiend_surge_reflex.dmi' = list("surge_reflex"),
		'bastionstation/icons/effects/arcfiend/arcfiend_magnetic_shield.dmi' = list("magnetic_shield_field", "magnetic_shield_up", "magnetic_shield_down", "magnetic_shield_block", "magnetic_shield_break"),
		'bastionstation/icons/effects/arcfiend/arcfiend_vaporize_restraints_effect.dmi' = list("vaporize_restraints"),
		'bastionstation/icons/effects/arcfiend/arcfiend_jumpstart.dmi' = list("jumpstart_charging", "jumpstart_revive"),
		'bastionstation/icons/effects/arcfiend/arcfiend_thunderclap.dmi' = list("thunderclap_charge"),
		'bastionstation/icons/effects/arcfiend/arcfiend_thunderclap_struck.dmi' = list("thunderclap_struck"),
		'bastionstation/icons/effects/arcfiend/arcfiend_tether_hook.dmi' = list("hook"),
		'bastionstation/icons/obj/antags/arcfiend/arcfiend_emag.dmi' = list("arcfiend_emag"),
		'bastionstation/icons/obj/antags/arcfiend/arcfiend_coilgun.dmi' = list("arcfiend_coilgun"),
		'bastionstation/icons/obj/antags/arcfiend/arcfiend_injector.dmi' = list("arcfiend_injector"),
		'bastionstation/icons/obj/antags/arcfiend/arcfiend_lateral_laser.dmi' = list("lateral_laser"),
		'bastionstation/icons/effects/arcfiend/arcfiend_lateral_laser_fx.dmi' = list("lateral_laser_beam", "lateral_laser_muzzle", "lateral_laser_impact", "lateral_laser_rupture", "lateral_laser_projectile"),
		'bastionstation/icons/obj/antags/arcfiend/arcfiend_tether.dmi' = list("biometal_tether", "biometal_tether_hook", "biometal_tether_beam"),
		'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_tether_lefthand.dmi' = list("biometal_tether"),
		'bastionstation/icons/mob/inhands/antag/arcfiend/arcfiend_tether_righthand.dmi' = list("biometal_tether"),
	)
	for(var/sprite_file in effect_sprites)
		for(var/sprite_state in effect_sprites[sprite_file])
			TEST_ASSERT(sprite_state in icon_states(sprite_file), "[sprite_file] has no [sprite_state] sprite")

/// The antagonist selection menu gets a picture of its own, not a placeholder
/datum/unit_test/arcfiend/preview_icon/Run()
	var/datum/antagonist/arcfiend/example = allocate(/datum/antagonist/arcfiend)
	var/icon/preview = example.get_preview_icon()
	TEST_ASSERT_NOTNULL(preview, "The arcfiend should have a picture in the antagonist selection menu")
	TEST_ASSERT_EQUAL(preview.Width(), ANTAGONIST_PREVIEW_ICON_SIZE, "The picture should be the size the menu uses")

/// A toggle that is on shows its sprites on the arcfiend, and takes them off again when it is switched off or taken away
/datum/unit_test/arcfiend/toggle_visuals/Run()
	if(!make_arcfiend())
		return
	antag.power = 1000
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/toggle/overdrive_sprint), "Could not buy Overdrive Sprint")
	var/datum/action/cooldown/arcfiend/toggle/overdrive_sprint/overdrive = locate() in user.actions
	var/overlays_before = length(user.overlays)
	overdrive.switch_on()
	TEST_ASSERT_NOTNULL(overdrive.visuals?["body"], "Switching on should show the body sprite")
	TEST_ASSERT(length(user.overlays) > overlays_before, "The body sprite should be on the arcfiend")
	overdrive.switch_off()
	TEST_ASSERT_NOTNULL(overdrive.visuals?["body"], "Switching off should play the off sprite")
	overdrive.remove_visual("body")
	overdrive.remove_visual("activate")
	TEST_ASSERT(!length(overdrive.visuals), "A removed sprite should be forgotten")
	TEST_ASSERT_EQUAL(length(user.overlays), overlays_before, "A removed sprite should come off the arcfiend")

/// The starting kit, the passives that come with the antag, and taking the antag away again
/datum/unit_test/arcfiend/core/Run()
	if(!make_arcfiend())
		return
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_SHOCKIMMUNE), "An arcfiend should be shock immune")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE), "An arcfiend should be immune to tesla shocks")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_KNOW_ALL_WIRES), "An arcfiend should know what every wire does")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD), "An arcfiend should have the diagnostic HUD trait")
	TEST_ASSERT_EQUAL(user.electrocute_act(50, "test shock"), FALSE, "An arcfiend should not take electric shocks")
	TEST_ASSERT_EQUAL(user.getFireLoss(), 0, "An arcfiend that was shocked shouldn't be burned")
	TEST_ASSERT_EQUAL(user.physiology.burn_mod, 1, "An arcfiend should take burn damage like anyone else")
	TEST_ASSERT_EQUAL(user.physiology.stamina_mod, 1, "An arcfiend should take stamina damage like anyone else")
	TEST_ASSERT_EQUAL(user.physiology.brute_mod, 1, "An arcfiend should not resist brute damage")

	for(var/power_type in list(/datum/action/cooldown/arcfiend/sap_power, /datum/action/cooldown/arcfiend/ride_lightning, /datum/action/cooldown/arcfiend/charge, /datum/action/cooldown/arcfiend/grown_item/shock_prod, /datum/action/cooldown/arcfiend/jumpstart))
		TEST_ASSERT_NOTNULL(locate(power_type) in user.actions, "An arcfiend should start with [power_type]")

	var/found_drain_objective = FALSE
	var/found_ending_objective = FALSE
	for(var/datum/objective/objective as anything in antag.objectives)
		if(istype(objective, /datum/objective/arcfiend_drain))
			found_drain_objective = TRUE
		if(istype(objective, /datum/objective/escape) || istype(objective, /datum/objective/hijack))
			found_ending_objective = TRUE
	TEST_ASSERT(found_drain_objective, "An arcfiend should get a drain objective")
	TEST_ASSERT(found_ending_objective, "An arcfiend should get an escape or hijack objective")

	user.mind.remove_antag_datum(/datum/antagonist/arcfiend)
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_SHOCKIMMUNE), "Losing the antag should remove shock immunity")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_KNOW_ALL_WIRES), "Losing the antag should remove wire knowledge")
	TEST_ASSERT_EQUAL(user.physiology.burn_mod, 1, "Losing the antag should restore burn damage")
	TEST_ASSERT_EQUAL(user.physiology.stamina_mod, 1, "Losing the antag should restore stamina damage")
	TEST_ASSERT_NULL(locate(/datum/action/cooldown/arcfiend) in user.actions, "Losing the antag should remove the powers")

/// Buying powers and upgrades, and the mind gate
/datum/unit_test/arcfiend/shop/Run()
	if(!make_arcfiend())
		return
	var/sap_type = /datum/action/cooldown/arcfiend/sap_power
	antag.power = 2500

	TEST_ASSERT_EQUAL(antag.get_max_power_level(sap_type), 3, "The starter powers should have 3 levels")
	TEST_ASSERT_EQUAL(antag.get_power_level(sap_type), 1, "The starter powers should start at level 1")

	// Upgrading needs minds
	TEST_ASSERT(!antag.upgrade_power(sap_type), "Upgrading to level 2 should need a drained mind")
	TEST_ASSERT_EQUAL(antag.power, 2500, "A refused upgrade should not cost power")
	antag.bonus_minds_drained = 1
	TEST_ASSERT(antag.upgrade_power(sap_type), "Upgrading to level 2 should work with 1 drained mind")
	TEST_ASSERT_EQUAL(antag.get_power_level(sap_type), 2, "Sap Power should be level 2")
	TEST_ASSERT_EQUAL(antag.power, 2350, "Upgrading to level 2 should cost 150")
	var/datum/action/cooldown/arcfiend/sap_power/sap = locate(sap_type) in user.actions
	TEST_ASSERT_NOTNULL(sap, "The arcfiend should have Sap Power")
	TEST_ASSERT(sap.get_drain_speed() > 1.3 && sap.get_drain_speed() < 1.4, "Level 2 Sap Power should drain 33% faster, got [sap.get_drain_speed()]")

	TEST_ASSERT(!antag.upgrade_power(sap_type), "Upgrading to level 3 should need 3 drained minds")
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.upgrade_power(sap_type), "Upgrading to level 3 should work with 3 drained minds")
	TEST_ASSERT(!antag.upgrade_power(sap_type), "A fully upgraded power should not upgrade further")
	TEST_ASSERT_EQUAL(antag.get_power_level(sap_type), 3, "Sap Power should be level 3")

	// Not enough power
	antag.power = 0
	TEST_ASSERT(!antag.purchase_power(/datum/action/cooldown/arcfiend/passive/nanite_regeneration), "Buying with no power should fail")
	TEST_ASSERT(!antag.has_power_unlocked(/datum/action/cooldown/arcfiend/passive/nanite_regeneration), "A failed purchase should not unlock the power")

	// Buying a new power
	antag.power = 2500
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/passive/nanite_regeneration), "Buying Nanite Regeneration should work")
	TEST_ASSERT(!antag.purchase_power(/datum/action/cooldown/arcfiend/passive/nanite_regeneration), "Buying a power twice should fail")
	// A passive has no button, so it isn't in the mob's list of actions, but the antag still owns it like any other power
	TEST_ASSERT_NOTNULL(antag.get_power_instance(/datum/action/cooldown/arcfiend/passive/nanite_regeneration), "A bought power should be granted")
	TEST_ASSERT_NULL(locate(/datum/action/cooldown/arcfiend/passive/nanite_regeneration) in user.actions, "A passive has no button, so it should not be in the mob's list of actions")
	TEST_ASSERT_EQUAL(antag.power, 2300, "Nanite Regeneration should cost 200")

	// Tier 2 needs a mind
	antag.bonus_minds_drained = 0
	TEST_ASSERT(!antag.purchase_power(/datum/action/cooldown/arcfiend/passive/ampullary_sense), "A tier 2 power should need a drained mind")
	antag.bonus_minds_drained = 1
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/passive/ampullary_sense), "A tier 2 power should work with 1 drained mind")

	// Fake paths
	TEST_ASSERT(!antag.purchase_power(/datum/action/cooldown/arcfiend/passive), "The passive base type isn't for sale")
	TEST_ASSERT(!antag.purchase_power(/obj/item), "Non-powers can't be bought")

	// The shop data builds without trouble and lists every power with sensible numbers
	var/list/data = antag.ui_data(user)
	var/list/shop_powers = get_arcfiend_shop_powers()
	TEST_ASSERT_EQUAL(length(data["powers"]), length(shop_powers), "Every shop power should be in the shop data")
	TEST_ASSERT(length(shop_powers) >= 11, "Expected at least the 5 starters and 6 other powers in the shop, got [length(shop_powers)]")
	for(var/list/power_data as anything in data["powers"])
		if(power_data["path"] == "[sap_type]")
			TEST_ASSERT_EQUAL(power_data["max_level"], 3, "Sap Power should show 3 levels in the shop")
			TEST_ASSERT_EQUAL(power_data["level"], 3, "Sap Power should show level 3 in the shop")
			TEST_ASSERT(isnull(power_data["cost"]), "A fully upgraded power should show no cost")
	var/list/static_data = antag.ui_static_data(user)
	TEST_ASSERT_EQUAL(length(static_data["tier_requirements"]), 3, "There should be 3 tier requirements")

/// Each of the passives actually applies what it says it does, at every level
/datum/unit_test/arcfiend/passives/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3

	// Ampullary Sense: night vision, then thermal vision, and the dark is lifted further than ordinary night vision
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/passive/ampullary_sense), "Could not buy Ampullary Sense")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_TRUE_NIGHT_VISION), "Ampullary Sense should give night vision")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_THERMAL_VISION), "Level 1 Ampullary Sense should not give thermal vision")
	user.lighting_cutoff = 0
	SEND_SIGNAL(user, COMSIG_MOB_UPDATE_SIGHT)
	TEST_ASSERT(user.lighting_cutoff >= ARCFIEND_NIGHT_VISION_CUTOFF, "Ampullary Sense should lift the dark by at least [ARCFIEND_NIGHT_VISION_CUTOFF], got [user.lighting_cutoff]")
	TEST_ASSERT(ARCFIEND_NIGHT_VISION_CUTOFF > LIGHTING_CUTOFF_HIGH, "Ampullary Sense should be brighter than ordinary night vision")
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/passive/ampullary_sense), "Could not upgrade Ampullary Sense")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_TRUE_NIGHT_VISION), "Upgraded Ampullary Sense should keep night vision")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_THERMAL_VISION), "Upgraded Ampullary Sense should give thermal vision")
	user.lighting_cutoff = 0
	SEND_SIGNAL(user, COMSIG_MOB_UPDATE_SIGHT)
	TEST_ASSERT(user.lighting_cutoff >= ARCFIEND_NIGHT_VISION_CUTOFF_UPGRADED, "Upgraded Ampullary Sense should lift the dark by at least [ARCFIEND_NIGHT_VISION_CUTOFF_UPGRADED], got [user.lighting_cutoff]")

	// Capacitive Soles: quiet, then no slipping
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/passive/capacitive_soles), "Could not buy Capacitive Soles")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_SILENT_FOOTSTEPS), "Capacitive Soles should silence footsteps")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_NO_SLIP_ALL), "Level 1 Capacitive Soles should not stop slipping")
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/passive/capacitive_soles), "Could not upgrade Capacitive Soles")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_SILENT_FOOTSTEPS), "Upgraded Capacitive Soles should stay silent")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_NO_SLIP_ALL), "Upgraded Capacitive Soles should stop slipping")

	// Nanite Regeneration heals over time, and heals faster when upgraded
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/passive/nanite_regeneration), "Could not buy Nanite Regeneration")
	user.adjustBruteLoss(30)
	user.adjustFireLoss(30)
	var/brute_before = user.getBruteLoss()
	var/burn_before = user.getFireLoss()
	SEND_SIGNAL(user, COMSIG_LIVING_LIFE, 1, 1)
	TEST_ASSERT(user.getBruteLoss() < brute_before, "Nanite Regeneration should heal brute damage")
	TEST_ASSERT(user.getFireLoss() < burn_before, "Nanite Regeneration should heal burn damage")
	var/level_1_heal = brute_before - user.getBruteLoss()
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/passive/nanite_regeneration), "Could not upgrade Nanite Regeneration")
	brute_before = user.getBruteLoss()
	SEND_SIGNAL(user, COMSIG_LIVING_LIFE, 1, 1)
	TEST_ASSERT((brute_before - user.getBruteLoss()) > level_1_heal, "Upgraded Nanite Regeneration should heal faster")

	// Organ Resonance repairs damaged organs
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/passive/organ_resonance), "Could not buy Organ Resonance")
	user.adjustOrganLoss(ORGAN_SLOT_HEART, 20)
	var/organ_damage_before = user.get_organ_loss(ORGAN_SLOT_HEART)
	TEST_ASSERT(organ_damage_before > 0, "The test could not damage the heart")
	SEND_SIGNAL(user, COMSIG_LIVING_LIFE, 1, 1)
	TEST_ASSERT(user.get_organ_loss(ORGAN_SLOT_HEART) < organ_damage_before, "Organ Resonance should repair organ damage")

	// Taking the antag away undoes all of it
	user.mind.remove_antag_datum(/datum/antagonist/arcfiend)
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_TRUE_NIGHT_VISION), "Losing the antag should remove night vision")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_THERMAL_VISION), "Losing the antag should remove thermal vision")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_SILENT_FOOTSTEPS), "Losing the antag should remove silent footsteps")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_NO_SLIP_ALL), "Losing the antag should remove no-slip")

/// Surge Reflex clears stuns, heals, and restores all stamina
/datum/unit_test/arcfiend/surge_reflex/Run()
	if(!make_arcfiend())
		return
	antag.power = 500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/surge_reflex), "Could not buy Surge Reflex")
	var/datum/action/cooldown/arcfiend/surge_reflex/surge = locate() in user.actions
	TEST_ASSERT_NOTNULL(surge, "The arcfiend should have Surge Reflex")
	user.Paralyze(20 SECONDS)
	user.Knockdown(20 SECONDS)
	user.adjustBruteLoss(40)
	user.stamina.adjust(-50)
	TEST_ASSERT(user.stamina.current < user.stamina.maximum, "The test could not drain the arcfiend's stamina")
	TEST_ASSERT(user.IsParalyzed(), "The test could not paralyze the arcfiend")
	var/power_before = antag.power
	var/brute_before = user.getBruteLoss()
	TEST_ASSERT(surge.Activate(user), "Surge Reflex should activate")
	TEST_ASSERT(!user.IsParalyzed(), "Surge Reflex should clear paralysis")
	TEST_ASSERT(!user.IsKnockdown(), "Surge Reflex should clear knockdowns")
	TEST_ASSERT(user.getBruteLoss() < brute_before, "Surge Reflex should heal")
	TEST_ASSERT_EQUAL(user.stamina.current, user.stamina.maximum, "Surge Reflex should restore all stamina")
	TEST_ASSERT_EQUAL(antag.power, power_before - surge.power_cost, "Surge Reflex should cost its power")
	TEST_ASSERT(next_use_time_is_in_future(surge), "Surge Reflex should go on cooldown")

	// For a few seconds after, nothing can stun or slow them down
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_STUNIMMUNE), "Surge Reflex should make the arcfiend immune to stuns")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_IGNOREDAMAGESLOWDOWN), "Surge Reflex should stop damage from slowing the arcfiend down")
	user.Paralyze(5 SECONDS)
	TEST_ASSERT(!user.IsParalyzed(), "The arcfiend shouldn't be paralyzed right after Surge Reflex")
	surge.end_immunity(user)
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_STUNIMMUNE), "The stun immunity should wear off")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_IGNOREDAMAGESLOWDOWN), "The damage slowdown immunity should wear off")
	user.Paralyze(5 SECONDS)
	TEST_ASSERT(user.IsParalyzed(), "The arcfiend should be stunnable again once it wears off")
	user.SetParalyzed(0)

	// Without the power it can't be used
	antag.power = 0
	surge.next_use_time = 0
	TEST_ASSERT(!surge.IsAvailable(), "Surge Reflex should be unavailable with no power")

/datum/unit_test/arcfiend/surge_reflex/proc/next_use_time_is_in_future(datum/action/cooldown/action)
	return action.next_use_time > world.time

/// EMPs hurt arcfiends and scatter their power, but never what they carry
/datum/unit_test/arcfiend/emp/Run()
	if(!make_arcfiend())
		return
	var/obj/item/gun/energy/laser/arcfiend_gun = allocate(/obj/item/gun/energy/laser)
	user.put_in_hands(arcfiend_gun)
	TEST_ASSERT_EQUAL(arcfiend_gun.loc, user, "The test could not hand the arcfiend a gun")

	// A control, so that we know an EMP really does drain this gun when nothing protects it
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/gun/energy/laser/bystander_gun = allocate(/obj/item/gun/energy/laser)
	bystander.put_in_hands(bystander_gun)
	var/bystander_charge = bystander_gun.cell.charge
	bystander.emp_act(EMP_HEAVY)
	TEST_ASSERT(bystander_gun.cell.charge < bystander_charge, "The control gun should lose charge to an EMP, otherwise this test proves nothing")

	// A heavy EMP
	antag.power = 1000
	var/gun_charge = arcfiend_gun.cell.charge
	user.emp_act(EMP_HEAVY)
	TEST_ASSERT(user.getFireLoss() > 0, "A heavy EMP should burn the arcfiend")
	TEST_ASSERT_EQUAL(antag.power, 750, "A heavy EMP should scatter 25% of the stored power")
	TEST_ASSERT_EQUAL(arcfiend_gun.cell.charge, gun_charge, "An arcfiend's carried gun should be safe from EMPs")

	// A light EMP
	antag.power = 1000
	var/burn_before = user.getFireLoss()
	user.emp_act(EMP_LIGHT)
	TEST_ASSERT(user.getFireLoss() > burn_before, "A light EMP should burn the arcfiend")
	TEST_ASSERT_EQUAL(antag.power, 900, "A light EMP should scatter 10% of the stored power")
	TEST_ASSERT_EQUAL(arcfiend_gun.cell.charge, gun_charge, "An arcfiend's carried gun should be safe from light EMPs too")

/// Sap Power takes from what it should and gives to the arcfiend, and upgrades make it faster
/datum/unit_test/arcfiend/sap/Run()
	if(!make_arcfiend())
		return

	// A person
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(victim.can_arcfiend_drain(user), "A living person should be drainable")
	TEST_ASSERT(!user.can_arcfiend_drain(user), "An arcfiend shouldn't drain themselves")
	var/gained = victim.arcfiend_drain(user, antag, 1)
	TEST_ASSERT_EQUAL(gained, ARCFIEND_DRAIN_MOB, "Draining a person for a second should give [ARCFIEND_DRAIN_MOB] power")
	TEST_ASSERT_EQUAL(antag.power, ARCFIEND_DRAIN_MOB, "The arcfiend should hold what it drained")
	TEST_ASSERT_EQUAL(antag.total_drained, ARCFIEND_DRAIN_MOB, "The drain objective total should count what was drained")
	TEST_ASSERT(victim.getFireLoss() > 0, "Being drained should burn the victim")
	TEST_ASSERT_EQUAL(antag.get_minds_drained(), 0, "A person with no client should not count as a mind drained")
	var/gained_faster = victim.arcfiend_drain(user, antag, 2)
	TEST_ASSERT_EQUAL(gained_faster, ARCFIEND_DRAIN_MOB * 2, "Draining for twice as long should give twice as much")
	victim.death()
	TEST_ASSERT(!victim.can_arcfiend_drain(user), "A dead person should not be drainable")

	// The pool has a cap
	antag.power = antag.power_cap - 5
	var/mob/living/carbon/human/victim_two = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT_EQUAL(victim_two.arcfiend_drain(user, antag, 1), 5, "An almost full pool should only take what fits")
	TEST_ASSERT_EQUAL(antag.power, antag.power_cap, "The pool should be full")
	TEST_ASSERT_EQUAL(victim_two.arcfiend_drain(user, antag, 1), 0, "A full pool should take nothing")

	// A cyborg
	antag.power = 0
	var/mob/living/silicon/robot/borg = allocate(/mob/living/silicon/robot)
	TEST_ASSERT_NOTNULL(borg.cell, "The test cyborg has no cell")
	TEST_ASSERT(borg.can_arcfiend_drain(user), "A cyborg with a charged cell should be drainable")
	var/borg_charge = borg.cell.charge
	TEST_ASSERT(borg.arcfiend_drain(user, antag, 1) > 0, "Draining a cyborg should give power")
	TEST_ASSERT(borg.cell.charge < borg_charge, "Draining a cyborg should empty its cell")

	// An SMES, whose charge lives in its cells and not in its charge var
	antag.power = 0
	var/obj/machinery/power/smes/smes = allocate(/obj/machinery/power/smes)
	smes.adjust_charge(STANDARD_BATTERY_CHARGE)
	TEST_ASSERT(smes.arcfiend_total_charge() > 0, "The test could not charge the SMES")
	TEST_ASSERT(smes.can_arcfiend_drain(user), "A charged SMES should be drainable")
	var/smes_charge = smes.arcfiend_total_charge()
	var/smes_gain = smes.arcfiend_drain(user, antag, 1)
	TEST_ASSERT(smes_gain > 0 && smes_gain <= ARCFIEND_DRAIN_SMES, "Draining an SMES should give some power, got [smes_gain]")
	TEST_ASSERT(smes.arcfiend_total_charge() < smes_charge, "Draining an SMES should empty it")

	// An APC
	antag.power = 0
	var/obj/machinery/power/apc/apc = allocate(/obj/machinery/power/apc)
	// The test world doesn't give a new APC its battery, so it gets one here
	if(!apc.cell)
		apc.cell = new /obj/item/stock_parts/power_store/battery/upgraded(apc)
	TEST_ASSERT_NOTNULL(apc.cell, "The test APC has no cell")
	TEST_ASSERT(apc.can_arcfiend_drain(user), "An APC with a charged cell should be drainable")
	var/apc_charge = apc.cell.charge
	var/apc_gain = apc.arcfiend_drain(user, antag, 1)
	TEST_ASSERT(apc_gain > 0 && apc_gain <= ARCFIEND_DRAIN_APC, "Draining an APC should give some power, got [apc_gain]")
	TEST_ASSERT(apc.cell.charge < apc_charge, "Draining an APC should empty its cell")

	// Upgrades make it faster
	var/datum/action/cooldown/arcfiend/sap_power/sap = locate() in user.actions
	TEST_ASSERT_NOTNULL(sap, "The arcfiend should have Sap Power")
	TEST_ASSERT_EQUAL(sap.get_drain_speed(), 1, "Level 1 Sap Power should drain at normal speed")

/// Charge refills cells, costs power, and ignores things that aren't tech
/datum/unit_test/arcfiend/charge/Run()
	if(!make_arcfiend())
		return
	var/datum/action/cooldown/arcfiend/charge/charge = locate() in user.actions
	TEST_ASSERT_NOTNULL(charge, "The arcfiend should have Charge")

	// Nothing to charge
	antag.power = 500
	TEST_ASSERT(!charge.Activate(user), "Charge should do nothing with empty hands")
	TEST_ASSERT_EQUAL(antag.power, 500, "A Charge with no target should be free")

	// A gun with an empty cell
	var/obj/item/gun/energy/laser/arcfiend_gun = allocate(/obj/item/gun/energy/laser)
	user.put_in_hands(arcfiend_gun)
	arcfiend_gun.cell.use(arcfiend_gun.cell.charge)
	TEST_ASSERT_EQUAL(arcfiend_gun.cell.charge, 0, "The test could not empty the gun")
	TEST_ASSERT(charge.Activate(user), "Charge should work on a gun")
	TEST_ASSERT_EQUAL(arcfiend_gun.cell.charge, arcfiend_gun.cell.maxcharge, "Charge should fill the gun's cell")
	TEST_ASSERT(antag.power < 500, "Charge should cost power")
	var/power_after_charge = antag.power
	TEST_ASSERT(!charge.Activate(user), "Charge should do nothing when everything is already full")
	TEST_ASSERT_EQUAL(antag.power, power_after_charge, "Charging something full should be free")

	// Not enough power only fills part of it
	arcfiend_gun.cell.use(arcfiend_gun.cell.charge)
	antag.power = 1
	TEST_ASSERT(charge.Activate(user), "Charge should still do what it can with little power")
	TEST_ASSERT(arcfiend_gun.cell.charge > 0 && arcfiend_gun.cell.charge < arcfiend_gun.cell.maxcharge, "With 1 power Charge should only part fill a cell")
	TEST_ASSERT_EQUAL(antag.power, 0, "Charge should use up what it was given")

	// A level 2 charge goes further for the same power
	antag.bonus_minds_drained = 1
	antag.power = 2500
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/charge), "Could not upgrade Charge")
	TEST_ASSERT(charge.get_joules_per_power() > ARCFIEND_JOULES_PER_POWER, "An upgraded Charge should be more efficient")

	// Magic is not technology
	user.drop_all_held_items()
	var/obj/item/gun/magic/staff/change/staff = allocate(/obj/item/gun/magic/staff/change)
	user.put_in_hands(staff)
	antag.power = 500
	TEST_ASSERT(!charge.Activate(user), "Charge should do nothing to a magic staff")
	TEST_ASSERT_EQUAL(antag.power, 500, "Charging a magic staff should be free")

/// Riding the cables: only along cables, costs power, cutting one throws you out
/datum/unit_test/arcfiend/ride_lightning/Run()
	if(!make_arcfiend())
		return
	var/datum/action/cooldown/arcfiend/ride_lightning/ride = locate() in user.actions
	TEST_ASSERT_NOTNULL(ride, "The arcfiend should have Ride the Lightning")

	var/turf/start_turf = run_loc_floor_bottom_left
	var/turf/second_turf = get_step(start_turf, EAST)
	var/turf/third_turf = get_step(second_turf, EAST)
	TEST_ASSERT(isturf(second_turf) && isturf(third_turf), "The test room is too small for the cable test")
	var/obj/structure/cable/first_cable = allocate(/obj/structure/cable, start_turf)
	var/obj/structure/cable/second_cable = allocate(/obj/structure/cable, second_turf)
	var/obj/structure/cable/third_cable = allocate(/obj/structure/cable, third_turf)
	TEST_ASSERT(first_cable.linked_dirs & EAST, "The test cables did not link up")
	user.forceMove(start_turf)

	// No power, no ride
	antag.power = 0
	TEST_ASSERT(!ride.Activate(user), "Riding with no power should fail")
	TEST_ASSERT(isturf(user.loc), "A failed ride should leave the arcfiend where they were")

	// Not on a cable
	antag.power = 1000
	user.forceMove(get_step(start_turf, NORTH))
	TEST_ASSERT(!ride.Activate(user), "Riding with no cable under you should fail")
	TEST_ASSERT_EQUAL(antag.power, 1000, "A refused ride should be free")
	user.forceMove(start_turf)

	// Entering
	TEST_ASSERT(ride.Activate(user), "Riding should work on a cable")
	var/obj/effect/dummy/phased_mob/arcfiend_lightning/ride_dummy = user.loc
	TEST_ASSERT(istype(ride_dummy), "The arcfiend should be riding the lightning")
	TEST_ASSERT_EQUAL(antag.power, 1000 - ARCFIEND_RIDE_ENTRY_COST, "Entering the cables should cost [ARCFIEND_RIDE_ENTRY_COST]")
	TEST_ASSERT_NOTNULL(ride_dummy.spark, "A visible ball of lightning should follow a rider")
	TEST_ASSERT_EQUAL(ride_dummy.spark.loc, start_turf, "The ball of lightning should start with the rider")
	TEST_ASSERT(ride_dummy.spark.invisibility == 0, "The ball of lightning should be visible")

	// Upkeep, even standing still
	var/power_before = antag.power
	ride_dummy.process(2)
	TEST_ASSERT(antag.power < power_before, "Riding should drain power even when standing still")

	// Moving along the cables
	sleep(0.5 SECONDS)
	power_before = antag.power
	ride_dummy.relaymove(user, EAST)
	TEST_ASSERT_EQUAL(get_turf(ride_dummy), second_turf, "The rider should move along the cable")
	TEST_ASSERT_EQUAL(ride_dummy.spark.loc, second_turf, "The ball of lightning should follow the rider")
	TEST_ASSERT(antag.power < power_before, "Moving a tile should cost power")

	// Not off the road
	sleep(0.5 SECONDS)
	power_before = antag.power
	ride_dummy.relaymove(user, NORTH)
	TEST_ASSERT_EQUAL(get_turf(ride_dummy), second_turf, "The rider should not leave the cables")
	TEST_ASSERT_EQUAL(antag.power, power_before, "Bumping into nothing should be free")
	TEST_ASSERT_EQUAL(user.loc, ride_dummy, "Bumping into nothing should not eject the rider")

	// Not diagonally
	sleep(0.5 SECONDS)
	ride_dummy.relaymove(user, NORTHEAST)
	TEST_ASSERT_EQUAL(get_turf(ride_dummy), second_turf, "The rider should not move diagonally")

	// Onwards to the third cable
	sleep(0.5 SECONDS)
	ride_dummy.relaymove(user, EAST)
	TEST_ASSERT_EQUAL(get_turf(ride_dummy), third_turf, "The rider should reach the third cable")

	// Someone cuts the cable behind us and we try to ride back over it
	qdel(second_cable)
	sleep(0.5 SECONDS)
	ride_dummy.relaymove(user, WEST)
	TEST_ASSERT(isturf(user.loc), "Riding over a cut cable should throw the arcfiend out")
	TEST_ASSERT_EQUAL(get_turf(user), third_turf, "The arcfiend should be thrown out where they were")
	TEST_ASSERT(user.IsParalyzed(), "Riding over a cut cable should stun the arcfiend")
	TEST_ASSERT(QDELETED(ride_dummy), "The ride should be over")
	TEST_ASSERT(QDELETED(ride_dummy.spark) || isnull(ride_dummy.spark), "The ball of lightning should go away with the ride")

	// Leaving by choice
	user.SetParalyzed(0)
	ride.next_use_time = 0
	antag.power = 1000
	TEST_ASSERT(ride.Activate(user), "Could not ride again")
	var/obj/effect/dummy/phased_mob/arcfiend_lightning/second_ride = user.loc
	TEST_ASSERT(istype(second_ride), "The arcfiend should be riding again")
	TEST_ASSERT(ride.Activate(user), "Using the power while riding should leave the cables")
	TEST_ASSERT(isturf(user.loc), "The arcfiend should be out of the cables")
	TEST_ASSERT(!user.IsParalyzed(), "Leaving by choice should not stun")

	// The cable under the rider being removed throws them out
	user.forceMove(second_turf)
	TEST_ASSERT(!(locate(/obj/structure/cable) in second_turf), "The second cable should be gone")
	user.forceMove(third_turf)
	ride.next_use_time = 0
	antag.power = 1000
	TEST_ASSERT(ride.Activate(user), "Could not ride a third time")
	var/obj/effect/dummy/phased_mob/arcfiend_lightning/third_ride = user.loc
	qdel(third_cable)
	third_ride.process(1)
	TEST_ASSERT(isturf(user.loc), "Losing the cable under you should throw you out")
	TEST_ASSERT(user.IsParalyzed(), "Losing the cable under you should stun")

	// Running out of power throws you out
	user.SetParalyzed(0)
	allocate(/obj/structure/cable, third_turf)
	ride.next_use_time = 0
	antag.power = ARCFIEND_RIDE_ENTRY_COST
	TEST_ASSERT(ride.Activate(user), "Could not ride a fourth time")
	var/obj/effect/dummy/phased_mob/arcfiend_lightning/fourth_ride = user.loc
	TEST_ASSERT(istype(fourth_ride), "The arcfiend should be riding a fourth time")
	fourth_ride.process(5)
	TEST_ASSERT(isturf(user.loc), "Running out of power should throw you out")

/// Pressing the drop key dispels what an arcfiend has grown instead of dropping it, and cancels a power that is ready
/datum/unit_test/arcfiend/drop_key/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/grown_item/electric_emag), "Could not buy Electric Emag")
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun), "Could not buy Manifest Coilgun")
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/brain_scramble), "Could not buy Brain Scramble")

	// The electric emag
	var/datum/action/cooldown/arcfiend/grown_item/electric_emag/emag_action = locate() in user.actions
	TEST_ASSERT(emag_action.Activate(user), "Could not grow the electric emag")
	var/obj/item/card/emag/arcfiend/emag = locate() in user.held_items
	TEST_ASSERT_NOTNULL(emag, "The electric emag should be in the arcfiend's hand")
	TEST_ASSERT(SEND_SIGNAL(user, COMSIG_KB_MOB_DROPITEM_DOWN) & COMSIG_KB_ACTIVATED, "The drop key should be taken by the electric emag")
	TEST_ASSERT(QDELETED(emag), "The drop key should dispel the electric emag")
	TEST_ASSERT_NULL(locate(/obj/item/card/emag/arcfiend) in user.held_items, "The electric emag should be gone from the arcfiend's hands")

	// The coilgun
	emag_action.next_use_time = 0
	var/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/weapon_action = locate() in user.actions
	TEST_ASSERT(weapon_action.Activate(user), "Could not grow the coilgun")
	var/obj/item/gun/energy/arcfiend/coilgun/gun = locate() in user.held_items
	TEST_ASSERT_NOTNULL(gun, "The coilgun should be in the arcfiend's hand")
	TEST_ASSERT(SEND_SIGNAL(user, COMSIG_KB_MOB_DROPITEM_DOWN) & COMSIG_KB_ACTIVATED, "The drop key should be taken by the coilgun")
	TEST_ASSERT(QDELETED(gun), "The drop key should dispel the coilgun")

	// Something ordinary is left to the normal drop
	var/obj/item/crowbar/crowbar = allocate(/obj/item/crowbar)
	user.put_in_hands(crowbar)
	TEST_ASSERT(!(SEND_SIGNAL(user, COMSIG_KB_MOB_DROPITEM_DOWN) & COMSIG_KB_ACTIVATED), "The drop key should not be taken for ordinary items")
	user.drop_all_held_items()

	// A power that is ready shows a hand, and the drop key puts it away
	var/datum/action/cooldown/arcfiend/brain_scramble/scramble = locate() in user.actions
	scramble.set_click_ability(user)
	TEST_ASSERT_NOTNULL(scramble.hand, "A ready power should show a glowing hand")
	TEST_ASSERT_EQUAL(user.click_intercept, scramble, "The ready power should be waiting for a click")
	var/obj/item/melee/touch_attack/arcfiend_hand/glowing_hand = scramble.hand
	TEST_ASSERT(glowing_hand in user.held_items, "The glowing hand should be in the arcfiend's hand")
	TEST_ASSERT(SEND_SIGNAL(user, COMSIG_KB_MOB_DROPITEM_DOWN) & COMSIG_KB_ACTIVATED, "The drop key should be taken by the glowing hand")
	TEST_ASSERT_NULL(user.click_intercept, "The drop key should cancel the ready power")
	TEST_ASSERT(QDELETED(glowing_hand), "The drop key should put the glowing hand away")
	TEST_ASSERT_NULL(scramble.hand, "The power should forget its hand")

	// Using the power puts the hand away too
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	scramble.set_click_ability(user)
	var/obj/item/melee/touch_attack/arcfiend_hand/second_hand = scramble.hand
	TEST_ASSERT_NOTNULL(second_hand, "The power should show a hand again")
	scramble.InterceptClickOn(user, null, victim)
	TEST_ASSERT(QDELETED(second_hand), "Using the power should put the glowing hand away")
	TEST_ASSERT_NULL(user.click_intercept, "Using the power should stop it waiting for a click")

/// An EMP reaches an arcfiend riding the cables, throws them out and stuns them
/datum/unit_test/arcfiend/ride_emp/Run()
	if(!make_arcfiend())
		return
	var/datum/action/cooldown/arcfiend/ride_lightning/ride = locate() in user.actions
	var/turf/start_turf = run_loc_floor_bottom_left
	allocate(/obj/structure/cable, start_turf)
	user.forceMove(start_turf)

	// An EMP from outside
	antag.power = 1000
	TEST_ASSERT(ride.Activate(user), "Could not ride the cables")
	var/obj/effect/dummy/phased_mob/arcfiend_lightning/ride_dummy = user.loc
	TEST_ASSERT(istype(ride_dummy), "The arcfiend should be riding the lightning")
	var/power_before = antag.power
	ride_dummy.emp_act(EMP_HEAVY)
	TEST_ASSERT(isturf(user.loc), "An EMP should throw a riding arcfiend out of the wires")
	TEST_ASSERT(user.IsParalyzed(), "An EMP should stun a riding arcfiend")
	TEST_ASSERT(user.getFireLoss() > 0, "An EMP should still burn a riding arcfiend")
	TEST_ASSERT(antag.power < power_before, "An EMP should still scatter a riding arcfiend's power")
	TEST_ASSERT(QDELETED(ride_dummy), "The ride should be over")

/// An arcfiend can see what every kind of wire does, including ones that nobody else's skills cover
/datum/unit_test/arcfiend/all_wires/Run()
	if(!make_arcfiend())
		return
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human/consistent)

	// Every kind of wire that has its own rules still falls back to the shared check
	var/list/wire_holders = list(
		/obj/machinery/syndicatebomb,
		/obj/machinery/door/airlock,
		/obj/machinery/power/apc,
	)
	for(var/holder_type in wire_holders)
		var/obj/machinery/holder = allocate(holder_type)
		TEST_ASSERT_NOTNULL(holder.wires, "[holder_type] has no wires to test with")
		TEST_ASSERT(holder.wires.can_reveal_wires(user), "An arcfiend should see what the wires of [holder_type] do")
		TEST_ASSERT(!holder.wires.can_reveal_wires(bystander), "An ordinary person should not see what the wires of [holder_type] do")

	// And the knowledge goes with the antag
	user.mind.remove_antag_datum(/datum/antagonist/arcfiend)
	var/obj/machinery/syndicatebomb/bomb = allocate(/obj/machinery/syndicatebomb)
	TEST_ASSERT(!bomb.wires.can_reveal_wires(user), "Losing the antag should lose the wire knowledge")

/// The galvanic prod comes with the antag, zaps like an emagged defib, costs power and has to recharge
/datum/unit_test/arcfiend/shock_prod/Run()
	if(!make_arcfiend())
		return
	var/datum/action/cooldown/arcfiend/grown_item/shock_prod/prod_action = locate() in user.actions
	TEST_ASSERT_NOTNULL(prod_action, "The galvanic prod should come with the antag")
	antag.power = 500

	TEST_ASSERT(prod_action.Activate(user), "Could not grow the galvanic prod")
	var/obj/item/melee/arcfiend_prod/prod = locate() in user.held_items
	TEST_ASSERT_NOTNULL(prod, "The galvanic prod should be in the arcfiend's hand")
	TEST_ASSERT_EQUAL(antag.power, 500, "Growing the prod should be free")

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(prod_action.try_zap(victim, user, prod), "The prod should zap")
	TEST_ASSERT(victim.IsKnockdown(), "A zap should knock the victim down")
	TEST_ASSERT(victim.has_status_effect(/datum/status_effect/convulsing), "A zap should make the victim's hands shake")
	TEST_ASSERT_EQUAL(antag.power, 500 - 40, "A zap should cost 40 power")
	TEST_ASSERT_EQUAL(prod_action.get_charges(), 3, "A zap should take one of the 4 charges")

	// There is a short pause between zaps, and a failed zap costs nothing
	TEST_ASSERT(!prod_action.try_zap(victim, user, prod), "The prod should be recharging")
	TEST_ASSERT_EQUAL(antag.power, 460, "A zap that was refused should be free")
	TEST_ASSERT_EQUAL(prod_action.get_charges(), 3, "A zap that was refused should keep its charges")
	// Putting it away and growing it again doesn't reset the recharge
	TEST_ASSERT(prod_action.dismiss(user), "Could not dismiss the prod")
	prod_action.next_use_time = 0
	TEST_ASSERT(prod_action.Activate(user), "Could not grow the prod again")
	prod = locate() in user.held_items
	TEST_ASSERT(!prod_action.try_zap(victim, user, prod), "A new prod should still be recharging")

	// Recharged, but nobody to zap: not enough power, then a shock immune target
	prod_action.prod_ready_time = 0
	antag.power = 10
	TEST_ASSERT(!prod_action.try_zap(victim, user, prod), "The prod should need power to zap")
	antag.power = 500
	var/mob/living/carbon/human/immune_victim = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(immune_victim, TRAIT_SHOCKIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!prod_action.try_zap(immune_victim, user, prod), "The prod should not affect someone shock immune")
	TEST_ASSERT_EQUAL(antag.power, 500, "Zapping someone shock immune should be free")
	TEST_ASSERT(!prod_action.try_zap(user, user, prod), "The prod should not zap its owner")

	// Each zap takes one charge and costs the same, until the prod is empty
	for(var/zap in 1 to 3)
		prod_action.prod_ready_time = 0
		var/mob/living/carbon/human/next_victim = allocate(/mob/living/carbon/human/consistent)
		TEST_ASSERT(prod_action.try_zap(next_victim, user, prod), "Zap [zap + 1] should work")
		TEST_ASSERT(next_victim.has_status_effect(/datum/status_effect/convulsing), "Zap [zap + 1] should make the victim's hands shake")
		TEST_ASSERT_EQUAL(prod_action.get_charges(), 3 - zap, "Zap [zap + 1] should take one charge")
	TEST_ASSERT_EQUAL(antag.power, 500 - 40 * 3, "Every zap should cost 40 power")
	prod_action.prod_ready_time = 0
	TEST_ASSERT(!prod_action.try_zap(victim, user, prod), "An empty prod should not zap")
	TEST_ASSERT_EQUAL(antag.power, 500 - 40 * 3, "An empty prod should not cost power")

	// One charge coming back is enough for another full zap
	prod_action.charge_recharged()
	TEST_ASSERT_EQUAL(prod_action.get_charges(), 1, "A charge should come back")
	var/mob/living/carbon/human/last_victim = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(prod_action.try_zap(last_victim, user, prod), "One charge should be enough to zap")
	TEST_ASSERT(last_victim.IsKnockdown(), "A zap with the last charge should knock the victim down")
	TEST_ASSERT(last_victim.has_status_effect(/datum/status_effect/convulsing), "A zap with the last charge should be as strong as any other")
	TEST_ASSERT_EQUAL(antag.power, 500 - 40 * 4, "A zap with the last charge should cost the same")
	TEST_ASSERT_EQUAL(prod_action.get_charges(), 0, "The last zap should use the last charge")
	TEST_ASSERT_NOTNULL(prod_action.charge_timer, "A charge should be on its way back")

	// The drop key puts it away
	TEST_ASSERT(SEND_SIGNAL(user, COMSIG_KB_MOB_DROPITEM_DOWN) & COMSIG_KB_ACTIVATED, "The drop key should be taken by the prod")
	TEST_ASSERT(QDELETED(prod), "The drop key should dispel the prod")

/// A plain left-click with the galvanic prod is a free melee hit, and Electrokinetic Smash reacts to it like any other
/datum/unit_test/arcfiend/shock_prod_melee/Run()
	if(!make_arcfiend())
		return
	antag.power = 1000
	antag.bonus_minds_drained = 3
	var/datum/action/cooldown/arcfiend/grown_item/shock_prod/prod_action = locate() in user.actions
	TEST_ASSERT(prod_action.Activate(user), "Could not grow the galvanic prod")
	var/obj/item/melee/arcfiend_prod/prod = locate() in user.held_items
	TEST_ASSERT_NOTNULL(prod, "The galvanic prod should be in the arcfiend's hand")

	// An ordinary hit
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	user.istate &= ~ISTATE_SECONDARY
	prod.attack(victim, user)
	TEST_ASSERT(victim.getFireLoss() >= 14, "A hit with the prod should burn for about 15, got [victim.getFireLoss()]")
	TEST_ASSERT_EQUAL(antag.power, 1000, "A hit with the prod should be free")
	// Knockdown is not checked: the test human is occasionally knocked down for 6 seconds after a hit for a reason that was never found. What matters is that this was not a zap.
	TEST_ASSERT(!victim.has_status_effect(/datum/status_effect/convulsing), "A plain hit should not make the victim's hands shake like a zap does")
	TEST_ASSERT_EQUAL(victim.stamina.loss, 0, "A plain hit should not drain stamina like a zap does")
	TEST_ASSERT_EQUAL(prod_action.get_charges(), ARCFIEND_PROD_MAX_CHARGES, "A plain hit should not use up the prod's charges")
	TEST_ASSERT(!prod_action.prod_ready_time, "A plain hit should not use up the prod's recharge")

	// With Electrokinetic Smash on, it hits harder, and costs the power a Smash hit costs
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash), "Could not buy Electrokinetic Smash")
	var/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/smash = locate() in user.actions
	TEST_ASSERT(smash.Activate(user), "Could not switch on Electrokinetic Smash")
	var/mob/living/carbon/human/second_victim = allocate(/mob/living/carbon/human/consistent)
	var/power_before = antag.power
	prod.attack(second_victim, user)
	TEST_ASSERT(second_victim.getFireLoss() > victim.getFireLoss(), "Electrokinetic Smash should add to a hit with the prod")
	TEST_ASSERT_EQUAL(antag.power, power_before - smash.hit_cost, "Electrokinetic Smash should charge for hits made with the prod")
	smash.Activate(user)

/// The coilgun has a magazine that costs a slug per shot and slowly rebuilds, and putting the gun away doesn't refill it
/datum/unit_test/arcfiend/coilgun_magazine/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun), "Could not buy Manifest Coilgun")
	var/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/weapon_action = locate() in user.actions
	TEST_ASSERT(weapon_action.Activate(user), "Could not grow the coilgun")
	var/obj/item/gun/energy/arcfiend/coilgun/gun = locate() in user.held_items
	TEST_ASSERT_NOTNULL(gun, "The coilgun should be in the arcfiend's hand")
	TEST_ASSERT_EQUAL(weapon_action.get_charges(), 7, "The magazine should start full at 7 slugs")
	TEST_ASSERT(gun.can_shoot(), "A full magazine and plenty of power should be able to shoot")

	// Every fired shot costs power and a slug. The gun hands out a spent round once a shot is fired.
	var/power_before = antag.power
	TEST_ASSERT_NOTNULL(gun.chambered, "The coilgun should have a round ready")
	// The game calls this with no shooter after a single shot, so that is how it is called here too
	gun.chambered.loaded_projectile = null
	gun.process_chamber()
	TEST_ASSERT_EQUAL(weapon_action.get_charges(), 6, "A shot should use up a slug")
	TEST_ASSERT_EQUAL(antag.power, power_before - 15, "A shot should cost 15 power")
	TEST_ASSERT_NOTNULL(gun.chambered?.loaded_projectile, "A fresh round should be ready after a shot, or the second shot just clicks")
	for(var/i in 1 to 6)
		TEST_ASSERT(gun.can_shoot(), "There should still be slugs to shoot")
		TEST_ASSERT_NOTNULL(gun.chambered?.loaded_projectile, "A round should be ready for shot [i + 1]")
		gun.chambered.loaded_projectile = null
		gun.process_chamber()
	TEST_ASSERT_EQUAL(weapon_action.get_charges(), 0, "Seven shots should empty the magazine")
	TEST_ASSERT(!gun.can_shoot(), "An empty magazine should not shoot, however much power there is")
	TEST_ASSERT(antag.power > 1000, "The test should still have plenty of power left")

	// Putting the gun away and growing it again doesn't refill the magazine
	TEST_ASSERT(weapon_action.dismiss(user), "Could not dismiss the coilgun")
	weapon_action.next_use_time = 0
	TEST_ASSERT(weapon_action.Activate(user), "Could not grow the coilgun again")
	gun = locate() in user.held_items
	TEST_ASSERT_EQUAL(weapon_action.get_charges(), 0, "A new coilgun should not have a fresh magazine")
	TEST_ASSERT(!gun.can_shoot(), "A new coilgun should still be out of slugs")

	// A slug is rebuilt, and then there is something to shoot again
	weapon_action.charge_recharged()
	TEST_ASSERT_EQUAL(weapon_action.get_charges(), 1, "A rebuilt slug should go back into the magazine")
	TEST_ASSERT(gun.can_shoot(), "A rebuilt slug should let the gun shoot again")
	TEST_ASSERT_NOTNULL(weapon_action.charge_timer, "The magazine should keep rebuilding slugs until it is full")

	// A bigger magazine with upgrades
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun), "Could not upgrade Manifest Coilgun")
	TEST_ASSERT_EQUAL(weapon_action.get_max_charges(), 8, "Level 2 should hold 8 slugs")
	TEST_ASSERT(weapon_action.get_charge_time() < 8 SECONDS, "Level 2 should rebuild slugs faster")

/// Myoelectric Stimulation speeds up do-afters, clicking and shooting, and gives all of it back exactly when switched off
/datum/unit_test/arcfiend/myoelectric_stimulation/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation), "Could not buy Myoelectric Stimulation")
	var/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation/stim = locate() in user.actions
	TEST_ASSERT_NOTNULL(stim, "The arcfiend should have Myoelectric Stimulation")
	var/slowdown_before = user.cached_multiplicative_actions_slowdown

	TEST_ASSERT(stim.Activate(user), "Could not switch on Myoelectric Stimulation")
	TEST_ASSERT(stim.active, "It should be on")
	TEST_ASSERT(user.cached_multiplicative_actions_slowdown < slowdown_before, "Do-afters should be faster")
	TEST_ASSERT(user.next_move_modifier < 1, "Clicking should be faster")
	TEST_ASSERT(user.gun_fire_delay_modifier < 1, "Shooting should be faster")

	// Upgrading while it is on reapplies it at the new level, without leaving anything of the old level behind
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/toggle/myoelectric_stimulation), "Could not upgrade Myoelectric Stimulation")
	TEST_ASSERT(abs(user.next_move_modifier - 0.7) < 0.001, "Level 2 should be 30% faster at clicking, got [user.next_move_modifier]")

	// Switching off puts everything back
	TEST_ASSERT(stim.Activate(user), "Could not switch off Myoelectric Stimulation")
	TEST_ASSERT(!stim.active, "It should be off")
	TEST_ASSERT(abs(user.next_move_modifier - 1) < 0.001, "Clicking speed should be back to normal, got [user.next_move_modifier]")
	TEST_ASSERT(abs(user.gun_fire_delay_modifier - 1) < 0.001, "Shooting speed should be back to normal, got [user.gun_fire_delay_modifier]")
	TEST_ASSERT(abs(user.cached_multiplicative_actions_slowdown - slowdown_before) < 0.001, "Do-after speed should be back to normal")

/// Electrokinetic Smash makes punches hit harder and never miss, and gives the punch damage back exactly when switched off
/datum/unit_test/arcfiend/smash_damage/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash), "Could not buy Electrokinetic Smash")
	var/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/smash = locate() in user.actions
	var/obj/item/bodypart/arm/arm = user.get_active_hand()
	TEST_ASSERT_NOTNULL(arm, "The arcfiend has no arm to punch with")
	var/low_before = arm.unarmed_damage_low
	var/high_before = arm.unarmed_damage_high
	TEST_ASSERT_EQUAL(low_before, 5, "This test expects an arm that punches for 5")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER), "Punches should be able to miss with Smash off")

	TEST_ASSERT(smash.Activate(user), "Could not switch on Electrokinetic Smash")
	TEST_ASSERT_EQUAL(arm.unarmed_damage_low, 6, "Level 1 Smash should make punches do 6")
	TEST_ASSERT_EQUAL(arm.unarmed_damage_high, 6, "Level 1 Smash should make punches do 6")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER), "Punches should never miss with Smash on")

	// Upgrading while it is on doesn't stack the old boost, and every level counts
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash), "Could not upgrade Electrokinetic Smash")
	TEST_ASSERT_EQUAL(arm.unarmed_damage_low, 7, "Level 2 Smash should make punches do 7")
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash), "Could not upgrade Electrokinetic Smash to level 3")
	TEST_ASSERT_EQUAL(arm.unarmed_damage_low, 8, "Level 3 Smash should make punches do 8")
	TEST_ASSERT_EQUAL(arm.unarmed_damage_high, 8, "Level 3 Smash should make punches do 8")
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER), "An upgrade should not lose the no-miss")

	// Switching off puts the punch damage back
	TEST_ASSERT(smash.Activate(user), "Could not switch off Electrokinetic Smash")
	TEST_ASSERT_EQUAL(arm.unarmed_damage_low, low_before, "Punch damage should be back to normal")
	TEST_ASSERT_EQUAL(arm.unarmed_damage_high, high_before, "Punch damage should be back to normal")
	TEST_ASSERT(!HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER), "Punches should be able to miss again")

/// Electrokinetic Smash shocks whoever a punch or weapon really hits, in combat mode or not, and leaves everything else alone
/datum/unit_test/arcfiend/smash_shock/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	var/smash_type = /datum/action/cooldown/arcfiend/toggle/electrokinetic_smash
	TEST_ASSERT(antag.purchase_power(smash_type), "Could not buy Electrokinetic Smash")
	var/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/smash = locate() in user.actions
	TEST_ASSERT(smash.Activate(user), "Could not switch on Electrokinetic Smash")
	antag.power = 2500
	user.istate &= ~(ISTATE_HARM | ISTATE_SECONDARY | ISTATE_CONTROL)

	// Hugs, grabs and shoves aren't hits
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	victim.forceMove(get_step(get_turf(user), EAST))
	victim.attack_hand(user, list(RIGHT_CLICK = FALSE))
	user.istate |= ISTATE_CONTROL
	victim.attack_hand(user, list(RIGHT_CLICK = FALSE))
	user.stop_pulling()
	user.istate &= ~ISTATE_CONTROL
	user.istate |= ISTATE_SECONDARY
	victim.attack_hand(user, list(RIGHT_CLICK = TRUE))
	user.istate &= ~ISTATE_SECONDARY
	TEST_ASSERT_EQUAL(victim.getFireLoss(), 0, "Hugs, grabs and shoves should not shock")
	TEST_ASSERT_EQUAL(antag.power, 2500, "Hugs, grabs and shoves should not cost power")

	// Neither is a blocked punch or swing
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	user.put_in_active_hand(toolbox, forced = TRUE)
	RegisterSignal(victim, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(block_attack))
	user.istate |= ISTATE_HARM
	victim.attack_hand(user, list(RIGHT_CLICK = FALSE))
	victim.attackby(toolbox, user)
	UnregisterSignal(victim, COMSIG_LIVING_CHECK_BLOCK)
	TEST_ASSERT_EQUAL(victim.getFireLoss(), 0, "A blocked hit should not shock")
	TEST_ASSERT_EQUAL(antag.power, 2500, "A blocked hit should not cost power")

	// Or anything that can't really hit someone
	toolbox.item_flags |= NOBLUDGEON
	victim.attackby(toolbox, user)
	toolbox.item_flags &= ~NOBLUDGEON
	var/old_force = toolbox.force
	toolbox.force = 0
	victim.attackby(toolbox, user)
	toolbox.force = old_force
	TEST_ASSERT_EQUAL(victim.getFireLoss(), 0, "An item that doesn't hit should not shock")
	TEST_ASSERT_EQUAL(antag.power, 2500, "An item that doesn't hit should not cost power")

	// A real swing shocks outside combat mode, once, and the weapon itself is no stronger
	user.istate &= ~ISTATE_HARM
	victim = allocate(/mob/living/carbon/human/consistent)
	victim.attackby(toolbox, user)
	TEST_ASSERT(abs(victim.getBruteLoss() - toolbox.force) < 1, "Smash should not change a weapon's damage, got [victim.getBruteLoss()]")
	TEST_ASSERT(abs(victim.getFireLoss() - 10) < 1, "A level 1 shock should burn for 10, got [victim.getFireLoss()]")
	TEST_ASSERT_EQUAL(antag.power, 2500 - smash.hit_cost, "A real swing should cost the hit cost")

	// A real punch shocks too, once
	user.istate |= ISTATE_HARM
	victim = allocate(/mob/living/carbon/human/consistent)
	var/power_before = antag.power
	victim.attack_hand(user, list(RIGHT_CLICK = FALSE))
	TEST_ASSERT(victim.getBruteLoss() > 0, "The punch should have landed")
	TEST_ASSERT(abs(victim.getFireLoss() - 10) < 1, "A level 1 shock should burn for 10, got [victim.getFireLoss()]")
	TEST_ASSERT_EQUAL(antag.power, power_before - smash.hit_cost, "A real punch should cost the hit cost")

	// Humans are shocked by the punch itself, not the click. Anything else is shocked by the click, but only in combat mode.
	var/mob/living/basic/mouse/mouse = allocate(/mob/living/basic/mouse)
	power_before = antag.power
	smash.on_unarmed_attack(user, victim, TRUE)
	TEST_ASSERT_EQUAL(antag.power, power_before, "Clicking a human should not shock them on top of the punch")
	user.istate &= ~ISTATE_HARM
	smash.on_unarmed_attack(user, mouse, TRUE)
	TEST_ASSERT_EQUAL(antag.power, power_before, "Touching a non-human outside combat mode should not shock them")
	user.istate |= ISTATE_HARM
	smash.on_unarmed_attack(user, mouse, TRUE)
	TEST_ASSERT_EQUAL(antag.power, power_before - smash.hit_cost, "Punching a non-human should shock them")

	// The shock immune still take the punch and still cost the power
	victim = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(victim, TRAIT_SHOCKIMMUNE, TRAIT_GENERIC)
	power_before = antag.power
	victim.attack_hand(user, list(RIGHT_CLICK = FALSE))
	TEST_ASSERT(victim.getBruteLoss() > 0, "The shock immune should still take the punch")
	TEST_ASSERT_EQUAL(victim.getFireLoss(), 0, "The shock immune should not be burned")
	TEST_ASSERT_EQUAL(antag.power, power_before - smash.hit_cost, "Shocking the shock immune should still cost power")

	// The burn goes up with each level
	antag.power = 2500
	TEST_ASSERT(antag.upgrade_power(smash_type), "Could not upgrade Electrokinetic Smash")
	victim = allocate(/mob/living/carbon/human/consistent)
	victim.attack_hand(user, list(RIGHT_CLICK = FALSE))
	TEST_ASSERT(abs(victim.getFireLoss() - 15) < 1, "A level 2 shock should burn for 15, got [victim.getFireLoss()]")
	antag.power = 2500
	TEST_ASSERT(antag.upgrade_power(smash_type), "Could not upgrade Electrokinetic Smash to level 3")
	victim = allocate(/mob/living/carbon/human/consistent)
	victim.attack_hand(user, list(RIGHT_CLICK = FALSE))
	TEST_ASSERT(abs(victim.getFireLoss() - 21) < 1, "A level 3 shock should burn for 21, got [victim.getFireLoss()]")

	// A blocked swing leaves the weapon waiting for a hit, which must not count once Smash is off
	RegisterSignal(victim, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(block_attack))
	victim.attackby(toolbox, user)
	UnregisterSignal(victim, COMSIG_LIVING_CHECK_BLOCK)
	TEST_ASSERT(smash.Activate(user), "Could not switch off Electrokinetic Smash")
	victim = allocate(/mob/living/carbon/human/consistent)
	power_before = antag.power
	victim.attackby(toolbox, user)
	TEST_ASSERT_EQUAL(victim.getFireLoss(), 0, "A swing with Smash off should not shock")
	TEST_ASSERT_EQUAL(antag.power, power_before, "A swing with Smash off should not cost power")

/datum/unit_test/arcfiend/smash_shock/proc/block_attack(mob/living/source)
	SIGNAL_HANDLER
	return SUCCESSFUL_BLOCK

/// Electrokinetic Smash's arcs jump to someone nearby for less burn. It's a chance, so this keeps hitting until one does.
/datum/unit_test/arcfiend/smash_arc/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	var/smash_type = /datum/action/cooldown/arcfiend/toggle/electrokinetic_smash
	TEST_ASSERT(antag.purchase_power(smash_type), "Could not buy Electrokinetic Smash")
	TEST_ASSERT(antag.upgrade_power(smash_type), "Could not upgrade Electrokinetic Smash")
	TEST_ASSERT(antag.upgrade_power(smash_type), "Could not upgrade Electrokinetic Smash to level 3")
	var/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/smash = locate() in user.actions
	TEST_ASSERT(smash.Activate(user), "Could not switch on Electrokinetic Smash")

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human/consistent)
	bystander.forceMove(get_step(get_turf(victim), EAST))
	var/arced = FALSE
	for(var/i in 1 to 50)
		antag.power = 2500
		victim.fully_heal()
		bystander.fully_heal()
		smash.discharge(victim)
		if(bystander.getFireLoss() > 0)
			arced = TRUE
			break
	TEST_ASSERT(arced, "A level 3 shock should have arced to the bystander in 50 tries")
	TEST_ASSERT(abs(bystander.getFireLoss() - 13) < 1, "A level 3 arc should burn for 13, got [bystander.getFireLoss()]")

/// Jolt brings back the dead even with no soul in them. When it can't, the power is still spent and the arcfiend's intuition says why.
/datum/unit_test/arcfiend/jolt_revive/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/jolt), "Could not buy Jolt")
	var/datum/action/cooldown/arcfiend/jolt/jolt = locate() in user.actions
	TEST_ASSERT_NOTNULL(jolt, "The arcfiend should have Jolt")
	user.istate &= ~ISTATE_HARM

	// Every reason a body can't be revived has something to tell the arcfiend, and a body that can be has nothing
	for(var/failure in list(DEFIB_FAIL_SUICIDE, DEFIB_FAIL_HUSK, DEFIB_FAIL_BLACKLISTED, DEFIB_FAIL_TISSUE_DAMAGE, DEFIB_FAIL_NO_HEART, DEFIB_FAIL_FAILING_HEART, DEFIB_FAIL_NO_BRAIN, DEFIB_FAIL_FAILING_BRAIN, DEFIB_FAIL_NO_INTELLIGENCE))
		TEST_ASSERT(istext(jolt.get_failure_feeling(failure)), "Jolt should have something to say about failure [failure]")
	TEST_ASSERT_NULL(jolt.get_failure_feeling(DEFIB_POSSIBLE), "A body that can be revived has no failure to explain")

	// A badly damaged body with nobody in it is brought back, and doesn't just die again
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human/consistent)
	corpse.adjustBruteLoss(150)
	corpse.death()
	TEST_ASSERT_NULL(corpse.client, "The corpse should have no player in it")
	TEST_ASSERT_EQUAL(corpse.stat, DEAD, "The test could not kill the corpse")
	var/power_before = antag.power
	TEST_ASSERT(!jolt.Activate(corpse), "Jolt shouldn't go off without a charged hand")
	jolt.charged = TRUE
	TEST_ASSERT(jolt.Activate(corpse), "Jolt should go ahead on a corpse with no soul")
	TEST_ASSERT(!jolt.charged, "Jolt should use up its charge")
	TEST_ASSERT(corpse.stat != DEAD, "The corpse should have been brought back")
	TEST_ASSERT_EQUAL(antag.power, power_before - 200, "Jolt should cost 200 power")

	// A husk can't be revived. The power is still spent, and nothing comes back.
	var/mob/living/carbon/human/husk = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(husk, TRAIT_HUSK, TRAIT_SOURCE_UNIT_TESTS)
	husk.death()
	TEST_ASSERT_EQUAL(husk.stat, DEAD, "The test could not kill the husk")
	jolt.next_use_time = 0
	jolt.charged = TRUE
	power_before = antag.power
	TEST_ASSERT(jolt.Activate(husk), "Jolt should go ahead even though it will fail")
	TEST_ASSERT_EQUAL(antag.power, power_before - 200, "Power should still be spent when the revival fails")
	TEST_ASSERT_EQUAL(husk.stat, DEAD, "A husk should stay dead")

/// The lateral laser only does its big damage at exactly the end of its range, hits everything and is set from the gun
/datum/unit_test/arcfiend/lateral_laser/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser), "Could not buy Lateral Laser")
	var/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/laser_action = locate() in user.actions
	TEST_ASSERT(laser_action.Activate(user), "Could not grow the lateral laser")
	var/obj/item/gun/energy/arcfiend/lateral_laser/gun = locate() in user.held_items
	TEST_ASSERT_NOTNULL(gun, "The lateral laser should be in the arcfiend's hand")

	// The beam is set up for the chosen range, and starts out as far as it can go
	var/obj/projectile/beam/laser/hitscan/arcfiend_lateral/beam = gun.chambered?.loaded_projectile
	TEST_ASSERT_NOTNULL(beam, "A beam should be ready")
	TEST_ASSERT_EQUAL(beam.travel_range, 4, "The beam should start at 4 tiles")
	TEST_ASSERT_EQUAL(beam.range, 4, "The beam should dissipate after 4 tiles")

	// Only the end of the beam hurts
	TEST_ASSERT_EQUAL(beam.damage_at_distance(1), 7, "The start of the beam should do the weak damage")
	TEST_ASSERT_EQUAL(beam.damage_at_distance(3), 7, "The middle of the beam should do the weak damage")
	TEST_ASSERT_EQUAL(beam.damage_at_distance(4), 50, "The end of the beam should do the full damage")
	TEST_ASSERT_EQUAL(beam.damage_at_distance(5), 0, "Past the end of the beam there should be no damage")

	// Everything is pierced, apart from the one who fired it
	beam.firer = user
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT_EQUAL(beam.prehit_pierce(victim), PROJECTILE_PIERCE_HIT, "The beam should pierce people")
	TEST_ASSERT_EQUAL(beam.prehit_pierce(get_step(user, NORTH)), PROJECTILE_PIERCE_HIT, "The beam should pierce walls and floors")
	TEST_ASSERT_EQUAL(beam.prehit_pierce(user), PROJECTILE_PIERCE_PHASE, "The beam should pass through whoever fired it")

	// Someone lying on the floor, even someone who can't do anything about it, is still hit
	victim.Paralyze(30 SECONDS)
	victim.set_resting(TRUE, silent = TRUE, instant = TRUE)
	beam.forceMove(get_turf(victim))
	TEST_ASSERT(beam.can_hit_target(victim, FALSE, FALSE), "The beam should hit people lying on the floor")
	TEST_ASSERT(!beam.can_hit_target(user, FALSE, TRUE), "The beam should not hit whoever fired it")

	// Using the gun in hand changes the range, wrapping round at the longest
	for(var/expected in list(1, 2, 3, 4, 1))
		gun.attack_self(user)
		TEST_ASSERT_EQUAL(laser_action.get_selected_range(), expected, "Using the gun in hand should change the range to [expected]")
	var/obj/projectile/beam/laser/hitscan/arcfiend_lateral/shorter_beam = gun.chambered?.loaded_projectile
	TEST_ASSERT_EQUAL(shorter_beam.travel_range, 1, "The next beam should be set for the new range")

	// Every shot costs power, and without the power it won't fire
	laser_action.selected_range = 4
	var/power_before = antag.power
	gun.chambered.loaded_projectile = null
	gun.process_chamber()
	TEST_ASSERT_EQUAL(antag.power, power_before - 30, "A shot should cost 30 power")
	TEST_ASSERT_NOTNULL(gun.chambered?.loaded_projectile, "A fresh beam should be ready after a shot")
	antag.power = 10
	TEST_ASSERT(!gun.can_shoot(), "It should not fire without the power")

	// Every shot also takes a charge from the magazine, which starts full and doesn't refill by putting the gun away
	TEST_ASSERT_EQUAL(laser_action.get_charges(), 2, "The first shot should have used a charge, leaving 2 of 3")
	for(var/i in 1 to 2)
		antag.power = 2500
		TEST_ASSERT(gun.can_shoot(), "There should still be charges to shoot")
		TEST_ASSERT_NOTNULL(gun.chambered?.loaded_projectile, "A beam should be ready")
		gun.chambered.loaded_projectile = null
		gun.process_chamber()
	TEST_ASSERT_EQUAL(laser_action.get_charges(), 0, "Three shots should empty the magazine")
	antag.power = 2500
	TEST_ASSERT(!gun.can_shoot(), "An empty magazine should not shoot, however much power there is")
	TEST_ASSERT(laser_action.dismiss(user), "Could not put the lateral laser away")
	laser_action.next_use_time = 0
	TEST_ASSERT(laser_action.Activate(user), "Could not grow the lateral laser again")
	gun = locate() in user.held_items
	TEST_ASSERT_EQUAL(laser_action.get_charges(), 0, "A new lateral laser should not have a fresh magazine")
	TEST_ASSERT(!gun.can_shoot(), "A new lateral laser should still be out of charges")
	laser_action.charge_recharged()
	TEST_ASSERT_EQUAL(laser_action.get_charges(), 1, "A rebuilt charge should go back into the magazine")
	TEST_ASSERT(gun.can_shoot(), "A rebuilt charge should let the gun shoot again")
	TEST_ASSERT_NOTNULL(laser_action.charge_timer, "The magazine should keep rebuilding charges until it is full")

	// Upgrades reach further, hold more, and the range can be set longer
	antag.power = 2500
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser), "Could not upgrade the lateral laser")
	TEST_ASSERT_EQUAL(laser_action.get_max_charges(), 4, "Level 2 should hold 4 charges")
	TEST_ASSERT(laser_action.get_charge_time() < 10 SECONDS, "Level 2 should rebuild charges faster")
	TEST_ASSERT_EQUAL(laser_action.get_max_range(), 5, "Level 2 should reach 5 tiles")
	TEST_ASSERT_EQUAL(laser_action.get_power_damage(), 65, "Level 2 should do 65 at the end of the beam")

	// The drop key puts it away
	TEST_ASSERT(SEND_SIGNAL(user, COMSIG_KB_MOB_DROPITEM_DOWN) & COMSIG_KB_ACTIVATED, "The drop key should be taken by the lateral laser")
	TEST_ASSERT(QDELETED(gun), "The drop key should dispel the lateral laser")

/// Upgrading with a gun out changes the very next shot, and the laser's longest range keeps up with upgrades
/datum/unit_test/arcfiend/gun_upgrades/Run()
	if(!make_arcfiend())
		return
	antag.power = 5000
	antag.bonus_minds_drained = 3
	var/coilgun_type = /datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun
	var/laser_type = /datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser
	TEST_ASSERT(antag.purchase_power(coilgun_type), "Could not buy Manifest Coilgun")
	TEST_ASSERT(antag.purchase_power(laser_type), "Could not buy Lateral Laser")

	// The coilgun's next slug hits harder
	var/datum/action/cooldown/arcfiend/grown_item/gun/manifest_coilgun/coilgun_action = locate() in user.actions
	TEST_ASSERT(coilgun_action.Activate(user), "Could not grow the coilgun")
	var/obj/item/gun/energy/arcfiend/coilgun/coilgun = locate() in user.held_items
	TEST_ASSERT_EQUAL(coilgun.chambered?.loaded_projectile?.damage, 22, "A level 1 slug should do 22 damage")
	TEST_ASSERT(antag.upgrade_power(coilgun_type), "Could not upgrade Manifest Coilgun")
	TEST_ASSERT_EQUAL(coilgun.chambered?.loaded_projectile?.damage, 27, "The slug ready when the coilgun is upgraded should do 27 damage")
	TEST_ASSERT(coilgun_action.dismiss(user), "Could not put the coilgun away")

	// The laser's next beam reaches further and hits harder
	var/datum/action/cooldown/arcfiend/grown_item/gun/lateral_laser/laser_action = locate() in user.actions
	TEST_ASSERT(laser_action.Activate(user), "Could not grow the lateral laser")
	var/obj/item/gun/energy/arcfiend/lateral_laser/laser = locate() in user.held_items
	var/obj/projectile/beam/laser/hitscan/arcfiend_lateral/beam = laser.chambered?.loaded_projectile
	TEST_ASSERT_EQUAL(beam.travel_range, 4, "A level 1 beam should reach 4 tiles")
	TEST_ASSERT(antag.upgrade_power(laser_type), "Could not upgrade the lateral laser")
	beam = laser.chambered?.loaded_projectile
	TEST_ASSERT_EQUAL(beam.travel_range, 5, "The beam ready when the laser is upgraded should reach 5 tiles")
	TEST_ASSERT_EQUAL(beam.range, 5, "The beam ready when the laser is upgraded should dissipate after 5 tiles")
	TEST_ASSERT_EQUAL(beam.damage_at_distance(5), 65, "The beam ready when the laser is upgraded should do 65 at the end")
	TEST_ASSERT_EQUAL(beam.damage_at_distance(1), 9, "The beam ready when the laser is upgraded should do 9 along the way")

	// Cycling all the way round to the longest range still keeps up with the next upgrade
	for(var/expected in list(1, 2, 3, 4, 5))
		laser.attack_self(user)
		TEST_ASSERT_EQUAL(laser_action.get_selected_range(), expected, "Using the laser in hand should change the range to [expected]")

	// Whereas a shorter range that was picked on purpose is left alone
	laser.attack_self(user)
	laser.attack_self(user)
	TEST_ASSERT_EQUAL(laser_action.get_selected_range(), 2, "The laser should be set to 2 tiles")
	TEST_ASSERT(antag.upgrade_power(laser_type), "Could not upgrade the lateral laser to level 3")
	TEST_ASSERT_EQUAL(laser_action.get_selected_range(), 2, "An upgrade should not change a shorter range that was picked")
	beam = laser.chambered?.loaded_projectile
	TEST_ASSERT_EQUAL(beam.damage_at_distance(2), 85, "A short range beam should still get the upgraded damage")
	for(var/expected in list(3, 4, 5, 6))
		laser.attack_self(user)
		TEST_ASSERT_EQUAL(laser_action.get_selected_range(), expected, "Using the laser in hand should change the range to [expected]")
	TEST_ASSERT_NULL(laser_action.selected_range, "The longest range should be stored as null, so it keeps up with upgrades")

/// Insulated gloves are not shock immunity, so they do nothing against an arcfiend's powers
/datum/unit_test/arcfiend/insulated_gloves/Run()
	if(!make_arcfiend())
		return
	antag.power = 10000
	antag.bonus_minds_drained = 3
	user.istate |= ISTATE_HARM
	var/prod_type = /datum/action/cooldown/arcfiend/grown_item/shock_prod
	if(!antag.has_power_unlocked(prod_type))
		TEST_ASSERT(antag.purchase_power(prod_type), "Could not buy Galvanic Prod")
	for(var/power_type in list(
		/datum/action/cooldown/arcfiend/brain_scramble,
		/datum/action/cooldown/arcfiend/arc_discharge,
		/datum/action/cooldown/arcfiend/thunderclap,
		/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash,
		/datum/action/cooldown/arcfiend/jolt,
	))
		TEST_ASSERT(antag.purchase_power(power_type), "Could not buy [power_type]")

	var/datum/action/cooldown/arcfiend/brain_scramble/scramble = locate() in user.actions
	var/mob/living/carbon/human/victim = make_gloved_victim()
	TEST_ASSERT(scramble.Activate(victim), "Brain Scramble should work on someone in insulated gloves")
	TEST_ASSERT(victim.getFireLoss() > 0, "Brain Scramble should burn someone in insulated gloves")

	var/datum/action/cooldown/arcfiend/arc_discharge/arc = locate() in user.actions
	victim = make_gloved_victim()
	arc.zap(user, victim, 15, 25)
	TEST_ASSERT(victim.getFireLoss() > 0, "Arc Discharge should burn someone in insulated gloves")

	var/datum/action/cooldown/arcfiend/thunderclap/clap = locate() in user.actions
	victim = make_gloved_victim()
	clap.hit_victim(user, victim, 1)
	TEST_ASSERT(victim.getFireLoss() > 0, "Thunderclap should burn someone in insulated gloves")

	var/datum/action/cooldown/arcfiend/toggle/electrokinetic_smash/smash = locate() in user.actions
	victim = make_gloved_victim()
	smash.shock(victim, 8, "A test shock")
	TEST_ASSERT(victim.getFireLoss() > 0, "Electrokinetic Smash should burn someone in insulated gloves")

	var/datum/action/cooldown/arcfiend/jolt/jolt = locate() in user.actions
	victim = make_gloved_victim()
	jolt.charged = TRUE
	TEST_ASSERT(jolt.Activate(victim), "Jolt should work on someone in insulated gloves")
	TEST_ASSERT(victim.getFireLoss() > 0, "Jolt should burn someone in insulated gloves")
	TEST_ASSERT(victim.undergoing_cardiac_arrest(), "Jolt should stop the heart of someone in insulated gloves")

	var/datum/action/cooldown/arcfiend/grown_item/shock_prod/prod_action = locate() in user.actions
	TEST_ASSERT(prod_action.Activate(user), "Could not grow the prod")
	var/obj/item/melee/arcfiend_prod/prod = locate() in user.held_items
	victim = make_gloved_victim()
	TEST_ASSERT(prod_action.try_zap(victim, user, prod), "The prod should zap someone in insulated gloves")
	TEST_ASSERT(victim.has_status_effect(/datum/status_effect/convulsing), "The prod should make the hands of someone in insulated gloves shake")

/datum/unit_test/arcfiend/insulated_gloves/proc/make_gloved_victim()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/gloves/color/yellow/gloves = allocate(/obj/item/clothing/gloves/color/yellow)
	TEST_ASSERT(victim.equip_to_slot_if_possible(gloves, ITEM_SLOT_GLOVES), "Could not put insulated gloves on the victim")
	return victim

/// Sapping feeds an arcfiend, up to full but never fat
/datum/unit_test/arcfiend/nourishment/Run()
	if(!make_arcfiend())
		return

	// Sapping feeds them
	user.set_nutrition(100)
	antag.power = 0
	TEST_ASSERT_EQUAL(antag.add_power(100), 100, "The arcfiend should have gained the power")
	TEST_ASSERT_EQUAL(user.nutrition, 100 + 100 * ARCFIEND_NUTRITION_PER_POWER, "Sapping power should feed the arcfiend")

	// But not past full
	user.set_nutrition(NUTRITION_LEVEL_FULL - 5)
	antag.power = 0
	antag.add_power(100)
	TEST_ASSERT_EQUAL(user.nutrition, NUTRITION_LEVEL_FULL, "Sapping should stop feeding at full")
	TEST_ASSERT(user.nutrition < NUTRITION_LEVEL_FAT, "Sapping should never make an arcfiend fat")

	// Someone who is already fat isn't fed any more, and isn't starved either
	user.set_nutrition(NUTRITION_LEVEL_FAT + 20)
	antag.power = 0
	antag.add_power(100)
	TEST_ASSERT_EQUAL(user.nutrition, NUTRITION_LEVEL_FAT + 20, "A fat arcfiend should not be fed any more")

/// Sapping charges an ethereal arcfiend, up to full charge but never into overcharge
/datum/unit_test/arcfiend/nourishment_ethereal/Run()
	user = allocate(/mob/living/carbon/human/species/ethereal)
	user.mind_initialize()
	antag = user.mind.add_antag_datum(/datum/antagonist/arcfiend)
	TEST_ASSERT_NOTNULL(antag, "Could not make the ethereal an arcfiend")
	TEST_ASSERT(isethereal(user), "The test human should be an ethereal")

	// Sapping charges them
	user.blood_volume = ETHEREAL_BLOOD_CHARGE_NORMAL
	antag.power = 0
	antag.add_power(100)
	TEST_ASSERT_EQUAL(user.blood_volume, ETHEREAL_BLOOD_CHARGE_NORMAL + 100 * ARCFIEND_NUTRITION_PER_POWER, "Sapping power should charge an ethereal")

	// But never past full charge, which is where overcharge starts
	user.blood_volume = ETHEREAL_BLOOD_CHARGE_FULL - 10
	antag.power = 0
	antag.add_power(200)
	TEST_ASSERT_EQUAL(user.blood_volume, ETHEREAL_BLOOD_CHARGE_FULL, "Sapping should stop charging an ethereal at full")
	antag.power = 0
	antag.add_power(200)
	TEST_ASSERT_EQUAL(user.blood_volume, ETHEREAL_BLOOD_CHARGE_FULL, "A full ethereal should not be overcharged by sapping")

/// An arcfiend's heart can't be stopped, but one too damaged to work still stops
/datum/unit_test/arcfiend/heart_attack_immunity/Run()
	if(!make_arcfiend())
		return
	TEST_ASSERT(HAS_TRAIT(user, TRAIT_HEART_ATTACK_IMMUNE), "An arcfiend should be immune to heart attacks")
	var/obj/item/organ/internal/heart/heart = user.get_organ_slot(ORGAN_SLOT_HEART)
	TEST_ASSERT_NOTNULL(heart, "The test arcfiend should have a heart")
	TEST_ASSERT(!user.can_heartattack(), "A healthy arcfiend should not be able to have a heart attack")
	TEST_ASSERT(!user.set_heartattack(TRUE), "A heart attack should not be possible on a healthy arcfiend")
	TEST_ASSERT(!user.undergoing_cardiac_arrest(), "A healthy arcfiend's heart should still beat")
	TEST_ASSERT(user.needs_heart(), "An arcfiend should still need their heart")

	heart.set_organ_damage(heart.maxHealth)
	TEST_ASSERT(heart.organ_flags & ORGAN_FAILING, "A heart at full damage should be failing")
	TEST_ASSERT(user.can_heartattack(), "A failing heart should be able to stop")
	user.set_heartattack(TRUE)
	TEST_ASSERT(user.undergoing_cardiac_arrest(), "An arcfiend's failing heart should stop")

	// Everyone else is unaffected
	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(other.can_heartattack(), "A normal human should still be able to have a heart attack")

/// Draining an ethereal runs their charge down, and draining anyone else leaves their nutrition alone
/datum/unit_test/arcfiend/drain_ethereal/Run()
	if(!make_arcfiend())
		return
	var/mob/living/carbon/human/species/ethereal/victim = allocate(/mob/living/carbon/human/species/ethereal)
	victim.blood_volume = ETHEREAL_BLOOD_CHARGE_FULL
	antag.power = 0
	var/drained = victim.arcfiend_drain(user, antag, 1)
	TEST_ASSERT(drained > 0, "Draining an ethereal should give power")
	TEST_ASSERT_EQUAL(victim.blood_volume, ETHEREAL_BLOOD_CHARGE_FULL - drained * ARCFIEND_ETHEREAL_CHARGE_PER_POWER, "Draining an ethereal should lower their charge")

	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human/consistent)
	other.set_nutrition(NUTRITION_LEVEL_FED)
	other.arcfiend_drain(user, antag, 1)
	TEST_ASSERT_EQUAL(other.nutrition, NUTRITION_LEVEL_FED, "Draining a normal human should not change their nutrition")

/// Draining an IPC runs their battery down, and their battery is their nutrition
/datum/unit_test/arcfiend/drain_ipc/Run()
	if(!make_arcfiend())
		return
	var/mob/living/carbon/human/species/ipc/victim = allocate(/mob/living/carbon/human/species/ipc)
	TEST_ASSERT(isipc(victim), "The test could not make an IPC")
	victim.set_nutrition(NUTRITION_LEVEL_FED)
	antag.power = 0
	var/drained = victim.arcfiend_drain(user, antag, 1)
	TEST_ASSERT(drained > 0, "Draining an IPC should give power")
	TEST_ASSERT_EQUAL(victim.nutrition, NUTRITION_LEVEL_FED - drained * ARCFIEND_IPC_NUTRITION_PER_POWER, "Draining an IPC should lower their charge")

/// The OPFOR injector makes whoever uses it on themselves an arcfiend, and is offered in the OPFOR menu
/datum/unit_test/arcfiend/opfor_injector/Run()
	var/mob/living/carbon/human/recruit = allocate(/mob/living/carbon/human/consistent)
	recruit.mind_initialize()
	var/obj/item/antag_granter/arcfiend/injector = allocate(/obj/item/antag_granter/arcfiend)
	TEST_ASSERT(!IS_ARCFIEND(recruit), "The recruit should not be an arcfiend yet")
	injector.attack_self(recruit)
	TEST_ASSERT(IS_ARCFIEND(recruit), "Using the injector should make the user an arcfiend")
	TEST_ASSERT(QDELETED(injector), "The injector should be used up")

	var/found_in_menu = FALSE
	for(var/category in SSopposing_force.equipment_list)
		for(var/datum/opposing_force_equipment/offered as anything in SSopposing_force.equipment_list[category])
			if(offered.item_type == /obj/item/antag_granter/arcfiend)
				found_in_menu = TRUE
	TEST_ASSERT(found_in_menu, "The injector should be offered in the OPFOR menu")

/// Brain Scramble burns a little and drains stamina, and Arc Discharge drains stamina too
/datum/unit_test/arcfiend/stamina_damage/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/brain_scramble), "Could not buy Brain Scramble")
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/arc_discharge), "Could not buy Arc Discharge")
	var/datum/action/cooldown/arcfiend/brain_scramble/scramble = locate() in user.actions
	var/datum/action/cooldown/arcfiend/arc_discharge/arc = locate() in user.actions

	var/mob/living/carbon/human/scrambled = allocate(/mob/living/carbon/human/consistent)
	TEST_ASSERT(scramble.Activate(scrambled), "Brain Scramble should work on someone next to the arcfiend")
	TEST_ASSERT(scrambled.getFireLoss() > 0, "Brain Scramble should burn a little")
	TEST_ASSERT(scrambled.getFireLoss() < 10, "Brain Scramble should only burn a little, got [scrambled.getFireLoss()]")
	TEST_ASSERT(scrambled.stamina.loss >= 60 * scrambled.physiology.stamina_mod, "Brain Scramble should drain a lot of stamina, got [scrambled.stamina.loss]")
	TEST_ASSERT(scrambled.has_status_effect(/datum/status_effect/eye_blur), "Brain Scramble should blur the target's eyes")
	TEST_ASSERT(scrambled.get_organ_loss(ORGAN_SLOT_BRAIN) >= 10, "Brain Scramble should damage the brain, got [scrambled.get_organ_loss(ORGAN_SLOT_BRAIN)]")
	TEST_ASSERT(HAS_TRAIT(scrambled, TRAIT_CLUMSY), "Brain Scramble should make the target clumsy")
	scrambled.remove_status_effect(/datum/status_effect/arcfiend_scrambled)
	TEST_ASSERT(!HAS_TRAIT(scrambled, TRAIT_CLUMSY), "The target should stop being clumsy when it wears off")

	var/mob/living/carbon/human/zapped = allocate(/mob/living/carbon/human/consistent)
	arc.zap(user, zapped, 20, 35)
	TEST_ASSERT(zapped.getFireLoss() > 0, "Arc Discharge should burn")
	TEST_ASSERT(zapped.stamina.loss > 0, "Arc Discharge should drain stamina")
	TEST_ASSERT(zapped.has_status_effect(/datum/status_effect/eye_blur), "Arc Discharge should blur the target's eyes")

	// Anyone shock immune takes none of it
	var/mob/living/carbon/human/immune = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(immune, TRAIT_SHOCKIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	arc.zap(user, immune, 20, 35)
	TEST_ASSERT_EQUAL(immune.getFireLoss(), 0, "Arc Discharge should not burn someone shock immune")
	TEST_ASSERT_EQUAL(immune.stamina.loss, 0, "Arc Discharge should not drain the stamina of someone shock immune")

/// Powers that need a hand always use the active hand, whatever is in it, and what they grow goes away when the arcfiend dies
/datum/unit_test/arcfiend/full_hands/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	var/obj/item/pen/main_item = allocate(/obj/item/pen)
	var/obj/item/pen/off_item = allocate(/obj/item/pen)
	user.put_in_active_hand(main_item)
	user.put_in_hands(off_item)
	TEST_ASSERT_EQUAL(user.get_active_held_item(), main_item, "The active hand should be holding the first item")
	TEST_ASSERT(off_item in user.held_items, "The other hand should be holding the second item")

	// With both hands full, a power that grows something takes the active hand, and the other hand is left alone
	var/datum/action/cooldown/arcfiend/grown_item/shock_prod/prod_action = locate() in user.actions
	TEST_ASSERT(prod_action.Activate(user), "The prod should be grown with both hands full")
	var/obj/item/melee/arcfiend_prod/prod = user.get_active_held_item()
	TEST_ASSERT(istype(prod), "The prod should be in the active hand")
	TEST_ASSERT(!(main_item in user.held_items), "The item in the active hand should have been dropped")
	TEST_ASSERT(off_item in user.held_items, "The item in the other hand should be kept")

	// A power that shows a hand takes over from the prod, which crumbles instead of blocking it
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/brain_scramble), "Could not buy Brain Scramble")
	var/datum/action/cooldown/arcfiend/brain_scramble/scramble = antag.get_power_instance(/datum/action/cooldown/arcfiend/brain_scramble)
	scramble.set_click_ability(user)
	TEST_ASSERT(QDELETED(prod), "The prod should have crumbled to make room")
	TEST_ASSERT(istype(user.get_active_held_item(), /obj/item/melee/touch_attack/arcfiend_hand), "The glowing hand should be in the active hand")
	TEST_ASSERT(off_item in user.held_items, "The item in the other hand should still be kept")

	// When the arcfiend dies, what they grew out of their hands is gone, even though it can't be dropped
	TEST_ASSERT(prod_action.Activate(user), "Could not grow the prod again")
	var/obj/item/melee/arcfiend_prod/last_prod = user.get_active_held_item()
	TEST_ASSERT(istype(last_prod), "The prod should be in the active hand")
	TEST_ASSERT(QDELETED(scramble.hand) || !scramble.hand, "The glowing hand should have crumbled to make room for the prod")
	user.death()
	TEST_ASSERT(QDELETED(last_prod), "A dead arcfiend should not be left holding the prod")
	TEST_ASSERT(!locate(/obj/item/melee/arcfiend_prod) in user.held_items, "A dead arcfiend should not be holding any prod")

/// Powers that need a person to be clicked on ignore a click on anything else, and don't waste the power
/datum/unit_test/arcfiend/mob_target_only/Run()
	if(!make_arcfiend())
		return
	antag.bonus_minds_drained = 3
	var/list/power_types = list(
		/datum/action/cooldown/arcfiend/brain_scramble,
		/datum/action/cooldown/arcfiend/arc_discharge,
		/datum/action/cooldown/arcfiend/jolt,
	)
	var/turf/floor = get_turf(user)
	for(var/power_type in power_types)
		antag.power = 2500
		TEST_ASSERT(antag.purchase_power(power_type), "Could not buy [power_type]")
		var/datum/action/cooldown/arcfiend/power = antag.get_power_instance(power_type)
		TEST_ASSERT(power.needs_mob_target, "[power_type] should need a person to be clicked on")
		antag.power = 2500
		TEST_ASSERT(power.InterceptClickOn(user, null, floor), "[power_type] should swallow a click on the floor")
		// Shift, control, alt and middle clicks are left alone, so the arcfiend can still examine things with a power ready
		for(var/modifier in list(SHIFT_CLICK, CTRL_CLICK, ALT_CLICK, MIDDLE_CLICK))
			TEST_ASSERT(!power.InterceptClickOn(user, "[modifier]=1", floor), "[power_type] should not swallow a [modifier] click")
		TEST_ASSERT(!power.Activate(floor), "[power_type] should do nothing to the floor")
		TEST_ASSERT_EQUAL(antag.power, 2500, "[power_type] should not cost power when the floor is clicked")
		TEST_ASSERT(power.next_use_time <= world.time, "[power_type] should not go on cooldown when the floor is clicked")

/// Thunderclap throws those who are close, and hurts those further out less and less the further they are
/datum/unit_test/arcfiend/thunderclap/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/thunderclap), "Could not buy Thunderclap")
	var/datum/action/cooldown/arcfiend/thunderclap/clap = locate() in user.actions
	TEST_ASSERT_NOTNULL(clap, "The arcfiend should have Thunderclap")
	TEST_ASSERT(!clap.shows_hand, "Thunderclap should not use a glowing hand")

	// The further away, the weaker, but never nothing within range
	TEST_ASSERT(clap.get_falloff(3) > clap.get_falloff(7), "Thunderclap should be weaker the further away you are")
	TEST_ASSERT(clap.get_falloff(clap.get_outer_range()) > 0, "Thunderclap should not drop to nothing within its range")

	// Close by: burned and drained as well as thrown away, and more than anyone further out
	var/mob/living/carbon/human/close = allocate(/mob/living/carbon/human/consistent)
	// Next to the arcfiend and not on top of them, which is where people are when they get hit
	close.forceMove(get_step(get_turf(user), EAST))
	clap.hit_victim(user, close, 1)
	TEST_ASSERT_NOTNULL(close.throwing, "Someone within 2 tiles should be thrown")
	TEST_ASSERT(close.getFireLoss() > 0, "Someone within 2 tiles should be burned too")
	TEST_ASSERT(close.stamina.loss > 0, "Someone within 2 tiles should lose stamina too")

	// Further out: burned, drained and flashed, but not thrown
	var/mob/living/carbon/human/mid = allocate(/mob/living/carbon/human/consistent)
	clap.hit_victim(user, mid, 4)
	TEST_ASSERT_NULL(mid.throwing, "Someone further than 2 tiles should not be thrown")
	TEST_ASSERT(mid.getFireLoss() > 0, "Someone further out should be burned a little")
	TEST_ASSERT(mid.stamina.loss > 0, "Someone further out should lose stamina")
	TEST_ASSERT(close.getFireLoss() > mid.getFireLoss(), "Someone close should be burned more than someone further out")
	var/mob/living/carbon/human/far = allocate(/mob/living/carbon/human/consistent)
	clap.hit_victim(user, far, 7)
	TEST_ASSERT(far.getFireLoss() < mid.getFireLoss(), "Someone further away should be burned less")
	TEST_ASSERT(far.stamina.loss < mid.stamina.loss, "Someone further away should lose less stamina")

	// Anyone shock immune is thrown if they are close, but not hurt
	var/mob/living/carbon/human/immune = allocate(/mob/living/carbon/human/consistent)
	ADD_TRAIT(immune, TRAIT_SHOCKIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	immune.forceMove(get_step(get_turf(user), WEST))
	clap.hit_victim(user, immune, 1)
	TEST_ASSERT_NOTNULL(immune.throwing, "Someone shock immune within 2 tiles should still be thrown")
	TEST_ASSERT_EQUAL(immune.getFireLoss(), 0, "Someone shock immune should not be burned")

	// Using it costs power and starts the recharge, after a windup nobody can miss
	var/power_before = antag.power
	TEST_ASSERT(clap.Activate(user), "Thunderclap should go off")
	TEST_ASSERT_EQUAL(antag.power, power_before - 120, "Thunderclap should cost 120 power")
	TEST_ASSERT(clap.next_use_time > world.time, "Thunderclap should start recharging")

	// Upgrades
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/thunderclap), "Could not upgrade Thunderclap")
	TEST_ASSERT_EQUAL(clap.get_outer_range(), 8, "Level 2 should reach 8 tiles")
	TEST_ASSERT_EQUAL(clap.get_throw_distance(), 4, "Level 2 should throw 4 tiles")
	TEST_ASSERT(clap.get_windup() < 1.5 SECONDS, "Level 2 should have a shorter windup")

/// Grid Leech slowly takes power from what's nearby, without breaking it, and stops once the pool is full
/datum/unit_test/arcfiend/grid_leech/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	TEST_ASSERT(!antag.purchase_power(/datum/action/cooldown/arcfiend/passive/grid_leech), "Grid Leech should need 3 drained minds")
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/passive/grid_leech), "Could not buy Grid Leech")
	var/datum/action/cooldown/arcfiend/passive/grid_leech/leech = antag.get_power_instance(/datum/action/cooldown/arcfiend/passive/grid_leech)
	TEST_ASSERT_NOTNULL(leech, "The arcfiend should own Grid Leech")

	var/obj/machinery/power/apc/apc = allocate(/obj/machinery/power/apc)
	// The test world doesn't give a new APC its battery, so it gets one here
	if(!apc.cell)
		apc.cell = new /obj/item/stock_parts/power_store/battery/upgraded(apc)
	var/apc_charge = apc.cell.charge

	antag.power = 1000
	leech.passive_tick(user, 2)
	TEST_ASSERT(abs(antag.power - (1000 + ARCFIEND_LEECH_RATE * 2)) < 0.001, "Two seconds of level 1 Grid Leech should give [ARCFIEND_LEECH_RATE * 2] power, got [antag.power - 1000]")
	TEST_ASSERT(apc.cell.charge < apc_charge, "Grid Leech should drain the nearby APC")

	// Unlike Sap Power, it never breaks what it drains
	for(var/i in 1 to 50)
		leech.passive_tick(user, 2)
	TEST_ASSERT(!(apc.machine_stat & BROKEN), "Grid Leech should not break the APC")

	// A full pool takes nothing
	antag.power = antag.power_cap
	apc_charge = apc.cell.charge
	leech.passive_tick(user, 2)
	TEST_ASSERT_EQUAL(apc.cell.charge, apc_charge, "A full pool should not drain the APC")

	// Upgrades make it faster
	antag.power = 2000
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/passive/grid_leech), "Could not upgrade Grid Leech")
	antag.power = 1000
	leech.passive_tick(user, 2)
	TEST_ASSERT(abs(antag.power - (1000 + ARCFIEND_LEECH_RATE * 4)) < 0.001, "Two seconds of level 2 Grid Leech should give [ARCFIEND_LEECH_RATE * 4] power, got [antag.power - 1000]")

/// Magnetic Shield stops half of what's shot at it and always stops electric shots, reflects what it can, and an EMP knocks it out
/datum/unit_test/arcfiend/magnetic_shield/Run()
	if(!make_arcfiend())
		return
	antag.power = 2500
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/toggle/magnetic_shield), "Could not buy Magnetic Shield")
	var/datum/action/cooldown/arcfiend/toggle/magnetic_shield/shield = locate() in user.actions
	TEST_ASSERT_NOTNULL(shield, "The arcfiend should have Magnetic Shield")

	// With the shield down nothing is stopped
	var/obj/projectile/energy/electrode/electrode = allocate(/obj/projectile/energy/electrode)
	TEST_ASSERT_EQUAL(shoot(electrode), NONE, "An electrode should not be stopped with the shield off")

	// Switching it on pulls out a taser that is already in
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/gun/energy/laser/taser = allocate(/obj/item/gun/energy/laser)
	user.apply_status_effect(/datum/status_effect/tased, taser, shooter)
	TEST_ASSERT(user.has_status_effect(/datum/status_effect/tased), "The test could not tase the arcfiend")
	TEST_ASSERT(shield.Activate(user), "Could not switch on Magnetic Shield")
	TEST_ASSERT(shield.active, "Magnetic Shield should be on")
	TEST_ASSERT(!user.has_status_effect(/datum/status_effect/tased), "Switching on Magnetic Shield should end a tase")

	// Electric shots always get stopped, and the ones that can be reflected are
	var/obj/projectile/energy/tesla/tesla = allocate(/obj/projectile/energy/tesla)
	var/obj/projectile/energy/tesla_cannon/tesla_orb = allocate(/obj/projectile/energy/tesla_cannon)
	for(var/i in 1 to 20)
		TEST_ASSERT(shoot(electrode) & COMPONENT_BULLET_BLOCKED, "An electrode should always be stopped")
		TEST_ASSERT(shoot(tesla) & COMPONENT_BULLET_PIERCED, "A tesla bolt should always be reflected")
		TEST_ASSERT(shoot(tesla_orb) & COMPONENT_BULLET_PIERCED, "A tesla orb should always be reflected")

	// Anything else is a coin flip. Energy shots are reflected, others are just stopped.
	var/obj/projectile/beam/laser/laser = allocate(/obj/projectile/beam/laser)
	var/obj/projectile/bullet/bullet = allocate(/obj/projectile/bullet)
	var/laser_reflected = 0
	var/bullet_stopped = 0
	for(var/i in 1 to 100)
		var/laser_result = shoot(laser)
		TEST_ASSERT(!(laser_result & COMPONENT_BULLET_BLOCKED), "A laser should be reflected, not stopped")
		if(laser_result & COMPONENT_BULLET_PIERCED)
			laser_reflected++
		var/bullet_result = shoot(bullet)
		TEST_ASSERT(!(bullet_result & COMPONENT_BULLET_PIERCED), "A bullet should be stopped, not reflected")
		if(bullet_result & COMPONENT_BULLET_BLOCKED)
			bullet_stopped++
	TEST_ASSERT(laser_reflected > 0 && laser_reflected < 100, "Some lasers should get through and some shouldn't, reflected [laser_reflected] of 100")
	TEST_ASSERT(bullet_stopped > 0 && bullet_stopped < 100, "Some bullets should get through and some shouldn't, stopped [bullet_stopped] of 100")

	// Harmless shots aren't stopped, which is how an ion bolt gets through to knock the shield out
	var/obj/projectile/ion/ion = allocate(/obj/projectile/ion)
	for(var/i in 1 to 20)
		TEST_ASSERT_EQUAL(shoot(ion), NONE, "An ion bolt should get through the shield")

	// You can't block your own shot at yourself
	laser.firer = user
	laser.original = user
	for(var/i in 1 to 20)
		TEST_ASSERT_EQUAL(shoot(laser), NONE, "The shield should not stop a shot the arcfiend fired at themselves")

	// An EMP knocks it out for a long time
	user.emp_act(EMP_LIGHT)
	TEST_ASSERT(!shield.active, "An EMP should shut off Magnetic Shield")
	TEST_ASSERT(shield.next_use_time > world.time + 60 SECONDS, "An EMP should put Magnetic Shield on a long cooldown")
	TEST_ASSERT(!shield.IsAvailable(), "Magnetic Shield should be unavailable after an EMP")
	TEST_ASSERT_EQUAL(shoot(electrode), NONE, "A shield knocked out by an EMP should stop nothing")

/// Sends the signal a projectile sends when it hits the arcfiend, returning what the shield did about it
/datum/unit_test/arcfiend/magnetic_shield/proc/shoot(obj/projectile/shot)
	return SEND_SIGNAL(user, COMSIG_ATOM_PRE_BULLET_ACT, shot, BODY_ZONE_CHEST, FALSE, 0)

/// Vaporize Restraints is a tier 2 power, destroys cuffs even when stunned, flashes those nearby, and gets to legcuffs at level 3
/datum/unit_test/arcfiend/vaporize_restraints/Run()
	if(!make_arcfiend())
		return
	antag.power = 1000
	TEST_ASSERT_NULL(locate(/datum/action/cooldown/arcfiend/vaporize_restraints) in user.actions, "Vaporize Restraints should not come with the antag")
	TEST_ASSERT(!antag.purchase_power(/datum/action/cooldown/arcfiend/vaporize_restraints), "Vaporize Restraints should need a drained mind")
	antag.bonus_minds_drained = 3
	TEST_ASSERT(antag.purchase_power(/datum/action/cooldown/arcfiend/vaporize_restraints), "Could not buy Vaporize Restraints")
	antag.power = 1000
	var/datum/action/cooldown/arcfiend/vaporize_restraints/vaporize = locate() in user.actions
	TEST_ASSERT_NOTNULL(vaporize, "The arcfiend should have Vaporize Restraints")

	// Nothing to vaporize
	TEST_ASSERT(!vaporize.Activate(user), "Vaporize Restraints should do nothing with no restraints")
	TEST_ASSERT_EQUAL(antag.power, 1000, "Having nothing to vaporize should be free")

	// Legcuffs are out of reach at first
	var/obj/item/restraints/legcuffs/bola/bola = allocate(/obj/item/restraints/legcuffs/bola)
	user.equip_to_slot(bola, ITEM_SLOT_LEGCUFFED)
	TEST_ASSERT_EQUAL(user.legcuffed, bola, "The test could not put a bola on the arcfiend")
	TEST_ASSERT(!vaporize.Activate(user), "Level 1 Vaporize Restraints should not reach a bola")
	TEST_ASSERT_EQUAL(user.legcuffed, bola, "The bola should still be there")
	TEST_ASSERT_EQUAL(antag.power, 1000, "Failing to reach a bola should be free")

	// It works while cuffed and stunned, and level 1 only reaches those right next to the arcfiend
	var/mob/living/carbon/human/close = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/far = allocate(/mob/living/carbon/human/consistent)
	far.forceMove(get_step(get_step(get_turf(user), EAST), EAST))
	var/obj/item/restraints/handcuffs/cuffs = allocate(/obj/item/restraints/handcuffs)
	user.equip_to_slot(cuffs, ITEM_SLOT_HANDCUFFED)
	TEST_ASSERT_EQUAL(user.handcuffed, cuffs, "The test could not cuff the arcfiend")
	user.Paralyze(20 SECONDS)
	TEST_ASSERT(vaporize.IsAvailable(), "Vaporize Restraints should be usable while cuffed and stunned")
	TEST_ASSERT(vaporize.Activate(user), "Vaporize Restraints should go off")
	TEST_ASSERT(QDELETED(cuffs), "The cuffs should be destroyed")
	TEST_ASSERT_NULL(user.handcuffed, "The arcfiend should no longer be cuffed")
	TEST_ASSERT_EQUAL(user.legcuffed, bola, "Level 1 Vaporize Restraints should leave the bola alone")
	TEST_ASSERT_EQUAL(antag.power, 1000 - vaporize.power_cost, "Vaporize Restraints should cost its power")
	TEST_ASSERT(vaporize.next_use_time > world.time, "Vaporize Restraints should go on cooldown")
	TEST_ASSERT(close.has_status_effect(/datum/status_effect/temporary_blindness), "Someone next to the arcfiend should be blinded")
	TEST_ASSERT(close.has_status_effect(/datum/status_effect/confusion), "Someone next to the arcfiend should be confused")
	TEST_ASSERT(!far.has_status_effect(/datum/status_effect/temporary_blindness), "Level 1 should not reach someone 2 tiles away")

	// Level 2 reaches 2 tiles
	antag.power = 2000
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/vaporize_restraints), "Could not upgrade Vaporize Restraints")
	vaporize.next_use_time = 0
	cuffs = allocate(/obj/item/restraints/handcuffs)
	user.equip_to_slot(cuffs, ITEM_SLOT_HANDCUFFED)
	TEST_ASSERT(vaporize.Activate(user), "Level 2 Vaporize Restraints should go off")
	TEST_ASSERT(far.has_status_effect(/datum/status_effect/temporary_blindness), "Level 2 should reach someone 2 tiles away")

	// Level 3 reaches the bola
	TEST_ASSERT(antag.upgrade_power(/datum/action/cooldown/arcfiend/vaporize_restraints), "Could not upgrade Vaporize Restraints to level 3")
	vaporize.next_use_time = 0
	TEST_ASSERT(vaporize.Activate(user), "Level 3 Vaporize Restraints should go off with only a bola on")
	TEST_ASSERT(QDELETED(bola), "The bola should be destroyed")
	TEST_ASSERT_NULL(user.legcuffed, "The arcfiend should no longer have anything on their legs")

/// Jumpstart comes with the antag, can't be upgraded, only works when dead, and takes its power when the charge finishes
/datum/unit_test/arcfiend/jumpstart/Run()
	if(!make_arcfiend())
		return
	antag.power = 500
	var/jumpstart_type = /datum/action/cooldown/arcfiend/jumpstart
	var/datum/action/cooldown/arcfiend/jumpstart/jumpstart = locate() in user.actions
	TEST_ASSERT_NOTNULL(jumpstart, "Jumpstart should come with the antag")
	TEST_ASSERT_EQUAL(antag.get_max_power_level(jumpstart_type), 1, "Jumpstart should not be upgradable")
	TEST_ASSERT_EQUAL(jumpstart.power_cost, 200, "Jumpstart should cost 200 power")
	TEST_ASSERT(!jumpstart.IsAvailable(), "Jumpstart should not be usable while alive")
	TEST_ASSERT(!jumpstart.Trigger(), "Clicking Jumpstart while alive should do nothing")
	TEST_ASSERT(!jumpstart.Activate(user), "Jumpstart should not start charging while alive")
	TEST_ASSERT_NULL(jumpstart.charge_timer, "Jumpstart should not be charging while alive")

	// A full charge brings them back
	user.adjustBruteLoss(50)
	user.death()
	TEST_ASSERT_EQUAL(user.stat, DEAD, "The test could not kill the arcfiend")
	TEST_ASSERT(jumpstart.IsAvailable(), "Jumpstart should be usable while dead")
	TEST_ASSERT(jumpstart.Activate(user), "Jumpstart should start charging")
	TEST_ASSERT_NOTNULL(jumpstart.charge_timer, "Jumpstart should be charging")
	TEST_ASSERT_NOTNULL(jumpstart.visuals?["jumpstart"], "A charging corpse should show it")
	TEST_ASSERT(!jumpstart.Activate(user), "Jumpstart should not start charging twice")
	TEST_ASSERT_EQUAL(antag.power, 500, "Jumpstart should not cost anything until the charge finishes")
	jumpstart.finish_charging()
	TEST_ASSERT_NULL(jumpstart.charge_timer, "Jumpstart should have finished charging")
	TEST_ASSERT(user.stat != DEAD, "Jumpstart should bring the arcfiend back")
	TEST_ASSERT_EQUAL(user.getBruteLoss(), 0, "Jumpstart should heal the arcfiend")
	TEST_ASSERT_EQUAL(antag.power, 300, "Jumpstart should cost 200 power")
	TEST_ASSERT(jumpstart.next_use_time > world.time, "Jumpstart should go on cooldown")

	// Too little power to start
	user.death()
	jumpstart.next_use_time = 0
	antag.power = 100
	TEST_ASSERT(!jumpstart.IsAvailable(), "Jumpstart should need its power to start")

	// Losing the power during the charge means staying dead, and it isn't wasted
	antag.power = 500
	TEST_ASSERT(jumpstart.Activate(user), "Jumpstart should start charging again")
	antag.power = 100
	jumpstart.finish_charging()
	TEST_ASSERT_EQUAL(user.stat, DEAD, "Jumpstart should fail without the power left to finish")
	TEST_ASSERT_EQUAL(antag.power, 100, "A failed Jumpstart should cost nothing")
	TEST_ASSERT(jumpstart.next_use_time <= world.time, "A failed Jumpstart should not go on cooldown")

	// Being revived some other way ends the charge
	antag.power = 500
	TEST_ASSERT(jumpstart.Activate(user), "Jumpstart should start charging a third time")
	user.revive(ADMIN_HEAL_ALL)
	TEST_ASSERT(user.stat != DEAD, "The test could not revive the arcfiend")
	TEST_ASSERT_NULL(jumpstart.charge_timer, "Being revived should end the charge")
	TEST_ASSERT_NULL(jumpstart.visuals?["jumpstart"], "Being revived should take the charging sprite off")
	TEST_ASSERT_EQUAL(antag.power, 500, "Being revived by someone else should cost nothing")
