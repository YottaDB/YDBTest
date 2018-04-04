#!/usr/local/bin/tcsh
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
# Test the handling of max key size from 3-1019.
#
# Choose value randomly between 3 and 1019
set value = `$gtm_dist/mumps -run ^%XCMD 'write $RANDOM(1020)'`
if (3 > $value) set value=3
echo "Max key size = $value"
setenv gtmdbglvl 49 # to check for memory corruption
# Create one-region gld and associated .dat file
$gtm_tst/com/dbcreate.csh mumps 1 $value 2048 2048

echo ""
echo "Try 1021 writes to globals with each one having a keysize one larger than the previous one"
$gtm_dist/mumps -run gtm6502 1021 >& gv.out
echo ""
echo "Check for the correct number of successes and failures based on the max key size in the database"
$gtm_dist/mumps -run check^gtm6502 $value 1021
$GTM << GTM_EOF
do ^%G
maxkey.glo
*
GTM_EOF
echo ""
echo "Globals are in maxkey.glo, with ^f being the number of failures"
set failures = `$gtm_dist/mumps -run ^%XCMD 'write ^f'`
echo ""
echo "Number of failures in ^f should equal number of lines containing GVSUBOFLOW in gv.out"
set error_lines = `$grep -c GVSUBOFLOW gv.out`
echo ""
if ($failures == $error_lines) then
	echo "Passed"
	# move this file so we don't see the expected YDB-E-GVSUBOFLOW errors
	mv gv.out gv.outx
else
	echo "Failed"
endif
echo ""
$gtm_tst/com/dbcheck.csh
