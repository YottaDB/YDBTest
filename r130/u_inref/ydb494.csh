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
set extrbiglabelzwr=`grep "^YottaDB MUPIP EXTRACT" extrbiglabel.zwr`

echo "\n# Extracting in go format with label having max string value"
$ydb_dist/mupip extract -format=go -label="$bigstring" extrbiglabel.go
set extrbiglabelgo=`grep "^YottaDB MUPIP EXTRACT" extrbiglabel.go`

# Checking load when label ( with special characters, of maximum size) is present in extract file
foreach labeltype("biglabel" "speciallabel")
	foreach format("zwr" "go")
		set file="extr$labeltype.$format"
		set file2="load$labeltype.$format.txt"
		echo "\n# Loading $file"

		$gtm_tst/$tst/u_inref/testloadcheck.csh "-format=$format" "$file">&! $file2

		if ("biglabel" == $labeltype) then
			# When the label length in mupip extract command is greater than (ZWR_GO_LABEL_MAX_SIZE or
			# ZWR_GO_LABEL_MAX_SIZE - UTF-8_NAME_LEN) the default label is formed having path, cmd and arguments.
			# Because of the size limit on the command line, it is possible some portion of the argument
			# gets truncated in case the first argument (which is dependent on realpath of $ydb_dist and
			# hence can vary depending on test env) is longer than usual.
			# In such a case statically comparing the label using reference files fail , so, we verify label's
			# presence and value by comparing the label seen in extract file and load. Expectation is they are same.
			set loadbiglabel=`grep "^YottaDB MUPIP EXTRACT" $file2`
			if (("zwr" == "$format") && ("$loadbiglabel" == "$extrbiglabelzwr")) then
				echo "LABEL WITH MAX LEN FOUND"
			else if (("go" == "$format") && ("$loadbiglabel" == "$extrbiglabelgo")) then
				echo "LABEL WITH MAX LEN FOUND"
			else
				echo "EXPECTED:\n`grep '^YottaDB MUPIP EXTRACT' $file`\nFOUND:\n$loadbiglabel"
				echo "LABEL WITH MAX LEN NOT FOUND IN $format"
			endif
		else
			grep -Fxq "$speciallabel" $file2
			if (0 == $status) then
				echo "LABEL WITH SPECIAL CHARACTERS FOUND"
			else
				echo "LABEL WITH SPECIAL CHARACTERS NOT FOUND"
			endif
		endif
		grep -Fxq "LOAD PASSED" $file2
		if (0 == $status) then
			echo "DATA LOAD PASSED"
		else
			echo "DATA LOAD FAILED"
		endif
	end
end
$gtm_tst/com/dbcheck.csh

echo "\n# Testing general usecases including upward compatibility of MUPIP extract with custom label"
testextract.csh 1
