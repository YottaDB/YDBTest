#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# this is not a multisite test, but it is easier this way
echo "External Filter test with a bad filter"
$MULTISITE_REPLIC_PREPARE 2
setenv gtm_tst_ext_filter_src \""$gtm_exe/mumps -run ^notalive"\"
$gtm_tst/com/dbcreate.csh mumps 1
$MSR START INST1 INST2
get_msrtime
setenv srclogfile SRC_${time_msr}.log
setenv pidsrc12 `$tst_awk '/Source server is alive in ACTIVE mode/ {print $2}' START_${time_msr}.out`
$GTM << EOF
s ^abc=1234
EOF
# Slow boxes (particularly those with 1-cpu) have been seen to take ~ 5 minutes to issue the FILTERNOTALIVE error
# in the source server log file. Therefore wait for 10 minutes (higher than the default of 2 minutes).
$gtm_tst/com/wait_for_log.csh -log $srclogfile -message FILTERNOTALIVE -duration 600
$gtm_tst/com/check_error_exist.csh $srclogfile FILTERNOTALIVE
# make sure source server process has stopped before removing jnlpool ipcs
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc12 120
if ($status) then
	echo "TEST-E-ERROR process $pidsrc12 did not die."
endif
$MSR STOPRCV INST1 INST2
$MSR REFRESHLINK INST1 INST2
# The jnlpool ipcs are left-behind when the source dies. Let's clean those up here:
# A mupip rundown would take care of this cleaning up. Need to use -override to avoid MUUSERLBK errors
$MUPIP rundown -reg "*" -override >& rundown.log
$gtm_tst/com/dbcheck.csh
