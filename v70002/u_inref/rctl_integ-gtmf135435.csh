#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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
GTM-F135435 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637482)

GT.M detects and recovers from certain integrity errors in the auto-relink control structures. GT.M also issues RLNKRECNFL
and RLNKINTEGINFO messages to the system log to report an integrity check. Previously, GT.M terminated with an
segmentation violation (SIG-11) or a GT.M assert when it encountered such integrity errors. (GTM-F135435)

CAT_EOF
echo ''

# We do not want autorelink-enabled directories that have been randomly assigned by the test system
# because we will assign the autorelink directory by ourself.
source $gtm_tst/com/gtm_test_disable_autorelink.csh
setenv ydb_msgprefix "GTM"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 176 # WBTEST_RTNOBJ_INTEG
echo "# This is a whitebox test that only runs in debug mode."
echo ''
echo '# Create database file'
$gtm_tst/com/dbcreate.csh mumps
echo ''
mkdir obj src1 src2
echo '# Create 2 different routines in same name'
echo 'rtn(x) set (text,x)="rtn 1" quit:$quit x quit' > src1/rtn.m
echo 'rtn(x) set (text,x)="rtn 2" quit:$quit x quit' > src2/rtn.m
echo ''
# Set start time for getoper.csh
set syslog_start = `date +"%b %e %H:%M:%S"`
echo '# Run the routine'
# Start M process that will create relinkctl file
echo '# WBTEST_RTNOBJ_INTEG will be triggered when numvers >= 2. So purpose of this routine is for make numvers=2'
echo '# and that will print out RLNKRECNFL and RLNKINTEGINFO in syslog.'
echo '# (numvers is the counter for number of version for routine in relinkctl file when enabled autorelink)'
echo '# First, we set $zroutines to "obj*(src1)" and compile rtn.m in src1 to obj/rtn.o in Process A.'
echo '# This will increase numvers to 1. After that, we start Process B and let process B set $zroutines to "obj*"'
echo '# Then, we proceed to compile different rtn.m in src2 to obj/rtn.o.'
echo '# Now numvers will increase to 2 and this will trigger the WBTEST_RTNOBJ_INTEG and'
echo '# will print out RLNKRECNFL and RLNKINTEGINFO in syslog'
$gtm_exe/mumps -run procA^gtmf135435
echo ''
# Check for system log
$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt
echo '# Check if RLNKRECNFL and RLNKINTEGINFO exist in syslog'
$grep -E "RLNKRECNFL|RLNKINTEGINFO" test_syslog.txt
echo ''
$gtm_tst/com/dbcheck.csh
