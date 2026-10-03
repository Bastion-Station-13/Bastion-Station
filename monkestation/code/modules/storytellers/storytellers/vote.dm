/datum/vote/var/has_desc = FALSE

/datum/vote/proc/return_desc(vote_name)
	return ""

/datum/vote/storyteller
	name = "Storyteller"
	default_message = "Vote for the storyteller!"
	has_desc = TRUE
	player_startable = FALSE
	count_method = VOTE_COUNT_METHOD_MULTI

/datum/vote/storyteller/New()
	. = ..()
	default_choices = list()

/// Roundstart storyteller vote doesn't properly work otherwise, this is the simplest fix
/datum/vote/storyteller/is_accessible_vote()
	return TRUE

/datum/vote/storyteller/can_be_initiated(mob/by_who, forced = FALSE)
	. = ..()
	if(SSticker.HasRoundStarted())
		return "This vote cannot be used after the round has already started."

/datum/vote/storyteller/return_desc(vote_name)
	return SSgamemode.storyteller_desc(vote_name)

/datum/vote/storyteller/create_vote()
	//This is intentionally before we call the parent proc
	default_choices = SSgamemode.storyteller_vote_choices()
	. = ..()
	if((length(choices) == 1)) // Only one choice, no need to vote. Let's just auto-rotate it to the only remaining storyteller because it would just happen anyways.
		var/de_facto_winner = choices[1]
		SSgamemode.storyteller_vote_result(de_facto_winner)
		to_chat(world, span_boldannounce("The storyteller vote has been skipped because there is only one storyteller left to vote for. \
									The storyteller has been changed to [de_facto_winner]."))
		return FALSE

/datum/vote/storyteller/finalize_vote(winning_option)
	SSgamemode.storyteller_vote_result(winning_option)
