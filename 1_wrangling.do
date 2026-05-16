
// ==============================================================================
// Paper:     Employment Stability and Social Origin: Cumulative Advantages in Young Adults' Homeownership and Financial Asset Accumulation
// Author:    Vincent Jerald Ramos and Ann Berrington
// Date:      May 2026
// Purpose:   Replication Codes for Figures and Tables in Text
// File:	  1_wrangling
// Describe:  create main/master file including new variables
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

	
* Step 1. Start with the W9 file and extract relevant variables

* Weights: Extract weights and understand attrition
	use "$source01/ns9_2022_longitudinal_file.dta", clear
	keep NSID SAMPPSU SAMPSTRATUM DESIGNWEIGHT MAINBOOST W9OUTCOME W9FINWTALLA W9FINWTLONGA W9FINWTALLB W9FINWTLONGB W8OUTCOME W8FINWT
	save "$write\weightsw9", replace
		
	* W9 file
	use "$source01/ns9_2022_main_interview.dta", clear
	keep NSID W9OUTCOME W9FULLINT W9MODE W9INTMTH W9INTYEAR W9DSEX W9BDATM W9BDATY W9NATIONRES W9RESIDENC2 W9HMS W9MORECH W9MCHMANY W9DEPCHILD W9DBICHILD 	W9HINT2 W9MOVINM W9MOVINY W9ACCOM W9DNUMROOMS W9TENURE W9RENTFROM W9WHOTEN W9BUYM W9BUYY W9PERCOWN W9FRSTOWN W9EVROWN W9AGEFRSTOWN W9RENT W9REPE W9REPE_FINAL W9RENT_DV W9WHYPAR W9PARMA W9PARSA W9PARSACHK W9EVRHOML W9NUMHOML W9FRSHOM W9PERHOMM W9PERHOMY W9TOPERHOM FF_DACTIVITY8 W9ECONLAST W9CJCONT W9ACTIVITYP W9EVERCOL W9EVEREMP W9STARTMO W9STARTYR W9CURACT W9CURACTST W9AGE25JOB2020 W9AGE25JOB2010 W9JDCHK W9MAKCHK W9CURACTIVITY2 W9CURPAIDWK W9CURSTUDYHRS W9CURUSUAL W9CURSICKDIS W9CLLOTHACT W9DACTIVITY5 W9STARTMOCUR W9STARTYRCUR W9ECONACT2 W9CJTITLE W9CJCHECK W9CURRJOB2020 W9CURRJOB2010 W9NSSEC W9NSSEC8 W9NSSEC5 W9DCURRJOBSIC2007 W9CJFICHK W9CJORG W9CJSUP W9CJEMPS W9CJSEEMPS1 W9CJSEEMPS2 W9CJSEEMPS3 W9CJSEEMPS4 W9CJSEEMPS W9CJSENEMP W9CJQUAL W9CJSEHRS W9OTIMEANY W9CHOURS1 W9HIWHCHK W9LOWHCHK W9FTWHCHK W9PTWHCHK W9CHOURS3 W9CHOURS4 W9CHOURS5 W9CHOURSTOTAL W9VHIWHCHK W9SHIFTWK W9SHIFTWKFRQA W9SHIFTWKFRQB W9ZEROWK W9PERMEMP W9NPERMEMP01 W9NPERMEMP02 W9NPERMEMP03 W9NPERMEMP04 W9NPERMEMP05 W9NPERMEMP06 W9NPERMEMP07 W9NPERMEMP08 W9NPERMEMP09 W9JOBSATIS W9LOSEJOB W9JOBATTA W9JOBATTB W9JOBATTC W9WKSTRESS W9REIN W9FIRSTJOB2020 W9FIRSTJOB2010 W9JDOPCHK W9FIRMDOPCHK W9QUALHELP W9PECONACT2 W9PECONACT3 W9PARTSTUDY W9PECONACT4 W9PECONACT5 W9PARTNERJOB2020 W9PARTNERJOB2010 W9PJDCHK W9PFIRMCHK W9CJSUPP W9CJSEEMPSP W9CJSENEMP2 W9ECSHOCKDV01 W9ECSHOCKDV02 W9ECSHOCKDV03 W9ECSHOCKDV04 W9ECSHOCKDV05 W9ECSCURR01 W9ECSCURR02 W9ECSCURR03 W9ECSCURR04 W9ECSCURR05 W9PAYS W9GROA W9GROP2 W9GROP3 W9GROW W9GROWCK W9QMAFI W9HHMD1 W9FINANCIALMAND W9IASI01 W9IASI02 W9IASI03 W9IASI04 W9IASI05 W9IASI06 W9IASI07 W9IASI08 W9IASI09 W9IASI10 W9IASI11 W9SAVTOT W9SAVTOA_01 W9SAVTOA_02 W9SAVTOA_03 W9SAVTOA_04 W9ACQU0A W9ACQU0B W9ACQU0C W9ACQU0D W9ACQU0E W9ACQU0F W9ACQU0G W9ACQU0H W9ACQU0I W9ACQU0J W9ACQU0K W9ACQU0L W9ACQU0M W9ACQU0N W9ACQU0O W9ACQU0P W9ACQU0Q W9ACQU0R W9ACQU0S W9ACQU0T W9ACQU0U W9ACQU0V W9ACQUCHK W9QHONS W9CLASS W9GRADY W9DSUBDEG W9FIRSC W9SJOF W9SIJF W9CUSTUCHK01 W9CURUGHONS W9FUNDSTUD0A W9FUNDSTUD0B W9FUNDSTUD0C W9FUNDSTUD0D W9FUNDSTUD0E W9FUNDSTUD0F W9FUNDSTUD0G W9FUNDSTUD0H W9FUNDSTUD0I W9FUNDSTUD0J W9FUNDSTUD0K W9FUNDSTUD0L W9FUNDSTUD0M W9HTMETRES W9HTCMS W9HEIGHT W9WEIGHT W9EXERCISEH W9HSLEEP W9HSLEEPCHK W9FIZZY W9ETHNICCAT W9ETHNWH W9ETHNMX W9ETHNAS W9ETHNBL W9ETHNOTH W9ETHNIC W9ETHIMP W9NIEU W9REBO W9REBOUK W9REWN W9MUBO W9MUBOUK W9DABO W9DABOUK W9ETHNICPCAT W9LISTEN W9FRDCOU W9SOCPROVA W9SOCPROVB W9SOCPROVC W9ATTAB W9ATTWWO W9ATTENS W9ATTENPO W9LEISUREBA W9LEISUREBB W9POL1 W9SOCPARTB W9VOTE W9VWHO W9VOEU W9VEUW W9FINLIT1 W9FINLIT2 W9FINLIT3 W9MIG W9ECOMIG W9LIFESAT W9WORTH W9HAPPY W9ANXIOUS W9OSATIS W9SORI W9SEXEVER W9SEXAGE W9SEXAGECK W9SEXNUMPART W9SEXNUMPARTCK W9MENAR W9EVERPREG W9PREGMANY W9CHPLAN W9NCHPLAN W9RELSAT1 W9REASONCH0A W9REASONCH0B W9REASONCH0C W9REASONCH0D W9REASONCH0E W9REASONCH0F W9REASONCH0G W9REASONCH0H W9REASONCH0I W9REASONCH0J W9REASONCH0K W9REASONCH0L W9REASONCH0M W9REASONCH0N W9REASONCH0O W9REASONCH0P W9REASONCH0Q W9REASONCH0R W9REASONCH0S W9REASONCH0T W9REASONCH0U W9DVIOL W9WDISCR0A W9WDISCR0B W9WDISCR0C W9WDISCR0D W9WDISCR0E W9WDISCR0F W9WDISCR0G W9CHSCH W9CHHLTH W9CHACE0A W9CHACE0C W9CHACE0D W9CHACE0E W9CHACE0F W9CHACE0G W9CHACE0H W9CHACE0I W9CHACE0J W9CHACEAGE0A W9CHACEAGE0B W9CHACEAGE0C W9CHACEAGE0D W9CHACEAGE0E W9CHACEAGE0F W9CHACEAGE0H W9CHACEAGE0J W9CHACEE W9CHACEAGEM W9CHACEAGEF W9CHACETIME0A W9CHACETIME0B W9CHACETIME0C W9CHACETIME0D W9DSUBDEG W9PURCHPR W9FUND*
	save "$write\maininterview", replace
	
	* Create "master" data.
	
		** Merge derived variables (master) with weights and main interview variables
		use "$source01/ns9_2022_derived_variables.dta", clear
		merge 1:1 NSID using "$write\weightsw9", keep(match) nogenerate
		merge 1:1 NSID using "$write\maininterview", nogenerate keep(match)
		merge 1:1 NSID using "$source01\lsype_history_file_wave_one_and_wave_two_june_2008", keep(match master) nogenerate 	//113 missing
		merge 1:1 NSID using "$source01\wave_five_lsype_family_background_2020", keep(match master) nogenerate	//1335 missing
		merge 1:1 NSID using "$source01\wave_four_lsype_family_background_2020", keep(match master) nogenerate	// 956 missing
		merge 1:1 NSID using "$source01\wave_two_lsype_young_person_2020.dta", keep(match master) nogenerate  // 575 missing 
		merge 1:1 NSID using "$source01\wave_one_lsype_parental_attitudes_file_16_05_08.dta", keep(match master) nogenerate 	// 113 missing 
		merge 1:1 NSID using "$source01\wave_one_lsype_young_person_2020.dta", keep(match master) nogenerate  // 113 missing 
		merge 1:1 NSID using "$source01\wave_one_lsype_family_background_2020.dta", keep(match master) nogenerate  // 113 missing  
		merge 1:1 NSID using "$source01\ns8_2015_derived.dta", keep(match master) nogenerate  // 1703 not matched
		merge 1:1 NSID using "$source01\ns8_2015_main_interview.dta", keepusing(W8NETW W8GROW) keep(match master) nogenerate  // 1703 not matched

	* Save "master" data.
	save "$write\master", replace		

