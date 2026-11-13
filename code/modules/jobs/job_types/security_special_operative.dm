/datum/job/security_special_operative
	title = JOB_SECURITY_SPECIAL_OPERATIVE
	description = "Reinforce station security during high-threat situations."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 0
	latejoin_only = TRUE
	supervisors = SUPERVISOR_HOS
	config_tag = "SECURITY_SPECIAL_OPERATIVE"

	outfit = /datum/outfit/job/security_special_operative
	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	display_order = JOB_DISPLAY_ORDER_SECURITY_SPECIAL_OPERATIVE
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/security,
	)
	job_flags = STATION_JOB_FLAGS
	antag_capacity_points = 3

/datum/job/security_special_operative/special_check_latejoin(client/latejoin)
	return SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED

/datum/outfit/job/security_special_operative
	name = "Security Special Operative"
	jobtype = /datum/job/security_special_operative
	id_trim = /datum/id_trim/job/security_special_operative
	uniform = /obj/item/clothing/under/rank/security/private/corporal
	suit = /obj/item/clothing/suit/armor/vest/alt/sec
	back = /obj/item/mod/control/pre_equipped/security_special_operative
	belt = /obj/item/modular_computer/pda/security_special_operative
	ears = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	gloves = /obj/item/clothing/gloves/color/black/security
	shoes = /obj/item/clothing/shoes/jackboots/sec
	l_pocket = /obj/item/assembly/flash/handheld
	r_pocket = /obj/item/holosign_creator/security
	backpack = /obj/item/storage/backpack/security
	backpack_contents = list(
		/obj/item/security_special_operative_requisition = 1,
	)
	implants = list(/obj/item/implant/mindshield)
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security

/datum/id_trim/job/security_special_operative
	assignment = JOB_SECURITY_SPECIAL_OPERATIVE
	trim_state = "trim_deathcommando"
	department_color = COLOR_SECURITY_RED
	subdepartment_color = "#1a6ab4"
	sechud_icon = 'bastionstation/icons/security_special_operative/hud.dmi'
	sechud_icon_state = SECHUD_SECURITY_OPERATIVE
	minimal_access = list(
		ACCESS_BRIG,
		ACCESS_BRIG_ENTRANCE,
		ACCESS_COURT,
		ACCESS_MECH_SECURITY,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_SECURITY,
		ACCESS_WEAPONS,
		ACCESS_PERMABRIG,
		ACCESS_MEDICAL,
		ACCESS_SCIENCE,
		ACCESS_ENGINEERING,
		ACCESS_SCIENCE,
		ACCESS_CARGO,

	)
	extra_access = list(
		ACCESS_DETECTIVE,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MORGUE,
	)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_HOS,
	)
	job = /datum/job/security_special_operative

/obj/item/modular_computer/pda/security_special_operative
	name = "security special operative PDA"
	greyscale_colors = "#C81E1E#EAB308"
	inserted_item = /obj/item/pen/red/security
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/lifeline,
	)

/// Catalog entries can be added as subtypes; costs are paid from that category's point pool.
/datum/security_special_operative_kit_item
	var/name = "Equipment"
	var/desc = ""
	var/category = "Utility"
	var/point_cost = 1
	var/item_type = /obj/item

/datum/security_special_operative_kit_item/lethal/heavy_combat_shotgun
	name = "Heavy Combat Shotgun"
	desc = "A compact, two-handed combat shotgun with a ten-shell capacity and a box of buckshot."
	category = "Lethal"
	item_type = /obj/item/storage/toolbox/guncase/security_special_operative/heavy_combat_shotgun

/datum/security_special_operative_kit_item/lethal/boner_lmg
	name = "Boner LMG"
	desc = "A two-handed light machine gun supplied with three spare 50-round magazines."
	category = "Lethal"
	item_type = /obj/item/storage/toolbox/guncase/security_special_operative/boner_lmg

/datum/security_special_operative_kit_item/lethal/herstal_62
	name = "HERSTAL-62"
	desc = "A 20-round battle rifle supplied with three spare magazines."
	category = "Lethal"
	item_type = /obj/item/storage/toolbox/guncase/security_special_operative/herstal_62

/datum/security_special_operative_kit_item/sidearm/macaroni_20
	name = "Macaroni-20"
	desc = "A fully automatic machine pistol supplied with three spare 32-round magazines."
	category = "Sidearm"
	item_type = /obj/item/storage/toolbox/guncase/security_special_operative/macaroni_20

/datum/security_special_operative_kit_item/sidearm/webley_mk6
	name = "Webley MK VI"
	desc = "A six-shot revolver supplied with three spare Webley speedloaders."
	category = "Sidearm"
	item_type = /obj/item/storage/toolbox/guncase/security_special_operative/webley_mk6

/datum/security_special_operative_kit_item/sidearm/energy_hausewhr
	name = "Energy Hausewhr"
	desc = "A compact energy blade with less striking power than a standard energy sword."
	category = "Sidearm"
	item_type = /obj/item/melee/energy/blade/security_special_operative

