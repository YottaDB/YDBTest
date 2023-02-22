#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $gtm_tst/com/cre_coll_sl.csh com/col_reverse.c 1
source $gtm_tst/com/cre_coll_sl.csh com/col_straight.c 2

setenv gtm_test_col_return_version 3
setenv gtm_collate_1 $PWD/libreverse.so
setenv gtm_collate_2 $PWD/libstraight.so
setenv gtm_collate_3 $PWD/libreverse.so

$GDE @$gtm_tst/$tst/inref/collationtests.gde >&! gdeout.out

$GDE show -gblname

$MUPIP create >&! mupipcreate.out

$gtm_tools/offset.csh sgmnt_data dse_dmp_fhead.c >&! dse_dmp_fhead_offset.out
set colveroffset = `$tst_awk '/def_coll_ver/ { gsub(/\[|\]/,"") ; print $4}' dse_dmp_fhead_offset.out`
$DSE << DSE_EOF >&! dse_change_def.out
find -reg=REG6
change -fi -def=2
change -fi -hexloc=$colveroffset -val=$gtm_test_col_return_version
find -reg=REG5
change -fi -def=3
find -reg=REG4
change -fi -def=2
find -reg=REG1
change -fi -def=0
DSE_EOF


$gtm_exe/mumps -run %XCMD 'set ^efgh(1,2,"efgh")="efgh_1_2_efgh",^mnop(1)="mnop_1"'
$gtm_exe/mumps -run %XCMD 'write ^efgh(1,2,"efgh"),\!,^mnop(1),\!'

echo "# Point the collation libraries to older versions of the exact same library"
echo "# Expect COLLTYPVERSION errors from both ^efgh (which uses libreverse) and ^mnop (using libstraight)"
setenv gtm_test_col_return_version 1
$gtm_exe/mumps -run wrongcoll^collationtests
$GDE show -gblname

echo "# Point the collation libraries to newer versions of the exact same library"
echo "# Expect COLLTYPVERSION errors only from ^mnop using libstraight - which has stricter version compatibility check"
setenv gtm_test_col_return_version 5
$gtm_exe/mumps -run wrongcoll^collationtests
$GDE show -gblname

echo "# Point the collation libraries to the original versions"
setenv gtm_test_col_return_version 3

$gtm_exe/mumps -run gbldeftests^collationtests
$gtm_exe/mumps -run ygldcolltests^collationtests
$gtm_exe/mumps -run viewregs^collationtests
$gtm_exe/mumps -run gbldef2^collationtests

echo "# Run YCOLLATE tests when the current collation version (gtm_test_col_return_version) is $gtm_test_col_return_version"
$gtm_exe/mumps -run ycollatetests^collationtests
unsetenv gtm_test_col_return_version
echo "# Run YCOLLATE tests when the current collation version is 0 (gtm_test_col_return_version undefined)"
$gtm_exe/mumps -run ycollatetests^collationtests
