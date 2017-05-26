#!/usr/local/bin/tcsh -f
#
######################################
### instream.csh for tprollbk test ###
######################################
#
# C9B12001841 [rog] test $REFERENCE after a partial rollback
echo "TPROLLBK test Starts..."
setenv subtest_list "tprollbk_nojnl tprollbk_jnl C9B12001841"
# filter out subtests that cannot pass with MM
# tprollbk_jnl	needs before image journaling for backwards recovery
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "tprollbk_jnl"
endif
$gtm_tst/com/submit_subtest.csh
echo "TPROLLBK test DONE."
#
##################################
###          END               ###
##################################
# Also add the subtest to appropriate subtest_list (replic vs non-replic etc) - and remove this line
