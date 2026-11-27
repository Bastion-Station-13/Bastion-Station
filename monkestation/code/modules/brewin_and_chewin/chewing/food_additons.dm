/obj/item
	///can in rare cases be on an item so generalizing onto items
	var/food_quality = 1

/obj/item/food/examine(mob/user)
	. = ..()

	var/food_descriptor
	var/quality = round(food_quality)
	if(quality < 0)
		food_descriptor = "It looks gross. Someone cooked this poorly."
	else if(quality >= 100)
		food_descriptor = "What cruel twist of fate it must be, for this unparalleled artistic masterpiece can only be truly appreciated through its destruction. Does this dish's transient form belie the true nature of all things? You see the totality of existence reflected through \the [src]."
	else
		switch(quality)
			if(0)
				food_descriptor = "It looks like an unappetizing meal."
			if(1 to 10)
				food_descriptor = "You can eat this!"
			if(11 to 20)
				food_descriptor = "It looks adequately made."
			if(21 to 30)
				food_descriptor = "The quality of the food is pretty good."
			if(31 to 50)
				food_descriptor = "This food looks very tasty."
			if(51 to 60)
				food_descriptor = "This food looks expertly prepared, and the smell alone is making your mouth water."
			if(61 to 70)
				food_descriptor = "There's a special spark in this cooking, a measure of love and care unseen by the casual chef."
			if(71 to 80)
				food_descriptor = "This dish is the work of a true professional. Every detail has been crafted with care."
			if(81 to 99)
				food_descriptor = "The quality of this food is legendary. Words fail to describe it further. It must be eaten."

	if(food_descriptor)
		. += span_notice(food_descriptor)
