#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_spanreg 0	# Test requires traditional global mappings because it assumes a set ^a=1
				# will update AREG (in the %XCMD call below), so disable spanning regions

echo "# ----------------------------------------------------------------------"
echo '# Test that MUPIP commands accept either space or "=" after "-region'
echo "# Below commands are picked from the list at https://gitlab.com/YottaDB/DB/YDB/-/issues/851#note_1674367308"
echo "# ----------------------------------------------------------------------"

echo "# Create a database with regions AREG, BREG, CREG and DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 4

echo "# Initialize all regions with some data"
$gtm_dist/mumps -run %XCMD 'set ^a=1,^b=1,^c=1,^d=1'

foreach nregs (1 2)
	if ($nregs == 1) then
		echo "#####################################################################"
		echo "# Test that all MUPIP commands work fine with single region (DEFAULT)"
		echo "#####################################################################"
		set reglist = "DEFAULT"
	else
		echo "#####################################################################"
		echo "# Test that all MUPIP commands work fine with multiple regions (CREG,AREG)"
		echo "#####################################################################"
		set reglist = "CREG,AREG"
	endif
	foreach mupipcmd (dumpfhead create extract integ reorg size rundown set upgrade)
		foreach after (" " "=")
			set shellcmd = "mupip $mupipcmd -region${after}$reglist"
			if ("extract" == $mupipcmd) then
				if ("$after" == " ") then
					set name = "space"
				else
					set name = "equal"
				endif
				set shellcmd = "$shellcmd extract${nregs}_${name}.ext"
			else if ("set" == $mupipcmd) then
				set shellcmd = "$shellcmd -acc=BG"
			endif
			echo "# Testing [$shellcmd]"
			if (("create" == $mupipcmd) && ("$nregs" == 2)) then
				echo "# MUPIP CREATE is an exception in case multiple regions are specified"
				echo "# It treats the comma-separated list of region names as 1 region name"
				echo "# It issues an error so we expect an error below"
			endif
			if (("dumpfhead" == $mupipcmd) || ("integ" == $mupipcmd) || ("reorg" == $mupipcmd) || ("size" == $mupipcmd)) then
				# integ/reorg/size output has non-deterministic output so just search for lines with "region"
				# as that is what we are interested in this test. Also sort the output since we have seen the
				# region order in the output change (likely based on ftok).
				$gtm_dist/$shellcmd |& $grep "region" | sort
			else if ("rundown" == $mupipcmd) then
				# sort the output for the same reasons as previous "if" (random/ftok order of region output)
				set shellcmd2 = "mupip $mupipcmd -r${after}$reglist"
				$gtm_dist/$shellcmd |& sort
				echo "# Testing [$shellcmd2]"
				$gtm_dist/$shellcmd2 |& sort
			else if ("set" == $mupipcmd) then
				# sort the output for the same reasons as previous "if" (random/ftok order of region output)
				$gtm_dist/$shellcmd |& sort
			else
				$gtm_dist/$shellcmd
			endif
		end
	end
end

echo ""
echo "# ----------------------------------------------------------------------"
echo "# Miscellaneous tests of use cases noted in YDB#851 on gitlab"
echo "# ----------------------------------------------------------------------"

echo "# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/851#note_1674367308"
echo "# Expect a %YDB-E-CLIERR error if -region and region name is separated by another qualifier"
echo "mupip integ -region -online DEFAULT"
$MUPIP integ -region -online DEFAULT

echo "# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/851#note_1675982258"
echo "# Expect a %YDB-E-CLIERR error if -region is specified but region name is not"
echo "mupip integ -region"
$MUPIP integ -region
echo "echo DEFAULT | mupip integ -region"
echo DEFAULT | $MUPIP integ -region

echo "# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/851#note_1675986337"
echo "# Expect a %YDB-E-CLIERR error if arbitrary name is specified before -region"
echo "# This used to treat that arbitrary parameter as the region name previously"
echo "mupip integ ABCD -region"
$MUPIP integ ABCD -region
echo "# Test that parameer specified AFTER -region is treated as region name and not the one BEFORE -region"
echo "# In below example, we expect EFGH to be the region name and not ABCD"
echo "# This used to treat that arbitrary parameter as the region name previously"
echo "mupip integ ABCD -region EFGH"
$MUPIP integ ABCD -region EFGH

echo "# Test of value expected but not found error for -REGION qualifier when -REGION= is not immediately followed by value"
echo "mupip integ ABCD -region="
$MUPIP integ ABCD -region=
echo "mupip integ ABCD -region= EFGH"
$MUPIP integ ABCD -region= EFGH

echo "# Do integ check at end of test"
$gtm_tst/com/dbcheck.csh

