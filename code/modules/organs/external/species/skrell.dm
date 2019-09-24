/obj/item/organ/external/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/chest/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/groin/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/arm/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/arm/right/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/leg/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/leg/right/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/foot/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/foot/right/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/hand/skrell
	s_col_blend = ICON_OVERLAY

/obj/item/organ/external/hand/right/skrell
	s_col_blend = ICON_OVERLAY

//skrell ORGANS.
/obj/item/organ/external/skrell/removed()
	if(BP_IS_ROBOTIC(src))
		return ..()
	var/mob/living/carbon/human/H = owner
	..()
	if(!istype(H) || !H.organs || !H.organs.len)
		H.death()
	// if(prob(50) && spawn_skrell_nymph(get_turf(src)))
	// 	qdel(src)

/obj/item/organ/external/head/skrell
	s_col_blend = ICON_OVERLAY
	var/eye_icon_location = 'icons/mob/human_races/species/skrell/eyes.dmi'

/obj/item/organ/external/head/skrell/get_eye_overlay()
	var/icon/I = get_eyes()
	if(glowing_eyes)
		var/image/eye_glow = image(I)
		eye_glow.layer = EYE_GLOW_LAYER
		eye_glow.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		return eye_glow

/obj/item/organ/external/head/skrell/get_eyes()
	return icon(icon = eye_icon_location, icon_state = "")

/obj/item/organ/external/head/skrell/removed()
	..()