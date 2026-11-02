/// Martial art for Blood brothers, you can land a wombo combo to destroy your opponents

/obj/item/clothing/gloves/scrapper
	name = "scrapper gloves"
	desc = "Rough and tough charcoal gloves perfect for brawling in maintenance tunnels with the martial art of back alley brawling. They also provide protection against electric shock."
	icon = 'bastionstation/icons/obj/clothing/gloves.dmi'
	icon_state = "scrapper_gloves"
	worn_icon = 'bastionstation/icons/mob/clothing/hands.dmi'
	lefthand_file = 'bastionstation/icons/mob/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'bastionstation/icons/mob/inhands/clothing/gloves_righthand.dmi'
	inhand_icon_state = "scrapper_gloves"
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	siemens_coefficient = 0
	clothing_traits = list(TRAIT_FAST_CUFFING)
	var/datum/martial_art/back_alley_brawling/style = new

/obj/item/clothing/gloves/scrapper/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)

/obj/item/clothing/gloves/scrapper/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(user)
