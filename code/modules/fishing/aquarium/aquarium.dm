<<<<<<< HEAD
#define AQUARIUM_LAYER_STEP 0.01
/// Aquarium content layer offsets
#define AQUARIUM_MIN_OFFSET 0.01
#define AQUARIUM_MAX_OFFSET 1

=======
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
/obj/structure/aquarium
	name = "aquarium"
	density = TRUE
	anchored = TRUE

<<<<<<< HEAD
	icon = 'icons/obj/aquarium.dmi'
	icon_state = "aquarium_base"

	integrity_failure = 0.3

=======
	icon = 'icons/obj/aquarium/tanks.dmi'
	icon_state = "aquarium_map"
	base_icon_state = "aquarium"

	integrity_failure = 0.3

	/// This is the area where fish can swim
	var/aquarium_zone_min_pw = 2
	/// The highest pixel w the fish can swim to
	var/aquarium_zone_max_pw = 31
	/// The lowest pixel z the fish can swim to
	var/aquarium_zone_min_pz = 10
	/// The highest pixel z the fish can swim to
	var/aquarium_zone_max_pz = 28

	/// Default beauty of the aquarium, without anything inside it
	var/default_beauty = 150

	///Tracks the fluid type of our aquarium component. Used for the icon suffix of some overlays and splashing water when broken.
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	var/fluid_type = AQUARIUM_FLUID_FRESHWATER

<<<<<<< HEAD
	/// Can fish reproduce in this quarium.
	var/allow_breeding = FALSE

	var/glass_icon_state = "aquarium_glass"
	var/broken_glass_icon_state = "aquarium_glass_broken"

	//This is the area where fish can swim
	var/aquarium_zone_min_px = 2
	var/aquarium_zone_max_px = 31
	var/aquarium_zone_min_py = 10
	var/aquarium_zone_max_py = 24

	var/list/fluid_types = list(AQUARIUM_FLUID_SALTWATER, AQUARIUM_FLUID_FRESHWATER, AQUARIUM_FLUID_SULPHWATEVER, AQUARIUM_FLUID_AIR)

	var/panel_open = TRUE

	///Current layers in use by aquarium contents
	var/list/used_layers = list()

	/// /obj/item/fish in the aquarium, sorted by type - does not include things with aquarium visuals that are not fish
	var/list/tracked_fish_by_type

/obj/structure/aquarium/Initialize(mapload)
	. = ..()
	update_appearance()
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(track_if_fish))
	AddElement(/datum/element/relay_attackers)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/obj/structure/aquarium/proc/track_if_fish(atom/source, atom/initialized)
	SIGNAL_HANDLER
	if(isfish(initialized))
		LAZYADDASSOCLIST(tracked_fish_by_type, initialized.type, initialized)

/obj/structure/aquarium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isfish(arrived))
		LAZYADDASSOCLIST(tracked_fish_by_type, arrived.type, arrived)

/obj/structure/aquarium/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVEASSOC(tracked_fish_by_type, gone.type, gone)

/// Returns tracked_fish_by_type but flattened and without the items in the blacklist, also shuffled if shuffle is TRUE.
/obj/structure/aquarium/proc/get_fishes(shuffle = FALSE, blacklist)
	. = list()
	for(var/fish_type in tracked_fish_by_type)
		. += tracked_fish_by_type[fish_type]
	. -= blacklist
	if(shuffle)
		. = shuffle(.)
	return .

/obj/structure/aquarium/proc/request_layer(layer_type)
	/**
	 * base aq layer
	 * min_offset = this value is returned on bottom layer mode
	 * min_offset + 0.1 fish1
	 * min_offset + 0.2 fish2
	 * ... these layers are returned for auto layer mode and tracked by used_layers
	 * min_offset + max_offset = this value is returned for top layer mode
	 * min_offset + max_offset + 1 = this is used for glass overlay
	 */
	//optional todo: hook up sending surface changed on aquarium changing layers
	switch(layer_type)
		if(AQUARIUM_LAYER_MODE_BOTTOM)
			return layer + AQUARIUM_MIN_OFFSET
		if(AQUARIUM_LAYER_MODE_TOP)
			return layer + AQUARIUM_MAX_OFFSET
		if(AQUARIUM_LAYER_MODE_AUTO)
			var/chosen_layer = layer + AQUARIUM_MIN_OFFSET + AQUARIUM_LAYER_STEP
			while((chosen_layer in used_layers) && (chosen_layer <= layer + AQUARIUM_MAX_OFFSET))
				chosen_layer += AQUARIUM_LAYER_STEP
			used_layers += chosen_layer
			return chosen_layer

