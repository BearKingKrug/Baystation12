#define CLAW_UP_Z_OFFSET 12
#define CLAW_DOWN_Z_OFFSET 8

/obj/machinery/claw
	name = "Claw"
	desc = "A claw attached to the rails on the ceiling"
	icon = 'icons/obj/xenobiology/xenos.dmi'
	icon_state = "claw_full"

	density = 0
	layer  = CAMERA_LAYER
	pass_flags = PASS_FLAG_SHORT | PASS_FLAG_TABLE

	var/atom/movable/grabbed_thing = null
	can_buckle = TRUE // so if you grab yourself you can get out
	buckle_lying = TRUE
	buckle_pixel_shift = 0
	pixel_z = CLAW_UP_Z_OFFSET

	var/allowed_area = /area/rnd/xenobiology // used to restrict movement to a specific area
	var/spray_amount = 150 // same as fire extinguisher
	var/particles = 3
	var/max_water = 2000
	var/state = 0
	/*
		0 - raised; for use
		1 - lowered; maint mode
	*/

/obj/machinery/claw/New()
	create_reagents(max_water)
	reagents.add_reagent(/datum/reagent/water, max_water)
	. = ..()

/obj/machinery/claw/Destroy()
	. = ..()

/obj/machinery/claw/proc/Raise()
	state = 0
	icon_state = "claw_full"

/obj/machinery/claw/proc/Lower()
	state = 1
	icon_state = "claw_maintenance_full"

/obj/machinery/claw/attackby(obj/item/W as obj, mob/living/user as mob)
	switch(state)
		if(1) //lowered
			if(isCrowbar(W))
				Raise()
			//TODO - ADD DISSASEMBLY
			//if(isScrewdriver(W)) //open hatch
			//if(istype(W, /obj/item/weapon/reagent_containers))//fill with water
		if(0) //raised
			if(isCrowbar(W))
				Lower()

// Claw can 'move through anything' except for walls, windows, and doors (things that go to the ceiling)
/obj/machinery/claw/proc/HandleMove(var/dir)
	var/turf/T = get_step(src, dir)
	if (!MayMove(T))
		return
	step(src, dir)
	if(grabbed_thing)
		grabbed_thing.forceMove(loc)

/obj/machinery/claw/MayMove(var/turf/T)
	return istype(get_area(T), allowed_area) && istype(T, /turf/simulated/floor)

//Will return true if it grabbed a /mob/living, otherwise false
//Will still cause the claw to drop and grab
/obj/machinery/claw/proc/TryGrab()
	var/mob/M = locate() in loc
	if (M)
		Grab(M)
	icon_state = "claw_grab_full" //TODO: CHOOSE BASED ON WATER LEVEL
	addtimer(CALLBACK(src, /obj/machinery/claw/proc/Retract), 1 SECOND)

/obj/machinery/claw/proc/Retract()
	pixel_z = CLAW_UP_Z_OFFSET
	if (grabbed_thing)
		icon_state = "claw_grab_up_full"
		grabbed_thing.pixel_z += CLAW_UP_Z_OFFSET
	else
		icon_state = "claw_full"

/obj/machinery/claw/proc/Grab(var/atom/M)
	pixel_z = CLAW_DOWN_Z_OFFSET
	loc = M.loc
	grabbed_thing = M
	buckle_mob(grabbed_thing)
	visible_message(loc, SPAN_WARNING("\The [src] closes its arms!"))
	grabbed_thing.alpha = 150
	grabbed_thing.pixel_z += (CLAW_DOWN_Z_OFFSET - grabbed_thing.pixel_z)//grabbed_thing.grab_offset
	//todo - fix slime glomping from grab state (add probability?)
	icon_state = "claw_grab_full" //TODO: CHOOSE BASED ON WATER LEVEL

/obj/machinery/claw/proc/Release()
	if (grabbed_thing)
		unbuckle_mob(grabbed_thing)
		visible_message(loc, SPAN_WARNING("\The [src] opens its arms!"))
	pixel_z = CLAW_UP_Z_OFFSET
	icon_state = "claw_full" //TODO: CHOOSE BASED ON WATER LEVEL

/obj/machinery/claw/unbuckle_mob()
	. = ..()
	grabbed_thing.alpha = 255
	grabbed_thing.pixel_z = initial(grabbed_thing.pixel_z)
	grabbed_thing = null

// Will spray the tile like a fire extinquisher if not currently clutching anything
// Else will transfer reagents directly to the target
/obj/machinery/claw/proc/Spray()
	if (!reagents.total_volume)
		return
	var/per_particle = min(spray_amount, reagents.total_volume)/particles
	if (grabbed_thing) 
		reagents.splash(grabbed_thing, min(spray_amount, reagents.total_volume))
		loc.visible_message(SPAN_ITALIC("The [src] sprays \the [grabbed_thing]!"))
	else
		loc.visible_message(SPAN_ITALIC("The [src] sprays \the [loc]!"))
		for(var/a = 1 to particles)
			var/obj/effect/effect/water/W = new /obj/effect/effect/water(get_turf(src))
			W.create_reagents(per_particle)
			reagents.trans_to_obj(W, per_particle)
			W.set_color()
			W.set_up(get_turf(loc))

	playsound(loc, 'sound/effects/extinguish.ogg', 75, 1, -3)

/obj/machinery/claw/proc/GetPathToTarget(var/atom/target)
	return AStar(get_turf(loc), get_turf(target.loc), /turf/proc/CardinalTurfsForClaw, /turf/proc/Distance, 0, 0)

/turf/proc/CardinalTurfsForClaw(var/obj/item/weapon/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in GLOB.cardinal)
		var/turf/simulated/T = get_step(src, d)
		var/canpass = TRUE
		if(istype(T) && !T.density && !istype(T, /turf/simulated/wall))
			for(var/obj/structure/D in src)
				if(istype(D) && D.density)
					canpass = FALSE
			if (canpass)
				L.Add(T)
	return L

#undef CLAW_UP_Z_OFFSET
#undef CLAW_DOWN_Z_OFFSET