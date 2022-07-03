/*
	Datum-based species. Should make for much cleaner and easier to maintain species code.
*/
///TODO SPLIT THIS INTO MULTIPLE FILES

/datum/species

	var/name                                             // Species name.
	var/name_plural

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.
	var/prone_icon                                       // If set, draws this from icobase when mob is prone.
	var/eyes = "eyes_s"                                  // Icon for eyes.

	var/tail                                   // Name of tail image in species effects icon file.
	var/datum/unarmed_attack/unarmed           // For empty hand harm-intent attack
	var/datum/unarmed_attack/secondary_unarmed // For empty hand harm-intent attack if the first fails.
	var/datum/hud_data/hud
	var/hud_type
	var/slowdown = 0
	var/taste_sensitivity = TASTE_NORMAL
	var/gluttonous        // Can eat some mobs. 1 for monkeys, 2 for people.
	var/rarity_value = 1  // Relative rarity/collector value for this species. Only used by ninja and cultists atm.
	var/unarmed_type =           /datum/unarmed_attack
	var/secondary_unarmed_type = /datum/unarmed_attack/bite
	var/default_language_holder = /datum/language_holder
	var/speech_verb_override
	var/secondary_langs = list()  // The names of secondary languages that are available to this species.
	var/list/speech_sounds        // A list of sounds to potentially play when speaking.
	var/list/speech_chance
	var/has_fine_manipulation = TRUE // Can use small items.
	var/insulated                 // Immune to electrocution and glass shards to the feet.
	var/count_human = FALSE // Does this count as a human?

	// Some species-specific gibbing data.
	var/gibbed_anim = "gibbed-h"
	var/dusted_anim = "dust-h"
	var/remains_type = /obj/effect/decal/remains/xeno
	var/death_sound
	var/death_message = "seizes up and falls limp, their eyes dead and lifeless..."

	var/breath_type = "oxygen"   // Non-oxygen gas breathed, if any.
	var/poison_type = "phoron"   // Poisonous air.
	var/exhale_type = "carbon_dioxide"      // Exhaled gas type.

	var/total_health = 100  //new maxHealth
	var/stamina_limit = 200
	var/max_stamina_buffer = 50

	var/cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT_ONE  	// Cold damage level 1 below this point.
	var/cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT_TWO  	// Cold damage level 2 below this point.
	var/cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT_THREE	// Cold damage level 3 below this point.

	var/heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT_ONE  	// Heat damage level 1 above this point.
	var/heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT_TWO  	// Heat damage level 2 above this point.
	var/heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT_THREE	// Heat damage level 2 above this point.

	var/body_temperature = BODYTEMP_NORMAL 	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/reagent_tag                 //Used for metabolizing reagents.

	var/darksight = 2
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_mod = null    // Physical damage reduction/malus.
	var/burn_mod = null     // Burn damage reduction/malus.

	///Whether this mob will tell when the user has logged out
	var/is_sentient = TRUE

	var/species_flags  = NONE       // Various specific features.

	var/list/abilities = list()	// For species-derived or admin-given powers
	var/list/preferences = list()
	var/list/screams = list()
	var/list/paincries = list()
	var/list/goredcries = list()
	var/list/gasps = list()
	var/list/coughs = list()
	var/list/burstscreams = list()
	var/list/warcries = list()

	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/base_color      //Used when setting species.
	var/hair_color      //If the species only has one hair color

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	// Species-specific abilities.
	var/list/inherent_verbs
	var/list/has_organ = list(
		"heart" =    /datum/internal_organ/heart,
		"lungs" =    /datum/internal_organ/lungs,
		"liver" =    /datum/internal_organ/liver,
		"kidneys" =  /datum/internal_organ/kidneys,
		"brain" =    /datum/internal_organ/brain,
		"appendix" = /datum/internal_organ/appendix,
		"eyes" =     /datum/internal_organ/eyes
		)

	var/knock_down_reduction = 1 //how much the knocked_down effect is reduced per Life call.
	var/stun_reduction = 1 //how much the stunned effect is reduced per Life call.
	var/knock_out_reduction = 1 //same thing
	var/lighting_alpha
	var/see_in_dark

	var/datum/namepool/namepool = /datum/namepool
	var/special_death_message = "<big>You have perished.</big><br><small>But it is not the end of you yet... if you still have your body or an unbursted corpse, wait until somebody can resurrect you...</small>" // Special death message that gets overwritten if possible.
	var/joinable_roundstart = FALSE

	var/list/default_mutant_bodyparts = list()
	var/specific_alpha = 255

	var/uses_ethnic_sprites = FALSE
	var/gets_random_bodymarkings = FALSE

/datum/species/New()
	if(hud_type)
		hud = new hud_type()
	else
		hud = new()

	if(unarmed_type) unarmed = new unarmed_type()
	if(secondary_unarmed_type) secondary_unarmed = new secondary_unarmed_type()

/datum/species/proc/get_random_features()
	return MANDATORY_FEATURE_LIST

/datum/species/proc/get_random_mutant_bodyparts(list/features)
	var/list/compiled = list()
	for(var/key in default_mutant_bodyparts)
		compiled[key] = GetDefaultMutantpart(src, key, features)
	return compiled

/datum/species/proc/get_random_body_markings(list/features)
	if(!gets_random_bodymarkings)
		return list()
	else
		var/list/candidates = get_body_marking_sets_for_species(src)
		if(!length(candidates))
			return list()
		var/name = pick(candidates)
		var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
		return assemble_body_markings_from_set(BMS, features, src)

