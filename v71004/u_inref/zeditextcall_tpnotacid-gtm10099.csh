#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-10099 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410099)

GT.M uses TPNOTACID behavior for all external calls and for ZEDIT; previously, external calls and the ZEDIT command were exempted from TPNOTACID handling. (GTM-10099)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log

# ZEDIT runs $EDITOR after the TPNOTACID check, so use an editor that does nothing and returns at once
setenv EDITOR `which true`

# Build the external call to the gtm10099() C function. Its object file is named gtm10099xc.o, since a gtm10099.o
# in the current directory would be taken as the object file of the gtm10099.m routine.
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtm10099.c -o gtm10099xc.o >& gtm10099_cc.out
$gt_ld_shl_linker ${gt_ld_option_output}gtm10099xc${gt_ld_shl_suffix} $gt_ld_shl_options gtm10099xc.o $gt_ld_syslibs >& gtm10099_ld.out
echo "`pwd`/gtm10099xc${gt_ld_shl_suffix}" > gtm10099.tab
echo "gtm10099: void gtm10099()" >> gtm10099.tab
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_xc GTMXC gtm10099.tab

echo "### Test 1: ZEDIT in the final retry of a transaction sends a TPNOTACID warning to the syslog"
echo "# Run [gtm10099.m], which restarts a transaction 3 times and then runs ZEDIT"
echo "# Expect a TPNOTACID warning for ZEDIT. Previously, ZEDIT sent no TPNOTACID message."
set test_num = T1
set t = `date +"%b %e %H:%M:%S"`
# The process runs in the background only to note its pid, so that only its own syslog messages are checked
($gtm_dist/mumps -run gtm10099 $test_num >& $test_num.out &; echo $! >& $test_num.pid) >& ${test_num}_bckg.out
set pid = `cat $test_num.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
cat $test_num.out
$gtm_tst/com/getoper.csh "$t" "" ${test_num}_syslog.txt "" "\[\<$pid\>\].*TPNOTACID"
$grep "\[\<$pid\>\].*TPNOTACID" ${test_num}_syslog.txt | sed 's/.*%GTM-W-TPNOTACID/%GTM-W-TPNOTACID/; s/ -- generated from .*//'
echo

echo "### Test 2: An external call in the final retry of a transaction sends a TPNOTACID warning to the syslog"
echo "# Run [gtm10099.m], which restarts a transaction 3 times and then calls the gtm10099() C function"
echo "# Expect EXT CALL from the function, and a TPNOTACID warning for the call. Previously, an external call sent no"
echo "# TPNOTACID message."
set test_num = T2
set t = `date +"%b %e %H:%M:%S"`
($gtm_dist/mumps -run gtm10099 $test_num >& $test_num.out &; echo $! >& $test_num.pid) >& ${test_num}_bckg.out
set pid = `cat $test_num.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
cat $test_num.out
$gtm_tst/com/getoper.csh "$t" "" ${test_num}_syslog.txt "" "\[\<$pid\>\].*TPNOTACID"
$grep "\[\<$pid\>\].*TPNOTACID" ${test_num}_syslog.txt | sed 's/.*%GTM-W-TPNOTACID/%GTM-W-TPNOTACID/; s/ -- generated from .*//'

$gtm_tst/com/dbcheck.csh mumps >& dbcheck.log
