*		PROGRAM MKDURATION
*		
*		version 1.0.4
*		Andrew Q. Philips
*		description: program to create duration variable using CSTS data
*		4/21/20
*
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------
* -------------------------------------------------------------------------
capture program drop mkduration
capture program define mkduration
syntax [varlist], [dname(string) spline(string) nknots(string) strict force rfill lfill]

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
	di in r _n "a single duration variable must be specified"
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

* if l/rfill is specified, force must be too:
if "`lfill'" != "" | "`rfill'" != "" {
	if "`force'" == "" {
		di in r _n "force must also be specified if lfill or rfill are specified"
		exit 198
	}
}

* if strict is specified, force (and l/rfill) can't be:
if "`strict'" != "" {
	if "`force'" != "" {
		di in r _n "force cannot be specified with strict"
		exit 198
	}
}

* create duration:
if "`dname'" == "" {
	loc dname = "__duration"
}
qui gen `dname' = 0

qui if "`strict'" != "" { // strict fill
	bysort `panelvar': replace `dname' = cond((l.`varlist' == 1), cond(l.`varlist' != ., 1, .), cond(l.`varlist' != ., l.`dname' + 1, .))
}
qui else if "`force'" != "" { // force over duration gaps? 4 conditions:
	if "`lfill'" != "" & "`rfill'" != "" { // both left and right fill
		bysort `panelvar': replace `dname' = cond((l.`varlist' == 1) | (_n == 1), 1, `dname'[_n-1] + (`timevar' - `timevar'[_n-1]))
	}
	else if "`lfill'" != "" { // left fill only
		bysort `panelvar': replace `dname' = cond((l.`varlist' == 1) | (_n == 1), 1, `dname'[_n-1] + (`timevar' - `timevar'[_n-1]))
		tempvar __tag__
		bysort `panelvar': egen `__tag__' = max(cond(`varlist' != ., `timevar', .))
		bysort `panelvar': replace `dname' = . if `timevar' > (`__tag__' + 1)
	}
	else if "`rfill'" != "" { // right fill only
		tempvar __obs__
		bysort `panelvar': gen `__obs__' = sum(!missing(`varlist')) if !missing(`varlist')
		bysort `panelvar': replace `dname' = cond((l.`varlist' == 1) | (`__obs__' == 1), 1, `dname'[_n-1] + (`timevar' - `timevar'[_n-1]))
	}
	else { // just force only
		tempvar __obs__
		bysort `panelvar': gen `__obs__' = sum(!missing(`varlist')) if !missing(`varlist')
		bysort `panelvar': replace `dname' = cond((l.`varlist' == 1) | (`__obs__' == 1), 1, `dname'[_n-1] + (`timevar' - `timevar'[_n-1]))
		tempvar __tag__
		bysort `panelvar': egen `__tag__' = max(cond(`varlist' != ., `timevar', .))
		bysort `panelvar': replace `dname' = . if `timevar' > (`__tag__' + 1)
	}
}
qui else { // regular fill
	tempvar __obs__
	bysort `panelvar': gen `__obs__' = sum(!missing(`varlist')) if !missing(`varlist')
	bysort `panelvar': replace `dname' = cond((l.`varlist' == 1) | (`__obs__' == 1), cond(l.`varlist' != . | `__obs__' == 1, 1, .), cond(l.`varlist' != ., l.`dname' + 1, .))
}

* create spline (optional):
qui if "`spline'" != "" {
	if "`spline'" == "linear" {
		loc nkplus1 = `nknots' + 1 // linear spline needs number of splits, not knots
		mkspline `dname'_spl `nkplus1' = `dname', pctile displayknots
	}
	else { // cubic spline
		mkspline `dname'_spl = `dname', cubic nknots(`nknots') displayknots
	}
}

end
