/obj/machinery/computer/xenobio_console
	name = "xenobio control console"
	desc = "Console used to assist with xenobiological research"
	icon_keyboard = "rd_key"
	icon_screen = "rdcomp"
	light_color = "#a97faa"
	req_access = list(access_research)	//Data and setting manipulation requires scientist access.
	var/list/slimes = list()
	var/list/data = list()
	var/obj/machinery/claw/claw = null


/obj/machinery/computer/xenobio_console/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	. = ..()

/obj/machinery/computer/xenobio_console/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	slimes = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!istype(C))
			continue
		if(istype(get_area(C), /area/rnd/xenobiology) && C.network.Find(NETWORK_RESEARCH) != 0)
			for(var/mob/living/carbon/slime/V in C.can_see())
				slimes += list(list("key1" = V.name, "key2" = "\ref[V]"))
	data["slimes"] = slimes
	data["claw"] = claw
	if (claw)
		data["grabbed"] = claw.grabbed_thing == null ? FALSE : TRUE
		data["maint"] = claw.state
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "xenobio.tmpl", "Xenobio Console", 565, 525)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/xenobio_console/attack_hand(mob/user as mob)
	// if(BROKEN|NOPOWER)
	// 	return
	if (!claw)
		claw = locate_claw()
	ui_interact(user)

/obj/machinery/computer/xenobio_console/OnTopic(var/mob/user, var/list/href_list, state)
	if(..())
		return TOPIC_HANDLED

	if(href_list["slime_click"])
		var/ret = href_list["slime_click"]
		var/mob/living/carbon/slime/retSlime = locate(ret)
		var/path = claw.GetPathToTarget(retSlime)
		data["pathd"] = path
		for(var/turf/node in path)
			if (node.contents.len > !!node.lighting_overlay)
				for(var/obj/machinery/door/window/W in node)
					if (W.density) //TODO disable buttons / add cancel button
						//If a door is closed, bump it
						claw.HandleMove(get_dir(claw.loc, node))
						sleep(10)
			claw.HandleMove(get_dir(claw.loc, node))
			sleep(5)
		return TOPIC_HANDLED
	if(href_list["release"])
		claw.Release()
		return TOPIC_HANDLED
	if(href_list["grab"])
		claw.TryGrab()
		return TOPIC_HANDLED
	if(href_list["move"])
		var/dir = text2num(href_list["move"])
		if(claw != null)
			claw.HandleMove(dir)
			return TOPIC_HANDLED
		return TOPIC_HANDLED
	if(href_list["find_claw"])
		claw = locate_claw()
		return TOPIC_HANDLED
	if(href_list["spray"])
		claw.Spray()
		return TOPIC_HANDLED
	return TOPIC_HANDLED

/obj/machinery/computer/xenobio_console/proc/locate_claw()
	for (var/sc in cameranet.cameras)
		if(istype(sc, /obj/machinery/camera))
			var/obj/machinery/camera/C = sc
			if(istype(get_area(C), /area/rnd/xenobiology) && C.network.Find(NETWORK_RESEARCH) != 0)
				for(var/obj/machinery/claw/W in C.can_see())
					if(istype(W, /obj/machinery/claw))
						. = W
						return

