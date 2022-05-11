/*******************************************************************************
Author: Parag Pathak

Description: This code replicates the figures shown in "Unobserved Punishment
Supports Cooperation"

********************************************************************************/

* Import data
import delimited "${clean_data}/unobserved_dataset.csv", clear

* Initialize matrices
foreach l in U O {
  forval i = 1/4 {
    matrix `l'`i' = J(10, 4, .)
  }
}
foreach l in B A {
  forval i = 1/2 {
    matrix `l'`i' = J(10, 2, .)
  }
}

* Compute averages by treatment and period
local n = 1
foreach var in contrib you_punished expend profit {
  foreach t in 0 1 {
    local r = 1
    if `t' == 0 local l = "U"
    if `t' == 1 local l = "O"
    forvalues p = 1/10 {
      mat `l'`n'[`r', 1] = `p'
      sum `var' if base == `t' & mod_period == `p'
      mat `l'`n'[`r', 2] = r(mean)
      mat `l'`n'[`r', 3] = r(mean) - (1.96*r(sd)/sqrt(r(N)))
      mat `l'`n'[`r', 4] = r(mean) + (1.96*r(sd)/sqrt(r(N)))
      local ++r
    }
  }
  svmat U`n'
  svmat O`n'
  local ++n
}

* Compute averages by set (before and after feedback) and period
local n = 1
foreach var in contrib you_punished {
  foreach s in 1 2 {
    local r = 1
    if `s' == 1 local l = "B"
    if `s' == 2 local l = "A"
    forvalues p = 1/10 {
      mat `l'`n'[`r', 1] = `p'
      sum `var' if set == `s' & mod_period == `p' & base == 0
      mat `l'`n'[`r', 2] = r(mean)
      local ++r
    }
  }
  svmat B`n'
  svmat A`n'
  local ++n
}

keep U* O* B* A*

* Font option
graph set window fontface "Times New Roman"

* Set graph options
local graph_options xtitle("Period", height(5) size(medsmall)) ///
  xlabel(1(1)10, labsize(small)) ///
  xmtick(.5(.5)10.5) ///
  graphregion(color(white)) ///
  legend(on order(1 "Unobserved" 2 "Observed") size(small)) ///

* Plot figure 1
twoway (rcap U14 U13 U11, lstyle(ci) lwidth(thin) lcolor(gs9)) ///
  (rcap O14 O13 O11, lstyle(ci) lwidth(thin) lcolor(black)) ///
  (connected U12 U11, msize(medium) color(gs9) msymbol(square)) ///
  (connected O12 O11, msize(medium) color(black) msymbol(d)), ///
  title("Evolution of Average Contribution with 95% Confidence Intervals", ///
  size(med) color(black)) ///
  ytitle("Average Contribution", height(5) size(medsmall)) ///
  ylabel(0(2)16, nogrid labsize(small)) ///
  `graph_options'
graph export "${output}/figures/fig1.pdf", replace

* Plot figure 2
twoway (rcap U24 U23 U21, lstyle(ci) lwidth(thin) lcolor(gs9)) ///
  (rcap O24 O23 O21, lstyle(ci) lwidth(thin) lcolor(black)) ///
  (connected U22 U21, msize(medium) color(gs9) msymbol(square)) ///
  (connected O22 O21, msize(medium) color(black) msymbol(d)), ///
  title("Evolution of Fraction Who Punish with 95% Confidence Intervals", ///
  size(med) color(black)) ///
  ytitle("Fraction Who Punish", height(5) size(medsmall)) ///
  ylabel(0(.05).5, nogrid labsize(small)) ///
  `graph_options'
graph export "${output}/figures/fig2.pdf", replace

* Plot figure 3
twoway (connected U32 U31, msize(medium) color(gs9) msymbol(square)) ///
  (connected O32 O31, msize(medium) color(black) msymbol(d)), ///
  title("Evolution of Average Expenditure on Punishment", ///
  size(med) color(black)) ///
  ytitle("Average Expenditure on Punishment", height(5) size(medsmall)) ///
  ylabel(0(.2)1.8, nogrid labsize(small)) ///
  `graph_options'
graph export "${output}/figures/fig3.pdf", replace

* Plot figure 4
twoway (connected U42 U41, msize(medium) color(gs9) msymbol(square)) ///
  (connected O42 O41, msize(medium) color(black) msymbol(d)), ///
  title("Evolution of Average Income", ///
  size(med) color(black)) ///
  ytitle("Average Income", height(5) size(medsmall)) ///
  ylabel(10(2)30, nogrid labsize(small)) ///
  `graph_options'
graph export "${output}/figures/fig4.pdf", replace

* Plot figure 5
twoway (connected B12 B11, msize(medium) color(black) msymbol(d) yaxis(1)) ///
  (connected A12 A11, msize(medium) color(gs9) msymbol(d) yaxis(1)) ///
  (connected B22 B21, msize(medium) color(black) msymbol(square) yaxis(2)) ///
  (connected A22 A21, msize(medium) color(gs9) msymbol(square) yaxis(2)), ///
  title("Evolution of Contribution and Fraction Punishing Before and After Feedback", ///
  size(med) color(black)) ///
  ytitle("Average Contribution", height(5) size(medsmall) axis(1)) ///
  ytitle("Fraction Who Punish", height(5) size(medsmall) axis(2) orientation(rvertical)) ///
  ylabel(0(2)16, nogrid labsize(small) axis(1)) ///
  ylabel(0(.1)1, nogrid labsize(small) axis(2)) ///
  `graph_options' ///
  legend(on order(1 "Before Feedback" 2 "After Feedback" 3 "Before Feedback" ///
  4 "After Feedback") size(small))
graph export "${output}/figures/fig5.pdf", replace