/datum/species/proc/create_organs(mob/living/carbon/human/H) //Handles creation of mob organs and limbs.

	H.limbs = list()
	H.internal_organs = list()
	H.internal_organs_by_name = list()

	//This is a basic humanoid limb setup.
	var/datum/limb/chest/C = new(null, H)
	H.limbs += C
	var/datum/limb/groin/G = new(C, H)
	H.limbs += G
	H.limbs += new/datum/limb/head(C, H)
	var/datum/limb/l_arm/LA = new(C, H)
	H.limbs += LA
	var/datum/limb/r_arm/RA = new(C, H)
	H.limbs += RA
	var/datum/limb/l_leg/LL = new(G, H)
	H.limbs += LL
	var/datum/limb/r_leg/RL = new(G, H)
	H.limbs += RL
	H.limbs +=  new/datum/limb/hand/l_hand(LA, H)
	H.limbs +=  new/datum/limb/hand/r_hand(RA, H)
	H.limbs +=  new/datum/limb/foot/l_foot(LL, H)
	H.limbs +=  new/datum/limb/foot/r_foot(RL, H)

	for(var/organ in has_organ)
		var/organ_type = has_organ[organ]
		H.internal_organs_by_name[organ] = new organ_type(H)

	if(species_flags & IS_SYNTHETIC)
		for(var/datum/limb/l in H.limbs)
			var/datum/limb/robotic_limb = l
			if(robotic_limb.limb_status & LIMB_DESTROYED)
				continue
			robotic_limb.add_limb_flags(LIMB_ROBOT)
		for(var/datum/internal_organ/I in H.internal_organs)
			I.mechanize()


/datum/species/proc/hug(mob/living/carbon/human/H,mob/living/target)
	if(H.zone_selected == "head")
		H.visible_message("<span class='notice'>[H] pats [target] on the head.</span>", \
					"<span class='notice'>You pat [target] on the head.</span>", null, 4)
	else if(H.zone_selected == "l_hand" && CONFIG_GET(flag/fun_allowed))
		H.visible_message("<span class='notice'>[H] holds [target] 's left hand.</span>", \
					"<span class='notice'>You hold [target]'s left hand.</span>", null, 4)
	else if (H.zone_selected == "r_hand" && CONFIG_GET(flag/fun_allowed))
		H.visible_message("<span class='notice'>[H] holds [target] 's right hand.</span>", \
					"<span class='notice'>You hold [target]'s right hand.</span>", null, 4)
	else
		H.visible_message("<span class='notice'>[H] hugs [target] to make [target.p_them()] feel better!</span>", \
					"<span class='notice'>You hug [target] to make [target.p_them()] feel better!</span>", null, 4)

/datum/species/proc/random_name(gender)
	return GLOB.namepool[namepool].get_random_name(gender)

/datum/species/human/random_name(gender)
	. = ..()
	if(CONFIG_GET(flag/humans_need_surnames))
		. += " " + pick(SSstrings.get_list_from_file("names/last_name"))

/datum/species/proc/prefs_name(datum/preferences/prefs)
	return prefs.real_name

/datum/species/human/prefs_name(datum/preferences/prefs)
	. = ..()
	if(CONFIG_GET(flag/humans_need_surnames))
		var/firstspace = findtext(., " ")
		if(!firstspace || firstspace == length(.))
			. += " " + pick(SSstrings.get_list_from_file("names/last_name"))

/datum/species/synthetic/prefs_name(datum/preferences/prefs)
	. = prefs.synthetic_name
	if(!. || . == "Undefined") //In case they don't have a name set.
		switch(prefs.gender)
			if(MALE)
				. = "David"
			if(FEMALE)
				. = "Anna"
			else
				. = "Jeri"
		to_chat(prefs.parent, "<span class='warning'>You forgot to set your synthetic name in your preferences. Please do so next time.</span>")

/datum/species/early_synthetic/prefs_name(datum/preferences/prefs)
	. = prefs.synthetic_name
	if(!. || . == "Undefined") //In case they don't have a name set.
		switch(prefs.gender)
			if(MALE)
				. = "David"
			if(FEMALE)
				. = "Anna"
			else
				. = "Jeri"
		to_chat(prefs.parent, "<span class='warning'>You forgot to set your synthetic name in your preferences. Please do so next time.</span>")

/datum/species/proc/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	return

//special things to change after we're no longer that species
/datum/species/proc/post_species_loss(mob/living/carbon/human/H)
	return

/datum/species/proc/remove_inherent_verbs(mob/living/carbon/human/H)
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			H.verbs -= verb_path
	return

/datum/species/proc/add_inherent_verbs(mob/living/carbon/human/H)
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			H.verbs |= verb_path
	return

