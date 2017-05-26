#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# To avoid reference file issues with suppl_INSTC in the shutdown command below (in case of A->P or P->Q), set A->B replication.
setenv test_replic_suppl_type 0

$gtm_tst/com/dbcreate.csh mumps 1


set shmid = `$MUPIP replic -edit -show $gtm_repl_instance	\
		|& $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("HDR","Journal Pool Shm Id"),!'`

echo
echo "===> Journal pool shared memory ID = GTM_TEST_DEBUGINFO $shmid <==="
echo

set start_time = `cat start_time`
# Wait for the Source Server to have written/read all information to/from the instance file before we move the instance file
# under a different name to avoid any unexpected REPLINSTOPEN errors.
$gtm_tst/com/wait_for_log.csh -message "New History Content" -log SRC_$start_time.log -duration 30

echo
echo "===> Move replication instance file under a different name <==="
echo
mv mumps.repl mumps.repl.bak

echo
echo "===> Run argumentless MUPIP RUNDOWN to ensure it doesn't remove the shared memory ID corresponding to this instance <==="
echo
$MUPIP rundown >&! mupip_rundown.outx
$grep -w "id = $shmid" mupip_rundown.outx | sed 's/id = [0-9]*/id = ##SHMID##/'

echo
echo "===> Move replication instance file back to the original name (to allow for shutdown) <==="
echo
mv mumps.repl.bak mumps.repl

echo
echo "===> Now, shutdown the source server. This should encounter NO errors"
echo
$MUPIP replic -source -shutdown -timeout=0

echo
echo "===> Now, shutdown the receiver server and passive source server as well to avoid dbcheck errors"
echo
$sec_shell "cd $SEC_SIDE;  $MUPIP replic -receiv -shut -time=0"
echo
$sec_shell "cd $SEC_SIDE;  $MUPIP replic -source -shut -time=0"
$sec_shell "$sec_getenv ; cd $SEC_SIDE; source $gtm_tst/com/portno_release.csh"
echo
$gtm_tst/com/dbcheck.csh -noshut
