/datum/mood_event
	/// Description of the mood event
	var/description
	/// An integer value that affects overall sanity over time
	var/mood_change = 0
	/// How long this mood event should last
	var/timeout = 0
	/// Is this mood event hidden on examine
	var/hidden = FALSE
	/**
	 * A category to put multiple mood events. If one of the mood events in the category
	 * is active while another mood event (from the same category) is triggered it will remove
	 * the effects of the current mood event and replace it with the new one
	 */
	var/category
	/// Icon state of the unique mood event icon, if applicable
	var/special_screen_obj
	/// if false, it will be an overlay instead
	var/special_screen_replace = TRUE
	/// Owner of this mood event
	var/mob/owner
	/// List of required jobs for this mood event
	var/list/required_job = list()

/datum/mood_event/New(mob/M, ...)
	owner = M
	var/list/params = args.Copy(2)
	if ((length(required_job) > 0) && M.mind && !(M.mind.assigned_role.type in required_job))
		qdel(src)
		return
	add_effects(arglist(params))

/datum/mood_event/Destroy()
	remove_effects()
	owner = null
	return ..()

<<<<<<< HEAD
/datum/mood_event/proc/add_effects(param)
=======
/**
 * Called when this datum is created, checks if the passed mob can experience this mood event
 *
 * * home - the mood datum we are being added to
 * * who - the mob to check
 * * ... - any other arguments that are passed to the mood event
 *
 * Return TRUE if the mob can experience this mood event
 * Return FALSE if the mob should be unaffected
 */
/datum/mood_event/proc/can_effect_mob(datum/mood/home, mob/living/who, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(LAZYLEN(required_job) && !is_type_in_list(who.mind?.assigned_role, required_job))
		return FALSE

	if((event_flags & MOOD_EVENT_WHIMSY))
		// Whimsical people get positive whimsical moodlets
		// Non-whimsical people get negative whimsical moodlets
		var/is_whimsical = HAS_PERSONALITY(who, /datum/personality/whimsical)
		if(mood_change >= 0 && !is_whimsical)
			return FALSE
		if(mood_change < 0 && is_whimsical)
			return FALSE

	if((event_flags & MOOD_EVENT_ART) && HAS_PERSONALITY(who, /datum/personality/unimaginative))
		return FALSE

	if((event_flags & MOOD_EVENT_PAIN) && HAS_TRAIT(who, TRAIT_ANALGESIA))
		return FALSE

	return TRUE

/**
 * Wrapper for the mood event being added to a mob
 *
 * * home - the mood datum we are being added to
 * * who - the mob to add the mood event to
 * * mood_args - any other arguments that are passed to the mood event
 */
/datum/mood_event/proc/on_add(datum/mood/home, mob/living/who, list/mood_args)
	SHOULD_NOT_OVERRIDE(TRUE)

	owner = who

	if((event_flags & MOOD_EVENT_ART) && HAS_PERSONALITY(who, /datum/personality/creative))
		mood_change *= 1.2

	if((event_flags & MOOD_EVENT_SPIRITUAL) && !HAS_TRAIT(who, TRAIT_SPIRITUAL))
		mood_change *= 0.2

	if(event_flags & MOOD_EVENT_FOOD)
		if(HAS_PERSONALITY(owner, /datum/personality/ascetic))
			mood_change *= 0.75
		if(HAS_PERSONALITY(owner, /datum/personality/gourmand))
			mood_change *= 1.25

	if(event_flags & MOOD_EVENT_FEAR)
		if(HAS_PERSONALITY(owner, /datum/personality/cowardly))
			mood_change *= 1.25
		if(HAS_PERSONALITY(owner, /datum/personality/brave))
			mood_change *= 0.75

	add_effects(arglist(mood_args))
	if(who.mind?.holy_role && GLOB.deity)
		var/static/regex/god_regex = regex(@"\bgods?\b", "ig")
		description = god_regex.Replace(description, "[GLOB.deity]$2")

	mood_change = floor(mood_change)

	timeout *= max((mood_change > 0) ? home.positive_moodlet_length_modifier : home.negative_moodlet_length_modifier, 0.1)
	if(timeout)
		addtimer(CALLBACK(home, TYPE_PROC_REF(/datum/mood, clear_mood_event), category), timeout, (TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_NO_HASH_WAIT))

/**
 * Called when added to a mob
 *
 * * ... - Any arguments passed to add_mood_event after the typepath are passed here
 */
/datum/mood_event/proc/add_effects(...)
>>>>>>> 457484c32 ([PORT] People get desensitized to death (#13191))
	return

/datum/mood_event/proc/remove_effects()
	return
