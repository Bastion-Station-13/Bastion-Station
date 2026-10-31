/**
 * Blood Brother gun parts.
 *
 * These are intentionally lightweight attachment objects. Sprites live in bb_gun_parts.dmi.
 * The *_parent sprites are only for the slot parents below, so real attachments should set their own icon_state.
 */

/obj/item/blood_brother_gun_part
	name = "Blood Brother gun part"
	desc = "The platonic ideal of a gun part, and therefore useless. Unless an admin spawned this, somebody needs to go beat a coder's ass."
	icon = 'bastionstation/icons/obj/weapons/guns/bb_gun_parts.dmi'
	icon_state = "BBgunpart_parent"
	w_class = WEIGHT_CLASS_SMALL
	/// The slot this part is installed into, as a BB_GUN_PART_* define.
	var/bb_part_slot
	/// The weapon family this part is restricted to, as a BB_GUN_* define. Null if it fits any family.
	var/bb_weapon_family

/obj/item/blood_brother_gun_part/examine(mob/user)
	. = ..()
	if(length(get_effect_lines()))
		. += span_notice("You can <b>examine closer</b> to see what this does to a weapon.")

/// The description is only flavor text, so what the part actually does is shown when examining closer.
/obj/item/blood_brother_gun_part/examine_more(mob/user)
	. = ..()
	for(var/effect in get_effect_lines())
		. += span_notice(effect)

/// The effects this part has on a weapon, one line each, built from its own values so they can't drift out of date.
/obj/item/blood_brother_gun_part/proc/get_effect_lines()
	return list()

/// Formats a multiplier as a signed percentage change, so 1.25 becomes "+25%" and 0.6 becomes "-40%".
/obj/item/blood_brother_gun_part/proc/percent_text(multiplier)
	var/percent = round((multiplier - 1) * 100)
	return "[percent > 0 ? "+" : ""][percent]%"

/// Describes a change in weight class.
/obj/item/blood_brother_gun_part/proc/weight_text(change)
	return "Makes the weapon [abs(change) == 1 ? "one size" : "[abs(change)] sizes"] [change > 0 ? "bigger" : "smaller"]."

/// Using a part on a Blood Brother weapon installs it.
/obj/item/blood_brother_gun_part/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isgun(interacting_with))
		return NONE

	var/datum/component/blood_brother_gun/modular_gun = interacting_with.GetComponent(/datum/component/blood_brother_gun)
	if(!modular_gun)
		interacting_with.balloon_alert(user, "incompatible part!")
		return ITEM_INTERACT_BLOCKING
	if(!modular_gun.try_install_part(src, user))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

// Slot parents. These set up each slot and aren't meant to be crafted themselves.
// Real attachments are subtypes of these, and should give themselves their own desc.

/obj/item/blood_brother_gun_part/magazine
	name = "magazine"
	desc = "Holds exactly zero rounds. The only thing it feeds is the issue tracker."
	icon_state = "BBmagazine_parent"
	bb_part_slot = BB_GUN_PART_MAGAZINE
	bb_weapon_family = BB_GUN_BALLISTIC
	/// Multiplier applied to a weapon's internal magazine capacity.
	var/bb_capacity_multiplier = 1
	/// How many weight classes this magazine adds to the weapon.
	var/bb_weight_class_increase = 0
	/// How long loading ammunition into the weapon takes with this magazine installed. 0 for instant.
	var/bb_load_delay = 0

/obj/item/blood_brother_gun_part/magazine/get_effect_lines()
	. = ..()
	if(bb_capacity_multiplier != 1)
		. += "Internal magazine capacity [percent_text(bb_capacity_multiplier)]."
	if(bb_weight_class_increase)
		. += weight_text(bb_weight_class_increase)
	if(bb_load_delay)
		. += "Loading ammunition takes [bb_load_delay / (1 SECONDS)] seconds."

