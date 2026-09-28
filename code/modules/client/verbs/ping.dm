<<<<<<< HEAD
/client/verb/update_ping(time as num)
	set instant = TRUE
	set name = ".update_ping"
=======
GAME_VERB_NATIVE_INSTANT(/client, update_ping, ".update_ping", null, time as num)
>>>>>>> f3f8c560 ([PORT] verb serialization, tgui command bar and admin verb panel (gmod style) (#12625))
	var/ping = pingfromtime(time)
	lastping = ping
	if (!avgping)
		avgping = ping
	else
		avgping = MC_AVERAGE_SLOW(avgping, ping)

/client/proc/pingfromtime(time)
	return ((world.time+world.tick_lag*TICK_USAGE_REAL/100)-time)*100

<<<<<<< HEAD
/client/verb/display_ping(time as num)
	set instant = TRUE
	set name = ".display_ping"
=======
GAME_VERB_NATIVE_INSTANT(/client, display_ping, ".display_ping", null, time as num)
>>>>>>> f3f8c560 ([PORT] verb serialization, tgui command bar and admin verb panel (gmod style) (#12625))
	to_chat(src, span_notice("Round trip ping took [round(pingfromtime(time),1)]ms"))

/client/verb/ping()
	set name = "Ping"
	set category = "OOC"
	winset(src, null, "command=.display_ping+[world.time+world.tick_lag*TICK_USAGE_REAL/100]")
