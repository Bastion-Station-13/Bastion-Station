/// A colour matrix that turns whatever colours a sprite has into glowing yellows, keeping its brightness
#define ARCFIEND_YELLOW_TINT list(0.45, 0.41, 0.135, 0.885, 0.805, 0.265, 0.165, 0.15, 0.05)

/// How much nutrition an arcfiend gets for every unit of power they sap, up to being full but never fat
#define ARCFIEND_NUTRITION_PER_POWER 0.25

/// The highest upgrade level any power has. Level 1 is the base power.
#define ARCFIEND_MAX_POWER_LEVEL 3

/// How many charges the galvanic prod holds
#define ARCFIEND_PROD_MAX_CHARGES 4
/// The pause between two zaps with the galvanic prod
#define ARCFIEND_PROD_ZAP_DELAY (2 SECONDS)

/// How much charge an ethereal loses for every unit of power an arcfiend drains out of them
#define ARCFIEND_ETHEREAL_CHARGE_PER_POWER 0.5

/// How much nutrition (an IPC's battery charge) an IPC loses for every unit of power an arcfiend drains out of them
#define ARCFIEND_IPC_NUTRITION_PER_POWER 0.25

/// Joules of station energy that one unit of arcfiend power is worth
#define ARCFIEND_JOULES_PER_POWER 2000
/// Joules an SMES loses for each unit of power an arcfiend gets from it, a very inefficient conversion
#define ARCFIEND_SMES_JOULES_PER_POWER (ARCFIEND_JOULES_PER_POWER * 5)

// Power gained per second of Sap Power, by source
#define ARCFIEND_DRAIN_APC 30
#define ARCFIEND_DRAIN_SMES 30
#define ARCFIEND_DRAIN_CABLE 10
#define ARCFIEND_DRAIN_MOB 40
#define ARCFIEND_DRAIN_CYBORG 40
#define ARCFIEND_DRAIN_MACHINE_MAX 8

/// Burn damage per second dealt to a human being sapped
#define ARCFIEND_SAP_MOB_BURN 5
/// Stamina damage per second dealt to a human being sapped
#define ARCFIEND_SAP_MOB_STAMINA 10
/// Burn damage per second dealt to a cyborg being sapped
#define ARCFIEND_SAP_CYBORG_BURN 3
/// Chance per second that sapping an APC breaks it
#define ARCFIEND_SAP_APC_BREAK_PROB 4

/// How much power must be drained from a mind, in total, before it counts towards the arcfiend's unlocks
#define ARCFIEND_MIND_DRAIN_REQUIRED 80

/// Power it costs to enter the cables with Ride the Lightning
#define ARCFIEND_RIDE_ENTRY_COST 75
/// Power it costs to move one tile along the cables
#define ARCFIEND_RIDE_TILE_COST 2
/// Power drained each second while riding the cables, even when standing still
#define ARCFIEND_RIDE_UPKEEP 1
/// How far, in tiles, an arcfiend can see hidden cables
#define ARCFIEND_CABLE_SIGHT_RANGE 5
/// How long it takes to enter or to leave the cables
#define ARCFIEND_RIDE_TRANSITION_TIME (1 SECONDS)
/// How long an arcfiend is stunned for when an EMP throws them out of the cables
#define ARCFIEND_RIDE_EMP_STUN (4 SECONDS)
/// How long an arcfiend is stunned for when a cable is cut out from under them
#define ARCFIEND_RIDE_CUT_STUN (3 SECONDS)

/// How much the dark is lifted by Ampullary Sense. Ordinary night vision is LIGHTING_CUTOFF_HIGH (30).
#define ARCFIEND_NIGHT_VISION_CUTOFF 50
/// How much the dark is lifted by the upgraded Ampullary Sense
#define ARCFIEND_NIGHT_VISION_CUTOFF_UPGRADED 75

/// Burn damage an arcfiend takes from a heavy EMP
#define ARCFIEND_EMP_HEAVY_DAMAGE 20
/// Burn damage an arcfiend takes from a light EMP
#define ARCFIEND_EMP_LIGHT_DAMAGE 10
/// Fraction of its stored power an arcfiend loses to a heavy EMP
#define ARCFIEND_EMP_HEAVY_POWER_LOSS 0.25
/// Fraction of its stored power an arcfiend loses to a light EMP
#define ARCFIEND_EMP_LIGHT_POWER_LOSS 0.1

