#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#GTM-7164
#    ORLBK : online_rollback : mupip trigger operations should be hit with a DBROLLEDBACK
setenv gtm_test_trigger 1
setenv test_specific_trig_file $gtm_tst/com/imptp.trg

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 5 125 1000 1024 4096 1024 4096

$echoline
echo "Start source server with journaling enabled"
$MSR STARTSRC INST1 INST2 RP

$gtm_exe/mumps -run triginstallorlbk
# Wait for the background jobs to complete. The pids are available in the *.mjo* files created by the "do ^job(...)"
# invocations done in triginstallorblk.m (there are 2 of them). The pids are stored as the second subscript in lines
# of the form "lock +^jobroller(1,PID1)" or "lock +^jobtrigger(1,PID2)". Hence the grep/sed expression below.
foreach pid (`grep -E "lock \+\^job(roller|trigger)" *.mjo* | sed 's/.*,//;s/)//;'`)
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 600
end

$echoline
echo "Start receiver server with journaling enabled"
$MSR STARTRCV INST1 INST2
$MSR SYNC ALL_LINKS
$MSR STOP ALL_LINKS

$gtm_tst/com/dbcheck_filter.csh -extract
