/mob/living/basic/mothroach/moffioso
	name = "Moffioso"
	desc = "The most evil mothroach known to man. Locked away for his innumerable crimes. Tread lightly when you walk on his turf."
	unique_name = FALSE
	icon = 'bastionstation/icons/mob/simple/moffia.dmi'
	icon_state = "mafiosoroach"
	icon_living = "mafiosoroach"
	icon_dead = "mafiosoroach_dead"
	head_icon = 'bastionstation/icons/mob/clothing/head/pets_head.dmi'

/mob/living/basic/mothroach/moffioso/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, 1)
