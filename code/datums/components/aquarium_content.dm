/// Allows movables to be inserted/displayed in aquariums.
/datum/component/aquarium_content

	/// This is visual effect holder that will end up in aquarium's vis_contents
	var/obj/effect/aquarium/vc_obj

	/**
	 * Fish sprite how to:
	 * The aquarium icon state needs to be centered on 16,16 in the dmi and facing left by default.
	 * sprite_width/sprite_height are the sizes it will have in aquarium and used to control animation boundaries.
	 * Ideally these two vars represent the size of the aquarium icon state, but they can be one or two units shorter
	 * to give more room for the visual to float around inside the aquarium, since the aquarium tank frame overlay will likely
	 * cover the extra pixels anyway.
	 */

<<<<<<< HEAD

	/// Icon used for in aquarium sprite
	var/icon = 'icons/obj/aquarium.dmi'
	/// If this is set this icon state will be used for the holder while icon_state will only be used for item/catalog. Transformation from source_width/height WON'T be applied.
	var/icon_state
	/// Applied to vc object only for use with greyscaled icons.
	var/aquarium_vc_color
	/// Transformation applied to the visual holder - used when scaled down sprites are used as in aquarium visual
	var/matrix/base_transform

	/// How the thing will be layered
	var/layer_mode = AQUARIUM_LAYER_MODE_AUTO

	/// If the starting position is randomised within bounds when inserted into aquarium.
	var/randomize_position = FALSE

	//Target sprite size for path/position calculations.
	var/sprite_height = 3
	var/sprite_width = 3

	//This is the size of the source sprite. This will be used to calculate scale down factor.
	var/source_width = 32
	var/source_height = 32

=======
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	/// Currently playing animation
	var/current_animation

	/// Does this behviour need additional processing in aquarium, will be added to SSobj processing on insertion
	var/processing = FALSE

	/// Signals for the aquarium we're in that trigger an animation update
	var/list/animation_update_signals

<<<<<<< HEAD
	/// Proc used to retrieve current animation state from the parent, optional
	var/animation_getter

	/// Signals of the parent that will trigger animation update
	var/animation_update_signals


/datum/component/aquarium_content/Initialize(animation_getter, animation_update_signals)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.animation_getter = animation_getter
	src.animation_update_signals = animation_update_signals
	if(animation_update_signals)
		RegisterSignals(parent, animation_update_signals, PROC_REF(generate_animation))

	if(istype(parent,/obj/item/fish))
		InitializeFromFish()
	else if(istype(parent,/obj/item/aquarium_prop))
		InitializeFromProp()
	else
		InitializeOther()
=======
/datum/component/aquarium_content/Initialize(animation_update_signals)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.animation_update_signals = islist(animation_update_signals) ? animation_update_signals : list(animation_update_signals)
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))

	ADD_TRAIT(parent, TRAIT_AQUARIUM_CONTENT, REF(src))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(enter_aquarium))

	//If component is added to something already in aquarium at the time initialize it properly.
	var/atom/movable/movable_parent = parent
	if(movable_parent.loc && HAS_TRAIT(movable_parent.loc, TRAIT_IS_AQUARIUM))
		on_inserted(movable_parent.loc)

<<<<<<< HEAD
/// Sets visuals properties for fish
/datum/component/aquarium_content/proc/InitializeFromFish()
	var/obj/item/fish/fish = parent

	icon = fish.icon
	sprite_height = fish.sprite_height
	sprite_width = fish.sprite_width
	aquarium_vc_color = fish.aquarium_vc_color

	if(fish.dedicated_in_aquarium_icon_state)
		if(fish.dedicated_in_aquarium_icon)
			icon = fish.dedicated_in_aquarium_icon
		icon_state = fish.dedicated_in_aquarium_icon_state
		base_transform = matrix()
	else
		icon_state = fish.icon_state
		var/matrix/matrix = matrix()
		var/x_scale = fish.sprite_width / fish.source_width
		var/y_scale = fish.sprite_height / fish.source_height
		matrix.Scale(x_scale, y_scale)
		base_transform = matrix

	randomize_position = TRUE

