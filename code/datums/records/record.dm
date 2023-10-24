/**
 * Record datum. Used for crew records and admin locked records.
 */
/datum/record
	/// Age of the character
	var/age
	/// Their blood type
	var/blood_type
	/// Character appearance
	var/mutable_appearance/character_appearance
	/// DNA string
	var/dna_string
	/// Fingerprint string (md5)
	var/fingerprint
	/// The character's gender
	var/gender
	/// The character's initial rank at roundstart
	var/initial_rank
	/// The character's name
	var/name = "Unknown"
	/// The character's rank
	var/rank
	/// The character's species
	var/species
	/// The character's ID trim
	var/trim
	/// The character's voice, if they have one.
	var/voice

/datum/record/New(
	age = 21,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	trim = "Unassigned",
	voice = "?????",
)
	src.age = age
	src.blood_type = blood_type
	src.character_appearance = character_appearance
	src.dna_string = dna_string
	src.fingerprint = fingerprint
	src.gender = gender
	src.initial_rank = rank
	src.name = name
	src.rank = rank
	src.species = species
	src.trim = trim

/**
 * Crew record datum
 */
/datum/record/crew
	/// List of citations
	var/list/citations = list()
	/// List of crimes
	var/list/crimes = list()
	/// Unique ID generated that is used to fetch lock record
	var/lock_ref
	/// Names of major disabilities
	var/major_disabilities
	/// Fancy description of major disabilities
	var/major_disabilities_desc
	/// List of medical notes
	var/list/medical_notes = list()
	/// Names of minor disabilities
	var/minor_disabilities
	/// Fancy description of minor disabilities
	var/minor_disabilities_desc
	/// Physical status of this person in medical records.
	var/physical_status
	/// Mental status of this person in medical records.
	var/mental_status
	/// Positive and neutral quirk strings
	var/quirk_notes
	/// Security note
	var/security_note
	/// Current arrest status
	var/wanted_status = WANTED_NONE

	// EffigyEdit Add -
	/// Contains their background information.
	var/background_information
	/// Contains their exploitable information.
	var/exploitable_information
	/// Contains their own custom past general records.
	var/past_general_records
	/// Contains their own custom past medical records.
	var/past_medical_records
	/// Contains their own custom past security records.
	var/past_security_records
	// EffigyEdit Add End

/datum/record/crew/New(
	age = 21,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	trim = "Unassigned",
	/// Crew specific
	lock_ref,
	major_disabilities = "None",
	major_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	minor_disabilities = "None",
	minor_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	physical_status = PHYSICAL_ACTIVE,
	mental_status = MENTAL_STABLE,
	quirk_notes,
	// EffigyEdit Add - Customization
	background_information = "",
	exploitable_information = "",
	past_general_records = "",
	past_medical_records = "",
	past_security_records = "",
	// EffigyEdit Add End
)
	. = ..()
	src.lock_ref = lock_ref
	src.major_disabilities = major_disabilities
	src.major_disabilities_desc = major_disabilities_desc
	src.minor_disabilities = minor_disabilities
	src.minor_disabilities_desc = minor_disabilities_desc
	src.physical_status = physical_status
	src.mental_status = mental_status
	src.quirk_notes = quirk_notes
	// EffigyEdit Add - Customization
	src.background_information = background_information
	src.exploitable_information = exploitable_information
	src.past_general_records = past_general_records
	src.past_medical_records = past_medical_records
	src.past_security_records = past_security_records
	// EffigyEdit Add End

	GLOB.manifest.general += src

/datum/record/crew/Destroy()
	GLOB.manifest.general -= src
	return ..()

/**
 * Admin locked record
 */
/datum/record/locked
	/// Mob's dna
	var/datum/dna/locked_dna
	/// Mind datum
	var/datum/weakref/mind_ref
	/// Typepath of species used by player, for usage in respawning via records
	var/species_type

/datum/record/locked/New(
	age = 21,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	trim = "Unassigned",
	/// Locked specific
	datum/dna/locked_dna,
	datum/mind/mind_ref,
)
	. = ..()
	src.locked_dna = locked_dna
	src.mind_ref = WEAKREF(mind_ref)
	species_type = locked_dna.species.type

	GLOB.manifest.locked += src

/datum/record/locked/Destroy()
	GLOB.manifest.locked -= src
	return ..()

/// A helper proc to get the front photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/record/crew/proc/get_front_photo()
	return get_photo("photo_front", SOUTH)

