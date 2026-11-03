/**
 * Deadchat Plays Things - The Componenting
 *
 * Allows deadchat to control stuff and things by typing commands into chat.
 * These commands will then trigger callbacks to execute procs!
 */
/datum/component/deadchat_control
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The id for the DEMOCRACY_MODE looping vote timer.
	var/timerid
	/// Assoc list of key-chat command string, value-callback pairs. list("right" = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), src, EAST))
	var/list/datum/callback/inputs = list()
	/// Assoc list of ckey:value pairings. In DEMOCRACY_MODE, value is the player's vote. In ANARCHY_MODE, value is world.time when their cooldown expires.
	var/list/ckey_to_cooldown = list()
	/// List of everything orbitting this component's parent.
	var/orbiters = list()
	/// A bitfield containing the mode which this component uses (DEMOCRACY_MODE or ANARCHY_MODE) and other settings)
	var/deadchat_mode
	/// In DEMOCRACY_MODE, this is how long players have to vote on an input. In ANARCHY_MODE, this is how long between inputs for each unique player.
	var/input_cooldown
	///Set to true if a point of interest was created for an object, and needs to be removed if deadchat control is removed. Needed for preventing objects from having two points of interest.
	var/generated_point_of_interest = FALSE
	/// Callback invoked when this component is Destroy()ed to allow the parent to return to a non-deadchat controlled state.
	var/datum/callback/on_removal

/datum/component/deadchat_control/Initialize(_deadchat_mode, _inputs, _input_cooldown = 12 SECONDS, _on_removal)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_BEGIN, PROC_REF(orbit_begin))
	RegisterSignal(parent, COMSIG_ATOM_ORBIT_STOP, PROC_REF(orbit_stop))
	RegisterSignal(parent, COMSIG_VV_TOPIC, PROC_REF(handle_vv_topic))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	deadchat_mode = _deadchat_mode
	inputs = _inputs
	input_cooldown = _input_cooldown
	on_removal = _on_removal
	if(deadchat_mode & DEMOCRACY_MODE)
		if(deadchat_mode & ANARCHY_MODE) // Choose one, please.
			stack_trace("deadchat_control component added to [parent.type] with both democracy and anarchy modes enabled.")
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	notify_ghosts(
		"[parent] is now deadchat controllable!",
		source = parent,
		action = NOTIFY_ORBIT,
		header = "Something Interesting!",
	)
	if(!ismob(parent) && !SSpoints_of_interest.is_valid_poi(parent))
		SSpoints_of_interest.make_point_of_interest(parent)
		generated_point_of_interest = TRUE

/datum/component/deadchat_control/Destroy(force)
	on_removal?.Invoke()
	inputs = null
	orbiters = null
	ckey_to_cooldown = null
	if(generated_point_of_interest)
		SSpoints_of_interest.remove_point_of_interest(parent)
	on_removal = null
	return ..()

/datum/component/deadchat_control/proc/deadchat_react(mob/source, message)
	SIGNAL_HANDLER

	message = LOWER_TEXT(message)

	if(!inputs[message])
		return

	if(deadchat_mode & ANARCHY_MODE)
		if(!source || !source.ckey)
			return
		var/cooldown = ckey_to_cooldown[source.ckey] - world.time
		if(cooldown > 0)
			to_chat(source, span_warning("Your deadchat control inputs are still on cooldown for another [CEILING(cooldown * 0.1, 1)] second\s."))
			return MOB_DEADSAY_SIGNAL_INTERCEPT
		ckey_to_cooldown[source.ckey] = world.time + input_cooldown
		addtimer(CALLBACK(src, PROC_REF(end_cooldown), source.ckey), input_cooldown)
		inputs[message].Invoke()
		to_chat(source, span_notice("\"[message]\" input accepted. You are now on cooldown for [input_cooldown * 0.1] second\s."))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

	if(deadchat_mode & DEMOCRACY_MODE)
		ckey_to_cooldown[source.ckey] = message
		to_chat(source, span_notice("You have voted for \"[message]\"."))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/deadchat_control/proc/democracy_loop()
	if(QDELETED(parent) || !(deadchat_mode & DEMOCRACY_MODE))
		deltimer(timerid)
		return
	var/result = count_democracy_votes()
	if(!isnull(result))
		inputs[result].Invoke()
		if(!(deadchat_mode & MUTE_DEMOCRACY_MESSAGES))
			var/message = "<span class='deadsay italics bold'>[parent] has done action [result]!<br>New vote started. It will end in [input_cooldown * 0.1] second\s.</span>"
			for(var/M in orbiters)
				to_chat(M, message)
	else if(!(deadchat_mode & MUTE_DEMOCRACY_MESSAGES))
		var/message = "<span class='deadsay italics bold'>No votes were cast this cycle.</span>"
		for(var/M in orbiters)
			to_chat(M, message)

