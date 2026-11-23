/datum/unit_test/prosthetic_item_arm
	var/mob/living/carbon/human/human
	var/obj/item/item
	var/obj/item/bodypart/arm
	var/arm_zone

/datum/unit_test/prosthetic_item_arm/Run()
	human = allocate(/mob/living/carbon/human/consistent)
	item = allocate(/obj/item/crowbar)

	var/obj/item/bodypart/active = human.get_active_hand()
	arm_zone = active.body_zone
	arm = human.make_item_prosthetic(item, arm_zone)
	TEST_ASSERT_NOTNULL(arm, "make_item_prosthetic did not make an arm")

	check_attached()
	check_not_held()
	check_stays()
	check_falls_off()

/datum/unit_test/prosthetic_item_arm/Destroy()
	human = null
	item = null
	arm = null
	return ..()

/datum/unit_test/prosthetic_item_arm/proc/check_attached()
	TEST_ASSERT(arm.bodypart_flags & BODYPART_PSEUDOPART, "The arm is not a pseudopart")
	TEST_ASSERT_EQUAL(human.get_bodypart(arm_zone), arm, "The arm was not attached to the owner")
	TEST_ASSERT_EQUAL(human.get_item_for_held_index(arm.held_index), item, "The item is not in the hand of the arm")
	TEST_ASSERT(HAS_TRAIT_FROM(item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT), "The item can be dropped")
	TEST_ASSERT(item.item_flags & ABSTRACT, "The item is not abstract")
	TEST_ASSERT_EQUAL(arm.name, "[arm_zone == BODY_ZONE_R_ARM ? "right" : "left"] [item.name]", "The arm is not named after the item")

/datum/unit_test/prosthetic_item_arm/proc/check_not_held()
	TEST_ASSERT_EQUAL(human.get_num_held_items(), 0, "An arm made of an item counts as a held item")

/// falling off is a chance, and zero means it stays
/datum/unit_test/prosthetic_item_arm/proc/check_stays()
	var/datum/component/item_as_prosthetic_limb/limb_comp = arm.GetComponent(/datum/component/item_as_prosthetic_limb)
	TEST_ASSERT_NOTNULL(limb_comp, "The arm has no prosthetic component")
	limb_comp.drop_prob = 0
	TEST_ASSERT_EQUAL(limb_comp.pop_limb(human), NONE, "The item fell off with a chance of zero")
	TEST_ASSERT_EQUAL(human.get_bodypart(arm_zone), arm, "The arm was lost with a chance of zero")

/datum/unit_test/prosthetic_item_arm/proc/check_falls_off()
	var/datum/component/item_as_prosthetic_limb/limb_comp = arm.GetComponent(/datum/component/item_as_prosthetic_limb)
	limb_comp.drop_prob = 100
	var/result = limb_comp.pop_limb(human)
	TEST_ASSERT(result & COMPONENT_CANCEL_ATTACK_CHAIN, "The attack was not cancelled when the item fell off")
	TEST_ASSERT(QDELETED(arm), "The arm was not deleted when the item fell off")
	TEST_ASSERT(!QDELETED(item), "The item was deleted with the arm")
	TEST_ASSERT_EQUAL(item.loc, human.drop_location(), "The item did not drop to the floor")
	TEST_ASSERT(!HAS_TRAIT_FROM(item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT), "The item is still undroppable")
	TEST_ASSERT(!(item.item_flags & ABSTRACT), "The item is still abstract")
	TEST_ASSERT(!human.get_bodypart(arm_zone), "The owner has an arm where the item was")

/datum/unit_test/prosthetic_item_deleted
	var/obj/item/bodypart/arm

/datum/unit_test/prosthetic_item_deleted/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/item = allocate(/obj/item/crowbar)
	var/obj/item/bodypart/active = human.get_active_hand()
	arm = human.make_item_prosthetic(item, active.body_zone)
	TEST_ASSERT_NOTNULL(arm, "make_item_prosthetic did not make an arm")

	qdel(item)
	TEST_ASSERT(QDELETED(arm), "The arm stayed when its item was deleted")
	TEST_ASSERT(!human.get_bodypart(active.body_zone), "The owner kept an arm made of a deleted item")