/datum/species/proc/handle_post_spawn(mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	add_inherent_verbs(H)

/datum/species/proc/handle_death(mob/living/carbon/human/H) //Handles any species-specific death events.

//TODO KILL ME
///Snowflake proc for monkeys so they can call attackpaw
/datum/species/proc/spec_unarmedattack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return FALSE

//Only used by horrors at the moment. Only triggers if the mob is alive and not dead.
/datum/species/proc/handle_unique_behavior(mob/living/carbon/human/H)
	return

// Used to update alien icons for aliens.
/datum/species/proc/handle_login_special(mob/living/carbon/human/H)
	return

// As above.
/datum/species/proc/handle_logout_special(mob/living/carbon/human/H)
	return

// Builds the HUD using species-specific icons and usable slots.
/datum/species/proc/build_hud(mob/living/carbon/human/H)
	return

// Grabs the window recieved when you click-drag someone onto you.
/datum/species/proc/get_inventory_dialogue(mob/living/carbon/human/H)
	return

//Used by xenos understanding larvae and dionaea understanding nymphs.
/datum/species/proc/can_understand(mob/other)
	return

/datum/species/proc/handle_fire(mob/living/carbon/human/H)
	return

/datum/species/proc/update_body(mob/living/carbon/human/H)
	return

/datum/species/proc/update_inv_head(mob/living/carbon/human/H)
	return

/datum/species/proc/update_inv_w_uniform(mob/living/carbon/human/H)
	return

/datum/species/proc/update_inv_wear_suit(mob/living/carbon/human/H)
	return

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(CHECK_BITFIELD(species_flags, NO_CHEM_METABOLIZATION)) //explicit
		H.reagents.del_reagent(chem.type) //for the time being
		return TRUE
	if(CHECK_BITFIELD(species_flags, NO_POISON) && istype(chem, /datum/reagent/toxin))
		H.reagents.remove_reagent(chem.type, chem.custom_metabolism * H.metabolism_efficiency)
		return TRUE
	if(CHECK_BITFIELD(species_flags, NO_OVERDOSE)) //no stacking
		if(chem.overdose_threshold && chem.volume > chem.overdose_threshold)
			H.reagents.remove_reagent(chem.type, chem.volume - chem.overdose_threshold)
	return FALSE

/datum/species/human
	name = "Human"
	name_plural = "Humans"
	unarmed_type = /datum/unarmed_attack/punch
	species_flags = HAS_SKIN_TONE|HAS_LIPS|HAS_UNDERWEAR
	count_human = TRUE

	screams = list(MALE = "male_scream", FEMALE = "female_scream")
	paincries = list(MALE = "male_pain", FEMALE = "female_pain")
	goredcries = list(MALE = "male_gored", FEMALE = "female_gored")
	gasps = list(MALE = "male_gasp", FEMALE = "female_gasp")
	coughs = list(MALE = "male_cough", FEMALE = "female_cough")
	burstscreams = list(MALE = "male_preburst", FEMALE = "female_preburst")
	warcries = list(MALE = "male_warcry", FEMALE = "female_warcry")
	joinable_roundstart = TRUE

	uses_ethnic_sprites = TRUE

	//If you wanted to add a species-level ability:
	/*abilities = list(/client/proc/test_ability)*/

/datum/species/genemodder
	name = "Genemodder"
	name_plural = "Genemodders"
	unarmed_type = /datum/unarmed_attack/punch
	species_flags = HAS_SKIN_TONE|HAS_LIPS|HAS_UNDERWEAR
	count_human = TRUE

	screams = list(MALE = "male_scream", FEMALE = "female_scream")
	paincries = list(MALE = "male_pain", FEMALE = "female_pain")
	goredcries = list(MALE = "male_gored", FEMALE = "female_gored")
	gasps = list(MALE = "male_gasp", FEMALE = "female_gasp")
	coughs = list(MALE = "male_cough", FEMALE = "female_cough")
	burstscreams = list(MALE = "male_preburst", FEMALE = "female_preburst")
	warcries = list(MALE = "male_warcry", FEMALE = "female_warcry")
	joinable_roundstart = TRUE

	uses_ethnic_sprites = TRUE

	default_mutant_bodyparts = list("tail" = "None", "snout" = "None", "horns" = "None", "ears" = "None", "wings" = "None", "neck_fluff" = "None", "moth_antennae" = "None")

/datum/species/humanoid
	name = "Humanoid"
	name_plural = "Humanoids"
	unarmed_type = /datum/unarmed_attack/punch
	species_flags = HAS_SKIN_COLOR|HAS_LIPS|HAS_UNDERWEAR
	count_human = TRUE

	icobase = 'icons/mob/human_races/r_mammal.dmi'
	deform = 'icons/mob/human_races/r_def_mammal.dmi'

	screams = list(MALE = "male_scream", FEMALE = "female_scream")
	paincries = list(MALE = "male_pain", FEMALE = "female_pain")
	goredcries = list(MALE = "male_gored", FEMALE = "female_gored")
	gasps = list(MALE = "male_gasp", FEMALE = "female_gasp")
	coughs = list(MALE = "male_cough", FEMALE = "female_cough")
	burstscreams = list(MALE = "male_preburst", FEMALE = "female_preburst")
	warcries = list(MALE = "male_warcry", FEMALE = "female_warcry")
	joinable_roundstart = TRUE

	default_mutant_bodyparts = list("tail" = "None", "snout" = "None", "horns" = "None", "ears" = "None", "wings" = "None", "neck_fluff" = "None", "moth_antennae" = "None")

/datum/species/human/vatborn
	name = "Vatborn"
	name_plural = "Vatborns"
	icobase = 'icons/mob/human_races/r_vatborn.dmi'
	deform = 'icons/mob/human_races/r_vatborn.dmi'

	namepool = /datum/namepool/vatborn
	uses_ethnic_sprites = FALSE

//Slightly tougher humans.
/datum/species/human/hero
	name = "Human Hero"
	name_plural = "Human Heroes"
	brute_mod = 0.55
	burn_mod = 0.55
	unarmed_type = /datum/unarmed_attack/punch/strong

	cold_level_1 = 220
	cold_level_2 = 180
	cold_level_3 = 80
	heat_level_1 = 390
	heat_level_2 = 480
	heat_level_3 = 1100
	joinable_roundstart = FALSE

/datum/species/human/vatgrown
	name = "Vat-Grown Human"
	name_plural = "Vat-Grown Humans"
	icobase = 'icons/mob/human_races/r_vatgrown.dmi'
	deform = 'icons/mob/human_races/r_vatgrown.dmi'
	brute_mod = 1.05
	burn_mod = 1.05
	slowdown = 1.05
	joinable_roundstart = FALSE

/datum/species/human/vatgrown/random_name(gender)
	return "CS-[gender == FEMALE ? "F": "M"]-[rand(111,999)]"

/datum/species/human/vatgrown/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "Bald"
	H.skills = getSkillsType(/datum/skills/vatgrown)

/datum/species/human/vatgrown/early
	name = "Early Vat-Grown Human"
	name_plural = "Early Vat-Grown Humans"
	brute_mod = 1.3
	burn_mod = 1.3
	slowdown = 1.3

	var/timerid

/datum/species/human/vatgrown/early/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.skills = getSkillsType(/datum/skills/vatgrown/early)
	timerid = addtimer(CALLBACK(src, .proc/handle_age, H), 15 MINUTES, TIMER_STOPPABLE)

/datum/species/human/vatgrown/early/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	// Ensure we don't update the species again
	if(timerid)
		deltimer(timerid)
		timerid = null

/datum/species/human/vatgrown/early/proc/handle_age(mob/living/carbon/human/H)
	H.set_species("Vat-Grown Human")


//todo: wound overlays are strange for monkeys and should likely use icon adding instead
//im not about to cram in that refactor with a carbon -> species refactor though
/datum/species/monkey
	name = "Monkey"
	name_plural = "Monkeys"
	icobase = 'icons/mob/human_races/r_monkey.dmi'
	deform = 'icons/mob/human_races/r_monkey.dmi'
	species_flags = HAS_NO_HAIR|NO_STAMINA|CAN_VENTCRAWL|DETACHABLE_HEAD
	reagent_tag = IS_MONKEY
	eyes = "blank_eyes"
	tail = "monkeytail" //todo
	speech_verb_override = "chimpers"
	unarmed_type = /datum/unarmed_attack/bite/strong
	secondary_unarmed_type = /datum/unarmed_attack/punch/strong
	joinable_roundstart = FALSE
	has_fine_manipulation = TRUE //monki gun
	death_message = "lets out a faint chimper as it collapses and stops moving..."
	dusted_anim = "dust-m"
	gibbed_anim = "gibbed-m"
	is_sentient = FALSE

/datum/species/monkey/handle_unique_behavior(mob/living/carbon/human/H)
	if(!H.client && H.stat == CONSCIOUS)
		if(prob(33) && H.canmove && !H.buckled && isturf(H.loc) && !H.pulledby) //won't move if being pulled
			step(H, pick(GLOB.cardinals))

		if(prob(1))
			H.emote(pick("scratch","jump","roll","tail"))

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.flags_pass |= PASSTABLE

/datum/species/monkey/spec_unarmedattack(mob/living/carbon/human/user, atom/target)
	if(!iscarbon(target))
		target.attack_paw(user)
		return TRUE
	var/mob/living/carbon/victim = target
	if(prob(25))
		victim.visible_message("<span class='danger'>[user]'s bite misses [victim]!</span>",
			"<span class='danger'>You avoid [user]'s bite!</span>", "<span class='hear'>You hear jaws snapping shut!</span>")
		to_chat(user, "<span class='danger'>Your bite misses [victim]!</span>")
		return TRUE
	victim.take_overall_damage(rand(10, 20), updating_health = TRUE)
	victim.visible_message("<span class='danger'>[name] bites [victim]!</span>",
		"<span class='userdanger'>[name] bites you!</span>", "<span class='hear'>You hear a chomp!</span>")
	to_chat(user, "<span class='danger'>You bite [victim]!</span>")
	target.attack_paw(user)
	return TRUE

/datum/species/monkey/random_name(gender,unique,lastname)
	return "[lowertext(name)] ([rand(1,999)])"

/datum/species/monkey/tajara
	name = "Farwa"
	icobase = 'icons/mob/human_races/r_farwa.dmi'
	deform = 'icons/mob/human_races/r_farwa.dmi'
	speech_verb_override = "mews"
	tail = null

/datum/species/monkey/skrell
	name = "Naera"
	icobase = 'icons/mob/human_races/r_naera.dmi'
	deform = 'icons/mob/human_races/r_naera.dmi'
	speech_verb_override = "squiks"
	tail = null

/datum/species/monkey/unathi
	name = "Stok"
	icobase = 'icons/mob/human_races/r_stok.dmi'
	deform = 'icons/mob/human_races/r_stok.dmi'
	speech_verb_override = "hisses"
	tail = null

/datum/species/monkey/yiren
	name = "Yiren"
	icobase = 'icons/mob/human_races/r_yiren.dmi'
	deform = 'icons/mob/human_races/r_yiren.dmi'
	speech_verb_override = "grumbles"
	tail = null
	cold_level_1 = ICE_COLONY_TEMPERATURE - 20
	cold_level_2 = ICE_COLONY_TEMPERATURE - 40
	cold_level_3 = ICE_COLONY_TEMPERATURE - 80



//Various horrors that spawn in and haunt the living.
/datum/species/human/spook
	name = "Horror"
	name_plural = "Horrors"
	icobase = 'icons/mob/human_races/r_spooker.dmi'
	deform = 'icons/mob/human_races/r_spooker.dmi'
	brute_mod = 0.15
	burn_mod = 1.50
	reagent_tag = IS_HORROR
	species_flags = HAS_SKIN_COLOR|NO_BREATHE|NO_POISON|HAS_LIPS|NO_PAIN|NO_SCAN|NO_POISON|NO_BLOOD|NO_SLIP|NO_CHEM_METABOLIZATION|NO_STAMINA
	unarmed_type = /datum/unarmed_attack/punch/strong
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	death_message = "doubles over, unleashes a horrible, ear-shattering scream, then falls motionless and still..."
	death_sound = 'sound/voice/scream_horror1.ogg'

	slowdown = 0.3
	insulated = 1
	has_fine_manipulation = FALSE

	heat_level_1 = 1000
	heat_level_2 = 1500
	heat_level_3 = 2000

	cold_level_1 = 100
	cold_level_2 = 50
	cold_level_3 = 20
	joinable_roundstart = FALSE

//To show them we mean business.
/datum/species/human/spook/handle_unique_behavior(mob/living/carbon/human/H)
	if(prob(25))
		animation_horror_flick(H)

	//Organ damage will likely still take them down eventually.
	H.adjustBruteLoss(-3)
	H.adjustFireLoss(-3)
	H.adjustOxyLoss(-15)
	H.adjustToxLoss(-15)

/datum/species/unathi
	name = "Unathi"
	name_plural = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	default_language_holder = /datum/language_holder/unathi
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	taste_sensitivity = TASTE_SENSITIVE
	gluttonous = 1

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#34AF10"

	reagent_tag = IS_UNATHI
	base_color = "#066000"

	joinable_roundstart = TRUE

	default_mutant_bodyparts = list("frills" = "Simple", "horns" = ACC_RANDOM, "snout" = ACC_RANDOM, "body_markings" = ACC_RANDOM, "tail" = ACC_RANDOM, "spines" = ACC_RANDOM)

/datum/species/unathi/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of green or brown colors, with a darker secondary and tertiary
	switch(random)
		if(1)
			main_color = "11CC00"
			second_color = "118800"
		if(2)
			main_color = "55CC11"
			second_color = "55AA11"
		if(3)
			main_color = "77AA11"
			second_color = "668711"
		if(4)
			main_color = "886622"
			second_color = "774411"
		if(5)
			main_color = "33BB11"
			second_color = "339911"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/lizardperson
	name = "Lizardperson"
	name_plural = "lizardperson"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	default_language_holder = /datum/language_holder/unathi
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	taste_sensitivity = TASTE_SENSITIVE
	gluttonous = 1

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#34AF10"

	reagent_tag = IS_UNATHI
	base_color = "#066000"

	joinable_roundstart = TRUE

	default_mutant_bodyparts = list("frills" = "Simple", "horns" = ACC_RANDOM, "snout" = ACC_RANDOM, "body_markings" = ACC_RANDOM, "tail" = ACC_RANDOM, "spines" = ACC_RANDOM)

/datum/species/lizardperson/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of green or brown colors, with a darker secondary and tertiary
	switch(random)
		if(1)
			main_color = "11CC00"
			second_color = "118800"
		if(2)
			main_color = "55CC11"
			second_color = "55AA11"
		if(3)
			main_color = "77AA11"
			second_color = "668711"
		if(4)
			main_color = "886622"
			second_color = "774411"
		if(5)
			main_color = "33BB11"
			second_color = "339911"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/tajaran
	name = "Tajara"
	name_plural = "Tajaran"
	icobase = 'icons/mob/human_races/r_mammal.dmi'
	deform = 'icons/mob/human_races/r_def_mammal.dmi'
	default_language_holder = /datum/language_holder/tajaran
	tail = "tajtail"
	unarmed_type = /datum/unarmed_attack/claws

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80 //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#AFA59E"
	base_color = "#333333"

	joinable_roundstart = TRUE
	gets_random_bodymarkings = TRUE

	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "ears" = ACC_RANDOM)