/datum/security_special_operative_kit_item/nonlethal/advanced_stun_baton
	name = "Advanced Stun Baton"
	desc = "An always-on baton that stuns in three hits and can overclock for a brief knockdown strike."
	category = "Non-lethal"
	item_type = /obj/item/melee/baton/security/security_special_operative

/datum/security_special_operative_kit_item/nonlethal/wavegun
	name = "Wavegun"
	desc = "A self-recharging energy weapon with a slow, heavy stamina orb, a wall-piercing shot, and a ricocheting shot."
	category = "Non-lethal"
	item_type = /obj/item/gun/energy/recharge/security_special_operative/wavegun

/datum/security_special_operative_kit_item/nonlethal/akimbo_disablers
	name = "Akimbo Disabler Bundle"
	desc = "A box containing two standard disablers."
	category = "Non-lethal"
	item_type = /obj/item/storage/box/security_special_operative/akimbo_disablers

/datum/security_special_operative_kit_item/nonlethal/xm05_stun_shotgun
	name = "XM-05 Stun Shotgun"
	desc = "A compact taser that fires four electrodes in a spreading volley."
	category = "Non-lethal"
	item_type = /obj/item/gun/energy/taser/security_special_operative/xm05

/datum/security_special_operative_kit_item/utility/flashbang_box
	name = "Box of Flashbangs"
	desc = "A box of standard flashbang grenades."
	category = "Utility"
	item_type = /obj/item/storage/box/flashbangs

/datum/security_special_operative_kit_item/utility/tactical_medkit
	name = "SSO Tactical Medkit"
	desc = "A tactical medical kit with patches, a hypospray, and a mixed bluespace chemical canister."
	category = "Utility"
	item_type = /obj/item/storage/medkit/tactical/security_special_operative

/datum/security_special_operative_kit_item/utility/stingbang_box
	name = "Box of 3 Stingbangs"
	desc = "A box containing three stingbang grenades."
	category = "Utility"
	item_type = /obj/item/storage/box/stingbangs/security_special_operative

/datum/security_special_operative_kit_item/utility/teargas_box
	name = "Box of Tear Gas"
	desc = "A box of standard tear gas grenades."
	category = "Utility"
	item_type = /obj/item/storage/box/teargas

/datum/security_special_operative_kit_item/utility/energy_bolas
	name = "Box of Energy Bolas"
	desc = "A box containing five energy bolas."
	category = "Utility"
	item_type = /obj/item/storage/box/security_special_operative/energy_bolas

/datum/security_special_operative_kit_item/utility/toolbelt
	name = "Full Toolbelt"
	desc = "A utility belt stocked with a complete set of tools."
	category = "Utility"
	item_type = /obj/item/storage/belt/utility/full

/datum/security_special_operative_kit_item/utility/stimulant_injectors
	name = "2x Stimulant Autoinjectors"
	desc = "Two autoinjectors, each containing methamphetamine, mannitol, and ephedrine."
	category = "Utility"
	item_type = /obj/item/storage/box/security_special_operative/stimulant_injectors

/datum/security_special_operative_kit_item/utility/smoke_grenades
	name = "Box of Smoke Grenades"
	desc = "A box of standard smoke grenades."
	category = "Utility"
	item_type = /obj/item/storage/box/smokebomb

/datum/security_special_operative_kit_item/utility/combat_medic_kit
	name = "Combat Medic Kit"
	desc = "A compact kit containing a medical beamgun, brute kit, and burn kit."
	category = "Utility"
	item_type = /obj/item/storage/box/security_special_operative/combat_medic

/datum/security_special_operative_kit_item/utility/shotgun_ammunition
	name = "Heavy Combat Shotgun Ammunition"
	desc = "Two spare boxes of buckshot for the Heavy Combat Shotgun."
	category = "Utility"
	point_cost = 1
	item_type = /obj/item/storage/box/security_special_operative/primary_ammunition/shotgun

/datum/security_special_operative_kit_item/utility/boner_lmg_ammunition
	name = "Boner LMG Ammunition"
	desc = "Two spare 50-round magazines for the Boner LMG."
	category = "Utility"
	point_cost = 1
	item_type = /obj/item/storage/box/security_special_operative/primary_ammunition/boner_lmg

/datum/security_special_operative_kit_item/utility/herstal_62_ammunition
	name = "HERSTAL-62 Ammunition"
	desc = "Two spare magazines for the HERSTAL-62."
	category = "Utility"
	point_cost = 1
	item_type = /obj/item/storage/box/security_special_operative/primary_ammunition/herstal_62

/datum/security_special_operative_kit_item/utility/engineer_kit
	name = "Engineer Kit"
	desc = "A loaded RCD and two bluespace matter cartridges."
	category = "Utility"
	point_cost = 1
	item_type = /obj/item/storage/box/security_special_operative/engineer

/datum/security_special_operative_kit_item/utility/experimental_energy_shield
	name = "Experimental Energy Shield Module"
	desc = "A weakened MODsuit shield module with limited protective charges."
	category = "Utility"
	point_cost = 2
	item_type = /obj/item/mod/module/energy_shield/security_special_operative