/// Sets visuals properties for fish
/datum/component/aquarium_content/proc/InitializeFromProp()
	var/obj/item/aquarium_prop/prop = parent

	icon = prop.icon
	icon_state = prop.icon_state
	layer_mode = prop.layer_mode
	sprite_height = 32
	sprite_width = 32
	base_transform = matrix()

	unique = TRUE

/// Mostly for admin abuse
/datum/component/aquarium_content/proc/InitializeOther()
	sprite_width = 8
	sprite_height = 8

	var/matrix/matrix = matrix()
	var/x_scale = sprite_width / 32
	var/y_scale = sprite_height / 32
	matrix.Scale(x_scale, y_scale)
	base_transform = matrix


/datum/component/aquarium_content/PreTransfer()
	. = ..()
	REMOVE_TRAIT(parent, TRAIT_AQUARIUM_CONTENT, REF(src))

=======
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
/datum/component/aquarium_content/Destroy(force)
	var/atom/movable/movable = parent
	if(movable.loc && HAS_TRAIT(movable.loc, TRAIT_IS_AQUARIUM))
		remove_from_aquarium(movable.loc)
	QDEL_NULL(vc_obj)
	REMOVE_TRAIT(parent, TRAIT_AQUARIUM_CONTENT, REF(src))
	return ..()

/datum/component/aquarium_content/proc/enter_aquarium(datum/source, OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(HAS_TRAIT(movable_parent.loc, TRAIT_IS_AQUARIUM))
		on_inserted(movable_parent.loc)

<<<<<<< HEAD
/datum/component/aquarium_content/proc/is_ready_to_insert(obj/structure/aquarium/aquarium)
	//This is kinda awful but we're unaware of other fish
	if(unique)
		for(var/atom/movable/fish_or_prop in aquarium)
			if(fish_or_prop == parent)
				continue
			if(fish_or_prop.type == parent.type)
				return FALSE
	return TRUE

/datum/component/aquarium_content/proc/on_inserted(atom/aquarium)
	current_aquarium = aquarium
	RegisterSignal(current_aquarium, COMSIG_ATOM_EXITED, PROC_REF(on_removed))
	RegisterSignal(current_aquarium, COMSIG_AQUARIUM_SURFACE_CHANGED, PROC_REF(on_surface_changed))
	RegisterSignal(current_aquarium, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_fluid_changed))
=======
/// Called when the parent is put inside an aquarium, registers the signals and adds the visual overlay
/datum/component/aquarium_content/proc/on_inserted(atom/movable/aquarium)
	RegisterSignal(aquarium, COMSIG_ATOM_EXITED, PROC_REF(on_removed))
	RegisterSignal(aquarium, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_fluid_changed))
	RegisterSignals(aquarium, animation_update_signals, PROC_REF(animation_update_signal_proc))
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))

	if(processing)
		START_PROCESSING(SSobj, src)

	//If we don't have vc object yet build it
	if(!vc_obj)
		generate_base_vc(aquarium)

	//Set default position and layer
	set_vc_base_position()
	generate_animation(reset = TRUE)

	//Finally add it to to objects vis_contents
	aquarium.vis_contents |= vc_obj

<<<<<<< HEAD
/// Aquarium surface changed in some way, we need to recalculate base position and aninmation
/datum/component/aquarium_content/proc/on_surface_changed()
	SIGNAL_HANDLER
	set_vc_base_position()
	generate_animation(reset = TRUE) //our animation start point changed, gotta redo

/datum/component/aquarium_content/proc/on_fluid_changed()
=======
/// Updates the visual overlay when the fluid type of the aquarium changes
/datum/component/aquarium_content/proc/on_fluid_changed(datum/source, new_fluid_type)
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	SIGNAL_HANDLER
	vc_obj.fluid_type = new_fluid_type
	generate_animation()

///Called when one of the signals in the 'animation_update_signals' is sent
/datum/component/aquarium_content/proc/animation_update_signal_proc(datum/source)
	generate_animation()

///Sends a signal to the parent to get them to update the aquarium animation of the visual object
/datum/component/aquarium_content/proc/generate_animation(reset = FALSE)
	var/atom/movable/movable = parent
	SEND_SIGNAL(movable, COMSIG_AQUARIUM_CONTENT_DO_ANIMATION, reset ? null : current_animation, vc_obj)

