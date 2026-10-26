/obj/item/book/manual/nanites
	name = "Nanites for Dummies"
	desc = "A handbook for the nanite lab. It claims to explain what a sent signal is."
	icon_state = "rdbook"
	starting_author = "Nanotrasen Research Division"
	starting_title = "Nanites for Dummies"
	starting_content = {"<html>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Nanites for Dummies</h1>
				Nanites are tiny machines that live inside a host and run programs for as long as they have nanites left to pay for them.
				This book is about the part everybody gets stuck on, which is how programs talk to each other.

				<h2>Signals</h2>
				A signal is just a number from 1 to 9999. When something sends a number to a host, every program inside that host compares it with its own four codes:
				<ul>
				<li><b>Activation</b> turns the program on.</li>
				<li><b>Deactivation</b> turns it off.</li>
				<li><b>Trigger</b> fires the program once, if it has something to fire.</li>
				<li><b>Kill</b> deletes the program for good.</li>
				</ul>
				A code of 0 means the program ignores that slot. Programs only listen to the number, they don't care who sent it.

				<h2>Who sends signals</h2>
				<ul>
				<li><b>Nanite remotes</b> send the number you set to the host you use them on. In relay mode they send it to every Relay program on a relay channel instead.</li>
				<li><b>Relay</b> nanites pass those long range signals on to their own host, but only when the relay channel matches.</li>
				<li><b>Sensors</b> and <b>Signal Repeaters</b> send signals on their own, see below.</li>
				</ul>

				<h2>So what is a sent signal?</h2>
				It is the number a sensor or repeater sends into its own host. Any program in that host that has the same number as one of its four codes will obey it.
				That is all of it, you wire programs together by giving one program's Sent Code and another program's Activation, Deactivation, Trigger or Kill code the same number.

				<h2>Sensors</h2>
				A sensor checks something about the host, like their health, blood, nutrition, species, consciousness or the health of one organ.
				<ul>
				<li><b>Sent Code (Signal)</b> is sent once when the check starts being true.</li>
				<li><b>Sent Code (Signal, Inverted)</b> is sent once when it stops being true.</li>
				<li><b>Sent Code (Trigger)</b> and <b>(Trigger, Inverted)</b> are only sent when the sensor itself gets triggered, one for a true check and one for a false check.</li>
				</ul>

				<h2>Rules</h2>
				A sensor can also be used as a rule for another program. Set the sensor up in the nanite programmer, then use Add Rule from Programmer on the program in the cloud controller.
				A program with rules only runs while its rules allow it, and a triggered program ignores triggers that its rules don't allow.
				<ul>
				<li><b>Meet all</b> needs every rule to be true.</li>
				<li><b>Meet any</b> needs one rule to be true.</li>
				<li><b>Groups</b> let you mix both. Rules in the same group are combined the opposite way first.
				With Meet any, a group of two rules means both must be true, so one group with a brute rule and a burn rule plus a loose health rule reads as (brute and burn) or health.
				With Meet all, a group means any of its rules will do.</li>
				</ul>

				<h2>Signal Repeaters</h2>
				When a Signal Repeater is triggered it sends its Sent Code, optionally after a delay. If its rules don't allow the trigger it sends its Sent Code (False) instead,
				so one repeater can give you a different signal for true and for false.
				</body>
			</html>
			"}

/datum/supply_pack/science/nanite_manual
	name = "Nanites for Dummies Crate"
	desc = "Three copies of the nanite handbook, for researchers who still think a sent signal is a rumor."
	cost = CARGO_CRATE_VALUE
	contains = list(/obj/item/book/manual/nanites = 3)
	crate_name = "nanite manuals crate"