/datum/security_special_operative_kit_item/utility/support_beacon
	name = "Special Operative Support Beacon"
	desc = "Polls for a ghost to deploy as a security support officer with standard equipment."
	category = "Utility"
	point_cost = 2
	item_type = /obj/item/antag_spawner/loadout/security_special_operative_support

/obj/item/security_special_operative_requisition
	name = "security requisition device"
	desc = "A secure equipment requisition interface for Security Special Operatives."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	w_class = WEIGHT_CLASS_SMALL

	var/list/category_points
	var/list/category_limits
	var/list/available_kits = list()
	var/list/selected_kits = list()

/obj/item/security_special_operative_requisition/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	available_kits = list()
	selected_kits = list()
	category_points = list(
		"Lethal" = 1,
		"Sidearm" = 1,
		"Non-lethal" = 1,
		"Utility" = 3,
	)
	category_limits = list(
		"Lethal" = 1,
		"Sidearm" = 1,
		"Non-lethal" = 1,
		"Utility" = 3,
	)
	var/list/catalog_categories = list(
		/datum/security_special_operative_kit_item/lethal,
		/datum/security_special_operative_kit_item/sidearm,
		/datum/security_special_operative_kit_item/nonlethal,
		/datum/security_special_operative_kit_item/utility,
	)
	for(var/category_type in catalog_categories)
		for(var/kit_type in subtypesof(category_type))
			var/datum/security_special_operative_kit_item/kit = new kit_type()
			if(!(kit.category in category_points) || !isnum(kit.point_cost) || kit.point_cost < 1 || round(kit.point_cost) != kit.point_cost || !ispath(kit.item_type, /obj/item))
				qdel(kit)
				CRASH("Invalid equipment shop catalog entry: [kit_type].")
			available_kits[kit_type] = kit

/obj/item/security_special_operative_requisition/Destroy()
	for(var/kit_type in available_kits)
		qdel(available_kits[kit_type])
	available_kits.Cut()
	return ..()

/obj/item/security_special_operative_requisition/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/security_special_operative_requisition/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/security_special_operative_requisition/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SecuritySpecialOperative", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/security_special_operative_requisition/proc/get_category_spent(category)
	var/total = 0
	for(var/kit_type in selected_kits)
		var/datum/security_special_operative_kit_item/kit = available_kits[kit_type]
		if(kit.category == category)
			total += kit.point_cost
	return total

/obj/item/security_special_operative_requisition/proc/get_category_item_count(category)
	var/count = 0
	for(var/kit_type in selected_kits)
		var/datum/security_special_operative_kit_item/kit = available_kits[kit_type]
		if(kit.category == category)
			count++
	return count

/obj/item/security_special_operative_requisition/ui_data(mob/user)
	var/list/categories = list()
	for(var/category in category_points)
		categories += list(list(
			"name" = category,
			"points" = category_points[category] - get_category_spent(category),
			"max_items" = category_limits[category],
			"selected_items" = get_category_item_count(category),
		))

	var/list/items = list()
	for(var/kit_type in available_kits)
		var/datum/security_special_operative_kit_item/kit = available_kits[kit_type]
		items += list(list(
			"id" = "[kit_type]",
			"name" = kit.name,
			"desc" = kit.desc,
			"category" = kit.category,
			"cost" = kit.point_cost,
		))

	var/list/selected_items = list()
	for(var/index in 1 to length(selected_kits))
		var/datum/security_special_operative_kit_item/kit = available_kits[selected_kits[index]]
		selected_items += list(list(
			"index" = index,
			"name" = kit.name,
			"category" = kit.category,
			"cost" = kit.point_cost,
		))

	return list(
		"categories" = categories,
		"items" = items,
		"selected_items" = selected_items,
	)

/obj/item/security_special_operative_requisition/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("add")
			var/kit_type = text2path(params["id"])
			var/datum/security_special_operative_kit_item/kit = available_kits[kit_type]
			if(!kit || !(kit.category in category_points))
				return TRUE
			if(get_category_item_count(kit.category) >= category_limits[kit.category])
				return TRUE
			if(kit.point_cost <= 0 || get_category_spent(kit.category) + kit.point_cost > category_points[kit.category])
				return TRUE
			selected_kits += kit_type
			SStgui.update_uis(src)
		if("remove")
			var/index = text2num(params["index"])
			if(index < 1 || index > length(selected_kits) || round(index) != index)
				return TRUE
			selected_kits.Cut(index, index + 1)
			SStgui.update_uis(src)
		if("checkout")
			if(!length(selected_kits))
				return TRUE
			for(var/kit_type in selected_kits)
				var/datum/security_special_operative_kit_item/kit = available_kits[kit_type]
				if(!kit || !ispath(kit.item_type, /obj/item))
					return TRUE
			for(var/kit_type in selected_kits)
				var/datum/security_special_operative_kit_item/kit = available_kits[kit_type]
				var/item_path = kit.item_type
				var/obj/item/gear = new item_path(get_turf(ui.user))
				ui.user.put_in_hands(gear)
			qdel(src)
			return TRUE
	return TRUE
