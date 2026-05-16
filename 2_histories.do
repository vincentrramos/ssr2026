// ==============================================================================
// Paper:     Employment Stability and Social Origin: Cumulative Advantages in Young Adults' Homeownership and Financial Asset Accumulation
// Author:    Vincent Jerald Ramos and Ann Berrington
// Date:      May 2026
// Purpose:   Replication Codes for Figures and Tables in Text
// File:	  2_histories
// Describe:  create activity histories file (until 2015) and reshape to monthly-period. Merge with master file and retain those with valid histories
// ==============================================================================


clear all
clear matrix
capture drop _all
capture log close
macro drop _all
capture program drop _all
set more off
set mat 2000
eststo clear
set more off 
set emptycells drop


* Set global paths - USERS MUST UPDATE THIS
global PROJDIR "[PATH_TO_PROJECT_FOLDER]"

* Source data folders
global source01 "$PROJDIR/data/UKDA-5545-stata/stata/stata13/safeguarded_eul"
global source02 "$PROJDIR/data/UKDA-5545-stata/stata/stata13/activity_histories"
global source03 "$PROJDIR/data/UKDA-5545-stata/stata/stata13/household_grids"

* Output folders
global write    "$PROJDIR/output/tables"
global GRAPH      "$PROJDIR/output/figures"

* Create output directories if they don't exist
capture mkdir "$PROJDIR/output"
capture mkdir "$write"
capture mkdir "$GRAPH"

/* Two-step process
	- 1. Create an activity_long datafile that starts in January 2006 to December 2016 (120 rows per observation)
	- 2. Using the longitudinal activity history file, clean the dates and make assumptions re start dates
	- 3. merge the start dates and populate the activity_long file forward
*/

********************************************************************************
****** STW TRAJECTORIES (AGES 16-25) *******************************************
********************************************************************************

	* Step 1. Activity Long datafile
	
	* Use next_steps_activities_longitudinal dataset (n=82798) Unique NSIDs: 12880
	use "$source01\next_steps_activities_longitudinal", clear	

	keep NSID
	duplicates drop NSID, force
	expand 127
	sort NSID 
	
	gen start_date = ym(2005, 06) // Starting date: July 2005
	format start_date %tm // Format as a monthly date
	
	bysort NSID: gen month = start_date if _n == 1

	bysort NSID: replace month = start_date + _n - 1 if month==. // Create a month variable for each observation
	format month %tm
	lab var month "Period (Year-Month)"
	drop start_date
	rename month start_date

	
	save "$write\activity_long.dta", replace
	
********************************************************************************	
	* Step 2. Activity Histories file clean
	
	* Use next_steps_activities_longitudinal dataset (n=82798) Unique NSIDs: 12880
	use "$source01\next_steps_activities_longitudinal", clear	

	* Prepare the original spell data for merging
	clonevar start_year = Start_Y
	clonevar start_month = Start_M

	* Replacements
	recode start_month (-2 = 9)													// Before October 1  = september

	replace start_month = 1 if Start_Y == -6 | Start_Y==-5
	recode start_year (-6 = 2007) (-5 = 2006)									// "Before 2007" and "Before 2006" coded as Jan 2007/ Jan 2006, respectively
	 
	bysort NSID: replace start_year = start_year[_n+1] if start_year == -7
	bysort NSID: replace start_month = start_month[_n+1] if start_month == -7	// replace the "same as sweep 6" to sweep 6 activity start dates
	
	recode start_year start_month (-61 -52 -51 -1 -8 = .)						// missing info or other - are considered missing 

	* Generate the start date
	gen start_date = ym(start_year, start_month)
	format start_date %tm
	
	bysort NSID (start_date): replace start_date = . if start_date == start_date[_n+1]	// replace duplicates to avoid errors later in merging

	* Save the original data
	save "$write\spell_data.dta", replace