*Step 2. Clean dataset
	
	* Use "master" data
	use "$write\master", clear	
	
		/* Merge parental background information from earlier waves and experiences of family complexity from current waves
			- 2.1. Time variables
			- 2.2. Current Info
			- 2.3. Parental/Family BG/info
			- 2.4. Global the variable groups
			- 2.5. save
		*/
			
		* 2.1. Generate time variables 
		
		** dob: date of birth of person
		g dob=ym(W9BDATY, W9BDATM)  
		label var dob "Date of birth"
		format dob %tm

		** doi: date of interview w9
		g doiw9=ym(W9INTYEAR,W9INTMTH)
		format doiw9 %tm
		label var doiw9 "Date of interview w9"
		ta doiw9
			
		** date of activity current (W9ECONACT2)
		g doaC =ym(W9STARTYRCUR,W9STARTMOCUR)
		format doaC %tm
		label var doaC "Date of current activity (start)"
		ta doaC
		
		** date moved into address dom(date moved into address) current
		g domC =ym(W9MOVINY,W9MOVINM)
		format domC %tm
		label var domC "Date moved into current address"
		ta domC
		
		** actual age at interview
		g agew9yrmth=doiw9-dob
		g agew9=round(agew9yrmth/12)
		drop agew9yrmth
		ta agew9
		
		** date property (living arrangement) bought
		g dopC =ym(W9BUYY,W9BUYM)
		format dopC %tm
		label var dopC "Date bought property"
		ta dopC
	
		*2.2 Present Info:  sex/gender, age, educ, ethnicity, migback, geographic activity, etc..
		
		** Parental coresidence
		g parentrescat = 1 if W9WHYPAR>0		// gave a reason for living currently with parents
		replace parentrescat = 2 if (W9PARMA >=0 & W9PARMA <21) & W9WHYPAR <=0 // early leavers before 21
		replace parentrescat = 3 if W9PARMA >=21 & W9WHYPAR <=0	// LATE LEAVERS at or after 21
		lab def parentrescat 1 "Current Coresident" 2 "Left before 21" 3 "Left at/after 21"
		lab val parentrescat parentrescat
		lab var parentrescat "Parental Residence Indicator"
		
		g parentres = 1 if W9WHYPAR>0
		replace parentres = 0 if W9WHYPAR==-1 
		replace parentres = . if W9WHYPAR < -1
		lab def parentres 1 "Current coresident" 0 "Not coresident"
		lab val parentres parentres 
		lab var parentres "Parental Coresidence Dummy"
		
		
		** Region, Financial Literacy: use variable as is
		recode W9DRGN W9DIMDD (-8=.)
		recode W9DFINLIT3 (-1=.)
		
		** Living arrangement: tenure
		g residence = 1 	if inlist(W9DTENURE, 1, 2, 3) 	// home-owner (incl. own, mortgage, or shared equity)
		replace residence = 2 if W9DTENURE==4 		// renter
		replace residence = 3 if W9DTENURE==5 | W9DTENURE==6  // rent-free (living with parents, includes 2 squatting)
		replace residence =4 if W9DTENURE==7 // other
		label define residence 1 "Owned" 2 "Rented" 3 "Rent-free" 4 "Other"
		label values residence residence
		lab var residence "Housing tenure"
		
		** Owned or ever-owned property
		g propertyown = 1 	if W9FRSTOWN==1 | W9EVROWN==1 	// own current property or ever owned a property
		replace propertyown = 0 if inlist(W9FRSTOWN, -1, 2) | W9EVROWN==2
		lab def propertyown 0"Never-owned" 1"Ever-owned"
		lab val propertyown propertyown
		lab var propertyown "Property owner"
		ta propertyown
		
		** Age at first property ownership: use W9AGEFRSTOWN as is
		
		** Supported home purchase
		g propertyown_psupport1 = 1 if W9FUND09==1 | W9FUND06 ==1									// inheritance, private loan from parents
		replace propertyown_psupport1=0 if propertyown_psupport1!=1 & (W9FUND09==2 | W9FUND06 ==2)
		g propertyown_psupport2 = 1 if W9FUND09==1 | W9FUND06 ==1 | W9FUND07==1 | W9FUND08==1 		// + other private loan, gift
		replace propertyown_psupport2 = 0 if propertyown_psupport2!=1 & (W9FUND09==2 | W9FUND06 ==2 | W9FUND07==2 | W9FUND08==2) 	
		lab def propertyown_psupport 1 "Yes" 0 "No"
		lab val propertyown_psupport1 propertyown_psupport2 propertyown_psupport
		lab var propertyown_psupport1 "Inheritance or Parental Loan"
		lab var propertyown_psupport2 "Inheritance, Parental Loan, Other Private Loan or Gift"
	
		** Any savings/investments (W9IASI01 to )
		g finassets = 1 if W9IASI01 == 1 | W9IASI02 == 1 | W9IASI03 == 1 | W9IASI04 == 1 | W9IASI05 == 1 | W9IASI06 == 1 | W9IASI07 == 1
		replace finassets = 0 if W9IASI08 ==1 	// don't know, refused, no answer = .
		lab def finassets 0"No" 1"Yes"
		lab val finassets finassets
		lab var finassets "Any financial assets"
		ta finassets
		
		** Value of savings and investments binned based on brackets selected in Next Steps
		g finassets_val = 1 if W9SAVTOT>=0 & W9SAVTOT<=500
		replace finassets_val=2 if W9SAVTOT>=501 & W9SAVTOT<=2000
		replace finassets_val=3 if W9SAVTOT>=2001 & W9SAVTOT<=8000
		replace finassets_val=4 if W9SAVTOT>=8001 & W9SAVTOT<=30000
		replace finassets_val=5 if W9SAVTOT>=30001
		replace finassets_val=1 if W9SAVTOA_01==2 | W9SAVTOA_01==3
		replace finassets_val=2 if W9SAVTOA_02==2 | W9SAVTOA_02==3
		replace finassets_val=3 if W9SAVTOA_03==2 | W9SAVTOA_03==3
		replace finassets_val=4 if W9SAVTOA_04==2 | W9SAVTOA_04==3
		replace finassets_val=5 if W9SAVTOA_04==1
		lab def finassets_val 1 "500 and below" 2 "501 to 2000" 3 "2001 to 8000" 4 "8000 to 30000" 5 "30000 and above"
		lab val finassets_val finassets_val
		lab var finassets_val "Any financial assets - total value"
		ta finassets_val
	
		
		  * Financial Assets
		  gen finassets_val_hi = finassets_val
		  recode finassets_val_hi (4 5 = 1) (1 2 3 = 0)
		  lab def finassets_val_hi 0"No" 1"Yes"
		  lab val finassets_val_hi finassets_val_hi
		  lab var finassets_val_hi "Financial assets above median?"
		  ta finassets_val_hi
	  
		* Generate a single variable for financial assets
		   * Financial Assets COMBO
		  gen finassets_combo = .
		  replace finassets_combo = 1 if finassets == 0
		  replace finassets_combo = 2 if finassets == 1 & finassets_val_hi==0
		  replace finassets_combo = 3 if finassets == 1 & finassets_val_hi==1
		  lab def finassets_combo 1"None" 2 "Below Median" 3 "Above Median"
		  lab val finassets_combo finassets_combo
		  lab var finassets_combo "Financial assets"
		  ta finassets_combo
		  
		  
		* Generate a single variable combining assets indicator
		  gen allassets_combo = .
		  replace allassets_combo = 1 if propertyown == 1 & finassets_combo == 3
		  replace allassets_combo = 2 if propertyown == 1 & (finassets_combo == 1 | finassets_combo == 2)
		  replace allassets_combo = 3 if propertyown == 0 & finassets_combo == 3
		  replace allassets_combo = 4 if propertyown == 0 & (finassets_combo == 1 | finassets_combo == 2)
		  lab def allassets_combo 1"Prop-High Fin" 2 "Prop-Low/No Fin" 3 "No Prop-High Fin" 4 "No Prop-Low/No Fin"
		  lab val allassets_combo allassets_combo
		  lab var allassets_combo "Combined assets indicator"
		  ta allassets_combo
			
		* Income variables
		count if !missing(W8GROW) & !missing(W9GROW)
		misstable patterns W8GROW W9GROW

		xtile W8INCOMERANK = W8GROW if W8GROW>=0, nq(100)
		xtile W9INCOMERANK = W9GROW if W9GROW>=0, nq(100)

		/* Income Rank Change between 25 and 32
		Interpretation: Positive → upward mobility in the income distribution
		Negative → downward mobility*/
		gen W8W9incrankchange = W9INCOMERANK - W8INCOMERANK if !missing(W8INCOMERANK, W9INCOMERANK) 

		/*Income Change between 25 and 32
		*/
		gen W8W9incchange = 100 * (W9GROW - W8GROW) / W8GROW if !missing(W8GROW, W9GROW) & W8GROW > 0
		xtile W8W9incchangerank = W8W9incchange, nq(100)
		
		* Optional Checks
		summ W8INCOMERANK W9INCOMERANK W8W9incrankchange W8W9incchange
		scatter W9INCOMERANK W8INCOMERANK if !missing(W8INCOMERANK, W9INCOMERANK)
		
		lab var W8W9incrankchange "Change in Income Rank"
		lab var W8W9incchange "Change in Income in %"
		
		** Sex
		g sex=1 		if W9DSEX==2	//female
		replace sex=0 	if W9DSEX==1	//male
		label define sex 0"Male" 1"Female", replace
		label values sex sex
		label var sex "Sex- Female"
		
		** Migration background
		g migback=1 		if W9REBO==2
		g age_arrived = W9REWN-W9BDATY if W9REBO==2 & W9REWN>=0 & W9BDATY >=0
		replace migback=0 	if W9REBO==2 & age_arrived<=15
		replace migback=0 	if migback!=1				// anyone who did not say they're not born in the UK + arrived after 15 = native
		lab def migback 0 "Native" 1 "Migrant"
		lab val migback migback 
		lab var migback "Migration background"
		ta migback
		
		
		** Ethnicity (broad)
		g ethnicity=1 			if W9DETHN6==1
		replace ethnicity=0 	if W9DETHN6>1 
		label var ethnicity "Ethnicity- White"
		label define ethnicity 1"White" 0"Non-white"
		label values ethnicity ethnicity
		
		** Ethnicity category
		g ethnicitycat=W9DETHN6
		recode ethnicitycat (6=2) (-8=.)
		lab def ethnicitycat 1 "White" 2 "Mixed and Others" 3 "Indian" 4 "Pakistan and Bangladeshi" 5 "Black or Black British"
		lab val ethnicitycat ethnicitycat
		
		
		** Degree holder at 25
		g degree25 = 1 if W8DDEGP==1 // first degree or higher
		replace degree25=0 if W8DDEGP==2 
		lab var degree25 "Degree Holder at 25"
		lab def degree25 1"Degree Holder" 0"Non-degree holder"
		lab val degree25 degree25
		
		** Degree holder
		g degree = 1 	if W9DDDEGP==1 		// first degree or higher
		replace degree = 0	if W9DDDEGP==2 
		label var degree "Degree Holder (First degree or higher)"
		label define degree 1"Degree Holder" 0"Non-degree holder"
		label values degree degree
		
		** Higher ed or higher
		g qual_higher = 1 	if W9DANVQH==4 | W9DANVQH==5	// undergrad or higher
		replace qual_higher = 0	if inlist(W9DANVQH, 1, 2, 3, 95, 96) 		// -1 -2 -3 are all "."
		label var qual_higher "Highest Qual (academic)"
		label define qual_higher 1"Higher education" 0"Non-higher education" 
		label values qual_higher qual_higher
		
		** Degree by RG uni
		g degree_rg = 1 	if W9DRUSSELL==1 		// degree from russell group
		replace degree_rg = 0	if W9DRUSSELL==2 
		label var degree_rg "Russell Group Degree"
		label define degree_rg 1"Russell Group Degree" 0"Other HE degree"
		label values degree_rg degree_rg
	
		** Degree subject
	
			*** Generate a string variable `subject_code` from value labels of `W9DSUBDEG`
			decode W9DSUBDEG, gen(subject_code) 

			*** Generate the subject group variable
			gen subject_group = .

			*** Define labels for each group
			label define subject_group_lbl ///
				1 "Medicine & Dentistry" ///
				2 "Subjects Allied to Medicine" ///
				3 "Biological Sciences" ///
				4 "Veterinary Science" ///
				5 "Agriculture & Related Subjects" ///
				6 "Physical Sciences" ///
				7 "Mathematical Sciences" ///
				8 "Computer Science" ///
				9 "Engineering & Technology" ///
				10 "Architecture, Building & Planning" ///
				11 "Social Studies" ///
				12 "Law" ///
				13 "Business & Administrative Studies" ///
				14 "Mass Communications & Documentation" ///
				15 "Languages" ///
				16 "Historical & Philosophical Studies" ///
				17 "Creative Arts & Design" ///
				18 "Education" ///
				19 "Combined & Interdisciplinary Studies"

				label values subject_group subject_group_lbl

			*** Assign numeric codes based on JACS3 two-digit codes
			replace subject_group = 1 if substr(subject_code, 1, 1) == "A"
			replace subject_group = 2 if substr(subject_code, 1, 1) == "B"
			replace subject_group = 3 if substr(subject_code, 1, 1) == "C"
			replace subject_group = 4 if inlist(subject_code, "D1", "D2")
			replace subject_group = 5 if substr(subject_code, 1, 1) == "D" & subject_group!=4
			replace subject_group = 6 if substr(subject_code, 1, 1) == "F"
			replace subject_group = 7 if substr(subject_code, 1, 1) == "G"
			replace subject_group = 8 if substr(subject_code, 1, 1) == "I"
			replace subject_group = 9 if substr(subject_code, 1, 1) == "H" | substr(subject_code, 1, 1) == "J"
			replace subject_group = 10 if substr(subject_code, 1, 1) == "K"
			replace subject_group = 11 if substr(subject_code, 1, 1) == "L"
			replace subject_group = 12 if substr(subject_code, 1, 1) == "M"
			replace subject_group = 13 if substr(subject_code, 1, 1) == "N"
			replace subject_group = 14 if substr(subject_code, 1, 1) == "P"
			replace subject_group = 15 if substr(subject_code, 1, 1) == "Q" | substr(subject_code, 1, 1) == "R" | substr(subject_code, 1, 1) == "T"
			replace subject_group = 16 if substr(subject_code, 1, 1) == "V"
			replace subject_group = 17 if substr(subject_code, 1, 1) == "W"
			replace subject_group = 18 if substr(subject_code, 1, 1) == "X"
			replace subject_group = 19 if substr(subject_code, 1, 1) == "Y"

			*** Check for unclassified codes
			*br subject_group if subject_group==.
			
			***tabulate
			tab subject_group

		*2.3 Parental and family background
		
		***** WAVE 4
		** Family composition at wave 4
		g fam_cmp=0 if w4famtyp==1 | w4famtyp==2
		replace fam_cmp=1 if w4famtyp>=3 & w4famtyp<=5
		label var fam_cmp "Lone parent/no parent family"
		ta fam_cmp, m
		
		** qualification in the family by main parent
		g mp_qualw4=1 		if w4hiqualgMP==1
		replace mp_qualw4=2 if w4hiqualgMP==2
		replace mp_qualw4=3	if w4hiqualgMP>=3 & w4hiqualgMP<=4
		replace mp_qualw4=4	if w4hiqualgMP>=5 & w4hiqualgMP<=6
		replace mp_qualw4=5	if w4hiqualgMP==7 | w4hiqualgMP==-996  //putting those w/o parents under "None" a
		replace mp_qualw4=.	if w4hiqualgMP<0 & w4hiqualgMP>-996	 // not interviewed or insufficient information
		lab def mp_qualw4 1 "Degree or equivalent" 2 "Higher education below degree" 3 "GCE/GCSEs" 4 "Level 1/Other" 5 "None"
		label values mp_qualw4 mp_qualw4
		label var mp_qualw4 "Highest qualification held by main parent"	
			ta mp_qualw4, m //1087 missing
			
		** qualification in the family by secondary parent
		g sp_qualw4=1 		if w4hiqualgSP==1
		replace sp_qualw4=2 if w4hiqualgSP==2
		replace sp_qualw4=3	if w4hiqualgSP>=3 & w4hiqualgSP<=4
		replace sp_qualw4=4	if w4hiqualgSP>=5 & w4hiqualgSP<=6
		replace sp_qualw4=5	if w4hiqualgSP==7 | w4hiqualgSP==-996  //putting those w/o parents under "None" a
		replace sp_qualw4=.	if w4hiqualgSP<0 & w4hiqualgSP>-996	 // not interviewed or insufficient information
		lab def sp_qualw4 1 "Degree or equivalent" 2 "Higher education below degree" 3 "GCE/GCSEs" 4 "Level 1/Other" 5 "None"
		label values sp_qualw4 sp_qualw4
		label var sp_qualw4 "Highest qualification held by secondary parent"	
			ta sp_qualw4, m //2788
	
		** qualification in the family  (highest by any parent)
		g fam_qualw4=1 		if w4hiqualgfam==1
		replace fam_qualw4=2 if w4hiqualgfam==2
		replace fam_qualw4=3	if w4hiqualgfam>=3 & w4hiqualgfam<=4
		replace fam_qualw4=4	if w4hiqualgfam>=5 & w4hiqualgfam<=6
		replace fam_qualw4=5	if w4hiqualgfam==7 | w4hiqualgfam==-996  //putting those w/o parents under "None" a
		replace fam_qualw4=.	if w4hiqualgfam<0 & w4hiqualgfam>-996	 // not interviewed or insufficient information
		lab def fam_qualw4 1 "Degree or equivalent" 2 "Higher education below degree" 3 "GCE/GCSEs" 4 "Level 1/Other" 5 "None"
		label values fam_qualw4 fam_qualw4
		label var fam_qualw4 "Highest qualification held in family"	
			ta fam_qualw4, m //1028
	
		** Main parent's highest qualification
		g mparent_educ=1 		if mp_qualw4>=1 & mp_qualw4<=2
		replace mparent_educ=0 	if mp_qualw4>=3 & mp_qualw4<=5
		label var mparent_educ "Main parent has higher education"
		ta mp_qualw4, gen(mpqual)
				
		** Number of siblings (including non-resident)
		g numsib=w4sibs2
		recode numsib (-94=.)
		ta numsib, m
		label var numsib "Number of siblings"

		** Whether mp has long-tstanding illness, disability, or infirmity
		g mp_disab = 1 if W4Hea2MP == 1
		replace mp_disab = 0 if W4Hea2MP ==2
		label def mp_disab 0"No" 1"Yes"
		lab val mp_disab mp_disab
		label var mp_disab "MP Long-standing illness/disability (W4)"
		ta mp_disab, m
		
		** Family class at w4 (HRP, not main parent)
		gen pclass=.
		replace pclass=1 if w4cnssecfam>=1 & w4cnssecfam<=2		// managers and professional occs
		replace pclass=2 if w4cnssecfam>=3 & w4cnssecfam<=4		// intermediate + own account + emp in small orgs
		replace pclass=3 if w4cnssecfam>=5 & w4cnssecfam<=7 	// inc. semi-routine and routine 
		replace pclass=4 if w4cnssecfam==8
		replace pclass=. if w4cnssecfam<0 							// all missing, insufficient, NA, etc. = .
		lab var pclass "Parental class"
		lab def pclass 1 "Service" 2 "Intermediate" 3 "Routine" 4 "Unemployed"
		lab val pclass pclass
		tab pclass,m
		
		  * Parental residence at 17
		  g parentalres = W4Hous12HH
		  recode parentalres (1 2 3 = 1) (4 5 6 = 2) (7 8 = 2)
		  replace parentalres = W5Hous12HH if W4Hous12HH==.
		  recode parentalres (-999 -997 -92 -91 -1 = .) 
		  lab def parentalres 1 "Owner" 2 "Renter and Other Arrangements"
		  lab val parentalres parentalres 
		  lab var parentalres "Housing Tenure at 17"
		 
		
		***** WAVE 1
		** Family composition at wave 1
		g fam_cmpw1 = W1famtyp2
		recode fam_cmpw1 (-999=.) 
		label var fam_cmpw1 "Single parent household at wave 1"
		lab def fam_cmpw1 1 "Yes" 0 "No"
		lab val fam_cmpw1 fam_cmpw1
		ta fam_cmpw1, m
		
		// Fix parental class at W1
	
		** Family class at w1 (HRP, not main parent)
		gen pclassw1=.
		replace pclassw1=1 if W1nssecfam>=1 & W1nssecfam<=2		// managers and professional occs
		replace pclassw1=2 if W1nssecfam>=3 & W1nssecfam<=4		// intermediate + own account + emp in small orgs
		replace pclassw1=3 if W1nssecfam>=5 & W1nssecfam<=7 	// inc. semi-routine and routine 
		replace pclassw1=4 if W1nssecfam==8
		replace pclassw1=. if W1nssecfam<0 							// all missing, insufficient, NA, etc. = .
		lab var pclassw1 "Parental class"
		lab def pclassw1 1 "Service" 2 "Intermediate" 3 "Routine" 4 "Unemployed"
		lab val pclassw1 pclassw1
		tab pclassw1,m		// 834 missing 
	
			** replace pclassw1 into pclass at w4 for missing 
			replace pclassw1 = pclass if pclassw1==.
			ta pclassw1
			
		** Highest qual in the family at Wave 1
		recode W1hiqualgMP W1hiqualgSP  (-99 -98 -92 -91 = .)
		gen W1highqualgfam = min(W1hiqualgMP, W1hiqualgSP)
		lab var W1highqualgfam "DV: Highest qual in the family whether MP/SP"
		label values W1highqualgfam `: value label W1hiqualgMP'
	
		g fam_qualw1=1 		if W1highqualgfam==1
		replace fam_qualw1=2 if W1highqualgfam==2
		replace fam_qualw1=3	if W1highqualgfam>=3 & W1highqualgfam<=4
		replace fam_qualw1=4	if W1highqualgfam>=5 & W1highqualgfam<=6
		replace fam_qualw1=5	if W1highqualgfam==7
		lab def fam_qualw1 1 "Degree or equivalent" 2 "Higher education below degree" 3 "GCE/GCSEs" 4 "Level 1/Other" 5 "None"
		label values fam_qualw1 fam_qualw1
		label var fam_qualw1 "Highest qualification held in family at wave 1"	
			ta fam_qualw1, m 
		
		* Parental residence at w1
		  g parentalresw1 = W1hous12HH
		  recode parentalresw1 (1 2 3 = 1) (4 5 6 = 2) (7 8 = 2)
		  recode parentalresw1 (-999 -997 -92 -91 -1 = .) 
		  lab def parentalresw1 1 "Owner" 2 "Renter and Other Arrangements"
		  lab val parentalresw1 parentalresw1
		  lab var parentalresw1 "Housing Tenure at wave 1"
				
				** replace parentalresw1 into parentalres at w4 for missing 
				replace parentalresw1 = parentalres if W1hous12HH==.		// 113 MISSING PARENTAL RESIDENCE AT W1, USE W4 = 108 OBTAINED

	
		* Household Income at w1 W1inc1est
		g hhincometert_w1 = 1 if W1inc1est >= 0 & W1inc1est <=21
		replace hhincometert_w1 = 2 if W1inc1est >= 22 & W1inc1est <=30
		replace hhincometert_w1 = 3 if W1inc1est >= 31 & W1inc1est <=33
		replace hhincometert_w1 = 4 if W1inc1est <0 
		lab def hhincometert_w1 1 "Lowest Tertile" 2 "Middle Tertile" 3 "Highest Tertile" 4 "Don't Know/Refused", replace
		lab val hhincometert_w1 hhincometert_w1
		lab var hhincometert_w1 "Household Income Total (Gross) Tertile at wave 1"
		
		** Self-perception of performance at wave1
		g perceived_acadperf = W1yys22YP
		recode perceived_acadperf (-99 -97 -96 -1 = .) (1=1) (2=2) (3 4 5=3)
		lab def perceived_acadperf 1 "Very good" 2 "Above average" 3 "Average or below"
		lab val perceived_acadperf perceived_acadperf
		lab var perceived_acadperf "How good YP thinks YP is at schoolwork w1"
		
		** Likelihood of going uni at wave1
		g likelihood_uniw1 = W1heposs9YP
		replace likelihood_uniw1 = W2heposs9YP if W1heposs9YP==-99
		recode likelihood_uniw1 (-99 -1 = .)
		lab def likelihood_uniw1 1 "Very likely" 2 "Fairly likely" 3 "Not very likely" 4 "Not at all"
		lab val likelihood_uniw1 likelihood_uniw1
		lab var likelihood_uniw1 "Likelihood of applying to uni at w1 or w2"
		
		
		** Family meal
		g familymealw1 = W1fammealMP
		recode familymealw1 (-99 -91 -1 = .)
		lab def familymealw1 1 "Every night" 2 "Most nights" 3 "1-2x a week" 4 "Not at all"
		lab val familymealw1 familymealw1
		lab var familymealw1 "Family meals in the last 7 days - freq"
			
		** Subjective Income Security
		g incomesecw1 = W1managhhMP
		recode incomesecw1 (-99 -92 -91 -1 = .)
		lab def incomesecw1 1 "Quite well" 2 "Getting by" 3 "Difficulties"
		lab val incomesecw1 incomesecw1
		lab var incomesecw1 "Subjective Income Security of the HH"
		
		** How often parents talk about school day
		g parenttalksch_w1 = W1talkschYP
		recode parenttalksch_w1 (-99 -97 -96 -92 -91 -1 = .)
		lab def parenttalksch_w1 1 "Never" 2 "Sometimes" 3 "Often"
		lab val parenttalksch_w1 parenttalksch_w1
		lab var parenttalksch_w1 "Parents talk about schools" 
		
		** Whether parents set curfew
		g parentsetcurfew_w1 = W1limitsnYP
		recode parentsetcurfew_w1 (-99 -97 -96 -92 -91 -1 = .)
		lab def parentsetcurfew_w1 1 "Never" 2 "Sometimes" 3 "Often" 4 "Not allowed to go out"
		lab val parentsetcurfew_w1 parentsetcurfew_w1
		lab var parentsetcurfew_w1 "Parents set curfew on school nights" 
		
		**2.4. Set variable groups

		/* 	GLOBAL THE VARIABLES (FOR LATER) 
		global bgcontrols_cnt	// insert varlist
		global bgcontrols_bin	// insert varlist
		global controls_sub		// insert varlist
		global priorcontrols	// insert varlist
		*/
		
		
		**Step 2.5. Save master dataset
		
	keep NSID W9FULLINT dob doiw9 doaC domC agew9 dopC parentrescat parentres residence propertyown propertyown_psupport1 propertyown_psupport2 finassets finassets_val finassets_val_hi finassets_combo allassets_combo sex migback ethnicity ethnicitycat perceived_acadperf likelihood_uniw1 degree25 degree qual_higher degree_rg subject_code subject_group fam_cmp mp_qualw4 sp_qualw4 fam_qualw4 mparent_educ mpqual1 mpqual2 mpqual3 mpqual4 mpqual5 numsib mp_disab pclass parentalres fam_cmpw1 pclassw1 W1highqualgfam fam_qualw1 parentalresw1 hhincometert_w1 familymealw1 incomesecw1 parenttalksch_w1 parentsetcurfew_w1 W8GROW W9GROW W8INCOMERANK W9INCOMERANK W8W9incrankchange W8W9incchange W8W9incchangerank W9DRGN W9DIMDD W9DAGEINT W9DHSIZE W9DCHNO W9DCHOWNNO W9DCHPARNO W9DCHNO4 W9DCHNO11 W9DFATHER W9DMOTHER W9DMARSTAT W9DCOHAB W9DPARTP W9DTIMAD W9DTENURE W9DRENTFROM W9DWHOTEN W9DACTIVITYC W9DWRK W9DEMPSZ W9DWRKP W9DDACTIVITYP W9DWRKCP W9DINCB W9DANVQH W9DVNVQH W9DDDEGP W9EVEREMP W9CJSEEMPS W9DFINLIT3  SAMPPSU SAMPSTRATUM DESIGNWEIGHT MAINBOOST W9OUTCOME W9FINWTALLA W9FINWTLONGA W9FINWTALLB W9FINWTLONGB W8OUTCOME W8FINWT W5finwt_cross W4Weight_MAIN W4Boost W4Weight_MAIN_BOOST W2FinWt W1FinWt Designweight 
		
		save "$write\master", replace		

		
		**Step 2.6. Extract weights dataset for all respondents 
		use "$source01/ns9_2022_longitudinal_file.dta", clear
		save "$write\weightslongitudinal", replace
		
		* Attrition notes:

			* 7279 individuals in w9 tab 
				tab W9OUTCOME
			* Of them, 5576 were in w8, 7166 in w1, 6704 in w2
				tab W8OUTCOME if W9OUTCOME==1
				tab W1OUTCOME if W9OUTCOME==1
				tab W2OUTCOME if W9OUTCOME==1

			* Need to impute
		