/datum/unit_test/prosthetic_item_deleted/Destroy()
	arm = null
	return ..()

/datum/unit_test/prosthetic_item_surgery
	var/datum/surgery_step/add_prosthetic/step

/datum/unit_test/prosthetic_item_surgery/Run()
	step = new
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)

	var/obj/item/normal = allocate(/obj/item/crowbar)
	normal.w_class = WEIGHT_CLASS_NORMAL
	TEST_ASSERT(step.tool_check(user, normal), "An item of a normal size was not accepted")

	var/obj/item/tiny = allocate(/obj/item/pen)
	TEST_ASSERT(!step.tool_check(user, tiny), "A tiny item was accepted")

	var/obj/item/huge = allocate(/obj/item/crowbar)
	huge.w_class = WEIGHT_CLASS_HUGE
	TEST_ASSERT(!step.tool_check(user, huge), "A huge item was accepted")

	var/obj/item/chainsaw/chainsaw = allocate(/obj/item/chainsaw)
	TEST_ASSERT(step.tool_check(user, chainsaw), "The chainsaw was not accepted")

	var/obj/item/nullrod/chainsaw/rod = allocate(/obj/item/nullrod/chainsaw)
	TEST_ASSERT(!step.tool_check(user, rod), "An abstract item was accepted")

	// anything on the anti-drop blacklist is refused, whatever its size
	for(var/blacklisted_type in ANTI_DROP_BLACKLIST())
		var/obj/item/blacklisted = allocate(blacklisted_type)
		blacklisted.w_class = WEIGHT_CLASS_NORMAL
		TEST_ASSERT(!step.tool_check(user, blacklisted), "[blacklisted_type] is on the anti-drop blacklist but was accepted")

/datum/unit_test/prosthetic_item_surgery/Destroy()
	QDEL_NULL(step)
	return ..()

/datum/unit_test/prosthetic_item_chainsaw

/datum/unit_test/prosthetic_item_chainsaw/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/chainsaw/chainsaw = allocate(/obj/item/chainsaw)
	TEST_ASSERT_NOTNULL(chainsaw.GetComponent(/datum/component/two_handed), "The chainsaw is not two handed")
	TEST_ASSERT_NULL(chainsaw.inhand_icon_state, "The chainsaw has a set inhand icon")

	var/obj/item/bodypart/active = human.get_active_hand()
	var/obj/item/bodypart/arm = human.make_item_prosthetic(chainsaw, active.body_zone)
	TEST_ASSERT_NOTNULL(arm, "The chainsaw did not become an arm")
	TEST_ASSERT_NULL(chainsaw.GetComponent(/datum/component/two_handed), "An arm chainsaw has to be held with two hands")
	TEST_ASSERT_EQUAL(chainsaw.inhand_icon_state, "mounted_chainsaw", "The arm chainsaw has the wrong inhand icon")

	arm.drop_limb()
	TEST_ASSERT_NOTNULL(chainsaw.GetComponent(/datum/component/two_handed), "The chainsaw is not two handed again after it was dropped")
	TEST_ASSERT_NULL(chainsaw.inhand_icon_state, "The dropped chainsaw keeps the arm inhand icon")

/datum/unit_test/prosthetic_item_nullrod

/datum/unit_test/prosthetic_item_nullrod/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/nullrod/chainsaw/rod = allocate(/obj/item/nullrod/chainsaw)

	rod.on_selected(null, human)
	var/obj/item/bodypart/active = human.get_active_hand()
	TEST_ASSERT(active.bodypart_flags & BODYPART_PSEUDOPART, "The chainsaw hand did not replace the arm")
	TEST_ASSERT(HAS_TRAIT_FROM(rod, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT), "The chainsaw hand can be dropped")
	TEST_ASSERT_EQUAL(rod.inhand_icon_state, "mounted_chainsaw", "The chainsaw hand has the wrong inhand icon")

	active.drop_limb()
	TEST_ASSERT(!QDELETED(rod), "The chainsaw hand was deleted with the arm")
	TEST_ASSERT(!HAS_TRAIT_FROM(rod, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT), "The chainsaw hand is still undroppable")

	// picking it up from the floor puts it back on an arm
	var/mob/living/carbon/human/other = allocate(/mob/living/carbon/human/consistent)
	other.put_in_active_hand(rod)
	var/obj/item/bodypart/new_active = other.get_active_hand()
	TEST_ASSERT(new_active.bodypart_flags & BODYPART_PSEUDOPART, "The chainsaw hand did not latch onto an arm when picked up")
	TEST_ASSERT_EQUAL(other.get_item_for_held_index(new_active.held_index), rod, "The chainsaw hand is not in the hand of the arm")

