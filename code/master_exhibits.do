/*******************************************************************************
Authors: Parag Pathak

Description: This is the Master program that replicates the exhibits in
	"Unobserved Punishment Supports Cooperation"

********************************************************************************/

* Set paths
global clean_data "A:/unobserved-punishment/vnorman/clean_data"
global output "A:/unobserved-punishment/vnorman/output"

* Switches
local figures 								 		 1
local tables											 1

********************************************************************************

* Travel time plots
if `figures' == 1 						 		 do "${code}/figures"

* Sample descriptives table
if `tables' == 1 						 			 do "${code}/tables"
