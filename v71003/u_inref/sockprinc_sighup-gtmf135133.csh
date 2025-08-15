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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F135133- Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-F135133)

USE for a socket device recognizes NOHUPENABLE and HUPENABLE deviceparameters to determine whether to recognize a SIGHUP signal on \$PRINCIPAL as an error. The gtm_hupenable environment variable determines the initial setting for the process. Previously, this feature was only available for terminal devices and a process with a socket \$PRINCIPAL device ignored all SIGHUP signals. (GTM-F135133)

How the two deviceparameters and the environment variable interact
-----------------------------------------------------------------
gtm_hupenable establishes the initial setting for the process, and a later USE \$PRINCIPAL:(HUPENABLE)
or USE \$PRINCIPAL:(NOHUPENABLE) overrides it, so the setting applied last is the one in effect. When
the setting in effect is HUPENABLE, a SIGHUP received by the process raises a SOCKHANGUP error; when it
is NOHUPENABLE, SIGHUP is ignored. Previously, SIGHUP was always ignored by a process whose \$PRINCIPAL
is a socket device, no matter what either the deviceparameters or the environment variable said.

Reporting a SOCKHANGUP implicitly reverts \$PRINCIPAL to NOHUPENABLE, exactly as V7.0-002 documented for
TERMHANGUP on a terminal, so a process that anticipates more than one hangup has to reissue
USE \$PRINCIPAL:(HUPENABLE) after each one.

How each test below drives that
-------------------------------
Every test runs [parent^gtmf135133], which
	1. OPENs a LISTENing LOCAL socket,
	2. JOBs [child1^gtmf135133], which CONNECTs to it,
	3. DETACHes the accepted (CONNECTED) socket and JOBs [child2^gtmf135133] with that socket as its \$PRINCIPAL and child2.mje as its error file, and
	4. waits for both jobbed off processes to terminate.
[child2^gtmf135133] then establishes the setting under test, records ZSHOW "D" output for \$PRINCIPAL,
and sends SIGHUP to itself with \$ZSIGPROC. Each test checks both the ZSHOW "D" output, which reports
the recorded HUPENABLE setting, and whether SOCKHANGUP reached child2.mje, which is what shows that a
SIGHUP handler is armed. The last test differs: it
sets \$ETRAP so that it survives the first SOCKHANGUP, and signals itself three times, printing a
ZSHOW "D" snapshot after each step rather than relying on child2.mje.
See the following discussion for more details: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/712#note_2704303463.

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
# ydb_hupenable would take precedence over the gtm_hupenable settings the tests below make
unsetenv ydb_hupenable

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log

# One entry per test in each array below:
# Test number
set testnums = (T1 T2 T3 T4 T5 T6)
# The gtm_hupenable setting ("unset" means the environment variable is left undefined)
set hupenvs  = (unset true true false unset unset)
# Whether SOCKHANGUP error is expected
set experrs  = (1 1 0 0 0 0)
# The $ZCMDLINE argument that tells [child2^gtmf135133] which setting to establish
set hupargs  = (HUPENABLE NONE NOHUPENABLE NONE HUPTHENNOHUP HUPRESET)
# A description of what that argument makes child2 do
# NOTE: single quotes below (and in the echoes further down) because tcsh expands \$ inside double quotes
set hupacts  = ( \
	'USE $P:(HUPENABLE) before sending itself a SIGHUP' \
	'USE $P with no deviceparameter before sending itself a SIGHUP' \
	'USE $P:(NOHUPENABLE) before sending itself a SIGHUP' \
	'USE $P with no deviceparameter before sending itself a SIGHUP' \
	'USE $P:(HUPENABLE) and then USE $P:(NOHUPENABLE) before sending itself a SIGHUP' \
	'the [hupreset^gtmf135133] sequence, which traps SOCKHANGUP with $ETRAP and signals itself three times' \
	)
# What the release note says used to happen in this case
set prevmsgs = ( \
	'Previously, SIGHUP was always ignored and no error was issued.' \
	'Previously, SIGHUP was always ignored and no error was issued.' \
	'Previously, SIGHUP was always ignored for a $PRINCIPAL socket device, so this behavior is unchanged.' \
	'Previously, SIGHUP was always ignored for a $PRINCIPAL socket device, so this behavior is unchanged.' \
	'Previously, SIGHUP was always ignored for a $PRINCIPAL socket device, so this behavior is unchanged.' \
	'Previously, SIGHUP was always ignored, so neither the SOCKHANGUP nor the implicit reset could happen.' \
	)
# The description of the test.
set testdescs = ( \
	'Test that the HUPENABLE deviceparameter on a $PRINCIPAL socket device recognizes SIGHUP as an error.' \
	'Test that gtm_hupenable=true alone makes a $PRINCIPAL socket device recognize SIGHUP as an error.' \
	'Test that the NOHUPENABLE deviceparameter overrides gtm_hupenable=true, so SIGHUP is ignored.' \
	'Test that gtm_hupenable=false leaves a $PRINCIPAL socket device ignoring SIGHUP.' \
	'Test that the NOHUPENABLE deviceparameter turns off SIGHUP recognition that HUPENABLE turned on earlier in the same process.' \
	'Test that a SOCKHANGUP implicitly reverts $PRINCIPAL to NOHUPENABLE, so a second SIGHUP is ignored until USE $P:(HUPENABLE) is reissued.' \
	)

foreach i (`seq 1 $#testnums`)
	set test_num = $testnums[$i]
	echo "### $test_num : $testdescs[$i]"
	if ("unset" == "$hupenvs[$i]") then
		unsetenv gtm_hupenable
		echo "# gtm_hupenable is left undefined"
	else
		setenv gtm_hupenable $hupenvs[$i]
		echo "# Set gtm_hupenable=$hupenvs[$i]"
	endif
	echo "# Run [parent^gtmf135133], with [child2^gtmf135133] doing $hupacts[$i]"
	$gtm_dist/mumps -r parent^gtmf135133 $hupargs[$i] $test_num >&! $test_num.outx
	cat $test_num.outx
	# Give each test its own copy of child2's JOB error file
	mv child2.mje child2$test_num.mje
	echo '# Check the ZSHOW "D" output taken by [child2^gtmf135133] for the recorded HUPENABLE setting.'
	if (! -e zshowd_$test_num.out) then
		echo "TEST-E-FILENOTFOUND zshowd_$test_num.out was not created by [child2^gtmf135133]"
	else if (`$grep -cE 'OPEN SOCKET.*HUPENABLE' zshowd_$test_num.out`) then
		echo '# ZSHOW "D" reports HUPENABLE for the $PRINCIPAL socket device'
	else
		echo '# ZSHOW "D" does not report HUPENABLE for the $PRINCIPAL socket device'
	endif
	if (-e hupreset_$test_num.out) then
		echo '# Trace written by [hupreset^gtmf135133], one line per step:'
		cat hupreset_$test_num.out
	endif
	if ($experrs[$i]) then
		echo "# Check child2$test_num.mje for the SOCKHANGUP error raised by the SIGHUP."
		echo "# $prevmsgs[$i]"
		$gtm_tst/com/check_error_exist.csh child2$test_num.mje "SOCKHANGUP"
	else
		echo "# Confirm no SOCKHANGUP error in child2$test_num.mje."
		echo "# $prevmsgs[$i]"
		$grep "SOCKHANGUP" child2$test_num.mje
	endif
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.log