/datum/species/tajaran/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly coldish, animal, matching colors
	switch(random)
		if(1)
			main_color = "BBAA88"
			second_color = "AAAA99"
		if(2)
			main_color = "777766"
			second_color = "888877"
		if(3)
			main_color = "AA9988"
			second_color = "AAAA99"
		if(4)
			main_color = "EEEEDD"
			second_color = "FFEEEE"
		if(5)
			main_color = "DDCC99"
			second_color = "DDCCAA"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/vulpkanin
	name = "Vulpkanin"
	name_plural = "Vulpkanins"
	icobase = 'icons/mob/human_races/r_mammal.dmi'
	deform = 'icons/mob/human_races/r_def_mammal.dmi'
	unarmed_type = /datum/unarmed_attack/claws

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#AFA59E"
	base_color = "#333333"

	joinable_roundstart = TRUE
	gets_random_bodymarkings = TRUE

	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "ears" = ACC_RANDOM)

/datum/species/vulpkanin/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly brightish, animal, matching colors
	switch(random)
		if(1)
			main_color = "FFAA00"
			second_color = "FFDD44"
		if(2)
			main_color = "FF8833"
			second_color = "FFAA33"
		if(3)
			main_color = "FFCC22"
			second_color = "FFDD88"
		if(4)
			main_color = "FF8800"
			second_color = "FFFFFF"
		if(5)
			main_color = "999999"
			second_color = "EEEEEE"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/mammal
	name = "Anthropomorph"
	name_plural = "Anthropomorph"
	icobase = 'icons/mob/human_races/r_mammal.dmi'
	deform = 'icons/mob/human_races/r_def_mammal.dmi'
	unarmed_type = /datum/unarmed_attack/claws

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#AFA59E"
	base_color = "#333333"

	joinable_roundstart = TRUE
	gets_random_bodymarkings = TRUE

	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "horns" = "None", "ears" = ACC_RANDOM, "wings" = "None", "neck_fluff" = "None", "moth_antennae" = "None")

