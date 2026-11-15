/// Station side

/area/station/bitrunning
	name = "Bitrunning"

/area/station/bitrunning/den
	name = "Bitrunning Den"
	desc = "Office of bitrunners, houses their equipment."
	icon_state = "bit_den"

/// VDOM

/area/virtual_domain
	name = "Virtual Domain"
	icon = 'icons/area/areas_station.dmi'
<<<<<<< HEAD
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
=======
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	has_gravity = STANDARD_GRAVITY

/area/virtual_domain/powered
	name = "Virtual Domain Ruins"
	icon_state = "bit_ruin"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/virtual_domain/powered_lighting
	name = "Virtual Domain Ruins"
	icon_state = "bit_ruin"
	requires_power = FALSE

/// Safehouse

/area/virtual_domain/safehouse
	name = "Virtual Domain Safehouse"
<<<<<<< HEAD
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | VIRTUAL_SAFE_AREA
=======
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	icon_state = "bit_safe"
	requires_power = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Custom subtypes

/area/lavaland/surface/outdoors/virtual_domain
	name = "Virtual Domain Lava Ruins"
	icon_state = "bit_ruin"
<<<<<<< HEAD
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA

/area/lavaland/surface/outdoors/virtual_domain/protected_space
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | VIRTUAL_SAFE_AREA
=======
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA

/area/lavaland/surface/outdoors/virtual_domain/protected_space
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	icon_state = "bit_safe"

/area/lavaland/surface/outdoors/virtual_domain/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/lavaland/surface/outdoors/virtual_domain/fullbright/protected_space
<<<<<<< HEAD
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | VIRTUAL_SAFE_AREA
=======
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	icon_state = "bit_safe"

/area/icemoon/underground/explored/virtual_domain
	name = "Virtual Domain Ice Ruins"
	icon_state = "bit_ice"
<<<<<<< HEAD
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
=======
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))

/area/ruin/space/has_grav/powered/virtual_domain
	name = "Virtual Domain Space Ruins"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_space"
<<<<<<< HEAD
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA

/area/ruin/space/has_grav/powered/virtual_domain/protected_space
	name = "Virtual Domain Safe Zone"
	area_flags = UNIQUE_AREA | NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | VIRTUAL_SAFE_AREA
=======
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA

/area/ruin/space/has_grav/powered/virtual_domain/protected_space
	name = "Virtual Domain Safe Zone"
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA | UNLIMITED_FISHING
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
>>>>>>> 3c2bdfb6 (Fish update part 2 (#12888))
	icon_state = "bit_safe"