/datum/unit_test/prosthetic_item_dualsaber

/datum/unit_test/prosthetic_item_dualsaber/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/dualsaber/saber = allocate(/obj/item/dualsaber)
	TEST_ASSERT_NOTEQUAL(saber.on_wield(saber, human), COMPONENT_TWOHANDED_BLOCK_WIELD, "A normal dual saber could not be wielded")
	saber.on_unwield(saber, human)
	ADD_TRAIT(saber, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	TEST_ASSERT_EQUAL(saber.on_wield(saber, human), COMPONENT_TWOHANDED_BLOCK_WIELD, "A dual saber that is an arm could be wielded")

/datum/unit_test/prosthetic_item_secure

/datum/unit_test/prosthetic_item_secure/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/crowbar = allocate(/obj/item/crowbar)
	var/obj/item/bodypart/active = human.get_active_hand()
	var/obj/item/bodypart/arm = human.make_item_prosthetic(crowbar, active.body_zone, 80)
	var/datum/component/item_as_prosthetic_limb/limb_comp = arm.GetComponent(/datum/component/item_as_prosthetic_limb)
	TEST_ASSERT_EQUAL(limb_comp.drop_prob, 80, "The chance of falling off is not what the surgery sets")

	var/datum/surgery_step/secure_arbitrary_prosthetic/step = new
	var/obj/item/stack/medical/suture/suture = allocate(/obj/item/stack/medical/suture)
	var/suture_amount = suture.amount
	TEST_ASSERT(step.success(human, human, active.body_zone, suture, null), "Securing the arm failed")
	TEST_ASSERT_EQUAL(limb_comp.drop_prob, 0, "A secured arm can still fall off")
	TEST_ASSERT_EQUAL(suture.amount, suture_amount - 1, "Securing the arm did not use up one of the sutures")
	TEST_ASSERT_EQUAL(arm.GetComponent(/datum/component/item_as_prosthetic_limb), limb_comp, "Securing the arm made a second prosthetic component")
	qdel(step)

/datum/unit_test/prosthetic_item_attach

/datum/unit_test/prosthetic_item_attach/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/crowbar = allocate(/obj/item/crowbar)
	crowbar.w_class = WEIGHT_CLASS_NORMAL
	var/datum/surgery/prosthetic_replacement/surgery = new
	var/datum/surgery_step/add_prosthetic/step = new

	patient.get_bodypart(BODY_ZONE_R_ARM).drop_limb()
	user.put_in_active_hand(crowbar)
	TEST_ASSERT(step.success(user, patient, BODY_ZONE_R_ARM, crowbar, surgery), "Attaching the item failed")

	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	TEST_ASSERT_NOTNULL(arm, "The patient has no arm after the item was attached")
	TEST_ASSERT(arm.bodypart_flags & BODYPART_PSEUDOPART, "The new arm is not a pseudopart")
	TEST_ASSERT_EQUAL(patient.get_item_for_held_index(arm.held_index), crowbar, "The item is not in the hand of the new arm")
	TEST_ASSERT(!user.is_holding(crowbar), "The surgeon is still holding the item")
	TEST_ASSERT(/datum/surgery_step/secure_arbitrary_prosthetic in surgery.steps, "The step to secure the item was not added")
	var/datum/component/item_as_prosthetic_limb/limb_comp = arm.GetComponent(/datum/component/item_as_prosthetic_limb)
	TEST_ASSERT_EQUAL(limb_comp.drop_prob, 80, "The item has the wrong chance of falling off")

	qdel(surgery)
	qdel(step)
