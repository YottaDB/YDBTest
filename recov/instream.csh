#!/usr/local/bin/tcsh -f
#
# We have removed mupip_set_jnlstate_0101_crash :: duplicate of C9C01001899_repeat_switch
# We have removed repeat_back_recov 		:: duplicate of ideminter_rolrec
# We have removed repeat_recover_after_crash 	:: duplicate of ideminter_rolrec
# We have removed repeat_rollback.csh 		:: duplicate of ideminter_rolrec
# We have removed repeat_rollback_after_crash	:: Added into rollback test
# setenv subtest_list "no_jnl_recov"	# Incomplete test. Do not remove from CVS
# D9E04002440_nobefore	: This is specially because Trivin Reported corrupt journal file with nobefore
#
if ($?test_replic) then
	echo " Not applicable for replication"
	exit
endif
#
setenv subtest_list "C9C01001899_repeat_switch mupip_backup_0_1 D9E04002440_nobefore D9E04002445"
# filter out subtests that cannot pass with MM
# C9C01001899_repeat_switch	Needs BEFORE image journaling
# mupip_backup_0_1		Needs BEFORE image journaling
setenv subtest_exclude_list ""
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "C9C01001899_repeat_switch mupip_backup_0_1"
endif
# The z/OS version of truss, bpxtrace, doesn't quite work right
if ("os390" == $gtm_test_osname) then
	setenv subtest_exclude_list "$subtest_exclude_list D9E04002445"
endif
#
$gtm_tst/com/submit_subtest.csh
#
##################################
###          END               ###
##################################
