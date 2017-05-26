#!/usr/local/bin/tcsh -f
#
######################################################################################
# C9D03-002250 Support Long Names
# indirection tests to support long names
######################################################################################
# [kishore] lblrtn "This tests the labels and routines using indirection (long names)"
# [kishore] atomic "This tests 'set @"xxx"="yyy"'  local/global with/without subscripts
# [kishore] maxindr longname test for max indirection
# [kishore] ind_stress run-time indirection stress using Long Names
# [kishore] indircom "Indirect code for certain commands using long names"
######################################################################################

echo "Long Names indirection test starts ..."

setenv subtest_list "lblrtn atomic maxindr ind_stress indircom"

$gtm_tst/com/submit_subtest.csh
echo "Long Names indirection test DONE."

