#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
###########################################
### mu_freeze.csh test for mupip freeze ###
###########################################
#
#
echo MUPIP FREEZE
#
#
@ corecnt = 1
setenv gtmgbldir "freeze.gld"
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh "freeze" 1 125 700 1536 400 256
else
	$gtm_tst/com/dbcreate.csh "freeze" 1 125 700 1536 100 256
endif
#
#
#######################
# basic functionality #
#######################
#
#
$GTM << GTM_EOF
d fill1^myfill("set")
d fill1^myfill("ver")
s ^a="old"
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "fr" "$corecnt"
#
#
($gtm_exe/mumps -r freeze &) >&! my_freeze.log
#
#
# 7.30.02
$MUPIP freeze -on NOEXIST
if ( 0 == $status ) then
    echo TEST-E-ERROR from mupip freeze NOEXIST does not exist
endif
#
#Region Name in Mixed cases should be accepted
#
$MUPIP freeze -on Default >& freeze_on_DEFAULT.out
if ( $status > 0 ) then
    echo TEST-E-ERROR from mupip freeze on DEFAULT.
endif
touch frozen.txt
#
#
# to make sure the other process has already
# tried to s ^a="new"
sleep 5
#$gtm_tst/$tst/u_inref/wait.csh done_freeze.txt verbose
#
#
$GTM << GTM_EOF
set failmsg="mu_freeze FAILED 1."
i (^a="old")  w "mu_freeze PASS 1.",!
e  w failmsg,!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "fr" "$corecnt"
#
#
$MUPIP freeze -off -override DEFAULT >& freeze_off_DEFAULT.out
if ( $status > 0 ) then
    echo TEST-E-ERROR from mupip freeze off DEFAULT.
endif
#
#
$gtm_tst/com/wait_for_log.csh -log done_freeze.txt -waitcreation -duration 180 -vrb>& wait1.log
$GTM << GTM_EOF
s failmsg="mu_freeze FAILED 2."
i (^a="new")  w "mu_freeze PASS 2.",!
e  w failmsg,!,"^a is: ",^a,!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "fr" "$corecnt"
#
#
$GTM << GTM_EOF
d fill1^myfill("ver")
s ^a="old"
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "fr" "$corecnt"
#
#
$gtm_tst/com/dbcheck.csh
#
#
if ($LFE == "L") then
	exit
endif
#
#
#############################
# multi-region and wildcard #
#############################
#
#
\rm -rf freeze.dat >& /dev/null
\rm -rf freeze.gld >& /dev/null
\rm -rf frozen.txt >& /dev/null
\rm -rf done_freeze.txt >& /dev/null
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	$gtm_tst/com/dbcreate.csh "freeze" 3 125 700 1536 300 256
else
	$gtm_tst/com/dbcreate.csh "freeze" 3 125 700 1536 100 256
endif
#
#
$GTM << GTM_EOF
d fill1^myfill("set")
d fill1^myfill("ver")
s ^a="old"
s ^b="old"
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "fr" "$corecnt"
#
#
($gtm_exe/mumps -r freeze &) >>&! my_freeze2.log
#
#
$MUPIP freeze -on "*" >& freeze_on_all.out
if ( $status > 0 ) then
    echo TEST-E-ERROR from mupip freeze on wildcard.
endif
touch frozen.txt
#
#
# to make sure the other process has already
# tried to s ^a="new",^b="new"
sleep 5
#
#
$GTM << GTM_EOF
s failmsg="mu_freeze FAILED 3."
i (^a="old")&(^b="old")  w "mu_freeze PASS 3.",!
e  w failmsg,!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "fr" "$corecnt"
#
#
$MUPIP freeze -off -override "*" >& freeze_off_all.out
if ( $status > 0 ) then
    echo TEST-E-ERROR from mupip freeze off wildcard.
endif

#
#
$gtm_tst/com/wait_for_log.csh -log done_freeze.txt -waitcreation -duration 180	-vrb>&! wait2.log
$GTM << GTM_EOF
s failmsg="mu_freeze FAILED 4."
i (^a="new")&(^b="new")  w "mu_freeze PASS 4.",!
e  w failmsg,!
h
GTM_EOF
source $gtm_tst/$tst/u_inref/check_core_file.csh "fr" "$corecnt"
#
#
$gtm_tst/com/dbcheck.csh
#
#
########################
# END of mu_freeze.csh #
########################
