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
# $1 -> 1 then script is run with custom label with a value "hello world"
# $1 -> 0 then script is run without custom label
if ($1) then
	set label=1
else
	set label=0
endif


# As GO extract format is not supported in UTF-8 mode changing to M mode
setenv gtm_test_unicode "FALSE"
echo "# Invoking switch_chset.csh M"
$switch_chset "M"

echo "=========================================="
echo "Part 1 populating data in database"
echo "=========================================="

$gtm_tst/com/dbcreate.csh "mumps" 1 125 700

echo "\n# Setting ^hello("one")="1" in database"
$ydb_dist/yottadb -r ^%XCMD 'set ^hello("one")="1"'


echo "\n=========================================="
echo "Part 2 extract "
echo "=========================================="

echo "# Extracting in zwr format"
if ($label) then
	$ydb_dist/mupip extract -format=zwr -label="hello world" extr.zwr
else
	$ydb_dist/mupip extract -format=zwr extr.zwr
endif
cat extr.zwr

echo "\n# Extracting in go format"
if ($label) then
	$ydb_dist/mupip extract -format=go -label="hello world" extr.go
else
	$ydb_dist/mupip extract -format=go extr.go
endif
cat extr.go


echo "\n=========================================="
echo "Part 3 load "
echo "=========================================="

foreach format("zwr" "go")
	$gtm_tst/$tst/u_inref/testloadcheck.csh "-format=$format" "extr.$format"
end
$gtm_tst/com/dbcheck.csh
\rm *.dat
\rm *.gld
echo "\n==============================================="
echo "Part 4 Extract and Load in ZWR format with UTF8 "
echo "================================================"
setenv gtm_test_unicode "TRUE"
echo "\n# Invoking switch_chset.csh UTF-8"
$switch_chset "UTF-8"
echo "\n# Creating database"
$GDE_SAFE exit
$ydb_dist/mupip create
echo "\n# Setting ^hello("one")="1" in database"
$ydb_dist/yottadb -r ^%XCMD 'set ^hello("one")="1"'

echo "\n# Performing mupip extract with zwr format"
if ($label) then
	$ydb_dist/mupip extract -format=zwr -label="hello world" extr3.zwr
else
	$MUPIP extract -format=zwr extr3.zwr
endif
cat extr3.zwr

$gtm_tst/$tst/u_inref/testloadcheck.csh "-format=zwr" "extr3.zwr"

$gtm_tst/com/dbcheck.csh
echo "\n=========================================="
echo "Part 5 Load onto older version"
echo "==========================================="

# Removing .dat and .gld files to obtain a clean environment
\rm *.dat
\rm *.gld

# As go is not supported in UTF mode changing to M mode
setenv gtm_test_unicode "FALSE"
echo "\n# Invoking switch_chset.csh M"
$switch_chset "M"

set last_ver = `$gtm_tst/com/random_ver.csh -type any`
echo "$last_ver" > priorver.txt
echo "\n# Switching to older version\n"
source $gtm_tst/com/switch_gtm_version.csh $last_ver pro
$GDE_SAFE exit
foreach format("zwr" "go")
	set file="extr.$format"
	set file2="load$format.txt"
	echo "\n# Creating database"
	$ydb_dist/mupip create

	echo "\n# Check if the database is empty"
	$ydb_dist/mumps -r dbhasdata^testextr

	echo "\n# Performing mupip load with $format format"
	$ydb_dist/mupip load $file -format=$format >&! $file2

	if ($label) then
		setenv label_text 'hello world'
	else
		setenv label_text 'YottaDB MUPIP EXTRACT'
	endif
	echo "\n# Check if $label_text is present"
		grep -E "$label_text" $file2

	echo "\n# Checking if data is loaded"
	$ydb_dist/mumps -r dbhasdata^testextr

	echo "\n# Removing .dat file to obtain a clean database"
	\rm *.dat
end

echo "\n# Completed"