/// A helper proc to get the side photo of a character from the record.
/// Handles calling `get_photo()`, read its documentation for more information.
/datum/record/crew/proc/get_side_photo()
	return get_photo("photo_side", WEST)

/**
 * You shouldn't be calling this directly, use `get_front_photo()` or `get_side_photo()`
 * instead.
 *
 * This is the proc that handles either fetching (if it was already generated before) or
 * generating (if it wasn't) the specified photo from the specified record. This is only
 * intended to be used by records that used to try to access `fields["photo_front"]` or
 * `fields["photo_side"]`, and will return an empty icon if there isn't any of the necessary
 * fields.
 *
 * Arguments:
 * * field_name - The name of the key in the `fields` list, of the record itself.
 * * orientation - The direction in which you want the character appearance to be rotated
 * in the outputed photo.
 *
 * Returns an empty `/icon` if there was no `character_appearance` entry in the `fields` list,
 * returns the generated/cached photo otherwise.
 */
/datum/record/crew/proc/get_photo(field_name, orientation)
	if(!field_name)
		return

	if(!character_appearance)
		return new /icon()

	var/icon/picture_image
	if(!isicon(character_appearance))
		var/mutable_appearance/appearance = character_appearance
		appearance.setDir(orientation)

		picture_image = getFlatIcon(appearance)
	else
		picture_image = character_appearance

	var/datum/picture/picture = new
	picture.picture_name = name
	picture.picture_desc = "This is [name]."
	picture.picture_image = picture_image

	var/obj/item/photo/photo = new(null, picture)
	field_name = photo
	return photo

/// Returns a paper printout of the current record's crime data.
/datum/record/crew/proc/get_rapsheet(alias, header = "Rapsheet", description = "No further details.")
	var/print_count = ++GLOB.manifest.print_count
	var/obj/item/paper/printed_paper = new
	var/final_paper_text = "<center><b>SR-[print_count]: [header]</b></center><br>"

	final_paper_text += "Name: [name]<br>Gender: [gender]<br>Age: [age]<br>"
	if(alias != name)
		final_paper_text += "Alias: [alias]<br>"

	final_paper_text += "Species: [species]<br>Fingerprint: [fingerprint]<br>Wanted Status: [wanted_status]<br><br>"

	// EffigyEdit Add - Customization
	if(past_general_records != "")
		final_paper_text += "\nGeneral Records:\n[past_general_records]\n"
	// EffigyEdit Add End

	final_paper_text += text("<center><B>Security Data</B></center><br><br>")

	// EffigyEdit Add - Customization
	if(past_security_records != "")
		final_paper_text += "<br>Security Records:<br>[past_security_records]<br>"
	// EffigyEdit Add End

	final_paper_text += "Crimes:<br>"
	final_paper_text += {"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Crime</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
						</tr>"}
	for(var/datum/crime/crime in crimes)
		if(crime.valid)
			final_paper_text += "<tr><td>[crime.name]</td>"
			final_paper_text += "<td>[crime.details]</td>"
			final_paper_text += "<td>[crime.author]</td>"
			final_paper_text += "<td>[crime.time]</td>"
		else
			for(var/i in 1 to 4)
				final_paper_text += "<td>--REDACTED--</td>"
		final_paper_text += "</tr>"
	final_paper_text += "</table><br><br>"

	final_paper_text += "Citations:<br>"
	final_paper_text  += {"<table style="text-align:center;" border="1" cellspacing="0" width="100%">
						<tr>
						<th>Citation</th>
						<th>Details</th>
						<th>Author</th>
						<th>Time Added</th>
						<th>Fine</th>
						</tr><br>"}
	for(var/datum/crime/citation/warrant in citations)
		final_paper_text += "<tr><td>[warrant.name]</td>"
		final_paper_text += "<td>[warrant.details]</td>"
		final_paper_text += "<td>[warrant.author]</td>"
		final_paper_text += "<td>[warrant.time]</td>"
		final_paper_text += "<td>[warrant.fine]</td>"
		final_paper_text += "</tr>"
	final_paper_text += "</table><br><br>"

	final_paper_text += "<center>Important Notes:</center><br>"
	if(security_note)
		final_paper_text += "- [security_note]<br>"
	if(description)
		final_paper_text += "- [description]<br>"

	printed_paper.name = "SR-[print_count] '[name]'"
	printed_paper.add_raw_text(final_paper_text)
	printed_paper.update_appearance()

	return printed_paper
