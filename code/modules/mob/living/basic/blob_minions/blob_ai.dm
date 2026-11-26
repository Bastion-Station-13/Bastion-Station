/**
 * Extremely simple AI, this isn't a very smart boy
 * Only notable quirk is that it uses JPS movement, simple avoidance would fail to realise it can path through blobs
 */
/datum/ai_controller/basic_controller/blobbernaut
	behavior_tree_json = "code/modules/mob/living/basic/blob_minions/blobbernaut.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

<<<<<<< HEAD
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
=======
	ai_movement = /datum/ai_movement/navmap_astar
>>>>>>> 01b29f44 ([PORT] Behavior trees and more basic mobs (#12982))

/**
 * Move to a point designated by the overmind, otherwise just slap people nearby
 */
/datum/ai_controller/basic_controller/blob_zombie
	behavior_tree_json = "code/modules/mob/living/basic/blob_minions/blob_zombie.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

<<<<<<< HEAD
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/travel_to_point/and_clear_target,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
=======
	ai_movement = /datum/ai_movement/navmap_astar
>>>>>>> 01b29f44 ([PORT] Behavior trees and more basic mobs (#12982))

/**
 * As blob zombie but will prioritise attacking corpses to zombify them
 */
/datum/ai_controller/basic_controller/blob_spore
	behavior_tree_json = "code/modules/mob/living/basic/blob_minions/blob_spore.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

<<<<<<< HEAD
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_and_hunt_target/corpses,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
=======
	ai_movement = /datum/ai_movement/navmap_astar
>>>>>>> 01b29f44 ([PORT] Behavior trees and more basic mobs (#12982))