/obj/structure/aquarium/proc/free_layer(value)
	used_layers -= value

/obj/structure/aquarium/proc/get_surface_properties()
	. = list()
	.[AQUARIUM_PROPERTIES_PX_MIN] = aquarium_zone_min_px
	.[AQUARIUM_PROPERTIES_PX_MAX] = aquarium_zone_max_px
	.[AQUARIUM_PROPERTIES_PY_MIN] = aquarium_zone_min_py
	.[AQUARIUM_PROPERTIES_PY_MAX] = aquarium_zone_max_py

/obj/structure/aquarium/update_overlays()
	. = ..()
	if(panel_open)
		. += "panel"

	//Glass overlay goes on top of everything else.
	var/mutable_appearance/glass_overlay = mutable_appearance(icon,broken ? broken_glass_icon_state : glass_icon_state,layer=AQUARIUM_MAX_OFFSET-1)
	. += glass_overlay

/obj/structure/aquarium/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to [panel_open ? "close" : "open"] the control panel.")

/obj/structure/aquarium/click_alt(mob/user)
	panel_open = !panel_open
	update_appearance()
	return CLICK_ACTION_SUCCESS
=======
	///The initial mode for the aquarium component
	var/init_mode = AQUARIUM_MODE_AUTO

/obj/structure/aquarium/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/aquarium, aquarium_zone_min_pw, aquarium_zone_max_pw, aquarium_zone_min_pz, aquarium_zone_max_pz, default_beauty, init_mode = init_mode)
	AddComponent(/datum/component/plumbing/aquarium, start = anchored)
	RegisterSignal(src, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_aquarium_liquid_changed))
	update_appearance()

/obj/structure/aquarium/update_icon()
	. = ..()
	///"aquarium_map" is used for mapping, so mappers can tell what it's.
	icon_state = base_icon_state + "_base"

/// Updates the appearance of the aquarium when its fluid type changes
/obj/structure/aquarium/proc/on_aquarium_liquid_changed(datum/source, fluid_type)
	SIGNAL_HANDLER
	src.fluid_type = fluid_type
	update_appearance()

/obj/structure/aquarium/update_overlays()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_AQUARIUM_PANEL_OPEN))
		. += base_icon_state + "_panel"

	var/icon_suffix = fluid_type == AQUARIUM_FLUID_AIR ? "air" : "water"
	///The glass overlay
	if(broken)
		icon_suffix += "_broken"
		. += mutable_appearance(icon, base_icon_state + "_glass_cracks", layer = layer + AQUARIUM_BORDERS_LAYER)
	. += mutable_appearance(icon, base_icon_state + "_glass_[icon_suffix]", layer = layer + AQUARIUM_GLASS_LAYER)
	. += mutable_appearance(icon, base_icon_state + "_borders", layer = layer + AQUARIUM_BORDERS_LAYER)
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))

/obj/structure/aquarium/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS
/// Starts processing the aquarium to feed the fish once something is put in the feed storage

<<<<<<< HEAD
/obj/structure/aquarium/attackby(obj/item/item, mob/living/user, params)
	if(broken)
		var/obj/item/stack/sheet/glass/glass = item
		if(istype(glass))
			if(glass.get_amount() < 2)
				to_chat(user, span_warning("You need two glass sheets to fix the case!"))
				return
			to_chat(user, span_notice("You start fixing [src]..."))
			if(do_after(user, 2 SECONDS, target = src))
				glass.use(2)
				broken = FALSE
				atom_integrity = max_integrity
				update_appearance()
			return TRUE
	else
		var/datum/component/aquarium_content/content_component = item.GetComponent(/datum/component/aquarium_content)
		if(content_component && content_component.is_ready_to_insert(src) && user.transferItemToLoc(item, src))
			update_appearance()
			return TRUE

	if(istype(item, /obj/item/fish_feed))
		if(!item.reagents.total_volume)
			balloon_alert(user, "[item] is empty!")
			return TRUE
		var/list/fishes = get_fishes()
		for(var/obj/item/fish/fish as anything in fishes)
			fish.feed(item.reagents)
		balloon_alert(user, "fed the fish")
		return TRUE
	return ..()

/obj/structure/aquarium/proc/on_attacked(datum/source, mob/attacker, attack_flags)
	var/list/fishes = get_fishes()
	//I wish this were an aquarium signal, but the aquarium_content component got in the way.
	for(var/obj/item/fish/fish as anything in fishes)
		SEND_SIGNAL(fish, COMSIG_FISH_STIRRED)

