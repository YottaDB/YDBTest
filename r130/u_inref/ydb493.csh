#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.  #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

#As go is not supported in UTF-8 mode changing to M mode
setenv gtm_test_unicode "FALSE"
echo "* Invoking switch_chset.csh M"
$switch_chset "M"

echo "=========================================="
echo "Part 1 populating data in database"
echo "=========================================="

$gtm_tst/com/dbcreate.csh "mumps" 1 125 700

echo "\n* Setting ^hello("one")="1" in database"
$ydb_dist/yottadb -r ^%XCMD 'set ^hello("one")="1"'


echo "\n=========================================="
echo "Part 2 extract "
echo "=========================================="

echo "* Extracting in zwr format"
$MUPIP extract -format=zwr extr.zwr
cat extr.zwr

echo "\n* Extracting in go format"
$MUPIP extract -format=go extr.go
cat extr.go


echo "\n=========================================="
echo "Part 3 load "
echo "=========================================="

foreach format("zwr" "go")
	set file="extr.$format"
	echo "* Removing .dat files to obtain a clean database for $file load"
	\rm *.dat

	echo "\n* Creating default database"
	$MUPIP create

	echo "\n* Check if the database doesn't have ^hello("one")="1" already"
	$ydb_dist/yottadb -r ^%XCMD 'if ^hello("one")="1" write "Failed: data already exist"'

	echo "\n* Performing mupip load with $format format"
	$MUPIP load $file -format=$format
	$ydb_dist/yottadb -r ^%XCMD 'if ^hello("one")="1" write "LOAD PASSED"',!
end

\rm *.dat
\rm *.gld
echo "\n==============================================="
echo "Part 4 Extract and Load in ZWR format with UTF8 "
echo "================================================"
setenv gtm_test_unicode "TRUE"
echo "\n* Invoking switch_chset.csh UTF-8"
$switch_chset "UTF-8"
echo "\n* Creating database"
$GDE_SAFE exit
$ydb_dist/mupip create
echo "\n* Setting ^hello("one")="1" in database"
$ydb_dist/yottadb -r ^%XCMD 'set ^hello("one")="1"'

echo "\n* Performing mupip extract with zwr format"
$MUPIP extract -format=zwr extr3.zwr
cat extr3.zwr

echo "* Removing .dat files to obtain a clean database for extr.zwr load"
\rm *.dat

echo "\n* Creating default database"
$MUPIP create

echo "\n* Check if the database doesn't have ^hello("one")="1" already"
$ydb_dist/yottadb -r ^%XCMD 'if ^hello("one")="1" write "Failed: data already exist"'

echo "\n* Performing mupip load with zwr format"
$MUPIP load extr3.zwr -format=zwr

$YDB << aaa
        if ^hello("one")="1" w "LOAD PASSED",!
aaa


echo "\n=========================================="
echo "Part 5 Load onto older version"
echo "==========================================="

# Removing .dat and .gld files to obtain a clean environment
\rm *.dat
\rm *.gld

# As go is not supported in UTF mode changing to M mode
setenv gtm_test_unicode "FALSE"
echo "\n* Invoking switch_chset.csh M"
$switch_chset "M"

set last_ver = `$gtm_tst/com/random_ver.csh -type any`
echo "$last_ver" > priorver.txt
echo "\n* Switching to older version\n"
source $gtm_tst/com/switch_gtm_version.csh $last_ver pro
$GDE_SAFE exit
foreach format("zwr" "go")
	set file="extr.$format"
	set file2="load$format.txt"
	echo "\n* Creating database"
	$ydb_dist/mupip create

	echo "\n* Check if the database is empty"
	$ydb_dist/mumps -r dbhasdata^ydb493

	echo "\n* Performing mupip load with $format format"
	$MUPIP load $file -format=$format >&! $file2
	grep -Fxq "YottaDB MUPIP EXTRACT" $file2
	if ($status) then
		echo "Has - "
		grep -E 'YottaDB MUPIP EXTRACT' $file2
	else
		echo "Doesn't have - YottaDB MUPIP EXTRACT"
	endif

	echo "\n* Checking if data is loaded"
	$ydb_dist/mumps -r dbhasdata^ydb493

	echo "\n* Removing .dat file to obtain a clean database"
	\rm *.dat
end

echo "\n* Completed"
