#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that the condition handler established in {mupip,util}_exit_handler() prevents NOCHLEFT errors.

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just a source server
# startup causing it to not treat itself as the last writer when it goes through gds_rundown. This means
# it will not issue a NOTALLDBRNDWN error like the test wants (even though it does issue a DBFLCORRP error
# like the test wants) so disable counter overflow in this test by setting the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

# Force reading from journal so that we can provoke a DBFLCORRP below.
setenv gtm_test_jnlfileonly 1

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps			>& dbcreate.log
$MSR START INST1 INST2 RP			>& start1.log

set srcpid=`$gtm_tst/com/get_pid.csh src`

echo "# Check mupip_exit_handler"
get_msrtime
set start_time=$time_msr
# Stop the receiver so that we can control when the source does a journal read.
# But before that ensure the source and receiver have connected. Or else we could get an INSUNKNOWN error
# when the receiver is restarted a little later in case the test framework chooses "test_replic_suppl_type"
# env var of 1 (i.e. A->P connection where P is supplementary).
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log -message "New History Content"'
$MSR STOPRCV INST1 INST2			>& stoprcv.log
# Add a transaction to read
$gtm_exe/mumps -r %XCMD 'set ^a=1'
$DSE CHANGE -FILEHEADER -CORRUPT_FILE=TRUE	>& corrupt.log
# Start the receiver, which will force the source to try to read the transaction on the corrupt database.
$MSR STARTRCV INST1 INST2			>& startrcv.log
$gtm_tst/com/wait_for_proc_to_die.csh $srcpid 300 "" nolog
$gtm_tst/com/check_error_exist.csh SRC_${start_time}.log DBFLCORRP NOTALLDBRNDWN

# We don't currently have a scenario which produces a NOCHLEFT from lke/dse pre-GTM-8501, but leave this here
# as a placeholder in case we come up with something.

#echo "# Check util_exit_handler"
#$gtm_exe/lke show -all

# Return to a sane state
$DSE CHANGE -FILEHEADER -CORRUPT_FILE=FALSE	>& uncorrupt.logx
# The source will have exited due to the above errors, so restart it.
$MSR STARTSRC INST1 INST2			>& startsrc.log

echo "# Final Checks"
$gtm_tst/com/dbcheck.csh