********************************************************************************
	* Step 3. Merging
		
	* Merge the spell data with the expanded panel data
	use "$write\activity_long.dta", clear
	merge 1:m NSID start_date using "$write\spell_data.dta", keep(master match)
	drop _merge


	bysort NSID (start_date): replace Activity = Activity[_n-1] if missing(Activity)
	bysort NSID (start_date): replace start_year = start_year[_n-1] if missing(start_year)
	bysort NSID (start_date): replace start_month = start_month[_n-1] if missing(start_month)
	
	recode Activity (-8 = .)

	keep NSID start_date Activity start_year start_month

	save "$write\activity_histories_long.dta", replace
	
********************************************************************************

		* Step 3a. MERGING AND PREP FOR 16 TO 25 LONG

		use "$write\activity_histories_long.dta", clear 
 
		drop start_year start_month
		sort NSID start_date
		unique NSID 	//12880
		
		
		 merge m:1 NSID using "$write\master", keep(match master)				// merges in the "master" file from w9/w1 - 6935 found. 5945 not.
		 *unique NSID if _merge==1
		drop if W9FINWTALLB == . 												// remove the activity histories of those not merged

		 // Variable imputations
	
		// Activity
		gen activitygrp = Activity
		recode activitygrp (1=1) (2 5 6 = 2) (3 4=3) 
		lab def activitygrp 1 "Employment" 2 "Education, Training, and Others" 3 "Unemployment/Inactive"
		lab val activitygrp activitygrp 
		lab var activitygrp "Activity category condensed"
		
		// Education Low: None/ Level 1/ Level 2 (~O Levels) = Low
		gen educ = W9DANVQH
		recode educ (1 2 96 = 1) (3 = 2) (4 5 = 3) (-9 -8 -1 95 = .)
		lab def educ 1 "Low" 2 "Medium" 3 "High"
		lab val educ educ
		lab var educ "Educational attainment"
		
		// Duration is time. Start at 16
		gen agemonths = start_date - dob
		lab var agemonths "Age in months"
		
		// gen age in years
		gen ageyears = floor((agemonths - 192) / 12) + 16
		lab var ageyears "Age in years"
		
		// gen agegrp (5 year intervals)
		gen agegrpcat = .
		replace agegrpcat = 1 if ageyears>=16 & ageyears<=19
		replace agegrpcat = 2 if ageyears>=20 & ageyears<=24
		replace agegrpcat = 3 if ageyears>=25 & ageyears<=29
		replace agegrpcat = 4 if ageyears>=30 & ageyears<=35
		lab def agegrpcat 1 "16-19" 2 "20-24" 3 "25-29" 4 "30-32"
		lab val agegrpcat agegrpcat
		lab var agegrpcat "Age group categories"
		
	
		// Due to missingness of many Activity variables, impute as educ if 2006m9 is educ and months before are . 
		drop if agemonths < 192 & agemonths!=.		// drops activities before 16th birthday
		
		gen tag = 1 if (start_date == tm(2006m9) | start_date == tm(2006m8)) & Activity == 2  // Identify cases where activitygrp is 2 in 2006m9/2006m8
		bysort NSID (start_date): replace tag = tag[_n-1] if tag[_n-1] != .
		bysort NSID (start_date): replace Activity = 2 if tag == . & Activity == . & agemonths < 210
		bysort NSID (start_date): replace activitygrp = 2 if tag == . & activitygrp == . & agemonths < 210
		drop tag
		
		save "$write\master_long_1625.dta", replace 

				
		keep NSID agemonths ageyears start_date Activity activitygrp
		save "$write\activity_histories_long_1625.dta", replace 



	* Step 4. Convert to wide
	
	use "$write\activity_histories_long_1625.dta", clear
	
	drop start_date ageyears activitygrp
	
	///label define activitylbl 1 "employed" 2 "education" 3 "unemp/inactive" 4 "caregiving" 5 "training" 6 "other"

	reshape wide Activity, i(NSID) j(agemonths)
	

	
	* RENAMEING VARIABLES
	* Start with the initial month number and initial age
	local start = 192
	local end = 326

	forvalues i = `start'/`end' {
		local months_since_16 = `i' - 192
		local age = 16 + floor(`months_since_16' / 12)
		local month = mod(`months_since_16', 12) + 1
		local newname = "y`age'm`month'"
		
		rename Activity`i' `newname'
	}	


	* Wide dataset
	
		save "$write\activity_histories_wide.dta", replace

