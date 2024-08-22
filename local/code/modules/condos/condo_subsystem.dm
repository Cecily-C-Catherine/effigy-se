SUBSYSTEM_DEF(condos)
	name = "Condos"
	flags = SS_NO_FIRE
	/// All possible condo templates.
	var/list/condo_templates = list()
	/// List of active reservations we have.
	var/list/active_condos = list()
	// Items we delibrately prevent being deleted. Malleable. Try to keep this to only items that cannot be re-obtained without admin interference; with some exceptions.
	var/list/item_blacklist = list(
		/obj/item/blackbox, \
		/obj/item/gun/energy/laser/captain, \
		/obj/item/gun/energy/e_gun/hos, \
		/obj/item/hand_tele, \
		/obj/item/tank/jetpack/oxygen/captain, \
		/obj/item/clothing/shoes/magboots/advance, \
		/obj/item/blueprints, \
		/obj/item/clothing/accessory/medal/gold/captain, \
		/obj/item/reagent_containers/hypospray/cmo, \
		/obj/item/fireaxe, \
		/obj/item/crowbar/mechremoval, \
		/obj/item/storage/belt/utility/chief, \
		/obj/item/mod/control/pre_equipped/magnate, \
		/obj/item/gun/ballistic/shotgun/automatic/combat/compact, \
		/obj/item/clothing/suit/hooded/ablative, \
		/obj/item/nuke_core, \
		/obj/item/nuke_core_container, \
		/obj/item/computer_disk/hdd_theft, \
		/obj/item/nuke_core_container/supermatter, \
		/obj/item/aicard, \
		/obj/item/gun/energy/temperature/security, \
		/obj/item/mod/control/pre_equipped/advanced, \
		/obj/item/mod/control/pre_equipped/research, \
		/obj/item/mod/control/pre_equipped/rescue, \
		/obj/item/mod/control/pre_equipped/safeguard, \
		/obj/item/storage/belt/sabre, \
	)

/datum/controller/subsystem/condos/Initialize()
	preload_condo_templates()
	item_blacklist += typesof(/obj/item/card)
	item_blacklist += typesof(/obj/item/modular_computer)
	item_blacklist += typesof(/obj/item/nullrod)
	item_blacklist += typesof(/obj/item/stamp/head)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/condos/proc/preload_condo_templates()
	for(var/item in subtypesof(/datum/map_template/condo))
		var/datum/map_template/condo/condo_type = item
		if(!(initial(condo_type.mappath)))
			continue
		var/datum/map_template/condo/condo_template = new condo_type()

		condo_templates[condo_template.name] = condo_template
		SSmapping.map_templates[condo_template.name] = condo_template


/datum/controller/subsystem/condos/proc/enter_active_room(condo_number, mob/user)
	if(active_condos["[condo_number]"])
		var/datum/turf_reservation/condo/target_active_condo = active_condos["[condo_number]"]
		if(!target_active_condo)
			to_chat(user, span_warning("Condo [condo_number] error. Unable to find condo reservation!"))
			return FALSE

		do_sparks(3, FALSE, get_turf(user)) // EffigyEdit TODO: Replace with sparks that don't set things on fire, lol I don't remember it off hand

		var/turf/condo_bottom_left = target_active_condo.bottom_left_turfs[1]
		if(!condo_bottom_left)
			to_chat(user, span_warning("Condo [condo_number] error. Unable to find entry turf!"))
			return FALSE

		if(user.forceMove(locate(
			condo_bottom_left.x + target_active_condo.condo_template.landing_zone_x_offset,
			condo_bottom_left.y + target_active_condo.condo_template.landing_zone_y_offset,
			condo_bottom_left.z,
		)))
			return TRUE

	to_chat(user, span_warning("Condo [condo_number] error. Mystery failure!"))
	return FALSE

/datum/controller/subsystem/condos/proc/create_and_enter_condo(condo_number, datum/map_template/condo/our_condo, mob/user, parent_object)
	if(active_condos["[condo_number]"])
		return // Get sanity'd
	var/datum/turf_reservation/condo/condo_reservation = SSmapping.request_turf_block_reservation(our_condo.width, our_condo.height, 1, reservation_type = /datum/turf_reservation/condo)
	var/turf/bottom_left = condo_reservation.bottom_left_turfs[1]
	if(!bottom_left)
		to_chat(user, span_warning("Failed to reserve a room for you! Contact the technical concierge."))
		return
	our_condo.load(bottom_left)
	condo_reservation.condo_template = our_condo
	active_condos["[condo_number]"] = condo_reservation
	link_condo_turfs(condo_reservation, condo_number, parent_object)
	do_sparks(3, FALSE, get_turf(user)) // EffigyEdit TODO: Replace with sparks that don't set things on fire, lol I don't remember it off hand
	user.forceMove(locate(
		bottom_left.x + our_condo.landingZoneRelativeX,
		bottom_left.y + our_condo.landingZoneRelativeY,
		bottom_left.z,
	))

/datum/controller/subsystem/condos/proc/link_condo_turfs(datum/turf_reservation/condo/current_reservation, condo_number, parent_object)
	var/turf/condo_bottom_left = current_reservation.bottom_left_turfs[1]
	var/area/misc/condo/current_area = get_area(condo_bottom_left)
	current_area.name = "Condo [condo_number]"
	current_area.parent_object = parent_object
	current_area.condo_number = condo_number
	current_area.reservation = current_reservation

	for(var/turf/closed/indestructible/hoteldoor/door in current_reservation.reserved_turfs)
		door.parentSphere = parent_object
		door.desc = "The door to this condo. \
			The placard reads 'Room [condo_number]'. \
			Strangely, this door doesn't even seem openable. \
			The doorknob, however, seems to buzz with unusual energy...<br/>\
			[span_info("Alt-Click to look through the peephole.")]"
	for(var/turf/open/space/bluespace/bluespace_turf in current_reservation.reserved_turfs)
		bluespace_turf.parentSphere = parent_object