// The sounds of the arcfiend powers. Anything missing here has no sound of its own and uses a stock one.
#define ARCFIEND_SOUND_STINGER 'monkestation/code/modules/antagonists/arcfiend/sound/arcfiend_stinger.ogg'
#define ARCFIEND_SOUND_TOGGLE_ON 'monkestation/code/modules/antagonists/arcfiend/sound/toggle_on.ogg'
#define ARCFIEND_SOUND_TOGGLE_OFF 'monkestation/code/modules/antagonists/arcfiend/sound/toggle_off.ogg'
#define ARCFIEND_SOUND_ITEM_GROW 'monkestation/code/modules/antagonists/arcfiend/sound/item_grow.ogg'
#define ARCFIEND_SOUND_ITEM_CRUMBLE 'monkestation/code/modules/antagonists/arcfiend/sound/item_crumble.ogg'
#define ARCFIEND_SOUND_SAP_START 'monkestation/code/modules/antagonists/arcfiend/sound/sap_start.ogg'
#define ARCFIEND_SOUND_SAP_LOOP 'monkestation/code/modules/antagonists/arcfiend/sound/sap_loop.ogg'
#define ARCFIEND_SOUND_CHARGE 'monkestation/code/modules/antagonists/arcfiend/sound/charge_refill.ogg'
#define ARCFIEND_SOUND_RIDE_ENTER 'monkestation/code/modules/antagonists/arcfiend/sound/ride_enter.ogg'
#define ARCFIEND_SOUND_RIDE_EXIT 'monkestation/code/modules/antagonists/arcfiend/sound/ride_exit.ogg'
#define ARCFIEND_SOUND_RIDE_EJECTED 'monkestation/code/modules/antagonists/arcfiend/sound/ride_ejected.ogg'
#define ARCFIEND_SOUND_SURGE_REFLEX 'monkestation/code/modules/antagonists/arcfiend/sound/surge_reflex.ogg'
#define ARCFIEND_SOUND_BRAIN_SCRAMBLE 'monkestation/code/modules/antagonists/arcfiend/sound/brain_scramble.ogg'
#define ARCFIEND_SOUND_ARC_DISCHARGE 'monkestation/code/modules/antagonists/arcfiend/sound/arc_discharge.ogg'
#define ARCFIEND_SOUND_THUNDERCLAP_WINDUP 'monkestation/code/modules/antagonists/arcfiend/sound/thunderclap_windup.ogg'
#define ARCFIEND_SOUND_THUNDERCLAP_BOOM 'monkestation/code/modules/antagonists/arcfiend/sound/thunderclap_boom.ogg'
#define ARCFIEND_SOUND_SMASH_HIT 'monkestation/code/modules/antagonists/arcfiend/sound/smash_hit.ogg'
#define ARCFIEND_SOUND_EMP_BURST 'monkestation/code/modules/antagonists/arcfiend/sound/emp_burst.ogg'
#define ARCFIEND_SOUND_JOLT_WINDUP 'monkestation/code/modules/antagonists/arcfiend/sound/jolt_windup.ogg'
#define ARCFIEND_SOUND_JOLT_STOP 'monkestation/code/modules/antagonists/arcfiend/sound/jolt_stop.ogg'
#define ARCFIEND_SOUND_JOLT_RESTART 'monkestation/code/modules/antagonists/arcfiend/sound/jolt_restart.ogg'
#define ARCFIEND_SOUND_COILGUN_FIRE 'monkestation/code/modules/antagonists/arcfiend/sound/coilgun_fire.ogg'
#define ARCFIEND_SOUND_COILGUN_RELOAD 'monkestation/code/modules/antagonists/arcfiend/sound/coilgun_reload.ogg'
#define ARCFIEND_SOUND_TETHER_FIRE 'monkestation/code/modules/antagonists/arcfiend/sound/tether_fire.ogg'
#define ARCFIEND_SOUND_LASER_FIRE 'monkestation/code/modules/antagonists/arcfiend/sound/lateral_laser_fire.ogg'
#define ARCFIEND_SOUND_LASER_RELOAD 'monkestation/code/modules/antagonists/arcfiend/sound/laser_reload.ogg'
#define ARCFIEND_SOUND_LASER_MODE 'monkestation/code/modules/antagonists/arcfiend/sound/laser_mode_click.ogg'
#define ARCFIEND_SOUND_PROD_HIT 'monkestation/code/modules/antagonists/arcfiend/sound/prod_hit.ogg'
#define ARCFIEND_SOUND_PROD_ZAP 'monkestation/code/modules/antagonists/arcfiend/sound/prod_zap.ogg'
#define ARCFIEND_SOUND_PROD_RECHARGED 'monkestation/code/modules/antagonists/arcfiend/sound/prod_recharged.ogg'
