#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log

echo "### Test 1: TPNOTACID call issued to syslog when ZEDIT called within a transaction"
set test_num = T1
# Set EDITOR to non-interactive editor for call to ZEDIT
setenv EDITOR `which sed`
echo 'extcall write "TEST",! quit' >& extcall.m
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time1
echo "# Call [gtm10099.m] routine to run ZEDIT in a transcation to produce TPNOTACID in syslog"
($gtm_dist/mumps -r gtm10099 $test_num >& $test_num.out &; echo $! >&! $test_num.pid) >& ${test_num}mumps.out
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time1
echo "# Confirm TPNOTACID appeared in syslog output for ZEDIT call"
echo "# Previously, no TPNOTACID message would appear for the ZEDIT call in gtm10099.m."
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" ${test_num}syslog.txt
set mpid = `cat $test_num.pid`
grep ".*\[$mpid\].*TPNOTACID, ZEDIT" ${test_num}syslog.txt
echo

echo "### Test 2: TPNOTACID call issued to syslog when external call made within a transaction"
set test_num = T2
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtm10099.c
$gt_ld_shl_linker ${gt_ld_option_output}gtm10099${gt_ld_shl_suffix} $gt_ld_shl_options gtm10099.o $gt_ld_syslibs
setenv	GTMXC gtmxc.tab
echo "`pwd`/gtm10099.so" > $GTMXC
cat >> $GTMXC << CAT_EOF
gtm10099:	void	gtm10099()
CAT_EOF
set syslog_begin = `date +"%b %e %H:%M:%S"`
echo "syslog_begin = $syslog_begin" > syslog_time1
echo "# Call [gtm10099.m] routine to make external call to the gtm10099() C function in a transaction to produce TPNOTACID in syslog"
cp $gtm_tst/$tst/inref/gtm10099.m .
$gtm_dist/mumps gtm10099.m
($gtm_dist/mumps -r gtm10099 $test_num >& $test_num.out &; echo $! >&! $test_num.pid) >& ${test_num}mumps.out
set syslog_end = `date +"%b %e %H:%M:%S"`
echo "syslog_end = $syslog_end" >> syslog_time1
echo "# Confirm TPNOTACID appeared in syslog output for external call"
echo "# Previously, no TPNOTACID message would appear for the external call in gtm10099.m."
$gtm_tst/com/getoper.csh "$syslog_begin" "$syslog_end" ${test_num}syslog.txt
set mpid = `cat $test_num.pid`
grep ".*\[$mpid\].*TPNOTACID, CALL OUT" ${test_num}syslog.txt

$gtm_tst/com/dbcheck.csh mumps >& dbcheck.log
