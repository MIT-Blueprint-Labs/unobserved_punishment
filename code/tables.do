/*******************************************************************************
Author: Parag Pathak

Description: This code replicates the tables shown in "Unobserved Punishment
Supports Cooperation"

*******************************************************************************/

* Import data
import delimited "${clean_data}/unobserved_dataset.csv", clear

* Create some additional variables
bys session set subject: egen freq_punished = total(you_punished)
gen never = 0
replace never = 1 if freq_punished == 0
gen more_than_once = 0
replace more_than_once = 1 if freq_punished > 1
egen session_ind = group(session)
gen ndiff = 0
replace ndiff = diff if diff < 0
gen pdiff = 0
replace pdiff = diff if diff > 0

***********************   Table 2: Experimental Design   ***********************

* Initialize matrix
matrix A = J(7, 11, .)
local cols "C1_first C2_first T1_first T1_second T2_first T2_second T3_first"
local cols "`cols' T3_second T4_first T4_second"
local rows "avg_contribution frac_who_punish frac_who_never_punish frac_who_punish_2p"
local rows "`rows' frac_punishment_below frac_punisher_above avg_income"

* Compute averages by treatment and period
local c = 1
foreach ses in C1 C2 T1 T2 T3 T4 {
  foreach s in 1 2 {
    local r = 1
    if "`ses'" == "C1" & `s' == 2 continue
    sum contrib if set == `s' & session == "`ses'" // average contribution
    mat A[`r', `c'] = round(r(mean), .01)
    local ++r
    sum you_punished if set == `s' & session == "`ses'" // average fraction who
    // punish in a period
    mat A[`r', `c'] = round(r(mean), .01) * 100
    local ++r
    sum never if set == `s' & session == "`ses'" // average fraction who
    // never punish
    mat A[`r', `c'] = round(r(mean), .01) * 100
    local ++r
    sum more_than_once if set == `s' & session == "`ses'" // average fraction who
    // punish in at least two periods
    mat A[`r', `c'] = round(r(mean), .01) * 100
    local ++r
    egen var1 = total(below) if set == `s' & session == "`ses'"
    egen var2 = total(punish) if set == `s' & session == "`ses'"
    gen var3 = var1 / var2
    sum var3 // how often punishment is directed at someone who contributed less
    // than the average of other group members
    mat A[`r', `c'] = round(r(mean), .01) * 100
    local ++r
    drop var*
    sum gave_more_than_avg if set == `s' & session == "`ses'" & you_punished == 1
    // how often punisher is someone who contributed more than the average of
    // other group members
    mat A[`r', `c'] = round(r(mean), .01) * 100
    local ++r
    sum profit if set == `s' & session == "`ses'" // average income
    mat A[`r', `c'] = round(r(mean), .01)
    local ++r
    local ++c
  }
}

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/tables/table2.xlsx", modify sheet("Experimental Design")
putexcel A1 = matrix(A), names

drop A*

********   Table 3: Comparisons of contributions, fraction who punish,   ********
**********   expenditure on punishment, and income across treatments  **********

* Initialize matrix
matrix A = J(22, 8, .)
local cols "contribution frac_who_punish exp_on_punishment income contribution"
local cols "`cols' frac_who_punish exp_on_punishment income"
local rows "observed _ p1_observed _ p2_observed _ p3_observed _ p4_observed _ "
local rows "`rows' p5_observed _ p6_observed _ p7_observed _ p8_observed _ "
local rows "`rows' p9_observed _ p10_observed _"

* Run regressions and hypothesis tests
local c = 1
foreach model in 1 2 {
  foreach var in contrib you_punished expend profit {
    if `model' == 1 {
      local r = 1
      glm `var' base mod_period#set // treatment effect (pooling periods)
      mat A[1, `c'] = round(_b[base], .001)
      mat A[2, `c'] = round(_se[base], .001)
    }
    if `model' == 2 {
      local r = 3
      glm `var' 1.base#mod_period mod_period#set // treatment effect by period
      forval n = 1/10 {
        mat A[`r', `c'] = round(_b[1.base#`n'.mod_period], .001)
        local r = `r' + 2
      }
      local r = 4
      forval n = 1/10 {
        ranksum `var' if mod_period == `n', by(base) exact // Wilcoxon two-sample
        // test
        mat A[`r', `c'] = round(r(p), .001)
        local r = `r' + 2
      }
    }
    local ++c
  }
}

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/tables/table3.xlsx", modify sheet("Table 3")
putexcel A1 = matrix(A), names

drop A*

******    Table 4: Estimates of punishment on deviation from group mean   ******

* Initialize matrix
matrix A = J(16, 8, .)
local cols "deviation deviation deviation deviation logit_deviation under_contrib"
local cols "`cols' over_contrib N"
local rows "observed _ unobserved _ C1 _ C2 _ T1 _ T2 _ T3 _ T4 _"

* Estimate models 1-4
local c = 1
// loop over models
forval model = 1/4 {
  // set controls
  if `model' == 2 | `model' == 4 {
    local controls i.subject#i.session_ind
  }
  else {
    local controls
  }
  if `model' == 3 | `model' == 4 {
    local controls `controls' i.period
  }
  else {
    local controls `controls'
  }
  // loop over treatments/sessions
  foreach ses in B1 B0 C1 C2 T1 T2 T3 T4 {
    if inlist("`ses'", "B1", "B0") {
      glm got diff set `controls' if base == 1 // estimate of effect of deviation
      // from group mean on punishment for observed treatment
      mat A[1, `c'] = round(_b[diff], .001)
      mat A[2, `c'] = round(_se[diff], .001)
      glm got diff set `controls' if base == 0 // estimate of effect of deviation
      // from group mean on punishment for unobserved treatment
      mat A[3, `c'] = round(_b[diff], .001)
      mat A[4, `c'] = round(_se[diff], .001)
      local r = 5
    }
    else {
      glm got diff set `controls' if session == "`ses'" // estimate of effect of
      // deviation from group mean on punishment by session
      mat A[`r', `c'] = round(_b[diff], .001)
      mat A[`r'+1, `c'] = round(_se[diff], .001)
      local r = `r' + 2
    }
  }
  local ++c
}
* Estimate model 5, loop over treatments/sessions
foreach ses in B1 B0 C1 C2 T1 T2 T3 T4 {
  if inlist("`ses'", "B1", "B0") {
    logit got diff set i.subject#i.session_ind if base == 1
    margins, dydx(diff)
    scalar n1 = r(b)[1,1]
    scalar n2 = sqrt(r(V)[1,1])
    mat A[1, 5] = round(n1, .001) // estimates of effects of over- and
    // under-contribution on punishment for observed treatment
    mat A[2, 5] = round(n2, .001)
    logit got diff set i.subject#i.session_ind if base == 0
    margins, dydx(diff)
    scalar n1 = r(b)[1,1]
    scalar n2 = sqrt(r(V)[1,1])
    mat A[3, 5] = round(n1, .001) // estimates of effects of over- and
    // under-contribution on punishment for unobserved treatment
    mat A[4, 5] = round(n2, .001)
    local r = 5
  }
  else {
    logit got diff set i.subject#i.session_ind if session == "`ses'"
    margins, dydx(diff)
    scalar n1 = r(b)[1,1]
    scalar n2 = sqrt(r(V)[1,1])
    // estimates of effects of over- and under-contribution on punishment by
    // session
    mat A[`r', 5] = round(n1, .001)
    mat A[`r'+1, 5] = round(n2, .001)
    local r = `r' + 2
  }
}
* Estimate model 6, loop over treatments/sessions
foreach ses in B1 B0 C1 C2 T1 T2 T3 T4 {
  if inlist("`ses'", "B1", "B0") {
    glm got ndiff pdiff set i.subject#i.session_ind i.period if base == 1
    mat A[1, 6] = round(_b[ndiff], .001) // estimates of effects of over- and
    // under-contribution on punishment for observed treatment
    mat A[2, 6] = round(_se[ndiff], .001)
    mat A[1, 7] = round(_b[pdiff], .001)
    mat A[2, 7] = round(_se[pdiff], .001)
    mat A[1, 8] = e(N)
    glm got ndiff pdiff set i.subject#i.session_ind i.period if base == 0
    mat A[3, 6] = round(_b[ndiff], .001) // estimates of effects of over- and
    // under-contribution on punishment for unobserved treatment
    mat A[4, 6] = round(_se[ndiff], .001)
    mat A[3, 7] = round(_b[pdiff], .001)
    mat A[4, 7] = round(_se[pdiff], .001)
    mat A[3, 8] = e(N)
    local r = 5
  }
  else {
    glm got ndiff pdiff set i.subject#i.session_ind i.period if session == "`ses'"
    // estimates of effects of over- and under-contribution on punishment by
    // session
    mat A[`r', 6] = round(_b[ndiff], .001)
    mat A[`r'+1, 6] = round(_se[ndiff], .001)
    mat A[`r', 7] = round(_b[pdiff], .001)
    mat A[`r'+1, 7] = round(_se[pdiff], .001)
    mat A[`r', 8] = e(N)
    local r = `r' + 2
  }
}

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/tables/table4.xlsx", modify sheet("Table 4")
putexcel A1 = matrix(A), names

drop A*

********   Table 5: Estimates of punishment expenditure as a function   ********
********************    of deviation from group average    *********************

* Initialize matrix
matrix A = J(16, 7, .)
local cols "deviation deviation deviation deviation under_contrib over_contrib N"
local rows "observed _ unobserved _ C1 _ C2 _ T1 _ T2 _ T3 _ T4 _"

* Estimate models 1-5
local c = 1
// loop over models
forval model = 1/4 {
  // set controls
  if `model' == 2 | `model' == 4 {
    local controls i.subject#i.session_ind
  }
  else {
    local controls
  }
  if `model' == 3 | `model' == 4 {
    local controls `controls' i.period
  }
  else {
    local controls `controls'
  }
  // loop over treatments/sessions
  foreach ses in B1 B0 C1 C2 T1 T2 T3 T4 {
    if inlist("`ses'", "B1", "B0") {
      reg expend diff set `controls' if base == 1 // estimate of effect of deviation
      // from group mean on punishment expenditure for observed treatment
      mat A[1, `c'] = round(_b[diff], .001)
      mat A[2, `c'] = round(_se[diff], .001)
      reg expend diff set `controls' if base == 0 // estimate of effect of deviation
      // from group mean on punishment expenditure for unobserved treatment
      mat A[3, `c'] = round(_b[diff], .001)
      mat A[4, `c'] = round(_se[diff], .001)
      local r = 5
    }
    else {
      reg expend diff set `controls' if session == "`ses'" // estimate of effect of
      // deviation from group mean on punishment expenditure by session
      mat A[`r', `c'] = round(_b[diff], .001)
      mat A[`r'+1, `c'] = round(_se[diff], .001)
      local r = `r' + 2
    }
  }
  local ++c
}
* Estimate model 5, loop over treatments/sessions
foreach ses in B1 B0 C1 C2 T1 T2 T3 T4 {
  if inlist("`ses'", "B1", "B0") {
    reg expend ndiff pdiff set i.subject#i.session_ind i.period if base == 1
    mat A[1, 5] = round(_b[ndiff], .001) // estimates of effects of over- and
    // under-contribution on punishment expenditure for observed treatment
    mat A[2, 5] = round(_se[ndiff], .001)
    mat A[1, 6] = round(_b[pdiff], .001)
    mat A[2, 6] = round(_se[pdiff], .001)
    mat A[1, 7] = e(N)
    reg expend ndiff pdiff set i.subject#i.session_ind i.period if base == 0
    mat A[3, 5] = round(_b[ndiff], .001) // estimates of effects of over- and
    // under-contribution on punishment expenditure for unobserved treatment
    mat A[4, 5] = round(_se[ndiff], .001)
    mat A[3, 6] = round(_b[pdiff], .001)
    mat A[4, 6] = round(_se[pdiff], .001)
    mat A[3, 7] = e(N)
    local r = 5
  }
  else {
    reg expend ndiff pdiff set i.subject#i.session_ind i.period if session == "`ses'"
    // estimates of effects of over- and under-contribution on punishment
    // expenditure by session
    mat A[`r', 5] = round(_b[ndiff], .001)
    mat A[`r'+1, 5] = round(_se[ndiff], .001)
    mat A[`r', 6] = round(_b[pdiff], .001)
    mat A[`r'+1, 6] = round(_se[pdiff], .001)
    mat A[`r', 7] = e(N)
    local r = `r' + 2
  }
}

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/tables/table5.xlsx", modify sheet("Table 5")
putexcel A1 = matrix(A), names
