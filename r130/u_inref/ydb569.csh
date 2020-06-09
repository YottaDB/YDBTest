#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.  	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# Although .bin and .go load is tested here, -ignorechset load option has no effect in these formats,
# tests for these formats are present only to ensure -ignorechset option doesn't change original load behavior.
echo "\n======================================================"
echo "Part 1 Extract in ZWR, GO & BINARY format with M CHSET"
echo "======================================================"
setenv gtm_test_unicode "FALSE"
echo "* Invoking switch_chset.csh M"
$switch_chset "M"

$gtm_tst/com/dbcreate.csh "mumps" 1 125 700

echo "\n* Setting ^hello("one")="1" in database"
$ydb_dist/yottadb -r ^%XCMD 'set ^hello("one")="1"'

echo "* Extracting in zwr format"
$MUPIP extract -format=zwr extr.zwr

echo "\n* Extracting in go format"
$MUPIP extract -format=go extr.go

echo "\n* Extracting in binary format"
$MUPIP extract -format=binary extr.bin

$gtm_tst/com/dbcheck.csh
\rm *.dat
\rm *.gld

echo "\n====================================================="
echo "Part 2 Extract in ZWR & BINARY format with UTF8 CHSET"
echo "====================================================="
setenv gtm_test_unicode "TRUE"
echo "\n* Invoking switch_chset.csh UTF-8"
$switch_chset "UTF-8"

echo "\n* Creating database"
$gtm_tst/com/dbcreate.csh "mumps" 1 125 700

echo "\n* Setting ^hello("one")="1" in database"
$ydb_dist/yottadb -r ^%XCMD 'set ^hello("one")="1"'

echo "\n* Performing mupip extract with zwr format"
$MUPIP extract -format=zwr extr3.zwr

echo "\n* Performing mupip extract with binary format"
$MUPIP extract -format=binary extr3.bin
$gtm_tst/com/dbcheck.csh

echo "\n=========================================="
echo "Part 3 load "
echo "=========================================="
# Already in UTF-8 chset, so chset change not required for first foreach iteration
echo "\n* loading M extracted files in UTF-8 mode"
set file="extr"
foreach chset("UTF-8" "M")
	if ("M" == $chset) then
		echo "\n* change chset from UTF-8 to M and create db"
		\rm *.dat
		\rm *.gld
		setenv gtm_test_unicode "FALSE"
		echo "\n* Invoking switch_chset.csh M"
		$switch_chset "M"
		$gtm_tst/com/dbcreate.csh "mumps" 1 125 700

		set file="extr3"
		echo "\n* loading UTF-8 extracted files in M mode"
	endif
	foreach ext("zwr" "bin" "go")
		if (("M" == $chset) && ("go" == $ext)) then
			# skip
		else
			$gtm_tst/$tst/u_inref/ydb569loadcheck.csh "$file.$ext" "-ignorechset"
		endif
	end
end

echo "\n=========================================="
echo "Part 4 test optional part of -i[gnorechset]"
echo "=========================================="
foreach option("-i" "-ig" "-ign" "-igno" "-ignor" "-ignore" "-ignorec" "-ignorech" "-ignorechs" "-ignorechse")
        $gtm_tst/$tst/u_inref/ydb569loadcheck.csh "extr3.zwr" $option
end

echo "\n=========================================="
echo "Part 5 CHSET mismatch error when -ignorechset option is not used and the file is extracted in UTF-8 and being loaded to M"
echo "=========================================="
$gtm_tst/$tst/u_inref/ydb569loadcheck.csh "extr3.zwr" ""

$gtm_tst/com/dbcheck.csh
echo "\n* Completed"
