ADMIN_VERB(adjust_players_antag_tokens, R_FUN, FALSE, "Adjust Antag Tokens", "You can modifiy a targets antag tokens by adding or subtracting from that tier.", ADMIN_CATEGORY_FUN)

	var/datum/antag_tokens_adjuster/ata = new()
	ata.ui_interact(user.mob)




/datum/antag_tokens_adjuster/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AntagTokensPanel")
		ui.open()

/datum/antag_tokens_adjuster/ui_status(mob/user, datum/ui_state/state)
	return check_rights_for(user.client, R_FUN) ? UI_INTERACTIVE : UI_CLOSE

/datum/antag_tokens_adjuster/ui_data(mob/user)
	var/list/data = list()

	data["clients"] = GLOB.clients
	return data

/datum/antag_tokens_adjuster/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!check_rights(R_FUN) || ..())
		return
	switch(action)
		if("submit")
			var/chosen_client = params["ckey"]
			if(!chosen_client)
				return
			var/adjustment_amount = tgui_input_number(ui.user, "How much should we adjust this users antag tokens by?", "Input Value", TRUE, 10, -10)
			if(!adjustment_amount)
				return
			var/tier = tgui_input_list(ui.user, "Choose a tier for the token", "Tier list", list(HIGH_THREAT, MEDIUM_THREAT, LOW_THREAT))
			if(!tier)
				return
			adjust_tokens(ui.user, params["ckey"], tier, adjustment_amount,)





/datum/antag_tokens_adjuster/proc/adjust_tokens(givermob, ckey, tier, amount)
	var/ckeytolookfor = lowertext(ckey)
	for(var/client/c in GLOB.clients)
		if(c.ckey == ckeytolookfor)
			c.client_token_holder.adjust_antag_tokens(tier,amount)
			log_admin("[key_name(givermob)] adjusted the [tier] antag tokens of [key_name(c)] by [amount].")
			message_admins("[key_name_admin(givermob)] adjusted the [tier] antag tokens of [key_name(c)] by [amount].")
			BLACKBOX_LOG_ADMIN_VERB("Adjust Antag Tokens")
			return
	var/datum/json_savefile/savefile = new /datum/json_savefile("data/player_saves/[ckeytolookfor[1]]/[ckeytolookfor]/preferences.json")
	if(!savefile)
		to_chat(givermob, span_warning("Unable to fetch savefile for ckey!"))
	var/list/tokens = savefile.get_entry("saved_tokens", list("high_threat" = 0,"medium_threat" = 0,"low_threat" = 0,"event_tokens" = 0,"event_token_month" = 0,"donator" = 0,	"donator_token_month" = 0,))
	var/listtier
	switch(tier)
		if(HIGH_THREAT)
			listtier = "high_threat"
		if(MEDIUM_THREAT)
			listtier = "medium_threat"
		if(LOW_THREAT)
			listtier = "low_threat"
	tokens[listtier] += amount
	savefile.set_entry("saved_tokens",tokens)
	savefile.save()
	log_admin("[key_name(givermob)] adjusted the [tier] antag tokens of [ckey] by [amount].")
	message_admins("[key_name_admin(givermob)] adjusted the [tier] antag tokens of [ckey] by [amount].")
	BLACKBOX_LOG_ADMIN_VERB("Adjust Antag Tokens")

