#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
$echoline
echo "Test recall history for M READ command"
$echoline
#
setenv TERM xterm
#

setenv gtm_prompt "YDB>"

cp $gtm_tst/$tst/u_inref/readcmd*.exp .

$gtm_tst/com/dbcreate.csh mumps

foreach file (readcmd1_simple.exp readcmd2_complex.exp)
	echo ""
	echo " --> Running test : $file <--"
	echo ""
	set basename = $file:r
	# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
	(expect -d $gtm_tst/$tst/u_inref/$basename.exp > $basename.out) >& $basename.dbg
	if ($status) then
		echo "EXPECT-E-FAIL : expect returned non-zero exit status. $basename.out and $basename.dbg output follows"
		echo "> cat $basename.out"
		cat $basename.out
		echo "> cat $basename.dbg"
		cat $basename.dbg
	else
		perl $gtm_tst/com/expectsanitize.pl $basename.out > ${basename}_sanitized.out
		if ($file == "readcmd1_simple.exp") then
			# Display full contents of simple test as it is deterministic
			# But keep only the useful things in the final reference file
			$grep -vE '^[0-9]|^YDB|^$|^> $' ${basename}_sanitized.out
		else
			echo "-----------------------------------------------------------------------"
			echo "# Test that Up/Down arrow N times (N is random) after M previous inputs (M is random too) goes back or forward correctly"
			echo "# Also test that recalled item gets added to recall history"
			echo "# Also test that READ X, READ X# and READ *X all share same recall history"
			echo "# Also test that additions to history don't happen if it is a duplicate of most recently added line"
			echo "# Also test that additions to history don't happen if it is an empty line"
			echo "# Also test using UTF-8 characters (which are multi-byte as well as have multi-column display width)"
			echo "# Also test that MUPIP INTRPT in the middle of READs is handled even if partial input has been read"
			echo "-----------------------------------------------------------------------"

			# Cannot display full contents of complex test as it is random output
			# Just check ^passcnt or ^failcnt
			grep -E "PASS|FAIL" ${basename}_sanitized.out
			# Check pass or fail and print status accordingly
			$GTM << GTM_EOF
				if ^passcnt=^ncursorupordowncnt write "PASS from readcmd2_complex",!
				if +\$get(^failcnt) write "FAIL from readcmd2_complex",!
GTM_EOF

		endif
	endif
	if ($file == "readcmd2_complex.exp") then
		# The backgrounded MUPIP INTRPT process in "readcmd2_complex.exp" needs to be terminated.
		# Or else it would keep sending SIGUSR1 to random processes in future tests (that take on the same pid
		# as ^parent) and cause all sorts of failures (e.g. processes terminate suddenly with a "User signal 1" symptom).
		# Therefore stop it.
		$ydb_dist/mumps -run ^%XCMD 'do stop^readcmdrecallhist'
	endif
end

$gtm_tst/com/dbcheck.csh

