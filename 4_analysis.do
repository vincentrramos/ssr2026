// ==============================================================================
// Paper:     Employment Stability and Social Origin: Cumulative Advantages in Young Adults' Homeownership and Financial Asset Accumulation
// Author:    Vincent Jerald Ramos and Ann Berrington
// Date:      May 2026
// Purpose:   Replication Codes for Figures and Tables in Text
// File:	  4_analysis
// Describe:  tables and figures in the main text. select appendix results are commented out using "/* [code] */". Remove to run if interested.
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
global source04 "$PROJDIR/_codes"

* Output folders
global write    "$PROJDIR/output/tables"
global GRAPH      "$PROJDIR/output/figures"

* Create output directories if they don't exist
capture mkdir "$PROJDIR/output"
capture mkdir "$write"
capture mkdir "$GRAPH"


* Merge in the sequence cluster
	use "$write\activity_merged.dta", clear
	merge 1:1 NSID using "$write\activity_clusters.dta", nogenerate keep(match master)


	* Dataset: n = 6,935 (from 7,279 original)
	
	tab clusters_om3 [aw= W9FINWTALLB]
	
	svyset [pweight=W9FINWTALLB], psu(SAMPPSU) strata(SAMPSTRATUM) singleunit(centered)
	svy: ta clusters_om3	// check if same
	  
	   save "$write\activity_clusters_wide.dta", replace 
	   

********************************************************************************
* Descriptive Table
********************************************************************************	   
	  
	* Descriptives on cluster memberships
	svy: ta clusters_om6 
	svy: ta clusters_om3
	
	svy: tabulate sex clusters_om6, row
	
	// Obtain descriptives for the main analytical sample
	preserve 
	svy: logit propertyown i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st , or baselevels 	
	keep if e(sample)
	 dtable i.propertyown i.finassets_combo i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 i.W9DRGN i.doiw9 i.parentrescat, svy ///
		 by(clusters_om6) ///
         sample(, statistics(frequency)) ///
         factor(, statistics(fvfrequency fvpercent))  ///
		 export("$GRAPH\clusterfrequency.xlsx", replace)
	restore 

	
********************************************************************************
* Start the Analysis
********************************************************************************

 use "$write\activity_clusters_wide.dta", clear 

	svyset [pweight=W9FINWTALLB], psu(SAMPPSU) strata(SAMPSTRATUM) singleunit(centered)

		
	*GLOBAL THE VARIABLES (FOR LATER) 
		global controls_demog	i.sex i.ethnicitycat i.perceived_acadperf  // demographic and adolescence chars alternative: likelihood_uniw1
		global controls_pbg	 	ib3.pclassw1 i.parentalresw1 					// parental socio-economic background class and tenure
		global controls_fam	 	i.fam_cmpw1 i.fam_qualw1					// family background characteristics
		global controls_st		ib7.W9DRGN i.doiw9								// spatial/temporal controls at w9	
		global controls_cw		ib2.W9DFINLIT3  i.W9DIMDD i.W9DCOHAB i.degree	// degree, financial literacy, multiple dep, cohab partner
		
		
		
		
