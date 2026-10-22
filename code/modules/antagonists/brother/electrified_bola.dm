/**
 * Electrified Blood Brother bola.
 *
 * It heavy emps you when you get ensnared, and then continues to shock you with burn and stamina until removed
 */

/obj/item/restraints/legcuffs/bola/electrified
	name = "electrified bola"
	desc = "A bola wired up to keep shocking whoever it catches."
	icon = 'bastionstation/icons/obj/restraints.dmi'
	icon_state = "bola_electrified"
	icon_state_preview = null
	inhand_icon_state = "bola_electrified"
	lefthand_file = 'bastionstation/icons/mob/inhands/weapons/thrown_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/weapons/thrown_righthand.dmi'

/obj/item/restraints/legcuffs/bola/electrified/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, gentle = FALSE, quickstart = TRUE)
	icon_state = "bola_electrified_thrown"
	. = ..()
	if(!throwing)
		icon_state = initial(icon_state)

/obj/item/restraints/legcuffs/bola/electrified/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	icon_state = initial(icon_state)
	return ..()

/obj/item/restraints/legcuffs/bola/electrified/ensnare(mob/living/carbon/victim)
	. = ..()
	if(victim.legcuffed != src)
		return

	// The EMP happens once, immediately when the bola successfully ensnares its target.
	victim.emp_act(EMP_HEAVY)
	victim.apply_status_effect(/datum/status_effect/electrified_bola, src)

/datum/status_effect/electrified_bola
	id = "electrified_bola"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 2 SECONDS
	processing_speed = STATUS_EFFECT_FAST_PROCESS
	// A new bola takes over from one that was only just removed, so the effect always tracks the bola actually on the target.
	status_type = STATUS_EFFECT_REPLACE
	on_remove_on_mob_delete = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/electrified_bola
	var/obj/item/restraints/legcuffs/bola/electrified/source_bola

/datum/status_effect/electrified_bola/on_creation(mob/living/new_owner, obj/item/restraints/legcuffs/bola/electrified/new_source)
	source_bola = new_source
	return ..()

/datum/status_effect/electrified_bola/on_apply()
	. = ..()
	to_chat(owner, span_userdanger("The electrified bola shocks you! Get it off quickly!"))

/datum/status_effect/electrified_bola/tick(seconds_between_ticks)
	var/mob/living/carbon/carbon_owner = owner
	if(QDELETED(source_bola) || !istype(carbon_owner) || carbon_owner.legcuffed != source_bola)
		qdel(src)
		return

	// Leave at least 25 stamina so this effect cannot repeatedly force stamina stuns.
	var/stamina_damage = min(5, max(0, owner.stamina.current - 25))
	if(stamina_damage)
		owner.stamina.adjust(-stamina_damage)

	owner.take_overall_damage(burn = 2 * seconds_between_ticks)

/atom/movable/screen/alert/status_effect/electrified_bola
	name = "Electrified Bola"
	desc = "An electrified bola is attached to you. Remove it quickly!"
