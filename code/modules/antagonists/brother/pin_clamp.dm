/**
 * Crushes whatever firing pin a gun has and jams a plain electronic one in its place, so pin locked guns work for anyone. (This will be fun when a miner rolls BB and uses it on their mining weapons)
 */
/obj/item/pin_clamp
	name = "pin clamp"
	desc = "A rusty clamp with a firing pin wedged in its jaws. Turn the handle and the old pin doesn't survive."
	icon = 'bastionstation/icons/obj/antags/blood_brother.dmi'
	icon_state = "pin_clamp"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/pin_clamp/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isgun(interacting_with))
		return NONE
	var/obj/item/gun/gun = interacting_with
	if(!can_clamp(gun, user))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(
		span_warning("[user] clamps [src] over [gun]'s receiver and starts cranking the handle..."),
		span_notice("You line the old pin up under the screw and start cranking..."),
	)
	playsound(gun, 'sound/items/ratchet.ogg', 50, TRUE)
	if(!do_after(user, 3 SECONDS, gun) || !can_clamp(gun, user))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/firing_pin/old_pin = gun.pin
	if(old_pin)
		old_pin.gun_remove(user)
		qdel(old_pin)
		playsound(gun, 'sound/effects/snap.ogg', 50, TRUE)
		user.visible_message(
			span_danger("[gun]'s old firing pin snaps out in pieces as [user] cranks [src] down!"),
			span_notice("The old pin is crushed, and the new electronic pin is jammed in its place."),
		)
	else
		user.visible_message(
			span_warning("[user] cranks [src] down, seating a new firing pin in [gun]."),
			span_notice("The new electronic pin seats into the empty receiver."),
		)
	var/obj/item/firing_pin/new_pin = new(gun)
	new_pin.gun_insert(user, gun)
	user.log_message("replaced the [old_pin ? old_pin.name : "missing firing pin"] of [gun] with an electronic firing pin using a pin clamp", LOG_GAME)
	to_chat(user, span_notice("[src] bends out of shape. It won't be cranking anything else."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Fail if the gun is pinless, already has an electronic pin, or if the gun is deleted while the clamp is being used.
/obj/item/pin_clamp/proc/can_clamp(obj/item/gun/gun, mob/living/user)
	if(QDELETED(gun))
		return FALSE
	if(gun.pinless)
		gun.balloon_alert(user, "doesn't take a pin!")
		return FALSE
	if(gun.pin?.type == /obj/item/firing_pin)
		gun.balloon_alert(user, "already electronic!")
		return FALSE
	return TRUE
