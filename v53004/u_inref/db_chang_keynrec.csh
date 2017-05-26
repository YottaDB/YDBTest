#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 23

$gtm_tst/com/dbcreate.csh mumps 1 -key=256 -rec=1024 -bl=512,1024
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
echo "# Change key and record size at the receiver"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; $GDE @$gtm_tst/$tst/inref/keychng.gde >& keychng.out"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; \rm -f *.dat; $MUPIP create >& create.out"
# dbcheck.csh called by the callers.
