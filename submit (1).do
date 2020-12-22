clear all

// use folder location here
local x "C:\Users\nikhi\Downloads\data\data" 
cd `x'

********************************
* Part 1 *

// store all file names in a local variable
local files : dir "`x'" files "*.csv"

scalar flag = 1 // indicates if it is the first run of the loop

foreach file in `files' {
	
	if(flag==1){
		// if first run of loop
		import delimited `file', clear // import the first csv file
		tempfile yourfilename //declare the temporary file 
		sa `yourfilename' // save the first csv file in a temporary file
		scalar flag = 0 // indicate for further iterations that it is not the first run
	}
	
	else{
		import delimited `file', clear // import that csv file
		append using `yourfilename' // append to the exisiting temporary file
		sa `yourfilename', replace // replace the temporary file
	}
}

save final.dta, replace // save the final data

*******************************
* Part 2 *

mdesc
// There are no missing values in the data

// find the details about each variable
codebook

// replace and drop  observations that have unreasonable values from observation in codebook
replace beer =. if beer == 999 
replace population =. if population <0
replace fatalities = . if fatalities < 0

drop if beer == . | population == . | fatalities == .

// encode state values as categorical values
encode state, gen(st)

********************************
* Part 3 *

qui reg population totalvmt
// store the slope from regression result
local s = e(b)[1,1]
twoway (scatter population totalvmt, mfcolor(red) mlcolor(black)) (lfit population totalvmt) (lfitci population totalvmt, color(blue%30)), note(slope=`s')
graph save assgn_graph_3.gph, replace

*******************************
* part 4 * 

// store the values for each regression
eststo: reg fatalities beer i.year

eststo: reg fatalities beer unemploy college primary secondary population i.year

eststo: reg fatalities beer unemploy college primary secondary population i.year i.st

esttab using reg_table1, se ar2 drop(*.st *.year )  label  nonumbers mtitles("OLS" "Controls" "State FE") replace

*********************************

* part 5 *
//. clear previously stored estimates
eststo clear 

eststo: ivregress 2sls fatalities (beer = friesprice) i.year i.st, first

esttab using reg_table2, se ar2 drop(*.st *.year )  label  nonumbers mtitles("IV with State FE") replace