/datum/species/mammal/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/third_color
	var/random = rand(1,6)
	switch(random)
		if(1)
			main_color = "FFFFFF"
			second_color = "333333"
			third_color = "333333"
		if(2)
			main_color = "FFFFDD"
			second_color = "DD6611"
			third_color = "AA5522"
		if(3)
			main_color = "DD6611"
			second_color = "FFFFFF"
			third_color = "DD6611"
		if(4)
			main_color = "CCCCCC"
			second_color = "FFFFFF"
			third_color = "FFFFFF"
		if(5)
			main_color = "AA5522"
			second_color = "CC8833"
			third_color = "FFFFFF"
		if(6)
			main_color = "FFFFDD"
			second_color = "FFEECC"
			third_color = "FFDDBB"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = third_color
	return returned

/datum/species/akula
	name = "Akula"
	name_plural = "Akulan"
	icobase = 'icons/mob/human_races/r_akula.dmi'
	deform = 'icons/mob/human_races/r_def_akula.dmi'

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#AFA59E"
	base_color = "#333333"

	joinable_roundstart = TRUE

	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "ears" = ACC_RANDOM)

/datum/species/akula/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of sharkish colors, with a whiter secondary and tertiary
	switch(random)
		if(1)
			main_color = "668899"
			second_color = "BBCCDD"
		if(2)
			main_color = "334455"
			second_color = "DDDDEE"
		if(3)
			main_color = "445566"
			second_color = "DDDDEE"
		if(4)
			main_color = "666655"
			second_color = "DDDDEE"
		if(5)
			main_color = "444444"
			second_color = "DDDDEE"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/aquatic
	name = "Aquatic"
	name_plural = "Aquatics"
	icobase = 'icons/mob/human_races/r_akula.dmi'
	deform = 'icons/mob/human_races/r_def_akula.dmi'

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#AFA59E"
	base_color = "#333333"

	joinable_roundstart = TRUE
	gets_random_bodymarkings = TRUE

	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "horns" = "None", "ears" = ACC_RANDOM, "wings" = "None", "neck_fluff" = "None", "moth_antennae" = "None")

/datum/species/aquatic/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of sharkish colors, with a whiter secondary and tertiary
	switch(random)
		if(1)
			main_color = "668899"
			second_color = "BBCCDD"
		if(2)
			main_color = "334455"
			second_color = "DDDDEE"
		if(3)
			main_color = "445566"
			second_color = "DDDDEE"
		if(4)
			main_color = "666655"
			second_color = "DDDDEE"
		if(5)
			main_color = "444444"
			second_color = "DDDDEE"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/skrell
	name = "Skrell"
	name_plural = "Skrell"
	eyes = "eyes_skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	default_language_holder = /datum/language_holder/skrell
	unarmed_type = /datum/unarmed_attack/punch

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#8CD7A3"

	reagent_tag = IS_SKRELL

	joinable_roundstart = TRUE

	default_mutant_bodyparts = list("skrell_hair" = ACC_RANDOM)