/obj/structure/aquarium/interact(mob/user)
	if(!broken && user.pulling && isliving(user.pulling))
		var/mob/living/living_pulled = user.pulling
		var/datum/component/aquarium_content/content_component = living_pulled.GetComponent(/datum/component/aquarium_content)
		if(content_component && content_component.is_ready_to_insert(src))
			try_to_put_mob_in(user)
	else if(panel_open)
		. = ..() //call base ui_interact
	else
		admire(user)

/// Tries to put mob pulled by the user in the aquarium after a delay
/obj/structure/aquarium/proc/try_to_put_mob_in(mob/user)
	if(user.pulling && isliving(user.pulling))
		var/mob/living/living_pulled = user.pulling
		if(living_pulled.buckled || living_pulled.has_buckled_mobs())
			to_chat(user, span_warning("[living_pulled] is attached to something!"))
			return
		user.visible_message(span_danger("[user] starts to put [living_pulled] into [src]!"))
		if(do_after(user, 10 SECONDS, target = src))
			if(QDELETED(living_pulled) || user.pulling != living_pulled || living_pulled.buckled || living_pulled.has_buckled_mobs())
				return
			var/datum/component/aquarium_content/content_component = living_pulled.GetComponent(/datum/component/aquarium_content)
			if(content_component || content_component.is_ready_to_insert(src))
				return
			user.visible_message(span_danger("[user] stuffs [living_pulled] into [src]!"))
			living_pulled.forceMove(src)
			update_appearance()

///Apply mood bonus depending on aquarium status
/obj/structure/aquarium/proc/admire(mob/living/user)
	to_chat(user,span_notice("You take a moment to watch [src]."))
	if(do_after(user, 5 SECONDS, target = src))
		var/alive_fish = 0
		var/dead_fish = 0
		var/list/tracked_fish = get_fishes()
		for(var/obj/item/fish/fish in tracked_fish)
			if(fish.status == FISH_ALIVE)
				alive_fish++
			else
				dead_fish++
		//Check if there are live fish - good mood
		//All fish dead - bad mood.
		//No fish - nothing.
		if(alive_fish > 0)
			user.add_mood_event("aquarium", /datum/mood_event/aquarium_positive)
		else if(dead_fish > 0)
			user.add_mood_event("aquarium", /datum/mood_event/aquarium_negative)
		// Could maybe scale power of this mood with number/types of fish

/obj/structure/aquarium/ui_data(mob/user)
	. = ..()
	.["fluid_type"] = fluid_type
	.["temperature"] = fluid_temp
	.["allow_breeding"] = allow_breeding
	var/list/content_data = list()
	for(var/atom/movable/fish in contents)
		content_data += list(list("name"=fish.name,"ref"=ref(fish)))
	.["contents"] = content_data

/obj/structure/aquarium/ui_static_data(mob/user)
	. = ..()
	//I guess these should depend on the fluid so lava critters can get high or stuff below water freezing point but let's keep it simple for now.
	.["minTemperature"] = min_fluid_temp
	.["maxTemperature"] = max_fluid_temp
	.["fluidTypes"] = fluid_types

/obj/structure/aquarium/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("temperature")
			var/temperature = params["temperature"]
			if(isnum(temperature))
				fluid_temp = clamp(temperature, min_fluid_temp, max_fluid_temp)
				. = TRUE
		if("fluid")
			if(params["fluid"] in fluid_types)
				fluid_type = params["fluid"]
				SEND_SIGNAL(src, COMSIG_AQUARIUM_FLUID_CHANGED, fluid_type)
				. = TRUE
		if("allow_breeding")
			allow_breeding = !allow_breeding
			. = TRUE
		if("remove")
			var/atom/movable/inside = locate(params["ref"]) in contents
			if(inside)
				if(isitem(inside))
					user.put_in_hands(inside)
				else
					inside.forceMove(get_turf(src))
				to_chat(user,span_notice("You take out [inside] from [src]."))

/obj/structure/aquarium/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Aquarium", name)
		ui.open()