/obj/item/blood_brother_gun_part/receiver
	name = "receiver"
	desc = "The abstract concept of a receiver, poorly disguised as a firing pin. It receives nothing. If you're holding this, someone has made a terrible mistake, and I know who."
	icon_state = "BBreciever_parent"
	bb_part_slot = BB_GUN_PART_RECEIVER
	/// The receiver's firing type, as a BB_GUN_RECEIVER_* define.
	var/bb_receiver_type = BB_GUN_RECEIVER_SEMI_AUTO
	/// Multiplier applied to projectile damage when this receiver is installed.
	var/bb_damage_multiplier = 1
	/// Multiplier applied to projectile speed when this receiver is installed.
	var/bb_projectile_speed_multiplier = 1
	/// Firing interval for this receiver. Used as the gun's delay between shots.
	var/bb_fire_interval

/obj/item/blood_brother_gun_part/receiver/get_effect_lines()
	. = ..()
	. += bb_receiver_type == BB_GUN_RECEIVER_AUTOMATIC ? "Keeps firing for as long as the trigger is held." : "Fires once per trigger pull."
	if(bb_damage_multiplier != 1)
		. += "Damage [percent_text(bb_damage_multiplier)]."
	if(bb_projectile_speed_multiplier != 1)
		. += "Projectile speed [percent_text(bb_projectile_speed_multiplier)]."
	if(bb_fire_interval)
		. += "Fires every [bb_fire_interval / (1 SECONDS)] seconds."

/obj/item/blood_brother_gun_part/barrel
	name = "barrel"
	desc = "A barrel with no bore, no rifling, and no reason to exist. Please report this to a coder, then check on the coder's mental health."
	icon_state = "BBbarrel_parent"
	bb_part_slot = BB_GUN_PART_BARREL
	bb_weapon_family = BB_GUN_BALLISTIC
	/// Multiplier applied to projectile damage. Stacks with the receiver's.
	var/bb_damage_multiplier = 1
	/// Extra armour penetration added to each projectile.
	var/bb_armour_penetration = 0
	/// How many weight classes this barrel adds to the weapon. Negative makes it smaller.
	var/bb_weight_class_change = 0
	/// Extra spread added to the weapon, in degrees.
	var/bb_spread = 0
	/// Multiplier applied to the weapon's spread and to each round's inaccuracy, including buckshot pellet spread.
	var/bb_spread_multiplier = 1
	/// Multiplier applied to the extra spread from dual wielding.
	var/bb_dual_wield_spread_multiplier = 1
	/// Percent chance for a single-projectile round to crit for double damage. Rounds that fire several pellets are unaffected.
	var/bb_crit_chance = 0

/obj/item/blood_brother_gun_part/barrel/get_effect_lines()
	. = ..()
	if(bb_damage_multiplier != 1)
		. += "Damage [percent_text(bb_damage_multiplier)]."
	if(bb_armour_penetration)
		. += "Armor penetration +[bb_armour_penetration]."
	if(bb_weight_class_change)
		. += weight_text(bb_weight_class_change)
	if(bb_spread)
		. += "Adds [bb_spread] degrees of spread."
	if(bb_spread_multiplier != 1)
		. += "Spread [percent_text(bb_spread_multiplier)]."
	if(bb_dual_wield_spread_multiplier != 1)
		. += "Dual wielding spread [percent_text(bb_dual_wield_spread_multiplier)]."
	if(bb_crit_chance)
		. += "[bb_crit_chance]% chance for a single-projectile round to crit for double damage. Buckshot and other pellet rounds don't benefit."

/obj/item/blood_brother_gun_part/power_cell
	name = "power cell"
	desc = "Contains zero joules and a lifetime supply of regret. This is a parent type. Do not use."
	icon_state = "BBcell_parent"
	bb_part_slot = BB_GUN_PART_POWER_CELL
	bb_weapon_family = BB_GUN_ENERGY
	/// Multiplier applied to the weapon's cell capacity.
	var/bb_capacity_multiplier = 1
	/// Whether an EMP fully recharges the weapon instead of draining it.
	var/bb_emp_recharges = FALSE
	/// Whether the weapon slowly recharges itself over time.
	var/bb_self_recharging = FALSE
	/// Whether the cell is unstable: it can be fed uranium, but sparks when fired and is wrecked by EMPs.
	var/bb_unstable = FALSE