/datum/component/deadchat_control/proc/count_democracy_votes()
	if(!length(ckey_to_cooldown))
		return
	var/list/votes = list()
	for(var/command in inputs)
		votes["[command]"] = 0
	for(var/vote in ckey_to_cooldown)
		votes[ckey_to_cooldown[vote]]++
		ckey_to_cooldown.Remove(vote)

	// Solve which had most votes.
	var/prev_value = 0
	var/result
	for(var/vote in votes)
		if(votes[vote] > prev_value)
			prev_value = votes[vote]
			result = vote

	if(result in inputs)
		return result

/datum/component/deadchat_control/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	if(var_name != NAMEOF(src, deadchat_mode))
		return
	ckey_to_cooldown = list()
	if(var_value == DEMOCRACY_MODE)
		timerid = addtimer(CALLBACK(src, PROC_REF(democracy_loop)), input_cooldown, TIMER_STOPPABLE | TIMER_LOOP)
	else
		deltimer(timerid)

/datum/component/deadchat_control/proc/orbit_begin(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	RegisterSignal(orbiter, COMSIG_MOB_DEADSAY, PROC_REF(deadchat_react))
	RegisterSignal(orbiter, COMSIG_MOB_AUTOMUTE_CHECK, PROC_REF(waive_automute))
	orbiters |= orbiter


/datum/component/deadchat_control/proc/orbit_stop(atom/source, atom/orbiter)
	SIGNAL_HANDLER

	if(orbiter in orbiters)
		UnregisterSignal(orbiter, list(
			COMSIG_MOB_DEADSAY,
			COMSIG_MOB_AUTOMUTE_CHECK,
		))
		orbiters -= orbiter

/**
 * Prevents messages used to control the parent from counting towards the automute threshold for repeated identical messages.
 *
 * Arguments:
 * - [speaker][/client]: The mob that is trying to speak.
 * - [client][/client]: The client that is trying to speak.
 * - message: The message that the speaker is trying to say.
 * - mute_type: Which type of mute the message counts towards.
 */
/datum/component/deadchat_control/proc/waive_automute(mob/speaker, client/client, message, mute_type)
	SIGNAL_HANDLER
	if(mute_type == MUTE_DEADCHAT && inputs[LOWER_TEXT(message)])
		return WAIVE_AUTOMUTE_CHECK
	return NONE


/// Allows for this component to be removed via a dedicated VV dropdown entry.
/datum/component/deadchat_control/proc/handle_vv_topic(datum/source, mob/user, list/href_list)
	SIGNAL_HANDLER
	if(!href_list[VV_HK_DEADCHAT_PLAYS] || !check_rights(R_FUN))
		return
	. = COMPONENT_VV_HANDLED
	INVOKE_ASYNC(src, PROC_REF(async_handle_vv_topic), user, href_list)

/// Async proc handling the alert input and associated logic for an admin removing this component via the VV dropdown.
/datum/component/deadchat_control/proc/async_handle_vv_topic(mob/user, list/href_list)
	if(tgui_alert(user, "Remove deadchat control from [parent]?", "Deadchat Plays [parent]", list("Remove", "Cancel")) == "Remove")
		// Quick sanity check as this is an async call.
		if(QDELETED(src))
			return

		to_chat(user, span_notice("Deadchat can no longer control [parent]."))
		log_admin("[key_name(user)] has removed deadchat control from [parent]")
		message_admins(span_notice("[key_name(user)] has removed deadchat control from [parent]"))

		qdel(src)

/// Informs any examiners to the inputs available as part of deadchat control, as well as the current operating mode and cooldowns.
/datum/component/deadchat_control/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!isobserver(user))
		return

	examine_list += span_notice("[A.p_theyre(TRUE)] currently under deadchat control using the [(deadchat_mode & DEMOCRACY_MODE) ? "democracy" : "anarchy"] ruleset!")

	if(deadchat_mode & DEMOCRACY_MODE)
		examine_list += span_notice("Type a command into chat to vote on an action. This happens once every [input_cooldown * 0.1] second\s.")
	else if(deadchat_mode & ANARCHY_MODE)
		examine_list += span_notice("Type a command into chat to perform. You may do this once every [input_cooldown * 0.1] second\s.")

	var/extended_examine = "<span class='notice'>Command list:"

	for(var/possible_input in inputs)
		extended_examine += " [possible_input]"

	extended_examine += ".</span>"

	examine_list += extended_examine

