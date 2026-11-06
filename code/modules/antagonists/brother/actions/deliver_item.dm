/datum/action/bb/deliver_item
	name = "Deliver Item"
	desc = "Teleport the item in your active hand to a fellow blood brother."
	button_icon = 'bastionstation/icons/mob/actions/deliver_item.dmi'
	button_icon_state = "gear_link"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED
	COOLDOWN_DECLARE(delivery_cooldown)

/datum/action/bb/deliver_item/IsAvailable(feedback)
	. = ..()
	if(!.)
		return
	if(length(team.members) < 2)
		if(feedback)
			owner.balloon_alert(owner, "no blood brothers to teleport to!")
		return FALSE

/datum/action/bb/deliver_item/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	if(!COOLDOWN_FINISHED(src, delivery_cooldown))
		owner.balloon_alert(owner, "recharging!")
		return FALSE
	var/obj/item/item = owner.get_active_held_item()
	if(!can_deliver(item))
		return FALSE

	var/list/targets = list()
	for(var/datum/mind/brother as anything in team.members - owner.mind)
		if(isliving(brother.current) && brother.current.stat != DEAD)
			targets[brother.current.real_name] = brother.current
	if(!length(targets))
		owner.balloon_alert(owner, "no living brothers!")
		return FALSE

	var/mob/living/target = targets[targets[1]]
	if(length(targets) > 1)
		var/chosen_name = tgui_input_list(owner, "Who should get [item]?", name, targets)
		if(isnull(chosen_name) || !IsAvailable(feedback = TRUE) || !COOLDOWN_FINISHED(src, delivery_cooldown))
			return FALSE
		target = targets[chosen_name]
		if(owner.get_active_held_item() != item || !can_deliver(item))
			return FALSE

	deliver(item, target)
	return TRUE

/datum/action/bb/deliver_item/proc/can_deliver(obj/item/item)
	if(isnull(item))
		owner.balloon_alert(owner, "nothing in your hand!")
		return FALSE
	if(HAS_TRAIT(item, TRAIT_NODROP) || (item.item_flags & (ABSTRACT | DROPDEL)))
		owner.balloon_alert(owner, "can't send that!")
		return FALSE
	return TRUE

/datum/action/bb/deliver_item/proc/deliver(obj/item/item, mob/living/target)
	// Forced, so that blessed and warded turfs can't stop it. That skips the no-teleport area check too, so it's done here.
	var/area/our_area = get_area(owner)
	var/area/target_area = get_area(target)
	if((our_area.area_flags & NOTELEPORT) || (target_area.area_flags & NOTELEPORT))
		owner.balloon_alert(owner, "something blocks the bond!")
		return
	if(!owner.dropItemToGround(item, silent = TRUE) || QDELETED(item))
		return
	if(!do_teleport(item, target, channel = TELEPORT_CHANNEL_FREE, no_effects = TRUE, forced = TRUE))
		owner.balloon_alert(owner, "the bond fails!")
		return
	target.put_in_hands(item)
	COOLDOWN_START(src, delivery_cooldown, 30 SECONDS)
	owner.balloon_alert(owner, "sent")
	do_sparks(3, FALSE, target)
	playsound(target, 'sound/effects/phasein.ogg', 35, TRUE)
	to_chat(target, span_notice("[owner.real_name] sends you [item] through your bond!"))
	owner.log_message("sent [item] to [key_name(target)] with Deliver Item", LOG_GAME)
