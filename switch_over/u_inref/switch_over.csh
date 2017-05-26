#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : CONTROLLED SWITCHOVER (6.15 & 6.16 & 6.30)
#
# This test can also be invoked by filter test running with different versions on the primary and the secondary
# If the differing version is less tha V5.2 then chosing chset modes to be UTF-8 will be problematic.
# So switch to "M" mode if we detect the test version and the remote version running different versions and one less than V5.2
if ((52 > `echo $tst_ver|cut -c2-3`) || (52 > `echo $remote_ver|cut -c2-3`)) $switch_chset "M" >&! switch_chset.log
if ((53 > `echo $tst_ver|cut -c2-3`) || (53 > `echo $remote_ver|cut -c2-3`)) then
	# Support for replication to run with NOBEFORE_IMAGE started only at V52001. Therefore if the test is run for an
	# older version, set BEFORE_IMAGE unconditionally (even if test was started with -jnl nobefore).
	source $gtm_tst/com/gtm_test_setbeforeimage.csh
endif
# The secondary doesn't support SSL/TLS. So, set gtm_test_plaintext_fallback to allow the source side to fallback to plaintext
# communication.
setenv gtm_test_plaintext_fallback
# The test does a switch over and the secondary side is an old version. So A->P and P->Q is not possible
setenv test_replic_suppl_type 0
# The test uses prior versions of GT.M. Disable huge pages for versions prior to V60001
if ( (`expr "V60001" \> "$tst_ver"`) || (`expr "V60001" \> "$remote_ver"`) ) then
	foreach envvar (gtm_test_hugepages HUGETLB_MORECORE HUGETLB_SHM HUGETLB_VERBOSE LD_PRELOAD)
		unsetenv $envvar
	end
endif
setenv gtm_test_tptype "ONLINE"
setenv tst_buffsize 33000000
$gtm_tst/com/dbcreate.csh mumps 4 125 1000
setenv portno `$sec_shell "$sec_getenv; cat $SEC_DIR/portno"`
setenv start_time `cat start_time`

# use short globals (in pfill) for the filter test to be able to run against V4* versions
setenv gtm_test_useshortglobals 1
#
echo "Database fill program starts"
$gtm_tst/com/fgdbfill.csh >>&! fgdbfill.out
echo "Database fill program ends"
#
$gtm_tst/com/RF_sync.csh
$gtm_tst/com/rfstatus.csh "AFTER_STEP1:"
#
# SWITCH OVER STARTS#
#
echo "Switch started at: `date +%H:%M:%S`" >>&! time.log
echo "Shut down primary source server..."
$gtm_tst/com/SRC_SHUT.csh "." >>&! SHUT_${start_time}.out
echo "Shut down receiver server/update process..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
$gtm_tst/com/dbcheck.csh -noshut
#
$DO_FAIL_OVER
#
# NEW PRIMARY SIDE (B) UP
setenv start_time `date +%H_%M_%S`
echo "Restarting (B) as primary..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"
# NEW SECONDARY SIDE (A) UP
$gtm_tst/com/RCVR.csh "." $portno $start_time >&! RCVR_${start_time}.out
$gtm_tst/com/rfstatus.csh "BOTH_UP:"
echo "Switch ends at: `date +%H:%M:%S`" >>&! time.log
#
# SWITCH OVER ENDS#
#
echo "Starting database fill program on new primary side..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/fgdbfill.csh < /dev/null "">>&!"" fgdbfill.out"
echo "Database fill program ends"
#
$gtm_tst/com/rfstatus.csh "BEFORE_TEST_STOPS:"
$gtm_tst/com/dbcheck.csh -extract
cd $PRI_DIR
echo "Please look at time.log for timing information."
