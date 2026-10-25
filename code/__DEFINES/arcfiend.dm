/// A colour matrix that turns whatever colours a sprite has into glowing yellows, keeping its brightness
#define ARCFIEND_YELLOW_TINT list(0.45, 0.41, 0.135, 0.885, 0.805, 0.265, 0.165, 0.15, 0.05)

/// How much nutrition an arcfiend gets for every unit of power they sap, up to being full but never fat
#define ARCFIEND_NUTRITION_PER_POWER 0.25

/// The organ slot of the grounding implant, it occupies it's own slot so it never competes for things like reviver implants or other cybernetics that go in the chest.
#define ORGAN_SLOT_ARCFIEND_GROUNDING "arcfiend_grounding"

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
/// How long it takes to enter or to leave the cables
#define ARCFIEND_RIDE_TRANSITION_TIME (1 SECONDS)
/// How long an arcfiend is stunned for when an EMP throws them out of the cables
#define ARCFIEND_RIDE_EMP_STUN (4 SECONDS)
/// How long Jolt holds its charge before it fades
#define ARCFIEND_JOLT_CHARGE_DURATION (10 SECONDS)
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
#define ARCFIEND_SOUND_STINGER 'bastionstation/sound/arcfiend/arcfiend_stinger.ogg'
#define ARCFIEND_SOUND_TOGGLE_ON 'bastionstation/sound/arcfiend/toggle_on.ogg'
#define ARCFIEND_SOUND_TOGGLE_OFF 'bastionstation/sound/arcfiend/toggle_off.ogg'
#define ARCFIEND_SOUND_ITEM_GROW 'bastionstation/sound/arcfiend/item_grow.ogg'
#define ARCFIEND_SOUND_ITEM_CRUMBLE 'bastionstation/sound/arcfiend/item_crumble.ogg'
#define ARCFIEND_SOUND_SAP_START 'bastionstation/sound/arcfiend/sap_start.ogg'
#define ARCFIEND_SOUND_SAP_LOOP 'bastionstation/sound/arcfiend/sap_loop.ogg'
#define ARCFIEND_SOUND_CHARGE 'bastionstation/sound/arcfiend/charge_refill.ogg'
#define ARCFIEND_SOUND_RIDE_ENTER 'bastionstation/sound/arcfiend/ride_enter.ogg'
#define ARCFIEND_SOUND_RIDE_EXIT 'bastionstation/sound/arcfiend/ride_exit.ogg'
#define ARCFIEND_SOUND_RIDE_EJECTED 'bastionstation/sound/arcfiend/ride_ejected.ogg'
#define ARCFIEND_SOUND_SURGE_REFLEX 'bastionstation/sound/arcfiend/surge_reflex.ogg'
#define ARCFIEND_SOUND_BRAIN_SCRAMBLE 'bastionstation/sound/arcfiend/brain_scramble.ogg'
#define ARCFIEND_SOUND_ARC_DISCHARGE 'bastionstation/sound/arcfiend/arc_discharge.ogg'
#define ARCFIEND_SOUND_THUNDERCLAP_WINDUP 'bastionstation/sound/arcfiend/thunderclap_windup.ogg'
#define ARCFIEND_SOUND_THUNDERCLAP_BOOM 'bastionstation/sound/arcfiend/thunderclap_boom.ogg'
#define ARCFIEND_SOUND_SMASH_HIT 'bastionstation/sound/arcfiend/smash_hit.ogg'
#define ARCFIEND_SOUND_EMP_BURST 'bastionstation/sound/arcfiend/emp_burst.ogg'
#define ARCFIEND_SOUND_JOLT_WINDUP 'bastionstation/sound/arcfiend/jolt_windup.ogg'
#define ARCFIEND_SOUND_JOLT_STOP 'bastionstation/sound/arcfiend/jolt_stop.ogg'
#define ARCFIEND_SOUND_JOLT_RESTART 'bastionstation/sound/arcfiend/jolt_restart.ogg'
#define ARCFIEND_SOUND_COILGUN_FIRE 'bastionstation/sound/arcfiend/coilgun_fire.ogg'
#define ARCFIEND_SOUND_COILGUN_RELOAD 'bastionstation/sound/arcfiend/coilgun_reload.ogg'
#define ARCFIEND_SOUND_TETHER_FIRE 'bastionstation/sound/arcfiend/tether_fire.ogg'
#define ARCFIEND_SOUND_LASER_FIRE 'bastionstation/sound/arcfiend/lateral_laser_fire.ogg'
#define ARCFIEND_SOUND_LASER_RELOAD 'bastionstation/sound/arcfiend/laser_reload.ogg'
#define ARCFIEND_SOUND_LASER_MODE 'bastionstation/sound/arcfiend/laser_mode_click.ogg'
#define ARCFIEND_SOUND_PROD_HIT 'bastionstation/sound/arcfiend/prod_hit.ogg'
#define ARCFIEND_SOUND_PROD_ZAP 'bastionstation/sound/arcfiend/prod_zap.ogg'
#define ARCFIEND_SOUND_PROD_RECHARGED 'bastionstation/sound/arcfiend/prod_recharged.ogg'