/datum/species/skrell/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/random = rand(1,6)
	//Choose from a range of green-blue colors
	switch(random)
		if(1)
			main_color = "44FF77"
		if(2)
			main_color = "22FF88"
		if(3)
			main_color = "22FFBB"
		if(4)
			main_color = "22FFFF"
		if(5)
			main_color = "22BBFF"
		if(6)
			main_color = "2266FF"
	returned["mcolor"] = main_color
	returned["mcolor2"] = main_color
	returned["mcolor3"] = main_color
	return returned

/datum/species/moth
	name = "Moth"
	name_plural = "Moth"
	icobase = 'icons/mob/human_races/r_moth.dmi'
	deform = 'icons/mob/human_races/r_moth.dmi'
	default_language_holder = /datum/language_holder/moth
	eyes = "blank_eyes"
	speech_verb_override = "flutters"
	count_human = TRUE

	species_flags = HAS_LIPS|HAS_NO_HAIR|HAS_SKIN_COLOR

	screams = list("neuter" = 'sound/voice/moth_scream.ogg')
	paincries = list("neuter" = 'sound/voice/human_male_pain_3.ogg')
	goredcries = list("neuter" = 'sound/voice/moth_scream.ogg')
	burstscreams = list("neuter" = 'sound/voice/moth_scream.ogg')
	warcries = list("neuter" = 'sound/voice/moth_scream.ogg')

	flesh_color = "#E5CD99"

	reagent_tag = IS_MOTH

	namepool = /datum/namepool/moth

	joinable_roundstart = TRUE
	gets_random_bodymarkings = TRUE

	default_mutant_bodyparts = list("wings" = ACC_RANDOM, "neck_fluff" = ACC_RANDOM, "moth_antennae" = ACC_RANDOM)

/datum/species/moth/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	returned["mcolor"] = "FFE8A7"
	returned["mcolor2"] = "FFE8A7"
	returned["mcolor3"] = "FFE8A7"
	return returned

/datum/species/Insectoid
	name = "Insectoid"
	name_plural = "Insectoids"
	icobase = 'icons/mob/human_races/r_moth.dmi'
	deform = 'icons/mob/human_races/r_moth.dmi'
	default_language_holder = /datum/language_holder/moth
	eyes = "blank_eyes"
	speech_verb_override = "flutters"
	count_human = TRUE

	species_flags = HAS_LIPS|HAS_NO_HAIR|HAS_SKIN_COLOR

	screams = list("neuter" = 'sound/voice/moth_scream.ogg')
	paincries = list("neuter" = 'sound/voice/human_male_pain_3.ogg')
	goredcries = list("neuter" = 'sound/voice/moth_scream.ogg')
	burstscreams = list("neuter" = 'sound/voice/moth_scream.ogg')
	warcries = list("neuter" = 'sound/voice/moth_scream.ogg')

	flesh_color = "#E5CD99"

	reagent_tag = IS_MOTH

	namepool = /datum/namepool/moth

	joinable_roundstart = TRUE
	gets_random_bodymarkings = TRUE

	default_mutant_bodyparts = list("tail" = "None", "snout" = "None", "horns" = "None", "ears" = ACC_RANDOM, "wings" = ACC_RANDOM, "neck_fluff" = ACC_RANDOM, "moth_antennae" = ACC_RANDOM)

/datum/species/sectoid
	name = "Sectoid"
	name_plural = "Sectoids"
	icobase = 'icons/mob/human_races/r_sectoid.dmi'
	deform = 'icons/mob/human_races/r_sectoid.dmi'
	default_language_holder = /datum/language_holder/sectoid
	eyes = "blank_eyes"
	speech_verb_override = "transmits"
	count_human = TRUE

	species_flags = HAS_NO_HAIR|NO_BREATHE|NO_POISON|NO_PAIN|USES_ALIEN_WEAPONS|NO_DAMAGE_OVERLAY

	paincries = list("neuter" = 'sound/voice/sectoid_death.ogg')
	death_sound = 'sound/voice/sectoid_death.ogg'

	blood_color = "#00FF00"
	flesh_color = "#C0C0C0"

	reagent_tag = IS_SECTOID

	namepool = /datum/namepool/sectoid
	special_death_message = "You have perished."

/datum/species/vox
	name = "Vox"
	name_plural = "Vox"
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	default_language_holder = /datum/language_holder/vox
	taste_sensitivity = TASTE_DULL
	unarmed_type = /datum/unarmed_attack/claws/strong
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	rarity_value = 2

	speech_sounds = list('sound/voice/shriek1.ogg')
	speech_chance = 20

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"

	breath_type = "oxygen"//"nitrogen"
	poison_type = "phoron"//"oxygen"
	insulated = 1

	species_flags = NO_SCAN

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	reagent_tag = IS_VOX

	has_organ = list(
		"heart" =    /datum/internal_organ/heart,
		"lungs" =    /datum/internal_organ/lungs,
		"liver" =    /datum/internal_organ/liver,
		"kidneys" =  /datum/internal_organ/kidneys,
		"brain" =    /datum/internal_organ/brain,
		"eyes" =     /datum/internal_organ/eyes,
		"stack" =    /datum/internal_organ/stack/vox
		)

/datum/species/vox/armalis
	name = "Vox Armalis"
	name_plural = "Vox"
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	rarity_value = 10

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	brute_mod = 0.2
	burn_mod = 0.2

	eyes = "blank_eyes"
	breath_type = "nitrogen"
	poison_type = "oxygen"

	species_flags = NO_SCAN|NO_BLOOD|NO_PAIN|NO_STAMINA

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	reagent_tag = IS_VOX


