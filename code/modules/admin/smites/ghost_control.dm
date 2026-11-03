/datum/smite/ghost_control
	name = "Ghost Control"

/datum/smite/ghost_control/effect(client/user, mob/living/target)
	target.AddComponent(/datum/component/deadchat_control/human_control, ANARCHY_MODE, list(), 4 SECONDS)
	to_chat(target, span_revenwarning("You feel a ghastly presence!!!"))
