/**
 * A lunchbox with a lever that blasts donk pockets with radiation, turning any of them into a warm super donk pocket. Did you know uranium contains a lot of calories? 20 billion actually.
 * And yes, i stole this idea from goonstation's syndicate items tab. Traitor chef donkpockets.
 */
/obj/item/donk_pocket_juicer
	name = "donk pocket juicer"
	desc = "An industrial lunchbox with a radiation sticker and lever. Load uranium and a Donk-pocket to 'supercharge' it."
	icon = 'bastionstation/icons/obj/antags/donk_pocket_juicer.dmi'
	icon_state = "donk_pocket_juicer"
	base_icon_state = "donk_pocket_juicer"
	inhand_icon_state = "donk_pocket_juicer"
	lefthand_file = 'bastionstation/icons/mob/inhands/equipment/donk_pocket_juicer_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/equipment/donk_pocket_juicer_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/food/donkpocket/loaded_pocket
	/// How many blasts we have left. Each uranium sheet is worth one.
	var/charges = 0
	var/max_charges = 5
	var/blasting = FALSE

/obj/item/donk_pocket_juicer/Destroy()
	QDEL_NULL(loaded_pocket)
	return ..()

/obj/item/donk_pocket_juicer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == loaded_pocket)
		loaded_pocket = null
		update_appearance(UPDATE_ICON_STATE)

/obj/item/donk_pocket_juicer/update_icon_state()
	if(blasting)
		icon_state = "[base_icon_state]_active"
	else if(loaded_pocket)
		icon_state = "[base_icon_state]_loaded"
	else
		icon_state = base_icon_state
	return ..()

/obj/item/donk_pocket_juicer/examine(mob/user)
	. = ..()
	. += span_notice("The uranium gauge shows [charges] out of [max_charges] blasts remaining. Feed it uranium sheets to add more.")
	if(loaded_pocket)
		. += span_notice("[loaded_pocket] is slotted inside. Use it in hand to pull the lever, or alt-click to take it back out.")
	else
		. += span_notice("The slot is empty. It'll take any Donk-pocket, warm or not.")

/obj/item/donk_pocket_juicer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/sheet/mineral/uranium))
		return feed_uranium(tool, user)
	if(istype(tool, /obj/item/food/donkpocket))
		return load_pocket(tool, user)
	return NONE

/obj/item/donk_pocket_juicer/proc/feed_uranium(obj/item/stack/sheet/mineral/uranium/uranium, mob/living/user)
	if(charges >= max_charges)
		balloon_alert(user, "already full!")
		return ITEM_INTERACT_BLOCKING
	if(!uranium.use(1))
		return ITEM_INTERACT_BLOCKING
	charges++
	balloon_alert(user, "fed uranium")
	return ITEM_INTERACT_SUCCESS

/obj/item/donk_pocket_juicer/proc/load_pocket(obj/item/food/donkpocket/pocket, mob/living/user)
	if(istype(pocket, /obj/item/food/donkpocket/warm/super))
		balloon_alert(user, "already super!")
		return ITEM_INTERACT_BLOCKING
	if(loaded_pocket)
		balloon_alert(user, "already loaded!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(pocket, src))
		return ITEM_INTERACT_BLOCKING
	loaded_pocket = pocket
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	balloon_alert(user, "pocket loaded")
	return ITEM_INTERACT_SUCCESS

/obj/item/donk_pocket_juicer/click_alt(mob/user)
	if(blasting || !loaded_pocket)
		return CLICK_ACTION_BLOCKING
	user.put_in_hands(loaded_pocket)
	balloon_alert(user, "pocket removed")
	return CLICK_ACTION_SUCCESS

/obj/item/donk_pocket_juicer/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	pull_lever(user)
	return TRUE

/obj/item/donk_pocket_juicer/proc/pull_lever(mob/living/user)
	if(blasting)
		return
	if(!loaded_pocket)
		balloon_alert(user, "no donk pocket!")
		return
	if(charges <= 0)
		balloon_alert(user, "needs uranium!")
		return

	blasting = TRUE
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/switch1.ogg', 50, TRUE)
	user.visible_message(
		span_warning("[user] pulls the lever on [src], and it starts to glow an alarming shade of green!"),
		span_notice("You pull the lever and hold it down as [src] starts to hum..."),
	)
	var/finished = do_after(user, 5 SECONDS, src)
	if(QDELETED(src))
		return
	blasting = FALSE
	update_appearance(UPDATE_ICON_STATE)
	if(!finished || !loaded_pocket)
		return

	charges--
	QDEL_NULL(loaded_pocket)
	playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	var/obj/item/food/donkpocket/warm/super/super_pocket = new(drop_location())
	user.put_in_hands(super_pocket)
	user.visible_message(
		span_warning("[src] dings and spits out a glowing [super_pocket.name]!"),
		span_notice("[src] dings and spits out [super_pocket]. Still warm!"),
	)

/// Only comes out of the juicer. The cold sprite does exist, but is unused
/obj/item/food/donkpocket/warm/super
	name = "Warm Super Donk-pocket"
	desc = "A Donk-pocket that's glowing green from all the healing chemicals and macronutrients inside of it! Or that's just the radiation. Either way don't eat 2 once or you'll regret it."
	icon = 'bastionstation/icons/obj/antags/super_donkpocket.dmi'
	icon_state = "donkpocketsuper_warm"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 10,
		/datum/reagent/medicine/salbutamol = 10,
		/datum/reagent/medicine/salglu_solution = 10,
		/datum/reagent/medicine/synaptizine = 10,
		/datum/reagent/drug/methamphetamine = 10,
		/datum/reagent/medicine/leporazine = 10,
		/datum/reagent/medicine/mannitol = 10,
		/datum/reagent/medicine/sal_acid = 10,
		/datum/reagent/medicine/oxandrolone = 10,
	)
	// Food only holds 50 units by default.
	max_volume = 100
	bite_consumption = 20
	tastes = list("meat" = 2, "dough" = 2, "uranium" = 1)
