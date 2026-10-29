/**
 * GLOCK-inspiel for Blood Brothers. Don't worry it's not a glocko i promise.
 */

#define GLOCKENSPIEL_SWITCH_FIRE_DELAY_MULTIPLIER 0.5
#define GLOCKENSPIEL_SWITCH_SPREAD 15
#define GLOCKENSPIEL_ARMOUR_PENETRATION -20

/obj/item/ammo_box/magazine/m9mm/empty
	start_empty = TRUE

/obj/item/gun/ballistic/automatic/pistol/glockenspiel
	name = "\improper GLOCK-inspiel"
	desc = "A glockenspiel that plays a little tune every time you pull the trigger. Flip the switch on the back and it goes full auto. Shame armor shrugs off whatever it shoots."
	icon = 'bastionstation/icons/obj/weapons/guns/glockenspiel.dmi'
	icon_state = "glockenspiel"
	inhand_icon_state = "gun"
	spawn_magazine_type = /obj/item/ammo_box/magazine/m9mm/empty
	fire_delay = 0.4 SECONDS
	can_suppress = FALSE
	show_bolt_icon = FALSE
	pinless = TRUE
	// Varying the pitch would put the notes out of tune.
	vary_fire_sound = FALSE
	actions_types = list(/datum/action/item_action/toggle_firemode)
	/// Whether the switch is on, making it fully automatic.
	var/switch_on = FALSE
	var/note_index = 1
	/// Each shot plays the next note of a C major chord.
	var/static/list/notes = list(
		'bastionstation/sound/items/weapons/gun/glockenspiel/glockenspiel_shot_c.ogg',
		'bastionstation/sound/items/weapons/gun/glockenspiel/glockenspiel_shot_e.ogg',
		'bastionstation/sound/items/weapons/gun/glockenspiel/glockenspiel_shot_g.ogg',
	)
	var/static/list/switch_notes = list(
		'bastionstation/sound/items/weapons/gun/glockenspiel/glockenspiel_shot_alt_c.ogg',
		'bastionstation/sound/items/weapons/gun/glockenspiel/glockenspiel_shot_alt_e.ogg',
		'bastionstation/sound/items/weapons/gun/glockenspiel/glockenspiel_shot_alt_g.ogg',
	)

/obj/item/gun/ballistic/automatic/pistol/glockenspiel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/blood_brother_gun, \
		weapon_family = BB_GUN_BALLISTIC, \
		part_slots = list(BB_GUN_PART_RECEIVER, BB_GUN_PART_BARREL, BB_GUN_PART_UNDERBARREL), \
		default_parts = list(/obj/item/blood_brother_gun_part/receiver/semi_auto), \
	)
	RegisterSignal(src, COMSIG_PROJECTILE_BEFORE_FIRE, PROC_REF(weaken_round))

/obj/item/gun/ballistic/automatic/pistol/glockenspiel/examine(mob/user)
	. = ..()
	. += span_notice("The switch is [switch_on ? "on, so it's full auto" : "off"]. Flip it with <b>Toggle Firemode</b>.")

/obj/item/gun/ballistic/automatic/pistol/glockenspiel/update_overlays()
	. = ..()
	if(switch_on)
		. += "[icon_state]_auto"

/obj/item/gun/ballistic/automatic/pistol/glockenspiel/burst_select()
	var/mob/living/user = usr
	switch_on = !switch_on
	var/datum/component/blood_brother_gun/modular_gun = GetComponent(/datum/component/blood_brother_gun)
	if(switch_on)
		modular_gun.set_fire_mode(TRUE, GLOCKENSPIEL_SWITCH_FIRE_DELAY_MULTIPLIER, GLOCKENSPIEL_SWITCH_SPREAD)
	else
		modular_gun.set_fire_mode(FALSE)
	balloon_alert(user, "switch [switch_on ? "on" : "off"]")
	playsound(src, 'sound/items/weapons/empty.ogg', 100, TRUE)
	update_appearance()
	update_item_action_buttons()

/obj/item/gun/ballistic/automatic/pistol/glockenspiel/fire_sounds()
	var/list/note_set = switch_on ? switch_notes : notes
	fire_sound = note_set[note_index]
	note_index = WRAP_UP(note_index, length(note_set))
	return ..()

/obj/item/gun/ballistic/automatic/pistol/glockenspiel/proc/weaken_round(datum/source, obj/projectile/projectile, atom/original_target)
	SIGNAL_HANDLER

	projectile.armour_penetration += GLOCKENSPIEL_ARMOUR_PENETRATION

#undef GLOCKENSPIEL_SWITCH_FIRE_DELAY_MULTIPLIER
#undef GLOCKENSPIEL_SWITCH_SPREAD
#undef GLOCKENSPIEL_ARMOUR_PENETRATION
