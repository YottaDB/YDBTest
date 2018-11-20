#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "-----------------------------------------------------------------------------------------------------------------------"
echo "# Test that an external call from MUMPS will defer processing a flush timer until after the external process concludes."
echo "-----------------------------------------------------------------------------------------------------------------------"

# Need to disable spanning region test-system option
setenv gtm_test_spanreg 0

# Pre-V63004 versions will pass in MM mode, so need to force BG mode
setenv acc_meth BG

# If this test chose r120 as the prior version, GDE won't work with that version unless ydb_msgprefix is set to "GTM".
# (https://github.com/YottaDB/YottaDB/issues/193). Therefore, set ydb_msgprefix to "GTM" in that case.
if ($tst_ver == "V63003A_R120") then
	setenv ydb_msgprefix "GTM"
endif

echo ""
echo "# Create a Database with 2 regions, DEFAULT and AREG"
$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate.txt
if ($status) then
	echo "# DBCreate failed, output as followed:"
	cat dbcreate.txt
	exit -1
endif

source $gtm_tst/$tst/u_inref/gtm8926_setc.csh

echo "# Run m script, which will start two job processes"
echo "# The first job process will set ^X to a value, call an external c program,and wait until ^A is set to True to exit the external call"
echo "# The second job will wait until ^X is set to a value, and if no flush has occured, it will set ^A to True."

$ydb_dist/mumps -run gtm8926^gtm8926
echo ""
echo "# Check and Close Database"
$gtm_tst/com/dbcheck.csh >& dbcheck.txt
if ($status) then
	echo "# DBCheck failed, output as followed:"
	cat dbcheck.txt
	exit -1
endif
