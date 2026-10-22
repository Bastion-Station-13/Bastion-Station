#define RIGHTS_NONE "none"
/obj/machinery/door/admin_rank
	name = "door"
	desc = "This door only opens to certain ranking officers."
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	icon_state = "closed"
	explosion_block = 3
	heat_proof = TRUE
	max_integrity = 600
	armor_type = /datum/armor/door_password
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	damage_deflection = 70
	///what rights do we need to be used
	var/needed_rights = RIGHTS_NONE

/obj/machinery/door/admin_rank/mentor
	name = "mentor door"
	desc = "This door shall only heed to mentors."
	needed_rights = R_MENTOR

/obj/machinery/door/admin_rank/admin
	name = "admin door"
	desc = "This door shall only heed to admins."
	needed_rights = R_ADMIN

/obj/machinery/door/admin_rank/Bumped(atom/movable/AM)
	return !density && ..()

/obj/machinery/door/admin_rank/try_to_activate_door(mob/user, access_bypass = FALSE)
	add_fingerprint(user)
	if(operating)
		return
	if((needed_rights != RIGHTS_NONE) && !check_rights_for(user.client, needed_rights))
		to_chat(user, span_warning("The door refuses to acknowledge your presence."))
		do_animate("deny")
		return
	if(density)
		open()
	else
		close()

/obj/machinery/door/admin_rank/update_icon_state()
	. = ..()
	icon_state = density ? "closed" : "open"

/obj/machinery/door/admin_rank/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'sound/machines/airlock/open.ogg', 30, TRUE)
		if("closing")
			flick("closing", src)
			playsound(src, 'sound/machines/airlock/close.ogg', 30, TRUE)
		if("deny")
			//Deny animation would be nice to have.
			playsound(src, 'sound/machines/deniedbeep.ogg', 30, TRUE)

/obj/machinery/door/admin_rank/emp_act(severity)
	return

/obj/machinery/door/admin_rank/ex_act(severity, target)
	return FALSE

#undef RIGHTS_NONE
