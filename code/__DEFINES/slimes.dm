#define ADULT_SLIME (1<<0)
#define PASSIVE_SLIME (1<<1)
#define STORED_SLIME (1<<2)
#define MUTATING_SLIME (1<<3)
#define SPLITTING_SLIME (1<<4)
#define CLEANER_SLIME (1<<5)
#define OVERWRITES_COLOR (1<<6)
#define NOEVOLVE_SLIME (1<<7)

#define TRAIT_ON_DEATH (1<<0)
#define TRAIT_VISUAL (1<<1)

#define TRAIT_MUTATOR_USED "mutator_trait"
#define TRAIT_IN_STACK "inside_mob_stack"
#define TRAIT_FEEDING "feeding_trait"
#define LATCH_TRAIT "latch_trait"
#define TRAIT_LATCH_FEEDERED "feeder_targetted"

#define BB_BASIC_MOB_SCARED_ITEM "BB_basic_mob_scared_item"
#define BB_WONT_TARGET_CLIENTS "BB_wont_target_clients"

<<<<<<< HEAD
=======
/// The alpha value of transparent slime types
#define SLIME_TRANSPARENCY_ALPHA 180

#define COLOR_SLIME_ADAMANTINE "#135f49"
#define COLOR_SLIME_BLACK "#3b3b3b"
#define COLOR_SLIME_BLUE "#19ffff"
#define COLOR_SLIME_BLUESPACE "#ebebeb"
#define COLOR_SLIME_CERULEAN "#5783aa"
#define COLOR_SLIME_DARK_BLUE "#2e9dff"
#define COLOR_SLIME_DARK_PURPLE "#9948f7"
#define COLOR_SLIME_GOLD "#c38b07"
#define COLOR_SLIME_GREEN "#07f024"
#define COLOR_SLIME_GREY "#c2c2c2"
#define COLOR_SLIME_LIGHT_PINK "#ffe1fa"
#define COLOR_SLIME_METAL "#676767"
#define COLOR_SLIME_OIL "#242424"
#define COLOR_SLIME_ORANGE "#ffb445"
#define COLOR_SLIME_PINK "#fe5bbd"
#define COLOR_SLIME_PURPLE "#d138ff"
#define COLOR_SLIME_PYRITE "#ffc427"
#define COLOR_SLIME_RAINBOW COLOR_SLIME_GREY // only for consistency
#define COLOR_SLIME_RED "#fb4848"
#define COLOR_SLIME_SEPIA "#9b8a7a"
#define COLOR_SLIME_SILVER "#dadada"
#define COLOR_SLIME_YELLOW "#fff419"

/// Vacuum can suck up rabid slimes, and calms them when it does.
#define VACUUM_CAN_PACIFY (1<<0)
/// Vacuum can print things using a biomass recycler.
#define VACUUM_CAN_PRINT (1<<1)

/// How far the vacuum can fling things, in tiles.
#define VACUUM_LAUNCH_RANGE 5
/// Throw speed of things the vacuum flings.
#define VACUUM_LAUNCH_SPEED 2

// these control how long slimes jiggle when splitting or mutating
#define SLIME_SPLIT_WINDUP (5 SECONDS)
#define SLIME_MUTATE_WINDUP (8 SECONDS)

/// Health an adult slime has to drain to secrete one extract (or roll a mutation)
#define SLIME_RANCH_EXTRACT_COST 50
/// A ranching slime won't secrete extracts while this many are already lying around nearby
#define SLIME_RANCH_NEARBY_EXTRACT_CAP 80
/// Health a slime told to split by a friend has to drain first
#define SLIME_RANCH_COMMAND_SPLIT_COST 50
/// Health a slime that ate a breeding pellet has to drain first
#define SLIME_RANCH_PELLET_SPLIT_COST 100
/// How long a refused or interrupted split/mutation waits before trying again
#define SLIME_RANCH_RETRY_COOLDOWN (5 SECONDS)
/// How long a slime ignores a target it couldn't path to
#define SLIME_CHASE_GIVE_UP_TIME (5 SECONDS)
/// How far (in path steps) a slime will walk to go find a player, or chase anything once it's moving with A*
#define SLIME_SEEK_PATH_LENGTH 60
/// How long a slime holds a grudge after the last hit
#define SLIME_GRUDGE_DURATION (1 MINUTES)
/// How many damaging hits a cat slime shrugs off before it holds a grudge
#define SLIME_CAT_PATIENCE_HITS 3
/// Hits further apart than this don't add up against a cat slime's patience
#define SLIME_CAT_PATIENCE_WINDOW (10 SECONDS)

