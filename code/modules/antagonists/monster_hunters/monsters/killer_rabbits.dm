/**
 * Spawned by rabbit power
 */
/mob/living/basic/killer_rabbit
	name = "killer baby rabbit"
	desc = "A cute little rabbit, surely its harmless... right?"
	icon = 'icons/mob/rabbit.dmi'
	icon_state = "killer_rabbit"
	maxHealth = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	faction = list(FACTION_RABBITS)
	ai_controller = /datum/ai_controller/basic_controller/killer_rabbit
	basic_mob_flags = DEL_ON_DEATH

/mob/living/basic/killer_rabbit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL)
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))

/mob/living/basic/killer_rabbit/proc/hostile_attackingtarget(mob/living/basic/source, atom/target, success)
	SIGNAL_HANDLER

	if(!success || !ishuman(target))
		return
	explosion(src, heavy_impact_range = 1, light_impact_range = 1, flame_range = 2)
	gib(src)


/datum/ai_controller/basic_controller/killer_rabbit
	blackboard = list(
		BB_AGGRO_RANGE = 10,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/killer_rabbit,
	)
	ai_movement = /datum/ai_movement/navmap_astar
	behavior_tree_json = "code/modules/antagonists/monster_hunters/monsters/killer_rabbit.bt.json"

/datum/targeting_strategy/basic/killer_rabbit/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, datum/ai_controller/controller = null)
	return ..(living_mob, the_target, 10, controller)
