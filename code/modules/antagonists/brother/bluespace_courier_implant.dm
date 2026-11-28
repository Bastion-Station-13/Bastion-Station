/**
 * Use it in hand to permanently unlock Deliver Item, which teleports held items to your blood brothers.
 */
/obj/item/bluespace_courier_implant
	name = "bluespace courier implant"
	desc = "A crude bluespace implant that links to your blood bond allowing you to teleport items to your fellow brothers."
	icon = 'bastionstation/icons/obj/antags/bluespace_courier_implant.dmi'
	icon_state = "bluespace_courier_implant"
	w_class = WEIGHT_CLASS_TINY

/obj/item/bluespace_courier_implant/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	var/datum/antagonist/brother/bond = user.mind?.has_antag_datum(/datum/antagonist/brother)
	if(!bond)
		balloon_alert(user, "nothing happens")
		return TRUE
	if(bond.has_courier_implant)
		balloon_alert(user, "already implanted!")
		return TRUE

	bond.unlock_deliver_item()
	to_chat(user, span_notice("You press [src] against your skin and it burrows in. You can feel your bond's reach now."))
	playsound(user, 'sound/machines/click.ogg', 30, TRUE)
	qdel(src)
	return TRUE