=======
/obj/structure/aquarium/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stack/sheet/glass))
		return
	if(!broken)
		balloon_alert(user, "aquarium not broken!")
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stack/sheet/glass/glass = tool
	if(glass.get_amount() < 2)
		balloon_alert(user, "it needs two sheets!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "fixing the aquarium...")
	if(!do_after(user, 2 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING
	glass.use(2)
	broken = FALSE
	atom_integrity = max_integrity
	update_appearance()
	return ITEM_INTERACT_SUCCESS
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))

/obj/structure/aquarium/atom_break(damage_flag)
	. = ..()
	if(!broken)
		aquarium_smash()

/obj/structure/aquarium/proc/aquarium_smash()
	broken = TRUE
	var/possible_destinations_for_fish = list()
	var/droploc = drop_location()
	if(isturf(droploc))
		possible_destinations_for_fish = get_adjacent_open_turfs(droploc)
	else
		possible_destinations_for_fish = list(droploc)
	playsound(src, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)
	for(var/atom/movable/content as anything in contents)
		content.forceMove(pick(possible_destinations_for_fish))
	if(fluid_type != AQUARIUM_FLUID_AIR)
		var/datum/reagents/reagent_splash = new()
		reagent_splash.add_reagent(/datum/reagent/water, 30)
		chem_splash(droploc, null, 3, list(reagent_splash))
	update_appearance()

<<<<<<< HEAD
#undef AQUARIUM_LAYER_STEP
#undef AQUARIUM_MIN_OFFSET
#undef AQUARIUM_MAX_OFFSET

=======
/obj/structure/aquarium/prefilled
	anchored = TRUE
	init_mode = AQUARIUM_MODE_SAFE
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))

/obj/structure/aquarium/prefilled/Initialize(mapload)
	. = ..()

	new /obj/item/aquarium_prop/rocks(src)
	new /obj/item/aquarium_prop/seaweed(src)

	new /obj/item/fish/goldfish(src)
	new /obj/item/fish/angelfish(src)
	new /obj/item/fish/guppy(src)
<<<<<<< HEAD
=======

	//They'll be alive for about 30 minutes with this amount.
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 3)

/obj/item/fish_tank
	name = "fish tank"
	desc = "A more portable sort of aquarium to store various fishes in, unless they're too big or there're too many of them."
	icon = 'icons/obj/aquarium/tanks.dmi'
	icon_state = "fish_tank_map"
	base_icon_state = "fish_tank"
	force = 5
	throwforce = 5
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	item_flags = SLOWS_WHILE_IN_HAND

	custom_price = PAYCHECK_CREW * 9

	///Tracks the fluid type of our aquarium component. Used for overlays
	var/fluid_type = AQUARIUM_FLUID_FRESHWATER

	///Fish which size exceed this value cannot be inserted
	var/maximum_relative_size = 100
	///Fish cannot be inserted if the sum of the size of all fish in this tank exceeds this value.
	var/max_total_size = 220
	///Tracks the sum of the size of all fish in this tank
	var/current_summed_size = 0
	///Tracks the sum of the weight of all fish in this tank
	var/current_summed_weight = 0

	/// Multiplier for the slowdown caused by the weight of the fish inside
	var/slowdown_coeff = 1
	/// Whether a speed potion was used on this, removing the slowdown for good. MONKESTATION EDIT: no TRAIT_SPEED_POTIONED
	var/speed_potioned = FALSE

	///The minimum fluid temperature of this fish tank
	var/min_fluid_temp = MIN_AQUARIUM_TEMP + 12
	///The maximum fluid temperature of this fish tank
	var/max_fluid_temp = MAX_AQUARIUM_TEMP - 32
	///The reagent capacity of this fish tank
	var/reagent_size = 4

	///The initial mode for the aquarium component
	var/init_mode = AQUARIUM_MODE_AUTO

/obj/item/fish_tank/Initialize(mapload)
	. = ..()
	update_appearance()
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_speed_potioned)) // MONKESTATION EDIT
	AddComponent(\
		/datum/component/aquarium,\
		min_px = 6,\
		max_px = 26,\
		min_py = 7,\
		max_py = 24,\
		default_beauty = 100,\
		reagents_size = src.reagent_size,\
		min_fluid_temp = src.min_fluid_temp,\
		max_fluid_temp = src.max_fluid_temp,\
		init_mode = init_mode,\
	)
	AddComponent(/datum/component/plumbing/aquarium, start = anchored)
	RegisterSignal(src, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_aquarium_liquid_changed))
	RegisterSignal(src, COMSIG_AQUARIUM_CAN_INSERT, PROC_REF(can_insert))
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_new_fish))

/obj/item/fish_tank/update_icon()
	. = ..()
	///"aquarium_map" is used for mapping, so mappers can tell what it's.
	icon_state = base_icon_state

/// Updates the appearance of the fish tank when its fluid type changes
/obj/item/fish_tank/proc/on_aquarium_liquid_changed(datum/source, fluid_type)
	SIGNAL_HANDLER
	src.fluid_type = fluid_type
	update_appearance()

