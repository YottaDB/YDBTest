#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
#C9G09-002804 Update process needs GVSUBOFLOW check
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 23
echo "CHECKING GVSUBOFLOW FOR KILL"
$gtm_tst/com/dbcreate.csh mumps 1 64 256
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
$GTM <<EOF
s ^a("12dfrfdfe")=12
halt
EOF
$gtm_tst/com/RF_sync.csh
echo "# Change key and record size at the receiver"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ;source $gtm_tst/$tst/inref/dsekeychng.dse 7 11>& keychng.out"
setenv start_time1 `date +%H_%M_%S`
echo "Starting receiver server ..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""on"" $portno $start_time1 < /dev/null "">>&!"" $SEC_SIDE/START_${start_time1}.out"
$GTM <<EOF
kill ^a("12dfrfdfe")
halt
EOF
# Check GVSUBOFLOW error exists in the log file
source $gtm_tst/$tst/u_inref/check_for_errors.csh "GVSUBOFLOW"   # dbcheck.csh call from check_for_errors.csh
$gtm_tst/com/check_error_exist.csh dbcheck.out "DBGTDBMAX" "INTEGERRS">>& ignore_err.outx
$sec_shell "$sec_getenv; cd $SEC_SIDE; if (-f *.err*) mv *.err* ERR_MU;"
cat dbcheck.out
echo ""
echo "Restoring the key and record size"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ;source $gtm_tst/$tst/inref/dsekeychng.dse 64 256>& keychng.out"
echo "Should not see any integ errors now"
$MUPIP integ mumps.dat
