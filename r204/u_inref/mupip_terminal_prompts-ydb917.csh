#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# There were 5 mupip commands that when run with the -file flag with no files in the command line"
echo '# would display the prompt "File or Region: ", but would only accept a file.'
echo "# These commands are mupip dumpfhead, integ, upgrade, set, and rundown."
echo "# For dumpfhead and integ the behavior also happens when given no arguments at all."
echo '# These prompts have been changed to "File: ".'
echo "# This test checks that the prompts are now correct."
echo "# This test also checks the fix to a mupip dumpfhead bug where the newline that was"
echo "# intended to go after the prompt and before the output would be printed after the output was printed."
echo

echo "# We start by creating a database as some of the tests will test entering"
echo "# real file or region names."
$gtm_tst/com/dbcreate.csh mumps
set start_time=`date "+%Y-%m-%d %H:%M:%S"`
echo

echo "# Testing mupip dumpfhead with non-existent file without -file arg."
echo '# For all non-existent file checks, the name "fake.txt" is used.'
echo "# Previously, this would say File or Region:, but now should just say File:"
echo "# as inputting a region name has never worked with this interface."
echo "# As the file does not exist we expect a NOTAPATH error."
$gtm_dist/mupip dumpfhead << EOF
fake.txt
EOF
echo

echo "# Next an expect script will test what happens when stdin is a terminal device"
echo "# and when stdin and stdout are both terminal devices."
echo "# Running the expect script for stdin=terminal stdout=file"
env > env2.txt
expect $gtm_tst/$tst/u_inref/ydb917.exp > expect.outx
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
echo "# The file ea.outx has the result of stdin being a terminal device and stdout a file."
echo "# We will now cat ea.outx and expect to see the File: prompt followed"
echo "# by a file not found error."
cat ea.outx
echo
echo "# Next, run the expect script for both the input and output streams being a terminal device."
echo "# We will check the output in this case by greping for the expected output."
echo "# If the expected output is not found, the entire output will be printed to the log."
echo "# Otherwise, just a note that the expected output was found."
expect $gtm_tst/$tst/u_inref/ydb917_2.exp > expect_2.outx
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
grep -zPq "\%DUMPFHEAD-F-NOTAPATH Path fake.txt does not exist[\s]+\%YDB-E-MUNOFINISH, MUPIP unable to finish all requested actions" expect_2.outx
if ($?) then
	echo "# grep did not find expected output, printing entire output"
	cat expect.outx
else
	echo "# grep found expected output"
endif

echo
echo "# Testing mupip dumpfhead with a real DB file."
echo "# Output stored in dumphead.txt."
$gtm_dist/mupip dumpfhead << EOF > dumphead.txt
mumps.dat
EOF
echo "# Checking the number of lines that start with 'record' in the output file."
echo "# Note that the test will pass if it finds 10 or more such lines."
grep -a "^record" "dumphead.txt" | wc -l
echo "# checking that the first line is just 'File:'."
echo "# Previously there would be not newline after the first line before the 'File:'"
echo "# so that the first line would be something like"
echo "# File:record("sgmnt_data.abandoned_kills")=0"
echo "# but now should just be File:"
head -n 1 dumphead.txt
echo "# Next, check that mupip dumpfhead works when stdin and stdout are not the terminal."
echo "# First, we will check dumpfhead where stdin is not the terminal."
echo "# We expect to see that dumpfhead producing output in the proper order,"
echo "# FIRST prompting the user for a file name, THAN reporting a failure to find fake.txt"
echo "# and issuing a general warning about failed mupip commands."
echo "fake.txt" | $gtm_dist/mupip dumpfhead
echo "# Next, check the case where the output is redirected to a file but the input is from the terminal."
echo '# We expect the output file to contain the "File:" prompt'
echo "# first on its own line followed by a no file found error message."
$gtm_dist/mupip dumpfhead << EOF > a.outx
fake.txt
EOF
cat a.outx
echo "# Next, check mupip dumpfhead when both the input and output device are not"
echo "# a terminal. This test will be tested with directing standard error and out"
echo "# into a file and just directing standard out into a file."
echo "# as stderr is not redirected we expect an "unable to finish all requested actions" error."
echo "fake.txt" | $gtm_dist/mupip dumpfhead > b.outx
echo "fake.txt" | $gtm_dist/mupip dumpfhead >& c.outx
echo "# Now checking the result with just stdout."
echo '# We expect to see the "FILE:" prompt first and'
echo "# then on a separate line a file not found error."
cat b.outx
echo "# And now checking the result that also has stderr"
echo "# expecting the same result as without stderr but with an error message at the end."
cat c.outx
echo "# Additionally, at some points there was a TERMWRITE error being sent to the syslog."
echo "# So now we check to ensure that none of this created a TERMWRITE error."
echo "# Note that contamination from other concurrent tests on the "
echo "# system is theoretically possible for this part of the test."
$gtm_tst/com/getoper.csh "$start_time" "" syslog1.txt ""
grep TERMWRITE syslog1.txt || echo "no TERMWRITE message found in syslog."
echo

