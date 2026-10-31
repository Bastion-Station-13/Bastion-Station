/**
 * Patchwork armor for Blood Brothers.
 *
 * A duster with a built in holster, and a hat with the bullet stopping component
 */

#define PATCHWORK_HAT_BLOCK_CHANCE 10

/datum/armor/patchwork
	melee = 40
	bullet = 35
	laser = 35
	energy = 45
	bomb = 30
	fire = 55
	acid = 55
	wound = 15

/obj/item/clothing/suit/armor/patchwork_duster
	name = "patchwork armored duster"
	desc = "A long leather coat with scrap plating sewn into it and space for a gun to holster."
	icon = 'bastionstation/icons/obj/clothing/suits/armor.dmi'
	icon_state = "patchwork_duster"
	worn_icon = 'bastionstation/icons/mob/clothing/suit.dmi'
	lefthand_file = 'bastionstation/icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/clothing/suits_righthand.dmi'
	inhand_icon_state = "patchwork_duster"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor_type = /datum/armor/patchwork
	actions_types = list(/datum/action/item_action/patchwork_holster)
	/// The gun in the holster.
	var/obj/item/gun/holstered
	COOLDOWN_DECLARE(holster_cooldown)

/obj/item/clothing/suit/armor/patchwork_duster/Destroy()
	if(holstered && drop_location())
		holstered.forceMove(drop_location())
	holstered = null
	return ..()

/obj/item/clothing/suit/armor/patchwork_duster/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == holstered)
		holstered = null

/obj/item/clothing/suit/armor/patchwork_duster/examine(mob/user)
	. = ..()
	if(holstered)
		. += span_notice("There's \a [holstered] in the holster.")
	else
		. += span_notice("The holster is empty.")
	. += span_notice("Wear it and use <b>Holster</b> to put a gun away or draw it.")

/obj/item/clothing/suit/armor/patchwork_duster/ui_action_click(mob/user, actiontype)
	toggle_holster(user)

/// Holsters the gun in the user's active hand, or draws the holstered one into it.
/obj/item/clothing/suit/armor/patchwork_duster/proc/toggle_holster(mob/living/user)
	if(!COOLDOWN_FINISHED(src, holster_cooldown))
		return
	if(holstered)
		if(!user.put_in_active_hand(holstered, forced = FALSE, ignore_animation = TRUE))
			balloon_alert(user, "hand full!")
			return
		balloon_alert(user, "weapon drawn")
	else
		var/obj/item/gun/holding = user.get_active_held_item()
		if(!holding)
			balloon_alert(user, "nothing to holster!")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_BULKY)
			balloon_alert(user, "it doesn't fit!")
			return
		if(!user.transferItemToLoc(holding, src, force = FALSE, silent = TRUE))
			return
		holstered = holding
		balloon_alert(user, "weapon holstered")
	COOLDOWN_START(src, holster_cooldown, 0.5 SECONDS)
	playsound(src, 'sound/items/weapons/gun/revolver/empty.ogg', 100, TRUE)

/datum/action/item_action/patchwork_holster
	name = "Holster"
	desc = "Put your gun away, or draw it."
	button_icon = 'icons/obj/clothing/belts.dmi'
	button_icon_state = "holster"

/obj/item/clothing/head/patchwork_hat
	name = "patchwork cowboy hat"
	desc = "Leather and cloth with a strip of scrap metal in the band. Shots have a funny habit of going through the brim instead of you."
	icon = 'bastionstation/icons/obj/clothing/head/hats.dmi'
	icon_state = "patchwork_cowboy_hat"
	worn_icon = 'bastionstation/icons/mob/clothing/head.dmi'
	lefthand_file = 'bastionstation/icons/mob/inhands/clothing/hats_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/clothing/hats_righthand.dmi'
	inhand_icon_state = "patchwork_cowboy_hat"
	armor_type = /datum/armor/patchwork
	/// Whether the brim is folded down into a flatcap.
	var/flatcap = FALSE

/obj/item/clothing/head/patchwork_hat/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/bullet_intercepting,\
		block_chance = PATCHWORK_HAT_BLOCK_CHANCE,\
		block_type = NONE,\
		active_slots = ITEM_SLOT_HEAD,\
		on_intercepted = CALLBACK(src, PROC_REF(on_intercepted_shot)),\
	)

/obj/item/clothing/head/patchwork_hat/examine(mob/user)
	. = ..()
	. += span_notice("<b>Use it in hand</b> to [flatcap ? "pop the brim back up" : "fold it into a flatcap"].")

/obj/item/clothing/head/patchwork_hat/attack_self(mob/user)
	. = ..()
	flatcap = !flatcap
	name = flatcap ? "patchwork flatcap" : "patchwork cowboy hat"
	icon_state = flatcap ? "patchwork_flatcap" : "patchwork_cowboy_hat"
	inhand_icon_state = icon_state
	balloon_alert(user, flatcap ? "brim folded down" : "brim popped up")
	update_appearance()
	user.update_held_items()

/obj/item/clothing/head/patchwork_hat/proc/on_intercepted_shot(mob/living/victim, obj/projectile/shot)
	victim.visible_message(
		span_warning("\The [shot] goes right through [victim]'s hat, missing [victim.p_them()] by an inch!"),
		span_userdanger("\The [shot] goes right through your hat, missing you by an inch!"),
	)
	playsound(victim, SFX_RICOCHET, 100, TRUE)

#undef PATCHWORK_HAT_BLOCK_CHANCE