/obj/item/blood_brother_gun_part/power_cell/get_effect_lines()
	. = ..()
	if(bb_capacity_multiplier != 1)
		. += "Charge capacity [percent_text(bb_capacity_multiplier)]."
	if(bb_emp_recharges)
		. += "An EMP fully recharges the weapon instead of draining it."
	if(bb_self_recharging)
		. += "Slowly recharges the weapon on its own."
	if(bb_unstable)
		. += "Can be recharged by feeding it uranium sheets. Sparks with every shot and leaks radiation, and an EMP discharges it into whoever is holding the weapon."

/obj/item/blood_brother_gun_part/underbarrel
	name = "underbarrel"
	desc = "Hangs from nothing, attaches to nothing, does nothing. A true monument to object-oriented design."
	icon_state = "BBunderbarrel_parent"
	bb_part_slot = BB_GUN_PART_UNDERBARREL
	/// How many weight classes this underbarrel adds to the weapon. Negative makes it smaller.
	var/bb_weight_class_change = 0
	/// Multiplier applied to the weapon's spread.
	var/bb_spread_multiplier = 1
	/// Multiplier applied to the extra spread from dual wielding.
	var/bb_dual_wield_spread_multiplier = 1
	/// If set, replaces the weapon's melee damage, and makes its melee attacks cut.
	var/bb_melee_force = 0
	/// Whether right-clicking with the weapon fires this underbarrel, instead of bashing or holding someone up.
	var/bb_fires = FALSE
	/// The item loaded into this underbarrel, for underbarrels that fire things.
	var/obj/item/loaded_item

/obj/item/blood_brother_gun_part/underbarrel/Destroy()
	QDEL_NULL(loaded_item)
	return ..()

/obj/item/blood_brother_gun_part/underbarrel/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == loaded_item)
		loaded_item = null

/obj/item/blood_brother_gun_part/underbarrel/examine(mob/user)
	. = ..()
	if(bb_fires)
		. += span_notice("It's [loaded_item ? "loaded with [loaded_item]" : "empty"].")

/obj/item/blood_brother_gun_part/underbarrel/get_effect_lines()
	. = ..()
	if(bb_weight_class_change)
		. += weight_text(bb_weight_class_change)
	if(bb_spread_multiplier != 1)
		. += "Spread [percent_text(bb_spread_multiplier)]."
	if(bb_dual_wield_spread_multiplier != 1)
		. += "Dual wielding spread [percent_text(bb_dual_wield_spread_multiplier)]."
	if(bb_melee_force)
		. += "Replaces the weapon's melee damage with [bb_melee_force], and its melee attacks cut."
	if(bb_fires)
		. += "Right-click the weapon with an item to load this, then right-click with the weapon to fire it."

/// Using a firing underbarrel in hand takes out whatever's loaded in it.
/obj/item/blood_brother_gun_part/underbarrel/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !loaded_item)
		return
	var/obj/item/unloaded = loaded_item
	if(!user.put_in_hands(unloaded))
		unloaded.forceMove(user.drop_location())
	balloon_alert(user, "unloaded [unloaded]")
	return TRUE

/// Tries to load an item into this underbarrel. Returns TRUE if it was loaded.
/obj/item/blood_brother_gun_part/underbarrel/proc/try_load(obj/item/item, mob/living/user)
	if(loaded_item)
		balloon_alert(user, "already loaded!")
		return FALSE
	if(!can_load(item, user))
		return FALSE
	if(!user.transferItemToLoc(item, src))
		return FALSE
	loaded_item = item
	balloon_alert(user, "loaded [item]")
	return TRUE

/// Whether the given item can be loaded into this underbarrel. Shows the user why not if it can't.
/obj/item/blood_brother_gun_part/underbarrel/proc/can_load(obj/item/item, mob/living/user)
	return FALSE

/// Fires whatever is loaded at the target. Called when the user right-clicks with the weapon.
/obj/item/blood_brother_gun_part/underbarrel/proc/fire_at(atom/target, mob/living/user, obj/item/gun/gun)
	return