///Removes the ghost from the ckey_to_cooldown list and lets them know they are free to submit a command for the parent again.
/datum/component/deadchat_control/proc/end_cooldown(ghost_ckey)
	ckey_to_cooldown -= ghost_ckey
	var/mob/ghost = get_mob_by_ckey(ghost_ckey)
	if(!ghost || isliving(ghost))
		return
	to_chat(ghost, "[FOLLOW_LINK(ghost, parent)] <span class='nicegreen'>Your deadchat control inputs for [parent] are no longer on cooldown.</span>")

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for a spicy
 * singularity or vomit goose.
 */
/datum/component/deadchat_control/cardinal_movement/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, NORTH)
	inputs["down"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, SOUTH)
	inputs["left"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, WEST)
	inputs["right"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, EAST)

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for spicy
 * immovable rod.
 */
/datum/component/deadchat_control/immovable_rod/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!istype(parent, /obj/effect/immovablerod))
		return COMPONENT_INCOMPATIBLE

	. = ..()

	inputs["up"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), NORTH)
	inputs["down"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), SOUTH)
	inputs["left"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), WEST)
	inputs["right"] = CALLBACK(parent, TYPE_PROC_REF(/obj/effect/immovablerod, walk_in_direction), EAST)

/**
 * Deadchat Moves Things
 *
 * A special variant of the deadchat_control component that comes pre-baked with all the hottest inputs for a human mob
 * Includes the ability for ghost chat to say things through the controlled mob
 * Also includes the emotes: Clap, Cry, Flip, Laugh, Scream, Spin, Swear
 */
/datum/component/deadchat_control/human_control
	var/mob/living/carbon/human/human_owner

/datum/component/deadchat_control/human_control/Initialize(_deadchat_mode, _inputs, _input_cooldown, _on_removal)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	human_owner = parent

	. = ..()

	if(deadchat_mode & ANARCHY_MODE) // Override deadchat_react will block "say" being passed to parent, preventing a null.invoke runtime
		inputs["say"] = null // Say needs to be handled seperately in the override as it needs the rest of the message to deterimine what to say.
	inputs["up"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, NORTH)
	inputs["down"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, SOUTH)
	inputs["left"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, WEST)
	inputs["right"] = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), parent, EAST)
	inputs["clap"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, emote), "clap")
	inputs["cry"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, emote), "cry")
	inputs["flip"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, emote), "flip")
	inputs["laugh"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, emote), "laugh")
	inputs["scream"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, emote), "scream")
	inputs["spin"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, emote), "spin")
	inputs["swear"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, emote), "swear")
	inputs["drop"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, drop_all_held_items))
	inputs["fall"]= CALLBACK(human_owner, TYPE_PROC_REF(/mob/living, Knockdown), 1 SECONDS)
	inputs["stand"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob/living, resist_buckle))
	inputs["throw"] = CALLBACK(human_owner, TYPE_PROC_REF(/mob, throw_item), get_edge_target_turf(human_owner, pick(GLOB.alldirs)))
	inputs["shove"] = CALLBACK(src, PROC_REF(ghost_shove))
	inputs["punch"] = CALLBACK(src, PROC_REF(ghost_punch))
	inputs["sit"] = CALLBACK(src, PROC_REF(ghost_sit))
	inputs["run"] = CALLBACK(src, PROC_REF(ghost_speed), MOVE_INTENT_RUN)
	inputs["walk"] = CALLBACK(src, PROC_REF(ghost_speed), MOVE_INTENT_WALK)

