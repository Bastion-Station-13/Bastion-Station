/datum/round_event_control/antagonist/arcfiend
	tags = list(TAG_COMBAT, TAG_CREW_ANTAG, TAG_DESTRUCTIVE)
	antag_flag = ROLE_ARCFIEND
	antag_datum = /datum/antagonist/arcfiend
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_NANOTRASEN_REPRESENTATIVE,
		JOB_BLUESHIELD,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIDGE_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	enemy_roles = list(
		JOB_AI,
		JOB_CYBORG,
		JOB_CAPTAIN,
		JOB_BLUESHIELD,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
		JOB_BRIG_PHYSICIAN,
		JOB_WARDEN,
		// arcfiends will be hell on a shift with no engineers
		JOB_CHIEF_ENGINEER,
		JOB_STATION_ENGINEER,
		JOB_ATMOSPHERIC_TECHNICIAN,
		JOB_NETWORK_ADMIN,
	)
	required_enemies = 4
	base_antags = 2
	maximum_antags = 3
	denominator = 30
	weight = 14
	min_players = 20
	shared_occurence_type = SHARED_ARCFIEND
	event_icon_state = "traitor"

/datum/round_event_control/antagonist/arcfiend/roundstart
	name = "Arcfiends"
	roundstart = TRUE
	earliest_start = 0 SECONDS
	max_occurrences = 1

/datum/round_event_control/antagonist/arcfiend/midround
	name = "Arcfiend Sleeper"
	antag_flag = ROLE_ARCFIEND_MIDROUND
	prompted_picking = TRUE
	maximum_antags = 2
	weight = 14
	min_players = 25
	max_occurrences = 3
