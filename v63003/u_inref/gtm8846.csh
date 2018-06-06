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
$MUPIP set -region default -journal=enable,on,nobefore,file=abcd.mjl >>& set.out
rm *.mjl* >>& rm.out
rm *.dat* >>& rm.out

mkdir temp
set rand=`$gtm_tst/com/genrandnumbers.csh 2 1 100`
set rand1=${rand[1]}
set rand2=${rand[2]}
$MUPIP create
set i = 1
foreach x (`seq 75 1 85` $rand1 $rand2)
	echo "# -----------------------------------------"
	echo "# $x slashes"
	echo "# -----------------------------------------"
	@ i++
	$ydb_dist/mumps -run gtm8846 $x >>& slash$i.out
	set s1="."`cat slash$i.out`
	set s2="temp"`cat slash$i.out`
	echo "# Verifying no Journal Files before running Mupip Set"
	$gtm_tst/com/lsminusl.csh *.mjl
	$gtm_tst/com/lsminusl.csh temp/*.mjl
	echo "# Paths we are feeding to Mupip Set Command"
	echo $s1
	echo $s2
	$MUPIP SET -REGION DEFAULT -JOURNAL=ENABLE,ON,BEFORE,FILE=$s1
	$MUPIP SET -REGION DEFAULT -JOURNAL=ENABLE,ON,BEFORE,FILE=$s2
	echo "# Verifying journal file was made properly"
	$gtm_tst/com/lsminusl.csh *.mjl* |& $tst_awk '{print $1 " " $2 " " $3 " " $4 " " $9}'
	$gtm_tst/com/lsminusl.csh temp/*.mjl* |& $tst_awk '{print $1 " " $2 " " $3 " " $4 " " $9}'
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