/datum/species/machine
	name = "Machine"
	name_plural = "machines"

	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	default_language_holder = /datum/language_holder/machine
	unarmed_type = /datum/unarmed_attack/punch
	rarity_value = 2

	eyes = "blank_eyes"
	brute_mod = 0.25
	burn_mod = 1.1

	warning_low_pressure = 0
	hazard_low_pressure = 0

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD

	blood_color = "#EEEEEE"
	flesh_color = "#272757"

	has_organ = list(
		"heart" =    /datum/internal_organ/heart,
		"brain" =    /datum/internal_organ/brain,
		)
	special_death_message = "You have shut down."

/datum/species/skeleton
	name = "Skeleton"
	name_plural = "skeletons"
	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'
	unarmed_type = /datum/unarmed_attack/punch
	speech_verb_override = "rattles"
	count_human = TRUE

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_CHEM_METABOLIZATION|DETACHABLE_HEAD // Where we're going, we don't NEED underwear.

	screams = list("neuter" = 'sound/voice/skeleton_scream.ogg') // RATTLE ME BONES
	paincries = list("neuter" = 'sound/voice/skeleton_scream.ogg')
	goredcries = list("neuter" = 'sound/voice/skeleton_scream.ogg')
	burstscreams = list("neuter" = 'sound/voice/moth_scream.ogg')
	death_message = "collapses in a pile of bones, with a final rattle..."
	death_sound = list("neuter" = 'sound/voice/skeleton_scream.ogg')
	warcries = list("neuter" = 'sound/voice/skeleton_warcry.ogg') // AAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	namepool = /datum/namepool/skeleton

/datum/species/synthetic
	name = "Synthetic"
	name_plural = "synthetics"

	default_language_holder = /datum/language_holder/synthetic
	unarmed_type = /datum/unarmed_attack/punch
	rarity_value = 2

	total_health = 125 //more health than regular humans

	brute_mod = 0.70
	burn_mod = 0.70 //Synthetics should not be instantly melted by acid compared to humans - This is a test to hopefully fix very glaring issues involving synthetics taking 2.6 trillion damage when so much as touching acid

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD|HAS_UNDERWEAR

	blood_color = "#EEEEEE"

	has_organ = list(
		"heart" =    /datum/internal_organ/heart/prosthetic,
		"brain" =    /datum/internal_organ/brain/prosthetic,
		)

	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8

	screams = list(MALE = "male_scream", FEMALE = "female_scream")
	paincries = list(MALE = "male_pain", FEMALE = "female_pain")
	goredcries = list(MALE = "male_gored", FEMALE = "female_gored")
	warcries = list(MALE = "male_warcry", FEMALE = "female_warcry")
	special_death_message = "You have been shut down.<br><small>But it is not the end of you yet... if you still have your body, wait until somebody can resurrect you...</small>"


/datum/species/synthetic/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.add_hud_to(H)


/datum/species/synthetic/post_species_loss(mob/living/carbon/human/H)
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.remove_hud_from(H)
	return ..()


/datum/species/early_synthetic //cosmetic differences only
	name = "Early Synthetic"
	name_plural = "Early Synthetics"
	icobase = 'icons/mob/human_races/r_synthetic.dmi'
	deform = 'icons/mob/human_races/r_synthetic.dmi'
	default_language_holder = /datum/language_holder/synthetic
	unarmed_type = /datum/unarmed_attack/punch
	rarity_value = 1.5
	total_health = 125
	brute_mod = 0.70
	burn_mod = 0.70

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD|HAS_UNDERWEAR

	blood_color = "#EEEEEE"
	hair_color = "#000000"
	has_organ = list(
		"heart" =    /datum/internal_organ/heart/prosthetic,
		"brain" =    /datum/internal_organ/brain/prosthetic,
		)

	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8

	screams = list(MALE = "male_scream", FEMALE = "female_scream")
	paincries = list(MALE = "male_pain", FEMALE = "female_pain")
	goredcries = list(MALE = "male_gored", FEMALE = "female_gored")
	warcries = list(MALE = "male_warcry", FEMALE = "female_warcry")
	special_death_message = "You have been shut down.<br><small>But it is not the end of you yet... if you still have your body, wait until somebody can resurrect you...</small>"


/datum/species/early_synthetic/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.add_hud_to(H)


/datum/species/early_synthetic/post_species_loss(mob/living/carbon/human/H)
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.remove_hud_from(H)
	return ..()


/mob/living/carbon/human/proc/reset_jitteriness() //todo kill this
	jitteriness = 0



// Called when using the shredding behavior.
/datum/species/proc/can_shred(mob/living/carbon/human/H)

	if(H.a_intent != INTENT_HARM)
		return FALSE

	if(unarmed.is_usable(H))
		if(unarmed.shredding)
			return TRUE
	else if(secondary_unarmed.is_usable(H))
		if(secondary_unarmed.shredding)
			return TRUE
	return FALSE

//Species unarmed attacks
/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/shredding = 0 // Calls the old attack_alien() behavior on objects/mobs when on harm intent.
	var/sharp = 0
	var/edge = 0

/datum/unarmed_attack/proc/is_usable(mob/living/carbon/human/user)
	if(user.restrained())
		return FALSE

	// Check if they have a functioning hand.
	var/datum/limb/E = user.get_limb("l_hand")
	if(E && !(E.limb_status & LIMB_DESTROYED))
		return TRUE

	E = user.get_limb("r_hand")
	if(E && !(E.limb_status & LIMB_DESTROYED))
		return TRUE
	return FALSE

/datum/unarmed_attack/bite
	attack_verb = list("bite") // 'x has biteed y', needs work.
	attack_sound = 'sound/weapons/bite.ogg'
	shredding = 0
	damage = 5
	sharp = 1
	edge = 1

