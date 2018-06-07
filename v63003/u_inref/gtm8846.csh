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
# Tests that Mupip Set can handle extra slashes before a filename
#
source $gtm_tst/com/gtm_test_setbgaccess.csh
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps 1>>& create.out
if ($status) then
	echo "DB Create Failed, Output Below"
	cat create.out
endif
rm *.mjl* >>& rm.out
rm *.dat* >>& rm.out

mkdir temp
set rand=`$gtm_tst/com/genrandnumbers.csh 2 1 100`
set rand1=${rand[1]}
set rand2=${rand[2]}
$MUPIP create
echo "Testing with number of slashes ranging from 75 to 85 and to random numbers"
foreach x (`seq 75 1 85` $rand1 $rand2)
	echo "# -----------------------------------------"
	echo "# $x slashes"
	echo "# -----------------------------------------"
	$ydb_dist/mumps -run gtm8846 $x >& slash.out
	set s1="."`cat slash.out`
	set s2="temp"`cat slash.out`
	echo "# Verifying no Journal Files before running Mupip Set"
	ls *.mjl*
	ls temp/*.mjl*
	echo "# Paths we are feeding to Mupip Set Command"
	echo $s1
	echo $s2
	$MUPIP SET -REGION DEFAULT -JOURNAL=ENABLE,ON,BEFORE,FILE=$s1
	$MUPIP SET -REGION DEFAULT -JOURNAL=ENABLE,ON,BEFORE,FILE=$s2
	echo "# Verifying journal file was made properly"
	ls *.mjl*
	ls temp/*.mjl*
	rm abcd*
	rm temp/abcd*
end

$gtm_tst/com/dbcheck.csh >>& check.out
if ($status) then
	echo "DB Check Failed, Output Below"
	cat check.out
endif
