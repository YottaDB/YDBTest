#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo "# [YDB#1353] MUPIP INTEG -REGION releases crit on a region it skips because of DBFLCORRP             #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo "# MUPIP INTEG -REGION gets crit on each region, and gets DBFLCORRP right after it if the database file"
echo "# header says the file is corrupt. It then skips that region and goes on to the next one, but it still"
echo "# held crit on the skipped region, so in a Debug build freezing the next region with -NOONLINE failed an"
echo "# assert in region_freeze.c. Each stage runs MUPIP INTEG on two regions, of which the first (AREG) is"
echo "# marked corrupt, checks that it integs the second (DEFAULT) without an assert failure, and prints PASS"
echo "# or WRONG."
echo

# Online INTEG uses a snapshot, which MM does not support, so use BG.
setenv acc_meth BG
echo "setenv acc_meth BG"	>> settings.csh

echo '# Create a database with two regions, AREG (a.dat) and DEFAULT (mumps.dat)'
$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
echo

echo '# Mark AREG as corrupt'
echo '# Command : $DSE find -region=AREG, change -fileheader -corrupt_file=TRUE'
$DSE >& dse_corrupt.out << DSE_EOF
find -region=AREG
change -fileheader -corrupt_file=TRUE
DSE_EOF
echo

set stage = 0
foreach qual (-noonline -online)
	@ stage++
	echo "# Stage $stage : MUPIP INTEG $qual -REGION *"
	echo '#   expect DBFLCORRP for AREG, then no errors for DEFAULT'
	if ("-noonline" == "$qual") then
		echo '#   previously a Debug build failed an assert in region_freeze.c when it froze DEFAULT'
	else
		echo '#   previously crit on AREG was also held when integ went on to DEFAULT, but nothing checked it'
	endif
	echo '# Command : $MUPIP integ '"$qual"' -reg "*"'
	$MUPIP integ $qual -reg "*" >& integ$stage.out
	$grep -q "YDB-F-ASSERT" integ$stage.out
	if ($status) then
		echo "PASS : no assert failure"
	else
		echo "WRONG : assert failure, see integ$stage.out"
	endif
	$grep -q "^Integ of region DEFAULT" integ$stage.out
	if ($status) then
		echo "WRONG : MUPIP INTEG did not integ DEFAULT, see integ$stage.out"
	else
		set noerrs = `$grep -c "^No errors detected by integ." integ$stage.out`
		if (1 == $noerrs) then
			echo "PASS : DEFAULT has no errors"
		else
			echo "WRONG : $noerrs regions instead of 1 have no errors, see integ$stage.out"
		endif
	endif
	echo '# Expected errors : DBFLCORRP for AREG (also at exit, from the rundown of AREG), MUNOTALLINTEG, NOTALLDBRNDWN'
	$gtm_tst/com/check_error_exist.csh integ$stage.out "YDB-E-DBFLCORRP" "YDB-W-MUNOTALLINTEG" "YDB-E-NOTALLDBRNDWN"
	echo
end

echo '# Mark AREG as not corrupt, so that the database can be checked'
echo '# Command : $DSE find -region=AREG, change -fileheader -corrupt_file=FALSE'
$DSE >& dse_uncorrupt.out << DSE_EOF
find -region=AREG
change -fileheader -corrupt_file=FALSE
DSE_EOF
echo '# Expected error : DSE reports DBFLCORRP as a warning when it opens AREG, which is still marked corrupt'
$gtm_tst/com/check_error_exist.csh dse_uncorrupt.out "YDB-W-DBFLCORRP"
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
