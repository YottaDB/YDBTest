#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# pre-multisite version of multisite_replic/update_helpers subtest
if !($?gtm_test_replay) then
	set extfilter_choice = `$gtm_exe/mumps -run rand 2`
	echo "# Randomly chosen extfilter choice : $extfilter_choice"	>>&! settings.csh
	echo "setenv extfilter_choice $extfilter_choice"		>>&! settings.csh
endif
if ($extfilter_choice) then
	source $gtm_tst/com/random_extfilter.csh	# sets gtm_tst_ext_filter_src and gtm_tst_ext_filter_rcvr env vars
else
	set filtername = "oldextfilter"
	setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^$filtername"
	setenv gtm_tst_ext_filter_rcvr "$gtm_exe/mumps -run ^$filtername"
endif
$gtm_tst/com/dbcreate.csh mumps 4 125 1000 4096 2000 4096 2000
echo "#- Start the Updates:"
setenv gtm_test_tptype "ONLINE"
setenv gtm_test_tp "TP"
setenv gtm_process  5
setenv tst_buffsize 33000000
$gtm_tst/com/imptp.csh $gtm_process >>&! imptp.out
sleep 50
echo "# Stop the updates"
$gtm_tst/com/endtp.csh >>&! imptp.out

$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