* Figure 4. Predicted probabilities of homeownership at age 32, by STW trajectory.
	
		* 1. Create a copy of the income variable at the end of the STW transition (age 25)
		gen income25_adj = W8GROW

		* 2. Replace negative values with 0 (Not applicable due to unemp/student)
		replace income25_adj = 0 if W8GROW<=0

		* 3. Create a flag for the "Zero Income group"
		gen no_wage_flag = 0
		replace no_wage_flag = 1 if income25_adj==0
		replace no_wage_flag = . if missing(W8GROW)
		gen wage_flag = 1 if no_wage_flag==0
		replace wage_flag = 0 if no_wage_flag==1


		* 4. Log transform (handling the zeros)
		* We add 1 so ln(0+1) = 0.
		gen ln_income25_adj = ln(income25_adj + 1)

		* 5. Run the model including just the income, conditional on being employed
		svy: logit propertyown i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, or		// Full Model
		eststo propown_om6: margins clusters_om6, atmeans post // determines marginal effect of each variable; note that "post" is necessary
		svy: logit propertyown i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, or 	// Control for Income
		eststo propown_om6_income: margins clusters_om6, atmeans post // a 1% increase in income increases the probability of propown by 0.024 pp (still small)

	
		* Figure 4
		coefplot (propown_om6, msymbol(D) msize(medium) label(Full)) (propown_om6_income, msymbol(C) msize(medium) label("with ln(inc) at 25")), ///
				keep(*.clusters_om6) baselevels ///
				graphregion(col(white)) scale(0.9) ///
				legend(position(6) col(2) size(medsmall)) ///
				levels(95 83) ciopts(recast(rspike rcap)) ///
				ylabel(, labsize(medsmall)) ///
				xtitle("Pr(Property Ownership)") ///
				xscale(range(0 0.8)) ///
				xlabel(0(0.2)0.8, angle(horizontal)) ///
				subtitle("Cluster Membership and Property Ownership at Age 32") ///
				note("Note: Both models control for sex, ethnicity, self-rated school performance, parental class, parental housing tenure, parental educ, lone parent HH, and region" "and period dummies. Ln(income) model conditional on reporting income. Sample: 1989/90 Next Steps cohort. (n=5,865 and 4,810 respectively, weighted using w9 weights).", size(vsmall) span)
				
		graph export "$GRAPH\cluster1625_propown_om6_ppmediation.png", replace 
		
		/* Average Marginal Effects (instead of PP)
		svy: logit propertyown i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, or		// Full Model
		eststo propown_om6_ame: margins, dydx(clusters_om6) post 
		svy: logit propertyown i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, or 	// Control for Income
		eststo propown_om6_income_ame: margins, dydx(clusters_om6) post  
		
		* Figure 1
		coefplot (propown_om6_ame, msymbol(D) msize(medium) label(Full)) (propown_om6_income_ame, msymbol(C) msize(medium) label("with ln(inc) at 25")), ///
				keep(*.clusters_om6) baselevels ///
				graphregion(col(white)) scale(0.9) ///
				legend(position(6) col(2) size(medsmall)) ///
				levels(95 83) ciopts(recast(rspike rcap)) ///
				ylabel(, labsize(medsmall)) ///
				xtitle("AME (vs. Early STW)") ///
				xscale(range(-0.3 0.3)) ///
				xlabel(-0.3(0.1)0.3, angle(horizontal)) ///
				subtitle("Cluster Membership and Property Ownership at Age 32") ///
				note("Note: Both models control for sex, ethnicity, self-rated school performance, parental class, parental housing tenure, parental educ, lone parent HH, and region" "and period dummies. Ln(income) model conditional on reporting income. Sample: 1989/90 Next Steps cohort. (n=5,865 and 4,810 respectively, weighted using w9 weights).", size(vsmall) span)
				
		graph export "$GRAPH\cluster1625_propown_om6_amemediation.png", replace 
		*/


