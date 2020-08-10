#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test that Interrupted MUPIP EXTRACT STDOUT to a pipe does not leave terminal in unfriendly state"

$gtm_tst/com/dbcreate.csh mumps

echo "# Populate database with enough global variable nodes that take up more than a page of terminal output"
$ydb_dist/mumps -run %XCMD 'for i=1:1:10000 set ^x(i)=$j(i,20)'

echo 'PS1="SHELL$ "' > .bashrc	# used by ydb568.exp for bash prompt

echo '# Running expect script [ydb568.exp]'
echo '# The expect script does an "echo 9876543" after the [mupip extract -stdout | more]'
echo '# With the YDB#568 bug not fixed, the output of the "echo" command would show up but the "echo" command would not'
echo '# With the YDB#568 bug fixed, we expect the "echo" command to also show up'
(expect -d $gtm_tst/$tst/u_inref/ydb568.exp > expect.out) >& expect.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx	# avoid SYSTEM-E-ENO32 Broken pipe error from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
echo '# Entire output of expect script pasted below'
# Note: Some platform specific discrepancies in output are filtered out
# e.g. Machines running an older version of expect display 2 lines starting with "--More--^x" while
# machines running newer versions display 1 such line. Filter the extra line out.
perl -wnle 'BEGIN {  $more_lines = 0; } $thisline = $_; if ($thisline =~ /^\-\-More\-\-\^x*/) { if (0 eq $more_lines) { print; } $more_lines++; } else { print; }' expect_sanitized.outx > expect_filtered.outx
# e.g. RHEL7/CentOS show the old shell prompt followed by a Ctrl-G in addition to the new shell prompt. Filter the old one out.
sed 's/.*SHELL$ /SHELL$ /;' expect_filtered.outx | $grep -vE '^\^x|bashrc|^  |exit|^SHELL. $'
echo ""

$gtm_tst/com/dbcheck.csh

