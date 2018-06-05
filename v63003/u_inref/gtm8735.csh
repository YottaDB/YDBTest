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
#

echo '# Creating database, manually setting variables so database is compatible with read only'
setenv gtm_test_db_format "NO_CHANGE"
setenv acc_meth MM
setenv test_encryption NON_ENCRYPT
source $gtm_tst/com/mm_nobefore.csh
$gtm_tst/com/dbcreate.csh mumps 1 >>& create1.out
$MUPIP SET -region DEFAULT -ACCESS_METHOD=MM -NOSTATS >>& settings.out

echo '# Setting default region to read only'
$MUPIP SET -region DEFAULT -READ_ONLY >& readonly.out
$DSE dump -file|&$grep "Access method"
$DSE dump -file|&$grep "Read Only"

echo '# Attempting to set a global variable while in read only mode'
$ydb_dist/mumps -run ^%XCMD "set ^X=1"

echo '# Attempting to set access method to BG while in read only mode'
$MUPIP SET -region DEFAULT -ACCESS_METHOD=BG
$DSE dump -file|&$grep "Access method"
$DSE dump -file|&$grep "Read Only"



echo '# Setting default region to no read only'
$MUPIP SET -region DEFAULT -NOREAD_ONLY
$DSE dump -file|&$grep "READ_ONLY"
$DSE dump -file|&$grep "Access method"
$DSE dump -file|&$grep "Read Only"



echo '# Setting a global variable'
$ydb_dist/mumps -run ^%XCMD "set ^X=1"
$ydb_dist/mumps -run ^%XCMD "zwrite ^X"

echo '# Setting access method to BG'
$MUPIP SET -region DEFAULT -ACCESS_METHOD=BG
$DSE dump -file|&$grep "Access method"
$DSE dump -file|&$grep "Read Only"


echo '# Attempting to set default region to read only with a BG access method'
$MUPIP SET -region DEFAULT -READ_ONLY
$DSE dump -file|&$grep "Access method"
$DSE dump -file|&$grep "Read Only"


echo '# Displaying status of gtmhelp databases to verify files have read-only permissions for user/group/other'
$gtm_tst/com/lsminusl.csh $ydb_dist/*.dat|$tst_awk '{print $1,$9}'

foreach dir ($ydb_dist/*.gld)
	echo "# Displaying status of "$dir
	setenv ydb_gbldir $dir
	$DSE dump -file |& $grep "Read Only"
	echo "# Attempting to change to no read only"
	$MUPIP SET -region DEFAULT -NOREAD_ONLY
	echo "# Attempting to write to database"
	$ydb_dist/mumps -run ^%XCMD "set ^X=2"
end
$gtm_tst/com/dbcheck.csh mumps 1 >>& check1.out

