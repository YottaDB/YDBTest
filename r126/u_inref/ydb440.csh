#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that yottadb will not optimize XECUTE lines if more commands follow it
#
#

echo '# Test that yottadb will not optimize XECUTE lines if more commands follow it'

# run the driver
echo '\n# mumps -machine -lis=xecutebug.lis xecutebugA.m'
cp $gtm_tst/$tst/inref/xecutebugA.m .
$gtm_dist/mumps -machine -lis=xecutebugA.lis xecutebugA.m
echo '# greping for "OC_" should see "OC_COMMARG" output if compiled correctly'
echo '# the OC_COMMARG corresponds to an unoptimized XECUTE'
grep "OC_" xecutebugA.lis

echo '\n# mumps -machine -lis=xecutebug.lis xecutebugB.m'
cp $gtm_tst/$tst/inref/xecutebugB.m .
$gtm_dist/mumps -machine -lis=xecutebugB.lis xecutebugB.m
echo '# greping for "OC_" should not see "OC_COMMARG" in the output if compiled correctly'
echo '# the OC_COMMARG corresponds to an unoptimized XECUTE'
grep "OC_" xecutebugB.lis