/obj/item/fish_tank/update_overlays()
	. = ..()
	. += "[base_icon_state]_panel[HAS_TRAIT(src, TRAIT_AQUARIUM_PANEL_OPEN) ? "_open" : ""]"
	. += mutable_appearance(icon, "[base_icon_state]_[fluid_type == AQUARIUM_FLUID_AIR ? "air" : "water"]", layer = layer + AQUARIUM_GLASS_LAYER)
	. += mutable_appearance(icon, "[base_icon_state]_borders", layer = layer + AQUARIUM_BORDERS_LAYER)

/// Stops fish that are too big for the tank from being put inside
/obj/item/fish_tank/proc/can_insert(atom/movable/source, obj/item/item, mob/living/user)
	SIGNAL_HANDLER
	if(!isfish(item))
		return
	var/obj/item/fish/fish = item
	if(fish.size > maximum_relative_size)
		balloon_alert(user, "fish is too big!")
		return COMSIG_CANNOT_INSERT_IN_AQUARIUM
	if(current_summed_size > max_total_size)
		balloon_alert(user, "fish tank is full!")
		return COMSIG_CANNOT_INSERT_IN_AQUARIUM
	return COMSIG_CAN_INSERT_IN_AQUARIUM

/obj/item/fish_tank/Entered(atom/movable/entered)
	. = ..()
	on_new_fish(src, entered)

/// Adds the size and weight of the fish that was just put inside the tank
/obj/item/fish_tank/proc/on_new_fish(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(!isfish(movable))
		return
	var/obj/item/fish/fish = movable
	change_size_weight(fish.size, fish.weight)
	RegisterSignal(fish, COMSIG_FISH_UPDATE_SIZE_AND_WEIGHT, PROC_REF(on_fish_size_weight_updated))

/// Updates the total size and weight of the tank when one of the fish inside grows
/obj/item/fish_tank/proc/on_fish_size_weight_updated(obj/item/fish/source, new_size, new_weight)
	SIGNAL_HANDLER
	change_size_weight(new_size - source.size, new_weight - source.weight)

/obj/item/fish_tank/Exited(atom/movable/gone)
	if(isfish(gone))
		var/obj/item/fish/fish = gone
		change_size_weight(-fish.size, -fish.weight)
		UnregisterSignal(fish, COMSIG_FISH_UPDATE_SIZE_AND_WEIGHT)
	return ..()

/// MONKESTATION EDIT: Speed potions remove the slowdown for good, even if more fish are added later
/obj/item/fish_tank/proc/on_speed_potioned(datum/source)
	SIGNAL_HANDLER
	if(speed_potioned || slowdown <= 0) //the potion itself refuses to work on items without slowdown
		return
	speed_potioned = TRUE
	slowdown = 0
	drag_slowdown = 0
	if(ismob(loc))
		var/mob/mob = loc
		mob.update_equipment_speed_mods()

/// Updates the total size and weight of the tank, its slowdown and whether the fish can grow and reproduce
/obj/item/fish_tank/proc/change_size_weight(size_change, weight_change)
	current_summed_size += size_change
	current_summed_weight += weight_change
	if(current_summed_size > max_total_size)
		ADD_TRAIT(src, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, INNATE_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, INNATE_TRAIT)
	if(speed_potioned || current_summed_weight < FISH_WEIGHT_SLOWDOWN)
		slowdown = 0
		drag_slowdown = 0
	else
		slowdown = GET_FISH_SLOWDOWN(current_summed_weight) * slowdown_coeff
		drag_slowdown = slowdown * 0.5
	if(ismob(loc))
		var/mob/mob = loc
		mob.update_equipment_speed_mods()

	force = min(2 + (GET_FISH_WEIGHT_RANK(current_summed_weight) * 3), 21)
	throwforce = force

/obj/item/fish_tank/examine(mob/user)
	. = ..()
	if(HAS_TRAIT_FROM(src, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, INNATE_TRAIT))
		. += span_warning("It's cramped in there. There's no more room for fish to reproduce and grow!")

///The lawyer's own pet goldfish's fish tank. It used to be an aquarium, but now it can be held and carried around.
/obj/item/fish_tank/lawyer
	init_mode = AQUARIUM_MODE_SAFE

/obj/item/fish_tank/lawyer/Initialize(mapload)
	. = ..()

	new /obj/item/aquarium_prop/sand(src)
	new /obj/item/aquarium_prop/seaweed(src)

	if(prob(85))
		new /obj/item/fish/goldfish/gill(src)
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 3)
	else
		new /obj/item/fish/goldfish/three_eyes/gill(src)
		reagents.add_reagent(/datum/reagent/toxin/mutagen, 3) //three eyes goldfish feed on mutagen.
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
