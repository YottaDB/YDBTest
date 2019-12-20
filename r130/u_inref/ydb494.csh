#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

# As go is not supported in UTF mode changing to M mode
setenv gtm_test_unicode "FALSE"
echo "# Invoking switch_chset.csh M"
$switch_chset "M"

# Testing mupip extract with label including all special characters "#$%&'()*+,-./:;<=>?@[\]^_{}|~"
echo "\n# Creating Database"
$gtm_tst/com/dbcreate.csh "mumps" 1 125 700

echo "\n# Setting ^hello("one")="1" in database"
$ydb_dist/yottadb -r ^%XCMD 'set ^hello("one")="1"'

set speciallabel='hello #$%& ( ) *+,-./: ; < = > ?@[\]^_{} | ~world'
echo "\n# Extracting in zwr format with custom label including special characters"
$ydb_dist/mupip extract -format=zwr -label="$speciallabel" extrspeciallabel.zwr
cat extrspeciallabel.zwr

echo "\n# Extracting in go format with custom label including special characters"
$ydb_dist/mupip extract -format=go -label="$speciallabel" extrspeciallabel.go
cat extrspeciallabel.go

# Generating 32767 length string for max length string for label value test
$ydb_dist/yottadb -r ^%XCMD 'w $$^longstr(32767)' >&! maxstring.txt
set bigstring=`cat maxstring.txt`

echo "\n# Extracting in zwr format with label having max string value"
$ydb_dist/mupip extract -format=zwr -label="$bigstring" extrbiglabel.zwr
cat extrbiglabel.zwr
echo "\n# Extracting in go format with label having max string value"
$ydb_dist/mupip extract -format=go -label="$bigstring" extrbiglabel.go
cat extrbiglabel.go

# Checking load when label with special characters is present in extract file
# Checking load when label of maximum size is present in extract file
foreach labeltype("biglabel" "speciallabel")
	foreach format("zwr" "go")
		set file="extr$labeltype.$format"
		set file2="load$labeltype.$format.txt"

		$gtm_tst/$tst/u_inref/testloadcheck.csh "-format=$format" "$file">&! $file2

		if ("biglabel" == $labeltype) then
			# only certain amount of $bigstring is copied as label as the size is larger than allowed. So we use the reference file to test in this case.
			# verifies label presence, error for passing extra long label and Load's success
			cat $file2
		else
			grep -Fxq "$speciallabel" $file2
			if ($status == 0) then
				echo "label with special characters found"
			else
				echo "label with special characters not found"
			endif
			grep -Fxq "LOAD PASSED" $file2
			if ($status == 0) then
				echo "LOAD PASSED"
			else
				echo "LOAD FAILED"
			endif
		endif
	end
end
$gtm_tst/com/dbcheck.csh

echo "\n# Testing general usecases including upward compatibility of MUPIP extract with custom label"
testextract.csh 1
