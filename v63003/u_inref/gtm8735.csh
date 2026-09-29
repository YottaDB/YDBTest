#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries.	#
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
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create1.out
endif
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
# The help databases in $ydb_dist are shared by every concurrently running subtest. If another process has one
# open, for example a process that used %PEEKBYNAME (such as an imptp worker), which keeps the help database open
# until it exits, MUPIP SET issues READONLYLKFAIL instead of DBFILOPERR. So the steps below work on a copy of each
# help database, which has the same file header and read-only permissions, through a copy of its global directory
# that points at the copy.
foreach gld ($ydb_dist/*.gld)
	set name = $gld:t:r
	echo "# Copying $name.gld and $name.dat from ydb_dist and pointing the copy of $name.gld at the copy of $name.dat"
	cp $gld $name.gld
	chmod u+w $name.gld
	cp $gld:r.dat $name.dat
	chmod 444 $name.dat
	setenv ydb_gbldir $name.gld
	# -file_name must be the last qualifier on the line as it takes the rest of the line
	$GDE change -segment DEFAULT -file_name=$PWD/$name.dat >& gde_$name.out
	if ($status) then
		echo "GDE Failed, Output Below"
		cat gde_$name.out
	endif
	echo "# Displaying status of $name.dat"
	$DSE dump -file |& $grep "Read Only"
	echo "# Attempting to change to no read only"
	$MUPIP SET -region DEFAULT -NOREAD_ONLY
	echo "# Attempting to write to database"
	$ydb_dist/mumps -run ^%XCMD "set ^X=2"
end
unsetenv ydb_gbldir	# so dbcheck.csh below checks mumps.dat and not the last help database copy
$gtm_tst/com/dbcheck.csh mumps 1 >>& check1.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check1.out
endif

