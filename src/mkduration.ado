*		PROGRAM MKDURATION
*		
*		version 1.0.3
*		Andrew Q. Philips
*		description: program to create duration variable using CSTS data
*		2/16/20
*
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------

capture program drop mkduration
capture program define mkduration
syntax [varlist], [force dname(string) POLYnomial spline(string) nknots(string)]

version 8

* are data xtset?
qui cap xtset
if "`r(panelvar)'" == "" | "`r(timevar)'" == "" {
	di in r _n "data must first be xtset"
	exit 198
}
loc panelvar = r(panelvar)
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
	di in r _n "only a single duration variable can be specified"
	exit 198
}

* is either polynomial or spline set? Optional
if "`polynomial'" != "" & "`spline'" != "" {
	di in r _n "either polynomial or spline can be specified, not both"
	exit 198
}

* is spline either linear or cubic? and if nknots not specified, default to 5:
if "`spline'" != "" {
	if !inlist("`spline'", "linear", "cubic") {
		di in r _n "spline can be either spline(linear) or spline(cubic)"
		exit 198
	}
	if "`nknots'" == "" {
		loc nknots = 5
	}
} 

* is nknots only specified w/ spline? and correct number of knots?
if "`nknots'" != "" {
	if "`spline'" == "" {
		di in r _n "nknots can only be specified with spline()"
		exit 198
	}
	if !inlist("`nknots'", "3", "4", "5", "6", "7") {
		di in r _n "nknots can only range from 3 to 7"
		exit 198
	}
} 

* create duration:
if "`dname'" == "" {
	loc dname = "duration"
}
cap drop `dname'
qui gen `dname' = 0
if "`force'" != "" { // force over duration gaps?
	qui bysort `panelvar': replace `dname' = cond((l.`varlist' == 1)| _n == 1, 1, `dname'[_n-1] + (`timevar' - `timevar'[_n-1]))
}
else {
	qui bysort `panelvar': replace `dname' = cond((l.`varlist' == 1)| _n == 1, 1, l.`dname' + 1) // if/else command; replace duration = 1 the time after event, else d + 1
}

* create polynomials (optional):
qui if "`polynomial'" != "" {
	cap drop `dname'2 `dname'3
	gen `dname'2 = `dname'*`dname'
	gen `dname'3 = `dname'*`dname'*`dname'
}

* create spline (optional):
if "`spline'" != "" {
	if "`spline'" == "linear" {
		cap drop `dname'_spl
		loc nkplus1 = `nknots' + 1 // linear spline needs number of splits, not knots
		mkspline `dname'_spl `nkplus1' = `dname', pctile displayknots
	}
	else { // cubic spline
		cap drop `dname'_spl
		mkspline `dname'_spl = `dname', cubic nknots(`nknots') displayknots
	}
}

end
