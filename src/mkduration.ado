*		PROGRAM MKDURATION
*		
*		version 1.0.1
*		Andrew Q. Philips
*		description: program to create duration variable using CSTS data
*		10/17/19
*
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------

capture program drop mkduration
capture program define mkduration
syntax [varlist], [force dname(string)]

version 8

* are data xtset?
qui cap xtset
if "`r(panelvar)'" == "" | "`r(timevar)'" == "" {
	di in r _n "data must first be xtset"
	exit 198
}
loc panelvar = r(panelvar)
di `panelvar'
loc timevar = r(timevar)

* is there a single event variable?
loc n_vars : word count `varlist' // count of vars
if "`n_vars'" == "1" {
	* is event dichotomous? 
	cap assert missing(`varlist') | inlist(`varlist', 0, 1)
	if _rc != 0 {
		di in r _n "duration variable is not [0,1] dichotomous"
	}

}
else {
	di in r _n "a single duration variable must be specified"
	exit 198
}

* create duration:
if "`dname'" == "" {
	loc dname = "duration"
}
gen `dname' = 0
if "`force'" != "" { // force over duration gaps?
	bysort `panelvar': replace `dname' = cond((l.`varlist' == 1)| _n == 1, 1, `dname'[_n-1] + (`timevar' - `timevar'[_n-1]))
}
else {
	bysort `panelvar': replace `dname' = cond((l.`varlist' == 1)| _n == 1, 1, l.`dname' + 1) // if/else command; replace duration = 1 the time after event, else d + 1
}

end