********************************************************************************
****** LONGER TRAJECTORIES (AGES 16-32) ****************************************
********************************************************************************
	*Use ns9_activity_history and reshape to long file from dec 2015 to dec 2022.
	*Use ns9_2022_activity_history Unique NSIDs: 4704

	* Step 1: Create a dataset with all months from December 2015 to December 2022
	clear
	set obs 1
	gen start_date = ym(2015, 12)
	expand 85  // 85 months from Dec 2015 to Dec 2022
	bysort start_date: gen month = start_date + _n - 1
	format month %tm
	keep month
	tempfile all_months
	save `all_months'

	* Step 2: Create a dataset with all NSIDs and months
	
	use "$source02\ns9_2022_activity_history", clear
	keep NSID
	duplicates drop
	cross using `all_months'
	tempfile nsid_months
	save `nsid_months'

	* Step 3: Merge with the original dataset to fill in "current activity"
	use "$source02\ns9_2022_activity_history", clear	
	keep NSID W9CLENDMO W9CLENDYR W9CLACTIVITY2 W9DACTIVITY4
	gen month = ym(W9CLENDYR, W9CLENDMO)  // Create a month variable
	format month %tm
	
	gen W9DACTIVITY4GRP = W9DACTIVITY4
	recode W9DACTIVITY4GRP (1 2 3 4 = 1) (6 7 = 2) (5=3) (13=4) (12 8 =5) (9 10 11 14 -3=6)
	lab def W9DACTIVITY4GRP 1 "Employment" 2 "Education" 3 "Unemployment/Inactive" 4 "Looking after home/family" 5 "Training" 6 "Other"
	lab val W9DACTIVITY4GRP W9DACTIVITY4GRP
	lab var W9DACTIVITY4GRP "Activity grouped"
	
	gen W9CLACTIVITY2GRP =  W9CLACTIVITY2
	recode W9CLACTIVITY2GRP (1 2  = 1) (5 = 2) (4=3) (9=4) (6 7 =5) (3 8 10 -9 -8 -3 -1 =6)
	lab def W9CLACTIVITY2GRP 1 "Employment" 2 "Education" 3 "Unemployment/Inactive" 4 "Looking after home/family" 5 "Training" 6 "Other"
	lab val W9CLACTIVITY2GRP W9CLACTIVITY2GRP
	lab var W9CLACTIVITY2GRP "Activity grouped"
	
	* Handle duplicates: Keep only the latest activity for each NSID-month combination
	bysort NSID month (W9CLENDYR W9CLENDMO): keep if _n == _N
	tempfile unique_activities
	save `unique_activities'

	* Step 4: Merge with the expanded dataset
	use `nsid_months', clear
	merge 1:1 NSID month using `unique_activities'
	
	* Step 4: Fill in missing "current activity" values
	bysort NSID (month): replace W9CLACTIVITY2GRP = W9CLACTIVITY2GRP[_n-1] if missing(W9CLACTIVITY2GRP)

	keep NSID month W9CLACTIVITY2GRP W9DACTIVITY4GRP
	
	preserve    // so we can come back to the original data
    keep NSID month W9CLACTIVITY2GRP W9DACTIVITY4GRP
    drop if missing(W9CLACTIVITY2GRP)            // keep only rows where CLACTIVITY2 is not missing
    sort NSID month
    by NSID: keep if _n == 1                     // for each NSID, keep only earliest row
    rename month earliestmonth
    rename W9DACTIVITY4GRP earliestgrp
    save earliestrows, replace
	restore     // back to the original, full data
	
	merge m:1 NSID using earliestrows, nogenerate

	replace W9CLACTIVITY2GRP = earliestgrp ///
    if missing(W9CLACTIVITY2GRP) ///
    & month < earliestmonth
	
	drop earliestgrp earliestmonth

	* Step 5: Keep only the relevant variables and sort
	keep NSID month W9CLACTIVITY2GRP
	sort NSID month

	rename month start_date
	rename W9CLACTIVITY2GRP Activity
	lab var start_date "Period (Year-Month)"
	lab var Activity "Activity in sweep"
	
	* Save the final dataset
	save "$write\activity_histories_long_ns9.dta", replace
	
		// retain only the 2016-2022 calendar
		use "$write\activity_histories_long_ns9.dta", clear
		keep if inrange(start_date, ym(2016,1), ym(2022,12))
		save "$write\activity_histories_long_2016_22.dta", replace
		