/datum/unarmed_attack/bite/is_usable(mob/living/carbon/human/user)
	if (user.wear_mask && istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		return FALSE
	return TRUE

/datum/unarmed_attack/punch
	attack_verb = list("punch")
	damage = 3

/datum/unarmed_attack/punch/strong
	attack_verb = list("punch","bust","jab")
	damage = 10

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 5
	sharp = 1
	edge = 1

/datum/unarmed_attack/claws/strong
	attack_verb = list("slash")
	damage = 10
	shredding = 1

/datum/unarmed_attack/bite/strong
	attack_verb = list("maul")
	damage = 15
	shredding = 1

/datum/hud_data
	var/icon              // If set, overrides ui_style.
	var/has_a_intent = 1  // Set to draw intent box.
	var/has_m_intent = 1  // Set to draw move intent box.
	var/has_warnings = 1  // Set to draw environment warnings.
	var/has_pressure = 1  // Draw the pressure indicator.
	var/has_nutrition = 1 // Draw the nutrition indicator.
	var/has_bodytemp = 1  // Draw the bodytemp indicator.
	var/has_hands = 1     // Set to draw shand.
	var/has_drop = 1      // Set to draw drop button.
	var/has_throw = 1     // Set to draw throw button.
	var/has_resist = 1    // Set to draw resist button.
	var/has_internals = 1 // Set to draw the internals toggle button.
	var/list/equip_slots = list() // Checked by mob_can_equip().

	// Contains information on the position and tag for all inventory slots
	// to be drawn for the mob. This is fairly delicate, try to avoid messing with it
	// unless you know exactly what it does.
	var/list/gear = list(
		"i_clothing" =   list("loc" = ui_iclothing, "slot" = SLOT_W_UNIFORM, "state" = "uniform", "toggle" = TRUE),
		"o_clothing" =   list("loc" = ui_oclothing, "slot" = SLOT_WEAR_SUIT, "state" = "suit",  "toggle" = TRUE),
		"mask" =         list("loc" = ui_mask,      "slot" = SLOT_WEAR_MASK, "state" = "mask",  "toggle" = TRUE),
		"gloves" =       list("loc" = ui_gloves,    "slot" = SLOT_GLOVES,    "state" = "gloves", "toggle" = TRUE),
		"eyes" =         list("loc" = ui_glasses,   "slot" = SLOT_GLASSES,   "state" = "glasses","toggle" = TRUE),
		"wear_ear" =     list("loc" = ui_wear_ear,  "slot" = SLOT_EARS,     "state" = "ears",   "toggle" = TRUE),
		"head" =         list("loc" = ui_head,      "slot" = SLOT_HEAD,      "state" = "head",   "toggle" = TRUE),
		"shoes" =        list("loc" = ui_shoes,     "slot" = SLOT_SHOES,     "state" = "shoes",  "toggle" = TRUE),
		"suit storage" = list("loc" = ui_sstore1,   "slot" = SLOT_S_STORE,   "state" = "suit_storage"),
		"back" =         list("loc" = ui_back,      "slot" = SLOT_BACK,      "state" = "back"),
		"id" =           list("loc" = ui_id,        "slot" = SLOT_WEAR_ID,   "state" = "id"),
		"storage1" =     list("loc" = ui_storage1,  "slot" = SLOT_L_STORE,   "state" = "pocket"),
		"storage2" =     list("loc" = ui_storage2,  "slot" = SLOT_R_STORE,   "state" = "pocket"),
		"belt" =         list("loc" = ui_belt,      "slot" = SLOT_BELT,      "state" = "belt")
		)

/datum/hud_data/New()
	. = ..()
	for(var/slot in gear)
		equip_slots |= gear[slot]["slot"]

	if(has_hands)
		equip_slots |= SLOT_L_HAND
		equip_slots |= SLOT_R_HAND
		equip_slots |= SLOT_HANDCUFFED
	if(SLOT_HEAD in equip_slots)
		equip_slots |= SLOT_IN_HEAD
	if(SLOT_BACK in equip_slots)
		equip_slots |= SLOT_IN_BACKPACK
		equip_slots |= SLOT_IN_B_HOLSTER
	if(SLOT_BELT in equip_slots)
		equip_slots |= SLOT_IN_HOLSTER
		equip_slots |= SLOT_IN_BELT
	if(SLOT_WEAR_SUIT in equip_slots)
		equip_slots |= SLOT_IN_S_HOLSTER
		equip_slots |= SLOT_IN_SUIT
	if(SLOT_SHOES in equip_slots)
		equip_slots |= SLOT_IN_BOOT
	if(SLOT_W_UNIFORM in equip_slots)
		equip_slots |= SLOT_IN_STORAGE
		equip_slots |= SLOT_IN_L_POUCH
		equip_slots |= SLOT_IN_R_POUCH
		equip_slots |= SLOT_ACCESSORY
		equip_slots |= SLOT_IN_ACCESSORY


/datum/species/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, mob/living/carbon/human/victim)
	var/hit_percent = (100 - blocked) * 0.01

	if(hit_percent <= 0) //total negation
		return 0

	damage *= CLAMP01(hit_percent) //Percentage reduction

	if(!damage) //Complete negation
		return 0

	if(victim.protection_aura)
		damage = round(damage * ((10 - victim.protection_aura) / 10))

	var/datum/limb/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		organ = victim.get_limb(check_zone(def_zone))
	if(!organ)
		return FALSE

	switch(damagetype)
		if(BRUTE)
			victim.damageoverlaytemp = 20
			if(brute_mod)
				damage *= brute_mod
			if(organ.take_damage_limb(damage, 0, sharp, edge))
				victim.UpdateDamageIcon()
		if(BURN)
			victim.damageoverlaytemp = 20
			if(burn_mod)
				damage *= burn_mod
			if(organ.take_damage_limb(0, damage, sharp, edge))
				victim.UpdateDamageIcon()
				return
			switch(damage)
				if(-INFINITY to 0)
					return FALSE
				if(25 to 50)
					if(prob(20))
						victim.emote("pain")
				if(50 to INFINITY)
					if(prob(60))
						victim.emote("pain")
		if(TOX)
			victim.adjustToxLoss(damage)
		if(OXY)
			victim.adjustOxyLoss(damage)
		if(CLONE)
			victim.adjustCloneLoss(damage)
		if(STAMINA)
			if(species_flags & NO_STAMINA)
				return
			victim.adjustStaminaLoss(damage)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	SEND_SIGNAL(victim, COMSIG_HUMAN_DAMAGE_TAKEN, damage)

	if(updating_health)
		victim.updatehealth()
	return damage