/// Generates common visual object, propeties that don't depend on aquarium surface
/datum/component/aquarium_content/proc/generate_base_vc(atom/movable/aquarium)
	vc_obj = new
	vc_obj.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_PLANE //plane so it shows properly in containers on inventory ui for handheld cases
	update_vc_color(parent)
	RegisterSignal(parent, COMSIG_ATOM_COLOR_UPDATED, PROC_REF(update_vc_color))
	SEND_SIGNAL(parent, COMSIG_AQUARIUM_CONTENT_GENERATE_APPEARANCE, vc_obj, aquarium)

/// Updates the color of the visual overlay to match the parent
/datum/component/aquarium_content/proc/update_vc_color(atom/movable/source)
	SIGNAL_HANDLER
	var/color_to_use = source.color
	if(!color_to_use && isfish(source)) //Small bit of snowflake code for those fish overlays that are greyscale.
		var/obj/item/fish/fish = source
		color_to_use = fish.aquarium_vc_color
	vc_obj.color = color_to_use

/datum/component/aquarium_content/proc/set_vc_base_position()
	var/atom/movable/movable = parent
	SEND_SIGNAL(movable.loc, COMSIG_AQUARIUM_SET_VISUAL, vc_obj) //set the necessary layer as well as the pixel bounds first
	SEND_SIGNAL(movable, COMSIG_AQUARIUM_CONTENT_RANDOMIZE_POSITION, movable.loc, vc_obj)

<<<<<<< HEAD
/datum/component/aquarium_content/proc/randomize_base_position()
	var/list/aq_properties = current_aquarium.get_surface_properties()
	var/avg_width = round(sprite_width / 2)
	var/avg_height = round(sprite_height / 2)
	var/px_min = aq_properties[AQUARIUM_PROPERTIES_PX_MIN] + avg_width - 16
	var/px_max = aq_properties[AQUARIUM_PROPERTIES_PX_MAX] - avg_width - 16
	var/py_min = aq_properties[AQUARIUM_PROPERTIES_PY_MIN] + avg_height - 16
	var/py_max = aq_properties[AQUARIUM_PROPERTIES_PY_MAX] - avg_width - 16

	base_px = rand(px_min,px_max)
	base_py = rand(py_min,py_max)

	vc_obj.pixel_x = base_px
	vc_obj.pixel_y = base_py

/datum/component/aquarium_content/proc/on_removed(datum/source, atom/movable/gone, direction)
=======
/// Called when something leaves the aquarium, removes the parent from it if it was the one leaving
/datum/component/aquarium_content/proc/on_removed(atom/movable/aquarium, atom/movable/gone, direction)
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	SIGNAL_HANDLER
	if(parent != gone)
		return
	remove_from_aquarium(aquarium)

<<<<<<< HEAD
/datum/component/aquarium_content/proc/remove_from_aquarium()
	UnregisterSignal(current_aquarium, list(COMSIG_AQUARIUM_SURFACE_CHANGED, COMSIG_AQUARIUM_FLUID_CHANGED, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_EXITED))
	remove_visual_from_aquarium()
	current_aquarium = null
=======
/// Unregisters the aquarium signals and removes the visual overlay from it
/datum/component/aquarium_content/proc/remove_from_aquarium(atom/movable/aquarium)
	UnregisterSignal(aquarium, list(COMSIG_AQUARIUM_FLUID_CHANGED, COMSIG_ATOM_EXITED) + animation_update_signals)
	SEND_SIGNAL(aquarium, COMSIG_AQUARIUM_REMOVE_VISUAL, vc_obj)

///The visual overlay of the aquarium content. It can hold a few vars with values about the component of the aquarium it's in.
/obj/effect/aquarium
	layer = 0 //set on set_vc_base_position
	/// How the visual will be layered
	var/layer_mode = AQUARIUM_LAYER_MODE_AUTO
	///minimum pixel x, inherited from the aquarium
	var/aquarium_zone_min_pw
	///maximum pixel x, inherited from the aquarium
	var/aquarium_zone_max_pw
	///minimum pixel y, inherited from the aquarium
	var/aquarium_zone_min_pz
	///maximum pixel y, inherited from the aquarium
	var/aquarium_zone_max_pz
	///The current fluid type, inherited fom the aquarium
	var/fluid_type
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
