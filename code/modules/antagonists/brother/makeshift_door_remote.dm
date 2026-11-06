#define REMOTE_MODE_SHOCK "shock"
/// How many charges electrifying a door costs. Each pip on the sprite is worth this much.
#define REMOTE_SHOCK_COST 5

/**
 * An omni door remote that can also electrify doors, but runs on a limited number of charges.
 */
/obj/item/door_remote/makeshift
	name = "makeshift door remote"
	desc = "A door remote hacked together from spare parts. It opens every door on the station and can electrify them too, but the battery won't last."
	icon = 'bastionstation/icons/obj/antags/makeshift_door_remote.dmi'
	icon_state = "remote_makeshift_open"
	inhand_icon_state = "remote_makeshift"
	lefthand_file = 'bastionstation/icons/mob/inhands/equipment/makeshift_door_remote_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/equipment/makeshift_door_remote_righthand.dmi'
	region_access = REGION_ALL_STATION
	remote_type = "makeshift"
	var/charges = 20
	var/max_charges = 20

/obj/item/door_remote/makeshift/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/door_remote/makeshift/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] of [max_charges] charges left. Electrifying a door takes [REMOTE_SHOCK_COST], and anything else takes 1.")

/obj/item/door_remote/makeshift/attack_self(mob/user)
	var/static/list/modes = list(
		"open" = "Open Door",
		"bolt" = "Toggle Bolts",
		"emergency" = "Toggle Emergency Access",
		REMOTE_MODE_SHOCK = "Electrify",
	)
	mode = modes[(modes.Find(mode) % length(modes)) + 1]
	update_appearance(UPDATE_ICON_STATE)
	balloon_alert(user, "mode: [modes[mode]]")

/obj/item/door_remote/makeshift/update_icon_state()
	. = ..()
	if(mode == REMOTE_MODE_SHOCK)
		icon_state = "[base_icon_state]_[remote_type]_[REMOTE_MODE_SHOCK]"

/obj/item/door_remote/makeshift/update_overlays()
	. = ..()
	. += "[base_icon_state]_[remote_type]_charge[CEILING(charges / max_charges * 4, 1)]"

/obj/item/door_remote/makeshift/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(mode == REMOTE_MODE_SHOCK)
		return toggle_electrified(interacting_with, user)
	if(charges <= 0)
		balloon_alert(user, "out of charge!")
		return ITEM_INTERACT_BLOCKING
	. = ..()
	if(. == ITEM_INTERACT_SUCCESS)
		use_charges(1)

/// Switching a door's shock off again is free, so you can always get out of your own trap.
/obj/item/door_remote/makeshift/proc/toggle_electrified(atom/target, mob/living/user)
	var/obj/machinery/door/airlock/airlock = target
	if(!istype(airlock))
		airlock = locate() in get_turf(target)
	if(isnull(airlock) || !airlock.opens_with_door_remote)
		target.balloon_alert(user, "only airlocks!")
		return ITEM_INTERACT_BLOCKING
	if(!airlock.check_access_list(access_list) || !airlock.requiresID())
		airlock.balloon_alert(user, "can't access!")
		return ITEM_INTERACT_BLOCKING
	if(!airlock.hasPower() || !airlock.canAIControl())
		airlock.balloon_alert(user, "nothing happens!")
		return ITEM_INTERACT_BLOCKING

	if(airlock.isElectrified())
		airlock.set_electrified(MACHINE_NOT_ELECTRIFIED, user)
		airlock.balloon_alert(user, "shock off")
		return ITEM_INTERACT_SUCCESS
	if(charges < REMOTE_SHOCK_COST)
		balloon_alert(user, "not enough charge!")
		return ITEM_INTERACT_BLOCKING
	airlock.set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, user)
	use_charges(REMOTE_SHOCK_COST)
	airlock.balloon_alert(user, "electrified")
	return ITEM_INTERACT_SUCCESS

/obj/item/door_remote/makeshift/proc/use_charges(amount)
	charges = max(charges - amount, 0)
	update_appearance(UPDATE_OVERLAYS)

#undef REMOTE_MODE_SHOCK
#undef REMOTE_SHOCK_COST