/obj/item/blood_brother_gun_part/lens
	name = "lens"
	desc = "Focuses absolutely nothing. If you can see through this, you're looking directly at a bug."
	icon_state = "BBlens_parent"
	bb_part_slot = BB_GUN_PART_LENS
	bb_weapon_family = BB_GUN_ENERGY
	/// Multiplier applied to projectile damage. Stacks with the receiver's.
	var/bb_damage_multiplier = 1
	/// Multiplier applied to projectile speed. Stacks with the receiver's.
	var/bb_projectile_speed_multiplier = 1
	/// Multiplier applied to the delay between shots. Above 1 fires slower, below 1 fires faster.
	var/bb_fire_delay_multiplier = 1
	/// Multiplier applied to how much charge each shot uses. Below 1 gets more shots out of a cell.
	var/bb_energy_cost_multiplier = 1
	/// Extra spread added to the weapon, in degrees.
	var/bb_spread = 0
	/// Extra armour penetration added to each shot.
	var/bb_armour_penetration = 0
	/// How long each shot knocks its target down for. 0 for no knockdown.
	var/bb_knockdown = 0
	/// Percent chance for each shot to teleport the mob it hits.
	var/bb_teleport_chance = 0

/obj/item/blood_brother_gun_part/lens/get_effect_lines()
	. = ..()
	if(bb_damage_multiplier != 1)
		. += "Damage [percent_text(bb_damage_multiplier)]."
	if(bb_projectile_speed_multiplier != 1)
		. += "Projectile speed [percent_text(bb_projectile_speed_multiplier)]."
	if(bb_fire_delay_multiplier != 1)
		. += "Time between shots [percent_text(bb_fire_delay_multiplier)]."
	if(bb_energy_cost_multiplier != 1)
		. += "Power used per shot [percent_text(bb_energy_cost_multiplier)]."
	if(bb_spread)
		. += "Adds [bb_spread] degrees of spread."
	if(bb_armour_penetration)
		. += "Armor penetration +[bb_armour_penetration]."
	if(bb_knockdown)
		. += "Knocks its target down for [bb_knockdown / (1 SECONDS)] seconds."
	if(bb_teleport_chance)
		. += "[bb_teleport_chance]% chance to teleport whoever it hits."

// Receivers

/obj/item/blood_brother_gun_part/receiver/semi_auto
	name = "semi-auto receiver"
	icon_state = "semi_auto_receiver"
	desc = "A basic semi-automatic receiver that does not modify the gun's stats in any way."
	bb_receiver_type = BB_GUN_RECEIVER_SEMI_AUTO

/obj/item/blood_brother_gun_part/receiver/automatic
	name = "automatic receiver"
	icon_state = "full_auto_receiver"
	desc = "A light fully automatic receiver. Hold down the trigger for full auto, but mind your ammo!"
	bb_receiver_type = BB_GUN_RECEIVER_AUTOMATIC
	bb_damage_multiplier = 1
	bb_projectile_speed_multiplier = 1
	bb_fire_interval = 0.2 SECONDS

/obj/item/blood_brother_gun_part/receiver/rifle
	name = "rifle receiver"
	icon_state = "rifle_receiver"
	desc = "A heavy rifle receiver. Slow to cycle, but every shot lands like a sledgehammer."
	bb_receiver_type = BB_GUN_RECEIVER_RIFLE
	bb_damage_multiplier = 1.2
	bb_projectile_speed_multiplier = 1.2
	bb_fire_interval = 1.2 SECONDS

/obj/item/blood_brother_gun_part/receiver/carbine
	name = "carbine receiver"
	icon_state = "carbine_receiver"
	desc = "A cut-down rifle receiver. Not as nasty as the real thing, but a lot handier."
	bb_receiver_type = BB_GUN_RECEIVER_CARBINE
	bb_damage_multiplier = 1.1
	bb_projectile_speed_multiplier = 1.1
	bb_fire_interval = 1 SECONDS

// Magazines. These only work on weapons with internal magazines, like revolvers.

/obj/item/blood_brother_gun_part/magazine/extended
	name = "extended magazine"
	icon_state = "extended_magazine"
	desc = "Extend your magazine to hold extra bullets."
	bb_capacity_multiplier = 1.5

/obj/item/blood_brother_gun_part/magazine/big
	name = "big magazine"
	icon_state = "big_magazine"
	desc = "A heavy magazine to hold more bullets, but makes your gun harder to carry."
	bb_capacity_multiplier = 2
	bb_weight_class_increase = 1