/// The fence sprite's own blue. A pen set to this color skips the recolor filter entirely, so the default look is the sprite as drawn.
#define SLIME_PEN_DEFAULT_COLOR "#4dc8e8"
/// How far away other slimes notice a monkey attacking a slime and join in.
#define SLIME_MONKEY_RALLY_RANGE 5

/// How many tiles away can an extract compressor link to a extract fridge or biomass recycler thingy
#define COMPRESSOR_LINK_RANGE 7
/// Extracts the compressor's type tank holds.
#define COMPRESSOR_EFFECT_EXTRACTS 10
/// Extracts the compressor's color tank holds.
#define COMPRESSOR_COLOR_EXTRACTS 5

#define EXTRACT_REQUEST_WAITING "waiting"
#define EXTRACT_REQUEST_CLAIMED "claimed"
#define EXTRACT_REQUEST_READY "ready"
#define EXTRACT_REQUEST_PICKED_UP "picked_up"
#define EXTRACT_REQUEST_DECLINED "declined"
#define EXTRACT_REQUEST_CANCELLED "cancelled"
/// Longest reason a requester or a decliner can write.
#define EXTRACT_REQUEST_REASON_LENGTH 60

/// Doesn't squash mobs like roaches and stuff when walking over them
>>>>>>> b00e6132 (adds a proper xenobio extract request console! (#12960))
#define TRAIT_CAREFUL_STEPS "careful_steps"
#define TRAIT_LIGHTWEIGHT "lightweight"
#define TRAIT_SLIME_STASIS "slime_stasis"
#define TRAIT_SLIME_RABID "slime_rabid"
#define TRAIT_SLIME_DUST_IMMUNE "slime_dust_immune"
#define COMSIG_ATOM_SUCKED "atom_sucked"

#define TRAIT_OVERFED "overfed_trait"
#define VACPACK_THROW "vacpack_throw"

///from obj/item/vacuum_nozzle/afterattack(atom/movable/target, mob/user, proximity, params): (obj/item/vacuum_nozzle/nozzle, mob/user)
#define COMSIG_LIVING_VACUUM_PRESUCK "living_vacuum_presuck"
	#define COMPONENT_LIVING_VACUUM_CANCEL_SUCK (1<<0)

#define SLIME_VALUE_TIER_1 200
#define SLIME_VALUE_TIER_2 400
#define SLIME_VALUE_TIER_3 800
#define SLIME_VALUE_TIER_4 1600
#define SLIME_VALUE_TIER_5 3200
#define SLIME_VALUE_TIER_6 6400
#define SLIME_VALUE_TIER_7 12800

#define SLIME_SELL_MODIFIER_MIN 	  -0.08
#define SLIME_SELL_MODIFIER_MAX 	  -0.01
#define SLIME_SELL_OTHER_MODIFIER_MIN 0.005
#define SLIME_SELL_OTHER_MODIFIER_MAX 0.01
#define SLIME_SELL_MAXIMUM_MODIFIER   2
#define SLIME_SELL_MINIMUM_MODIFIER   0.1
#define SLIME_RANDOM_MODIFIER_MIN -0.0003
#define SLIME_RANDOM_MODIFIER_MAX 0.0003

#define EMOTION_HAPPY "happy"
#define EMOTION_SAD "sad"
#define EMOTION_SCARED "scared"
#define EMOTION_FUNNY "funny"
#define EMOTION_ANGER "anger"
#define EMOTION_SUPRISED "suprised"
#define EMOTION_HUNGRY "hungry"

#define FOOD_CHANGE "food_change"
#define ENVIRONMENT_CHANGE "enviro_change"
#define BEHAVIOUR_CHANGE "behaviour_change"
#define DANGEROUS_CHANGE "dangerous_change"
#define DOCILE_CHANGE "docile_change"

#define FRIENDSHIP_HATED "hated"
#define FRIENDSHIP_DISLIKED "disliked"
#define FRIENDSHIP_STRANGER "stranger"
#define FRIENDSHIP_NEUTRAL "neutral"
#define FRIENDSHIP_ACQUAINTANCES "acquaintances"
#define FRIENDSHIP_FRIEND "friend"
#define FRIENDSHIP_BESTFRIEND "bestfriend"

#define COMSIG_FRIENDSHIP_CHECK_LEVEL "friendship_check_level"
#define COMSIG_FRIENDSHIP_CHANGE "friendship_change"
#define COMSIG_FRIENDSHIP_PASS_FRIENDSHIP "friendship_passfriends"

#define TRAIT_RAINBOWED "rainbowed"

#define COMSIG_CLIENT_HOVER_NEW "client_new_hover"