echo "# Now checking the error message for mupip upgrade with the -file argument"
echo "# with a non-existent file."
echo "# Previously, this would say File or Region:, but now should just say File:"
echo "# as inputting a region name has never worked with this interface."
echo "# Note, for mupip upgrade, the warning prompt is answered with 'y'."
$gtm_dist/mupip upgrade -file << EOF
fake.txt
y
EOF
echo "# And again mupip upgrade, this time with a real region"
echo "# to make sure a real region is not accepted."
echo '# We expect a "No such file or directory" error message.'
$gtm_dist/mupip upgrade -file << EOF
DEFAULT
y
EOF
echo

echo "# Now checking the error message for mupip set with the -file argument"
echo "# with a non-existent file."
echo "# Previously, this would say File or Region:, but now should just say File:"
echo "# as inputting a region name has never worked with this interface."
$gtm_dist/mupip set -file << EOF
fake.txt
EOF
echo "# And again mupip set, this time with a real region"
echo "# to make sure a real region is not accepted."
$gtm_dist/mupip set -file << EOF
DEFAULT
EOF
echo

echo "# Now checking the error message for mupip rundown with the -file argument"
echo "# with a non-existent file."
echo "# Previously, this would say File or Region:, but now should just say File:"
echo "# as inputting a region name has never worked with this interface."
$gtm_dist/mupip rundown -file << EOF
fake.txt
EOF
echo "# And again mupip rundown, this time with a real region"
echo "# to make sure a real region is not accepted."
echo '# We expect a "No such file or directory" error indicating a region name did not work.'
$gtm_dist/mupip rundown -file << EOF
DEFAULT
EOF

echo
echo "# Now checking the error message for mupip integ with the -file argument"
echo "# with a non-existent file."
echo "# Previously, this would say File or Region:, but now should just say File:"
echo "# as inputting a region name has never worked with this interface."
$gtm_dist/mupip integ -file << EOF
fake.txt
EOF
echo "# As mupip integ, unlike most of the other commands, also works without the -file argument"
echo "# we will now test mupip integ with a non-existent file without the -file argument."
echo "# This should give exactly the same output as testing with the -file argument above"
$gtm_dist/mupip integ << EOF
fake.txt
EOF
echo "# And again mupip integ, this time with a real region"
echo "# to make sure a real region is not accepted."
echo '# We expect an "Error opening database file DEFAULT" message indicating that'
echo "# a region name does not work."
$gtm_dist/mupip integ -file << EOF
DEFAULT
EOF
echo "# Now mupip integ with a real region name without the -file arg"
echo "# to check that the output is identical to the output with the -file tag above."
$gtm_dist/mupip integ << EOF
DEFAULT
EOF
echo

echo "# Now checking the error message for mupip dumpfhead with the -file argument"
echo "# with non-existent file."
echo "# Previously, this would say File or Region:, but now should just say File:"
echo "# as inputting a region name has never worked with this interface."
$gtm_dist/mupip dumpfhead -file << EOF
fake.txt
EOF
echo "# And again mupip dumpfhead, this time with a real region"
echo "# to make sure a real region is not accepted."
echo '# We expect "Path DEFAULT does not exist" indicating a region does not work.'
$gtm_dist/mupip dumpfhead -file << EOF
DEFAULT
EOF
echo

echo "# Running dbcheck.csh."
$gtm_tst/com/dbcheck.csh
