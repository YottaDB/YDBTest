#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_spanreg 0	# because we dont support remote regions for globals spanning multiple regions
source $gtm_tst/com/dbcreate.csh mumps 4 -key=40 -rec=512
#AREG is local, all others GT.CM
# Test case for basic operations in GT.CM environment
# And C9C08-002116
echo "Changing the key size to a larger value at one remote host"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2;$GDE @$gtm_tst/$tst/inref/keychng.gde >& keychng.out"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; \rm -f *.dat; $MUPIP create >& create.out"

$gtm_exe/mumps -run gtcm101

$GTM << GTM_EOF
d ^gtcm
GTM_EOF

$gtm_exe/mumps -run tdata^gtcm
$gtm_exe/mumps -run tquery^gtcm
$gtm_exe/mumps -run trevquery^gtcm
$gtm_exe/mumps -run tget^gtcm
$gtm_exe/mumps -run torder^gtcm
$gtm_exe/mumps -run tzprev^gtcm
$gtm_exe/mumps -run setpie^gtcm
$gtm_exe/mumps -run textr^gtcm
$gtm_exe/mumps -run tkill^gtcm

$gtm_exe/mumps -run gvstats^gtcm

$gtm_tst/com/dbcheck.csh

echo "# Run rqtest08, rqtest07 and rqtest10 sections of the r110/reversequery subtest using GT.CM GNP"
echo "# To avoid duplicating that test code here, we copy it explicitly even though it is in a different test"
source $gtm_tst/com/dbcreate.csh mumps 4 -key=255 -rec=512
cp $gtm_tst/r110/inref/rqtest08.m .
$gtm_exe/mumps -run ^rqtest08
cp $gtm_tst/r110/inref/rqtest07.m .
cp $gtm_tst/r110/inref/rqtest10.m .
foreach stdnull (true false)
	$rsh $tst_remote_host_1  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_1 ; cd $SEC_DIR_GTCM_1; $gtm_tst/$tst/u_inref/stdnull.csh $stdnull >& stdnull_${stdnull}.out"
	foreach querydir (1 -1)
		$gtm_dist/mumps -run rqtest07 $querydir $stdnull
	end
	$gtm_dist/mumps -run rqtest10 $stdnull
end
$gtm_tst/com/dbcheck.csh

echo "# Run C9E10002648 test using GT.CM GNP"
echo "# To avoid duplicating that test code here, we copy it explicitly even though it is in a different test"
source $gtm_tst/com/dbcreate.csh mumps 4 -key=255 -rec=512
cp $gtm_tst/v53004/inref/c002648.m .
$gtm_exe/mumps -run c002648
$gtm_tst/com/dbcheck.csh