/obj/item/blood_brother_gun_part/magazine/bluespace
	name = "bluespace magazine"
	icon_state = "bluespace_magazine"
	desc = "Use the power of bluespace to create a pocket dimension around your gun to store an absurd amount of bullets! Loading them takes time though."
	bb_capacity_multiplier = 4
	bb_load_delay = 1.5 SECONDS

// Power cells

/obj/item/blood_brother_gun_part/power_cell/upgraded
	name = "upgraded cell"
	icon_state = "upgraded_cell"
	desc = "An improved power cell that holds more charge."
	bb_capacity_multiplier = 2

/obj/item/blood_brother_gun_part/power_cell/emp_shielded
	name = "EMP shielded cell"
	icon_state = "emp_shielded_cell"
	desc = "A cell wrapped in shielding. It holds less charge than an upgraded cell, but an EMP recharges it instead of draining it."
	bb_capacity_multiplier = 1.5
	bb_emp_recharges = TRUE

/obj/item/blood_brother_gun_part/power_cell/self_recharging
	name = "self-recharging cell"
	icon_state = "self_recharging_cell"
	desc = "A cell wired to a yellow slime core for self-recharging."
	bb_self_recharging = TRUE

/obj/item/blood_brother_gun_part/power_cell/unstable
	name = "unstable cell"
	icon_state = "unstable_cell"
	desc = "A stupidly unsafe and powerful cell that can be recharged by feeding uranium, but it sparks and shocks you if you get EMPed."
	bb_capacity_multiplier = 4
	bb_unstable = TRUE

// Lenses

/obj/item/blood_brother_gun_part/lens/bluespace
	name = "bluespace lens"
	icon_state = "bluespace_lens"
	desc = "A lens laced with bluespace crystal. Hits hard, flies fast, and might just send somebody somewhere else, though your battery is going to hate you for it."
	bb_damage_multiplier = 1.25
	bb_projectile_speed_multiplier = 1.5
	bb_fire_delay_multiplier = 1.25
	bb_energy_cost_multiplier = 1.5
	bb_teleport_chance = 20

/obj/item/blood_brother_gun_part/lens/spray
	name = "spray lens"
	icon_state = "spray_lens"
	desc = "A lens that turns the beam into a spray of weak shots. Don't expect to hit what you're aiming at!"
	bb_damage_multiplier = 0.7
	bb_fire_delay_multiplier = 0.6
	bb_energy_cost_multiplier = 0.75
	bb_spread = 20
	bb_armour_penetration = 20

/obj/item/blood_brother_gun_part/lens/densifying
	name = "densifying lens"
	icon_state = "densifying_lens"
	desc = "A lens that squashes the beam into a slow, heavy shot. It hits like a truck, but it isn't going to be quick."
	bb_damage_multiplier = 1.4
	bb_projectile_speed_multiplier = 0.6
	bb_fire_delay_multiplier = 1.5
	bb_knockdown = 1 SECONDS

/obj/item/blood_brother_gun_part/lens/efficiency
	name = "efficiency lens"
	icon_state = "efficiency_lens"
	desc = "A lens that reduces the power of your shots to get more out of your battery."
	bb_damage_multiplier = 0.75
	bb_energy_cost_multiplier = 0.5

// Barrels

/obj/item/blood_brother_gun_part/barrel/long
	name = "long barrel"
	icon_state = "long_barrel"
	desc = "Two pipes welded end to end. It's longer and meaner, and not exactly easy to hide."
	bb_damage_multiplier = 1.25
	bb_armour_penetration = 15
	bb_weight_class_change = 1

/obj/item/blood_brother_gun_part/barrel/shortened
	name = "shortened barrel"
	icon_state = "shortened_barrel"
	desc = "A barrel hacked down with a saw until it fits under a coat. Easy to hide, awful at actually hitting things."
	bb_weight_class_change = -1
	bb_spread = 15

/obj/item/blood_brother_gun_part/barrel/lucky
	name = "lucky barrel"
	icon_state = "lucky_barrel"
	desc = "A barrel with a pair of dice rattling around inside it for luck. Don't ask how it works, it just does."
	bb_crit_chance = 15