* Figure 5. Predicted probabilities of financial assets at age 32, by STW trajectory.

		svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		eststo finass_outcome1: margins clusters_om6, atmeans predict(outcome(1)) post
		svy: mlogit finassets_combo i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		eststo finassinc_outcome1: margins clusters_om6, atmeans predict(outcome(1)) post
		coefplot (finass_outcome1, msymbol(D) msize(medium) label(Full)) (finassinc_outcome1, msymbol(C) msize(medium) label("with ln(inc) at 25")), ///
				name(mediation_none, replace) ///
				graphregion(col(white)) scale(0.9) ///
				legend(position(6) col(2) size(medsmall)) ///
				levels(95 83) ciopts(recast(rspike rcap)) ///
				ylabel(, labsize(small)) ///
				xscale(range(0 1)) ///
				xlabel(0(0.2)1, angle(horizontal)) ///
				subtitle("Pr(No Financial Assets)")
		
		svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		eststo finass_outcome2: margins clusters_om6, atmeans predict(outcome(2)) post
		svy: mlogit finassets_combo i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		eststo finassinc_outcome2: margins clusters_om6, atmeans predict(outcome(2)) post
		coefplot (finass_outcome2, msymbol(D) msize(medium) label(Full)) (finassinc_outcome2, msymbol(C) msize(medium) label("with ln(inc) at 25")), ///
				name(mediation_below, replace) ///
				graphregion(col(white)) scale(0.9) ///
				legend(position(6) col(2) size(medsmall)) ///
				levels(95 83) ciopts(recast(rspike rcap)) ///
				ylabel(, labsize(small)) ///
				xscale(range(0 1)) ///
				xlabel(0(0.2)1, angle(horizontal)) ///
				subtitle("Pr(Below Median Financial Assets)") 
		
		svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		eststo finass_outcome3: margins clusters_om6, atmeans predict(outcome(3)) post
		svy: mlogit finassets_combo i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		eststo finassinc_outcome3: margins clusters_om6, atmeans predict(outcome(3)) post
		coefplot (finass_outcome3, msymbol(D) msize(medium) label(Full)) (finassinc_outcome3, msymbol(C) msize(medium) label("with ln(inc) at 25")), ///
				name(mediation_above, replace) ///
				graphregion(col(white)) scale(0.9) ///
				legend(position(6) col(2) size(medsmall)) ///
				levels(95 83) ciopts(recast(rspike rcap)) ///
				ylabel(, labsize(small)) ///
				xscale(range(0 1)) ///
				xlabel(0(0.2)1, angle(horizontal)) ///
				subtitle("Pr(Above Median Financial Assets)") 
		
		
		grc1leg2  mediation_none mediation_below mediation_above, rows(3) ysize(8) graphregion(margin(vsmall)) imargin(0 0 0 0) ///
		note("Note: Ext I/U: Extended Inactivity/Unemployment. Models control for sex, ethnicity, self-rated school" "performance, parental class, parental housing tenure, parental educ, lone parent HH, and region and" "period dummies. Sample: 1989/90 Next Steps cohort. (n=5,424 and n=4,442 weighted using w9 weights).", size(vsmall) span) ///
		subtitle("Clusters and Financial Assets at Age 32") ///
		title("")
		
		graph export "$GRAPH\cluster1625_finassets_om6_ppmediation.png", replace 
		
		
	/* Approach 2. KHB mediation analysis // accounts for selection into STW trajectory and income reporting at age 25

		svy: logit wage_flag $controls_demog $controls_pbg $controls_fam $controls_st, or baselevels
		predict p_inc25rep, pr
		gen ipw_m1 = 1/p_inc25rep if wage_flag == 1
		replace ipw_m1 = 10 if ipw_m1>10 & ipw_m1!=.  				// crump et al (2009): replace ipw_m1>10 to 10
		gen fw_m1 = ipw_m1*W9FINWTALLB 									// ridgeway et al (2015)
		br propertyown W8GROW wage_flag ln_income25_adj W9FINWTALLB ipw_m1 fw_m1 p_inc25rep if W8GROW!=.

		eststo model_khb: khb logit propertyown i.clusters_om6 || ln_income25_adj [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf ib3.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1) summary or disentangle vce(cluster SAMPPSU)
		
		eststo model_khb_finass: khb mlogit finassets_combo i.clusters_om6 || ln_income25_adj [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 W9DRGN i.doiw9) summary or disentangle vce(cluster SAMPPSU) baseoutcome(3)
	*/
	
	

		
