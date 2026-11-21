/**
 * An agent card that can be linked to other bonded agent cards, which all share the same access.
 */
/obj/item/card/id/advanced/chameleon/bonded
	name = "bonded agent card"
	desc = "An agent card with a transmitter wired in. Touch it on another bonded agent card to link them into a hivemind, so any access one of them gains or loses, they all do. Touch it on any other ID card or person to choose which accesses to copy."
	/// Every card in our hivemind, including us. They all point at this same list, and at the same access and wildcard lists.
	var/list/hivemind

/obj/item/card/id/advanced/chameleon/bonded/Destroy()
	if(hivemind)
		leave_hivemind()
	return ..()

/obj/item/card/id/advanced/chameleon/bonded/examine(mob/user)
	. = ..()
	if(hivemind)
		var/other_cards = length(hivemind) - 1
		. += span_notice("It is linked to [other_cards] other card[other_cards == 1 ? "" : "s"]. Alt-right-click it to unlink it.")
	else
		. += span_notice("It isn't linked to anything. Touch it on another bonded agent card to link them.")

/obj/item/card/id/advanced/chameleon/bonded/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/card/id/advanced/chameleon/bonded))
		return ..()
	var/obj/item/card/id/advanced/chameleon/bonded/other_card = interacting_with
	if(hivemind && other_card.hivemind)
		balloon_alert(user, hivemind == other_card.hivemind ? "already linked!" : "already in a hivemind!")
		return ITEM_INTERACT_BLOCKING
	if(hivemind)
		other_card.join_hivemind(src, user)
	else
		join_hivemind(other_card, user)
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	balloon_alert(user, "hivemind of [length(hivemind)]")
	return ITEM_INTERACT_SUCCESS

/obj/item/card/id/advanced/chameleon/bonded/click_alt_secondary(mob/user)
	if(!hivemind)
		balloon_alert(user, "not linked!")
		return
	if(tgui_alert(user, "Unlink [src] from its hivemind? It keeps the access it has now, but stops sharing.", "Unlink Card", list("Yes", "No")) != "Yes")
		return
	if(QDELETED(src) || !hivemind || !user.can_perform_action(src))
		return
	leave_hivemind()
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	balloon_alert(user, "unlinked")
	user.log_message("unlinked [src] from its hivemind", LOG_GAME)

/obj/item/card/id/advanced/chameleon/bonded/proc/join_hivemind(obj/item/card/id/advanced/chameleon/bonded/member, mob/user)
	if(!member.hivemind)
		member.hivemind = list(member)
	var/list/own_access = access
	hivemind = member.hivemind
	hivemind += src
	access = member.access
	wildcard_slots = member.wildcard_slots
	if(length(own_access))
		add_access(own_access, mode = TRY_ADD_ALL)
	var/list/lost_access = own_access - access
	if(length(lost_access))
		to_chat(user, span_warning("The hivemind has no room for [length(lost_access)] of [src]'s accesses, so they are lost."))
	user.log_message("linked [src] into a hivemind of [length(hivemind)] cards", LOG_GAME)

/// A hivemind can't be just one card, so the last one left leaves too.
/obj/item/card/id/advanced/chameleon/bonded/proc/leave_hivemind()
	hivemind -= src
	if(length(hivemind) == 1)
		var/obj/item/card/id/advanced/chameleon/bonded/last_card = hivemind[1]
		last_card.leave_hivemind()
	hivemind = null
	access = access.Copy()
	wildcard_slots = deep_copy_list(wildcard_slots)

/// For when something replaces the access list instead of editing it.
/obj/item/card/id/advanced/chameleon/bonded/proc/share_access()
	for(var/obj/item/card/id/advanced/chameleon/bonded/card as anything in hivemind)
		card.access = access

/obj/item/card/id/advanced/chameleon/bonded/set_access(list/new_access_list, mode = ERROR_ON_FAIL)
	. = ..()
	share_access()

/// Applying a trim writes a new list straight to the card, then always updates the label.
/obj/item/card/id/advanced/chameleon/bonded/update_label()
	. = ..()
	share_access()