/obj/item/blood_brother_gun_part/barrel/choke
	name = "choke"
	icon_state = "choke_barrel"
	desc = "A barrel narrowed at the muzzle to keep your shots in a tight bunch."
	bb_spread_multiplier = 0.4
	bb_dual_wield_spread_multiplier = 0.5

// Underbarrels

/obj/item/blood_brother_gun_part/underbarrel/launcher
	name = "crude launcher"
	icon_state = "crude_launcher_underbarrel"
	desc = "A pneumatic cannon mounted onto your firearm. Right-click to fire whatever's loaded."
	bb_fires = TRUE

/obj/item/blood_brother_gun_part/underbarrel/launcher/get_effect_lines()
	. = ..()
	. += "Holds one item of normal size or smaller, like a knife or a bola. Grenades don't fit, and bullets just plink out harmlessly."

/obj/item/blood_brother_gun_part/underbarrel/launcher/can_load(obj/item/item, mob/living/user)
	if(istype(item, /obj/item/grenade))
		balloon_alert(user, "grenades don't fit!")
		return FALSE
	if(item.w_class > WEIGHT_CLASS_NORMAL)
		balloon_alert(user, "too big!")
		return FALSE
	return TRUE

/obj/item/blood_brother_gun_part/underbarrel/launcher/fire_at(atom/target, mob/living/user, obj/item/gun/gun)
	if(!loaded_item)
		gun.balloon_alert(user, "launcher empty!")
		return
	var/obj/item/launched = loaded_item
	launched.forceMove(get_turf(user))
	playsound(gun, 'sound/items/weapons/sonic_jackhammer.ogg', 50, TRUE)
	user.visible_message(span_warning("[user] launches [launched] from [gun]!"), span_notice("You launch [launched] from [gun]."))
	launched.throw_at(target, 7, 3, user)

/obj/item/blood_brother_gun_part/underbarrel/grenade_launcher
	name = "underbarrel grenade launcher"
	icon_state = "grenade_launcher_underbarrel"
	desc = "A stubby launcher tube bolted under a weapon, made to lob a single grenade wherever you point it."
	bb_fires = TRUE

/obj/item/blood_brother_gun_part/underbarrel/grenade_launcher/get_effect_lines()
	. = ..()
	. += "Holds a single grenade of any kind, which goes off after a short fuse."

/obj/item/blood_brother_gun_part/underbarrel/grenade_launcher/can_load(obj/item/item, mob/living/user)
	if(!istype(item, /obj/item/grenade))
		balloon_alert(user, "only fits grenades!")
		return FALSE
	return TRUE

/obj/item/blood_brother_gun_part/underbarrel/grenade_launcher/fire_at(atom/target, mob/living/user, obj/item/gun/gun)
	if(!loaded_item)
		gun.balloon_alert(user, "launcher empty!")
		return
	var/obj/item/grenade/launched = loaded_item
	launched.forceMove(get_turf(user))
	playsound(gun, 'sound/items/weapons/gun/general/grenade_launch.ogg', 50, TRUE)
	user.visible_message(span_danger("[user] fires [launched] from [gun]!"), span_notice("You fire [launched] from [gun]."))
	// Arming handles everything about the grenade itself, including chemical grenades that aren't assembled yet.
	launched.arm_grenade(user, 1.5 SECONDS, msg = FALSE)
	launched.throw_at(target, 10, 2, user)

/obj/item/blood_brother_gun_part/underbarrel/saw_blade
	name = "saw blade"
	icon_state = "saw_blade_underbarrel"
	desc = "A spinning saw blade bolted under a weapon, because shooting people wasn't enough."
	bb_melee_force = 23
	bb_weight_class_change = 1

/obj/item/blood_brother_gun_part/underbarrel/foregrip
	name = "scrap foregrip"
	icon_state = "scrap_foregrip_underbarrel"
	desc = "A fold-out handle bolted under a weapon, for when you'd like something steadier to hold on to."
	bb_spread_multiplier = 0.5
	bb_dual_wield_spread_multiplier = 0.25