* Figure 6. Stw transition cluster and homeownership at age 32, by social origin

	** Interaction of cluster * parental class pclass 
	
	svy: logit propertyown i.clusters_om6##i.pclassw1 $controls_demog $controls_pbg $controls_fam $controls_st , or baselevels 	
	margins i.clusters_om6#i.pclassw1, post
	mplotoffset, recast(scatter) offset(0.2) ylab(0(.2).6) ysc(r(0(.2).6)) legend(position(6) col(4)) name(int_om6_propown_pclass, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "Parental Class" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush Predicted Probabilities // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		graph export "$GRAPH\int_om6_propown_pclass.png", replace width(1000)

		
	** Interaction of cluster * parental tenure parentalres
	
	svy: logit propertyown i.clusters_om6##i.parentalresw1 $controls_demog $controls_pbg $controls_fam $controls_st , or baselevels 	
	margins i.clusters_om6#i.parentalresw1, post
	mplotoffset, recast(scatter) offset(0.2) ylab(0(.2).6) ysc(r(0(.2).6)) legend(position(6) col(3)) name(int_om6_propown_pres, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "Parental Housing Tenure" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush Predicted Probabilities // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		graph export "$GRAPH\int_om6_propown_pres.png", replace width(1000)
		

	
	** Merge Plots 
	graph combine int_om6_propown_pclass int_om6_propown_pres, rows(2) note("Note: Models control for sex, ethnicity, self-rated school performance, remaining family background variables and region and period dummies." "Ext I/U: Extended Inactivity/Unemployment. Clusters derived using OM and estimates used w9 weights", size(vsmall) span)
	gr_edit .title.text = {}
	gr_edit .subtitle.text = {}
	gr_edit .subtitle.text.Arrpush "Cluster and Property Ownership, by Parental Background" // title edits
	gr_edit .plotregion1.graph2.yaxis1.reset_rule 0 0.8 0.2 , tickset(major) ruletype(range) 
	gr_edit .plotregion1.graph1.yaxis1.reset_rule 0 0.8 0.2 , tickset(major) ruletype(range) 
	graph export "$GRAPH\int_om6_propown_all_v3.png", replace 


* Fig. 7. Cluster membership and financial assets at 32, by parental class.

		svy: mlogit finassets_combo i.clusters_om6##i.pclassw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(pclassw1) atmeans predict(outcome(1)) post
		mplotoffset, name(none, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("None") ytitle("Predicted Probability") legend(position(6) col(4)) offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		
		svy: mlogit finassets_combo i.clusters_om6##i.pclassw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 		
		margins clusters_om6, over(pclassw1) atmeans predict(outcome(2)) post
		mplotoffset, name(belowmedian, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("Below Median") ytitle("Predicted Probability") legend(position(6) col(4))	offset(0.2)	title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		
		svy: mlogit finassets_combo i.clusters_om6##i.pclassw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(pclassw1) atmeans predict(outcome(3)) post
		mplotoffset, name(abovemedian, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("Above Median") ytitle("Predicted Probability") legend(position(6) col(4))	offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		
		grc1leg2 none belowmedian abovemedian, lsize(2) lmsize(2) ycommon rows(3) ysize(8) ///
		note("Note: Models control for sex, ethnicity, self-rated school performance, remaining family background"  "variables and region and period dummies. 6 clusters derived using OM. Sample: 1989/90 Next Steps" "cohort (n=5,424, weighted using w9 weights). Ext I/U: Extended Inactivity/Unemployment", size(vsmall) span) ///
		subtitle("Clusters and Financial Assets, by Parental Class") ///
		title("")
		graph export "$GRAPH\int_om6_finassmult_pclass.png", replace 
		
			
		/* Appendix Figure A7. Cluster Membership and Financial Assets at 32, by Parental Housing Tenure
		svy: mlogit finassets_combo i.clusters_om6##i.parentalresw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(parentalresw1) atmeans predict(outcome(1)) post
		mplotoffset, name(none, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("None") ytitle("Predicted Probability") legend(position(6) col(4)) offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		
		svy: mlogit finassets_combo i.clusters_om6##i.parentalresw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(parentalresw1) atmeans predict(outcome(2)) post
		mplotoffset, name(belowmedian, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("Below Median") ytitle("Predicted Probability") legend(position(6) col(4))	offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)

		svy: mlogit finassets_combo i.clusters_om6##i.parentalresw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(parentalresw1) atmeans predict(outcome(3)) post
		mplotoffset, name(abovemedian, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("Above Median") ytitle("Predicted Probability") legend(position(6) col(4))	offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
				
		grc1leg2 none belowmedian abovemedian, lsize(2) lmsize(2) ycommon rows(3) ysize(8) ///
		note("Note: Models control for sex, ethnicity, self-rated school performance, remaining family background"  "variables and region and period dummies. 6 clusters derived using OM. Sample: 1989/90 Next Steps" "cohort (n=5,424, weighted using w9 weights). Ext I/U: Extended Inactivity/Unemployment", size(vsmall) span) ///
		subtitle("Clusters and Financial Assets, by Parental Tenure") ///
		title("")
		graph export "$GRAPH\int_om6_finassmult_ptenure.png", replace 
		
			
		* Appendix Figure A8. Cluster Membership and Financial Assets at 32, by Parental Educ
		svy: mlogit finassets_combo i.clusters_om6##i.fam_qualw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(fam_qualw1) atmeans predict(outcome(1)) post
		mplotoffset, name(none, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("None") ytitle("Predicted Probability") legend(position(6) col(3)) offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)

		svy: mlogit finassets_combo i.clusters_om6##i.fam_qualw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(fam_qualw1) atmeans predict(outcome(2)) post
		mplotoffset, name(belowmedian, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("Below Median") ytitle("Predicted Probability") legend(position(6) col(3))	offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)

		svy: mlogit finassets_combo i.clusters_om6##i.fam_qualw1 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
		margins clusters_om6, over(fam_qualw1) atmeans predict(outcome(3)) post
		mplotoffset, name(abovemedian, replace) recast(scatter) ylab(0(0.2)0.8) subtitle("Above Median") ytitle("Predicted Probability") legend(position(6) col(3))	offset(0.2) title("") xtitle("Clusters")
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		
		grc1leg2 none belowmedian abovemedian, lsize(2) lmsize(2) ycommon rows(3) ysize(8) ///
		note("Note: Models control for sex, ethnicity, self-rated school performance, remaining family background"  "variables and region and period dummies. 6 clusters derived using OM. Sample: 1989/90 Next Steps" "cohort (n=5,424, weighted using w9 weights). Ext I/U: Extended Inactivity/Unemployment", size(vsmall) span) ///
		subtitle("Clusters and Financial Assets, by Parental Education") ///
		title("")
		graph export "$GRAPH\int_om6_finassmult_peduc.png", replace 


		*/

* Figure 8. Predicted probability of receiving parental support for home purchase among homeowners.
	
	* Conditional model (subpopulation analysis) with parental housing tenure
		svy, subpop(propertyown): logit propertyown_psupport2 ib6.clusters_om6, or		// M1a: Clusters -> Support (Homeowners) 
		svy, subpop(propertyown): logit propertyown_psupport2 ib6.clusters_om6##i.parentalresw1 $controls_demog $controls_pbg $controls_fam, or		// M1b: Clusters -> Support (Homeowners)
		margins i.clusters_om6#i.parentalresw1, subpop(propertyown) post
		mplotoffset, recast(scatter) offset(0.2) ylab(0(.2)1) ysc(r(0(.2)1)) legend(position(6) col(3)) name(psupport_homeowners, replace)
			gr_edit .title.text = {}
			gr_edit .title.text.Arrpush "Parental Support by Clusters and Parental Housing Tenure (among Homeowners)" // title edits
			gr_edit .yaxis1.title.text = {}
			gr_edit .yaxis1.title.text.Arrpush Pr(Inheritance | Loan | Gift) // title edits
			gr_edit .xaxis1.title.text = {}
			gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		graph export "$GRAPH\cluster1625_propown_psupport2.png", replace 
		
	/* Appendix Figure A9. Predicted Probability of Receiving Parental Support for Home Purchase among Homeowners (IPW) 
	* Selection Model
	quietly svy: logit propertyown i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st
	predict p_own if e(sample), pr
	gen ipw = 1 / p_own
	gen combined_weight = W9FINWTALLB * ipw

	* Re-declare survey design using the new combined weight
	svyset [pweight=combined_weight], psu(SAMPPSU) strata(SAMPSTRATUM) singleunit(centered)


	* Outcome Model
	svy, subpop(propertyown): logit propertyown_psupport2 ib6.clusters_om6##i.parentalresw1
	margins i.clusters_om6#i.parentalresw1, subpop(propertyown) post
	mplotoffset, recast(scatter) offset(0.2) ylab(0(.2)1) ysc(r(0(.2)1)) legend(position(6) col(3)) 
			gr_edit .title.text = {}
			gr_edit .title.text.Arrpush "Parental Support by Clusters and Parental Housing Tenure (IPW)" // title edits
			gr_edit .yaxis1.title.text = {}
			gr_edit .yaxis1.title.text.Arrpush Pr(Inheritance | Loan | Gift) // title edits
			gr_edit .xaxis1.title.text = {}
			gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		graph export "$GRAPH\cluster1625_propown_psupport2_ipw.png", replace 
		
	*/		

	
	
	
	/* Supplementary Question: Does controlling for income change the buffering story
	
	svy: logit propertyown i.clusters_om6##i.parentalresw1 $controls_demog $controls_pbg $controls_fam $controls_st , or baselevels 	
	margins i.clusters_om6#i.parentalresw1, post
	mplotoffset, recast(scatter) offset(0.2) ylab(0(.2).6) ysc(r(0(.2).6)) legend(position(6) col(3)) name(int_om6_propown_pres, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "Not Controlling for Income" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush Predicted Probabilities // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
	
	svy: logit propertyown i.clusters_om6##i.parentalresw1 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st , or baselevels 	
	margins i.clusters_om6#i.parentalresw1, post
	mplotoffset, recast(scatter) offset(0.2) ylab(0(.2).6) ysc(r(0(.2).6)) legend(position(6) col(3)) name(int_om6_propown_income, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "Controlling for Income" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush Predicted Probabilities // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .xaxis1.edit_tick 6 6 `"Ext I/U"', tickset(major)
		
		** Merge Plots NO ED
	graph combine int_om6_propown_pres int_om6_propown_income, rows(2) note("Note: Both models control for sex, ethnicity, self-rated school performance, remaining family background variables and region and period dummies." "Ext I/U: Extended Inactivity/Unemployment. Clusters derived using OM and estimates used w9 weights", size(vsmall) span)
	gr_edit .title.text = {}
	gr_edit .subtitle.text = {}
	gr_edit .subtitle.text.Arrpush "Cluster and Property Ownership, by Parental Housing Tenure" // title edits
	gr_edit .plotregion1.graph2.yaxis1.reset_rule 0 0.8 0.2 , tickset(major) ruletype(range) 
	gr_edit .plotregion1.graph1.yaxis1.reset_rule 0 0.8 0.2 , tickset(major) ruletype(range) 
			graph export "$GRAPH\int_om6_propown_ptenure_mediation.png", replace 

		
	*/
		
********************************************************************************	
	***** Full Tables
********************************************************************************

	/* Appendix Table A2. Stepwise Regression Results for Homeownership (Predicted Probabilities) 
	* Property Ownership
	svy: logit propertyown i.clusters_om6 $controls_demog, or baselevels 	
	margins clusters_om6, atmeans post // determines marginal effect of each variable; note that "post" is necessary
	outreg2 using "$GRAPH\stepwise_propown.xls", replace bracket ctitle(Property Owner, Base) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)

	svy: logit propertyown i.clusters_om6 $controls_demog $controls_pbg, or baselevels 	
	margins clusters_om6, atmeans post // determines marginal effect of each variable; note that "post" is necessary
	outreg2 using "$GRAPH\stepwise_propown.xls", append bracket ctitle(Property Owner, with SES) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)

	svy: logit propertyown i.clusters_om6 $controls_demog $controls_pbg $controls_fam, or baselevels 	
	margins clusters_om6, atmeans post // determines marginal effect of each variable; note that "post" is necessary
	outreg2 using "$GRAPH\stepwise_propown.xls", append bracket ctitle(Property Owner, with Fam BG) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)

	svy: logit propertyown i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, or baselevels 	
	margins clusters_om6, atmeans post // determines marginal effect of each variable; note that "post" is necessary
	outreg2 using "$GRAPH\stepwise_propown.xls", append bracket ctitle(Property Owner, Full) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	
	svy: logit propertyown i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, or 	// Control for Income
	margins clusters_om6, atmeans post // a 1% increase in income increases the probability of propown by 0.024 pp (still s
	outreg2 using "$GRAPH\stepwise_propown.xls", append bracket ctitle(Property Owner, w/Income) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	*/
	
	/* Appendix Table A3. Stepwise Regression Results – Financial Asset Ownership (Predicted Probabilities)  
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(1)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", replace bracket ctitle(No Financial Assets, Base) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(1)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(No Financial Assets, with SES) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(1)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(No Financial Assets, with Fam BG) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(1)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(No Financial Assets, Full) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(1)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(No Financial Assets, w/Income) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)

	svy: mlogit finassets_combo i.clusters_om6 $controls_demog, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(2)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(Low Financial Assets, Base) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(2)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(Low Financial Assets, with SES) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(2)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(Low Financial Assets, with Fam BG) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(2)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(Low Financial Assets, Full) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(2)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(No Financial Assets, w/Income) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(3)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(High Financial Assets, Base) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(3)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(High Financial Assets, with SES) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(3)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(High Financial Assets, with Fam BG) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(3)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(High Financial Assets, Full) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)
	svy: mlogit finassets_combo i.clusters_om6 ln_income25_adj $controls_demog $controls_pbg $controls_fam $controls_st, rrr baselevels 	
	margins clusters_om6, atmeans predict(outcome(3)) post
	outreg2 using "$GRAPH\stepwise_finass.xls", append bracket ctitle(No Financial Assets, w/Income) label bdec(3) sdec(3) alpha(0.01, 0.05, 0.1) symbol(***, **, *)

	*/



********************************************************************************
** Regression Results for Appendix Tables A6-A8 
********************************************************************************	
	
	/*
	*** Property Ownership
	
	*A6. Cohabiting partner - significant only for the cohab - attenuates. lower prob of ownership due to cohab
	khb logit propertyown i.clusters_om6 || i.W9DCOHAB [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 W9DRGN i.doiw9) summary disentangle cluster(SAMPPSU)   

	
	*A7. Parental Coresidence - not significant. Coefficients stay largely the same
	khb logit propertyown i.clusters_om6 || i.parentres [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 W9DRGN i.doiw9) summary disentangle cluster(SAMPPSU)   
	
	*A8. Qualification
	khb logit propertyown i.clusters_om6 || i.degree [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 W9DRGN i.doiw9) summary disentangle cluster(SAMPPSU) 
	
	
	*** Financial Assets

	* A6. Cohabiting partner - sig for cluster 5. attenuating
	khb mlogit finassets_combo i.clusters_om6 || i.W9DCOHAB [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 W9DRGN i.doiw9) summary disentangle cluster(SAMPPSU) baseoutcome(3)
	
	* A7. Parental Coresidence not sig. differences insig
	khb mlogit finassets_combo i.clusters_om6 || i.parentres [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 W9DRGN i.doiw9) summary disentangle cluster(SAMPPSU) baseoutcome(3)


	* A8. Qualification
	khb mlogit finassets_combo i.clusters_om6 || i.degree [pw=W9FINWTALLB], c(i.sex i.ethnicitycat i.perceived_acadperf i.pclassw1 i.parentalresw1 i.fam_cmpw1 i.fam_qualw1 W9DRGN i.doiw9) summary disentangle cluster(SAMPPSU) baseoutcome(3)
	


* Figure A3. Kernel Density Curves of Total Savings and Investments, by Cluster
	
	merge 1:1 NSID using "$write\w9savings.dta", nogenerate keep(match master)

	* Recode true non-response to Stata missing
	replace W9SAVTOT = . if W9SAVTOT == -9  // Refused
	replace W9SAVTOT = . if W9SAVTOT == -8  // Don't know
	replace W9SAVTOT = . if W9SAVTOT == -3  // Not asked at fieldwork stage

	* Recode "not applicable" (skipped, i.e. no savings) to zero
	replace W9SAVTOT = 0 if W9SAVTOT == -1

	gen W9SAVTOT_log = log(W9SAVTOT + 1)

	kdensity W9SAVTOT_log if clusters_om6==1, addplot( ///
		kdensity W9SAVTOT_log if clusters_om6==2 || ///
		kdensity W9SAVTOT_log if clusters_om6==3 || ///
		kdensity W9SAVTOT_log if clusters_om6==4 || ///
		kdensity W9SAVTOT_log if clusters_om6==5 || ///
		kdensity W9SAVTOT_log if clusters_om6==6) ///
		legend(order(1 "Early STW" 2 "Late STW" 3 "Training" 4 "Higher Ed" 5 "Intermittent" 6 "Extended U/I")) ///
		legend(pos(6) col(3)) ///
		title("Distribution of Financial Assets by Labour Market Cluster") ///
		xtitle("Log Total Savings £ (log+1)") ytitle("Density")
			graph export "$GRAPH\finassets_continuous.png", replace 


*/
