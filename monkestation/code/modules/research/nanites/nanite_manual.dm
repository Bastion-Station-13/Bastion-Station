/obj/item/book/manual/nanites
	name = "Nanites for Dummies"
	desc = "A handbook for the nanite lab. It claims to explain what a sent signal is."
	icon_state = "rdbook"
	starting_author = "Nanotrasen Research Division"
	starting_title = "Nanites for Dummies"
	// the book viewer reads markdown, so these lines can't be indented or they turn into code blocks
	starting_content = {"# Nanites for Dummies

Nanites are tiny machines that live inside a host and run programs for as long as they have nanites left to pay for them. This book is about the part everybody gets stuck on, which is how programs talk to each other.

## Signals

A signal is just a number from 1 to 9999. When something sends a number to a host, every program inside that host compares it with its own four codes:

- **Activation** turns the program on.
- **Deactivation** turns it off.
- **Trigger** fires the program once, if it has something to fire.
- **Kill** deletes the program for good.

A code of 0 means the program ignores that slot. Programs only listen to the number, they don't care who sent it.

## Who sends signals

- **Nanite remotes** send the number you set to the host you use them on. In relay mode they send it to every Relay program on a relay channel instead.
- **Relay** nanites pass those long range signals on to their own host, but only when the relay channel matches.
- **Sensors** and **Signal Repeaters** send signals on their own, see below.

## So what is a sent signal?

It is the number a sensor or repeater sends into its own host. Any program in that host that has the same number as one of its four codes will obey it.

That is all of it. You wire programs together by giving one program's Sent Code and another program's Activation, Deactivation, Trigger or Kill code the same number.

## Sensors

A sensor checks something about the host, like their health, blood, nutrition, species, consciousness or the health of one organ.

- **Sent Code (Signal)** is sent once when the check starts being true.
- **Sent Code (Signal, Inverted)** is sent once when it stops being true.
- **Sent Code (Trigger)** and **(Trigger, Inverted)** are only sent when the sensor itself gets triggered, one for a true check and one for a false check.

## Rules

A sensor can also be used as a rule for another program. Set the sensor up in the nanite programmer, then use Add Rule from Programmer on the program in the cloud controller. A program with rules only runs while its rules allow it, and a triggered program ignores triggers that its rules don't allow.

- **Meet all** needs every rule to be true.
- **Meet any** needs one rule to be true.
- **Groups** let you mix both. Rules in the same group are combined the opposite way first.

With Meet any, a group of two rules means both must be true. A group with a brute rule and a burn rule, plus a loose health rule, reads as (brute and burn) or health. With Meet all, a group means any one of its rules will do.

## Signal Repeaters

When a Signal Repeater is triggered it sends its Sent Code, optionally after a delay. If its rules don't allow the trigger it sends its Sent Code (False) instead, so one repeater can give you a different signal for true and for false.
"}