/datum/component/deadchat_control/human_control/deadchat_react(mob/source, message)
	if(!(deadchat_mode & ANARCHY_MODE)) // Only for anarchy because there isnt a clean way for people to vote on what to say in democracy mode. Also here to prevent null.invoke, see above.
		return ..()

	if(!source || !source.ckey)
		return

	var/cooldown = ckey_to_cooldown[source.ckey] - world.time
	if(cooldown > 0)
		to_chat(source, span_warning("Your deadchat control inputs are still on cooldown for another [CEILING(cooldown * 0.1, 1)] second\s."))
		return MOB_DEADSAY_SIGNAL_INTERCEPT

	message = LOWER_TEXT(message)
	var/list/message_contents = splittext(message, " ", 1, 4)
	if(message_contents[1] != "say")
		return ..()

	INVOKE_ASYNC(src, PROC_REF(ghost_say), message_contents[2])
	ckey_to_cooldown[source.ckey] = world.time + input_cooldown
	addtimer(CALLBACK(src, PROC_REF(end_cooldown), source.ckey), input_cooldown)
	to_chat(source, span_notice("\"[message]\" input accepted. You are now on cooldown for [input_cooldown * 0.1] second\s."))
	return MOB_DEADSAY_SIGNAL_INTERCEPT

/datum/component/deadchat_control/human_control/proc/ghost_punch()
	if(!istype(human_owner) || human_owner.get_active_held_item())
		return
	var/list/punchies = list()
	for(var/mob/living/victim in orange(1, human_owner))
		punchies += victim
	if(!length(punchies))
		return
	var/mob/living/punch_me = pick(punchies)
	var/old_istate = human_owner.istate // Manually set istate so its always a punch and not help.
	human_owner.istate = 3
	human_owner.UnarmedAttack(punch_me, proximity_flag = TRUE)
	human_owner.istate = old_istate

/datum/component/deadchat_control/human_control/proc/ghost_say(to_say)
	human_owner.say(to_say, forced = "deadchat control say")
	return

/datum/component/deadchat_control/human_control/proc/ghost_shove()
	if(!istype(human_owner) || human_owner.get_active_held_item())
		return
	var/list/shoveables = list()
	for(var/mob/living/victim in orange(1, human_owner))
		shoveables += victim
	if(!length(shoveables))
		return
	var/mob/living/shove_me = pick(shoveables)
	human_owner.disarm(shove_me)

/datum/component/deadchat_control/human_control/proc/ghost_sit()
	if(HAS_TRAIT(human_owner, TRAIT_IMMOBILIZED))
		return
	var/list/chairs = list()
	for(var/obj/structure/chair/possible_chair in range(1, human_owner))
		chairs += possible_chair
	if(!length(chairs))
		return
	var/obj/structure/chair/sitting_chair = pick(chairs)
	sitting_chair.buckle_mob(human_owner, check_loc = FALSE)

/datum/component/deadchat_control/human_control/proc/ghost_speed(new_speed)
	if(human_owner.m_intent == new_speed)
		return
	if(human_owner.m_intent != MOVE_INTENT_WALK)
		human_owner.set_move_intent(MOVE_INTENT_WALK)
	else
		human_owner.set_move_intent(MOVE_INTENT_RUN)
