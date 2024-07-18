/obj/item/food/cookie/bacon
	name = "strip of bacon"
	desc = "BACON!!!"
	icon = 'local/icons/obj/food/snacks.dmi'
	icon_state = "bacon_strip"
	tastes = list("bacon" = 1)
	foodtypes = MEAT

/obj/item/food/cookie/cloth
	name = "odd cookie"
	desc = "A cookie that appears to be made out of... some form of cloth?"
	icon = 'local/icons/obj/food/snacks.dmi'
	icon_state = "cookie_cloth"
	tastes = list("cloth" = 1)
	foodtypes = CLOTH

/obj/item/food/cookie/tungsten
	name = "tungsten bar"
	desc = "A highly sought-after treat among synthetic beings, tungsten is known for its extraordinary ability to short-circuit pleasure response processors, resulting in endearing and heartwarming behaviour."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-metalhydrogen"
	food_reagents = list(
		/datum/reagent/consumable/tungsten = 5,
	)
	tastes = list("beep" = 3, "metal" = 4)
	foodtypes = GROSS