********************************************************************************
	
	* Step 4. Convert to wide
	
	use "$write\activity_histories_long_2016_22.dta", clear

	reshape wide Activity, i(NSID) j(start_date)

	* RENAMING VARIABLES
	local start_year = 2016
	local end_year = 2022

	* Create a loop to rename variables and update labels
	local i = 672
	forval year = `start_year'/`end_year' {
		forval month = 1/12 {
			local month_str : word `month' of Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
			local var_name = "Act_`month_str'`year'"
			
			* Rename the variable and update the label
			rename Activity`i' `var_name'
			label variable `var_name' "Activity `month_str' `year'"
			
			* Increment the index
			local i = `i' + 1
			
			* Exit the loop if the index exceeds the number of variables
			if `i' > 756 {
				exit
			}
		}
	}

	* Wide dataset
	
		save "$write\activity_histories_wide_2016_22.dta", replace



********************************************************************************
********MERGE THE HISTORIES TO THE MAIN FILE ***********************************
********************************************************************************


* Generate a dataframe with only those with employment histories
	
	use "$write\master", clear	
	merge 1:1 NSID using "$write\activity_histories_wide.dta", keep(master match)		// 6935 merged
	
	* Retain only those with employment histories (6935 of 7279 have employment histories)
	keep if _merge==3
	drop _merge

	order NSID W9FINWTALLB y* sex ethnicity ethnicitycat migback perceived_acadperf likelihood_uniw1 degree25 degree qual_higher degree_rg subject_code subject_group fam_cmp mp_qualw4 sp_qualw4 fam_qualw4 mparent_educ numsib mp_disab pclass parentalres fam_cmpw1 pclassw1 W1highqualgfam fam_qualw1 parentalresw1 propertyown finassets finassets_val finassets_val_hi allassets_combo propertyown_psupport1 propertyown_psupport2 finassets_combo parentrescat parentres dopC domC doaC doiw9 dob W9DFINLIT3 hhincometert_w1 familymealw1 incomesecw1 parenttalksch_w1 parentsetcurfew_w1 W8GROW W9GROW W8INCOMERANK W9INCOMERANK W8W9incrankchange W8W9incchange W8W9incchangerank
	
	* Save for SA in R
	save "$write\activity_merged.dta", replace
	
	
* Generate an activity merged data consisting of all 7279 observations, even those w/o employment histories
	
	use "$write\master", clear	
	merge 1:1 NSID using "$write\activity_histories_wide.dta", keep(master match)		// 6935 merged
	
	order NSID W9FINWTALLB y* sex ethnicity ethnicitycat migback perceived_acadperf likelihood_uniw1 degree25 degree qual_higher degree_rg subject_code subject_group fam_cmp mp_qualw4 sp_qualw4 fam_qualw4 mparent_educ numsib mp_disab pclass parentalres fam_cmpw1 pclassw1 W1highqualgfam fam_qualw1 parentalresw1 propertyown finassets finassets_val finassets_val_hi allassets_combo propertyown_psupport1 propertyown_psupport2 finassets_combo parentrescat parentres dopC domC doaC doiw9 dob W9DFINLIT3 hhincometert_w1 familymealw1 incomesecw1 parenttalksch_w1 parentsetcurfew_w1 W8GROW W9GROW W8INCOMERANK W9INCOMERANK W8W9incrankchange W8W9incchange W8W9incchangerank
	
	* Save for SA in R
	save "$write\activity_merged_all.dta", replace

