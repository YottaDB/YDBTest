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
GTM-10098 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410098)

By default, TPNOTACID retries for a transaction exceed 16, GT.M issues a trappable TPNOTACID error in order to limit livelock. The limit may be adjusted to between four (4) and 100, or set to zero (0) by appropriately defining the gtm_tpnotacidtries environment variable; specifying a value outside the supported values silently reverts to the default. The setting of zero (0) acts like an audit by reporting all encountered operations capable of causing TPNOTACID detection to the syslog but setting the actual error limit to the default. In addition, GT.M suppresses TPNOTACID syslog warning messages that originate from the same action as the last prior message from a given process. Previously, GT.M did not enforce any limit on TPNOTACID retries, had no "audit" capability and could be noisy with informational messages for TPNOTACID retries. (GTM-10098)

CAT_EOF
echo

# TPNOTACID considers a timed operation only when its timeout exceeds gtm_tpnotacidtime, so set that to 0 and let
# gtm10098.m drive its restarts with a 1 millisecond HANG. HANG needs no fork, which keeps the 101 restart case cheap.
setenv gtm_tpnotacidtime 0

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

# Drop the syslog prefix, the "generated from" address and the churn prone line offset, keeping the operation name.
set filter = 's/^.*MUMPS\[[0-9][0-9]*\]: //;s/+[0-9][0-9]*\^gtm10098/+OFFSET^gtm10098/;s/ -- generated from .*$//'

echo '# The limit is compared against $TRESTART, which counts the restarts of a single transaction, so each run below'
echo '# is one transaction that restarts itself. See v71004/inref/gtm10098.m for why the restarts are driven that way.'
echo

set settings = ( unset 4 100 3 101 0 )
set limits   = ( 16 4 100 16 16 16 )
set descs = ( "the default limit" "the supported minimum" "the supported maximum" "below the supported minimum, so the default applies" "above the supported maximum, so the default applies" "audit mode, where the default limit still applies" )

set test_num = 1
@ i = 1
while ($i <= $#settings)
	set setting = "$settings[$i]"
	@ limit = $limits[$i]
	set desc = "$descs[$i]"
	if ("unset" == "$setting") then
		unsetenv gtm_tpnotacidtries
	else
		setenv gtm_tpnotacidtries "$setting"
	endif
	@ over = $limit + 1
	echo "### Test ${test_num}: gtm_tpnotacidtries=${setting} - ${desc}"
	echo "# Restarting a transaction twice, well short of the limit of ${limit}, must not produce a TPNOTACID error"
	$gtm_dist/mumps -run gtm10098 single 2 |& sed "$filter"
	echo "# Restarting it past that limit must get a trappable TPNOTACID error reporting exactly ${over} restarts"
	$gtm_dist/mumps -run gtm10098 single $over |& sed "$filter"
	echo ""
	@ test_num = $test_num + 1
	@ i = $i + 1
end

# The release note describes the remaining behaviour in terms of syslog messages, so the tests below count the
# messages a single process writes. Each notes the pid and searches for messages only from it, so that TPNOTACID
# messages from other tests running concurrently, including another copy of this subtest, cannot affect the count.
#
# "cycle" runs HANG, LOCK and ZSYSTEM on every pass. Each is reported by a different module of the source, so each
# is a distinct operation "capable of causing TPNOTACID detection" as far as the release note is concerned.
echo "### Test ${test_num}: nothing is reported before the final retry unless gtm_tpnotacidtries is 0"
echo '# Run a transaction that does not restart at all, encountering HANG, LOCK and ZSYSTEM'
unsetenv gtm_tpnotacidtries
set t = `date +"%b %e %H:%M:%S"`
($gtm_dist/mumps -run gtm10098 cycle 0 >& notacid_default.out &; echo $! >& pid_default.out) >& bckg_default.out
set pid = `cat pid_default.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
cat notacid_default.out
sleep 1
$gtm_tst/com/getoper.csh "$t" "" syslog_default.txt
echo '# Expect no TPNOTACID line between this line'
$grep "MUMPS\[\<$pid\>\].*TPNOTACID" syslog_default.txt |& sed "$filter"
echo '# and this line'
echo ""
@ test_num = $test_num + 1

echo "### Test ${test_num}: gtm_tpnotacidtries=0 audits every operation encountered, from the very first try"
echo '# The same single pass, which reached the syslog not at all above, must now report all three operations'
setenv gtm_tpnotacidtries 0
set t = `date +"%b %e %H:%M:%S"`
($gtm_dist/mumps -run gtm10098 cycle 0 >& notacid_audit.out &; echo $! >& pid_audit.out) >& bckg_audit.out
set pid = `cat pid_audit.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
cat notacid_audit.out
$gtm_tst/com/getoper.csh "$t" "" syslog_audit.txt "" "MUMPS\[\<$pid\>\].*TPNOTACID" 3
echo '# Expect one message each for HANG, LOCK and ZSYSTEM, all reported at 0 RESTARTs'
$grep "MUMPS\[\<$pid\>\].*TPNOTACID" syslog_audit.txt |& sed "$filter"
echo '# Count of TPNOTACID messages reported:'
$grep -c "MUMPS\[\<$pid\>\].*TPNOTACID" syslog_audit.txt
echo ""
@ test_num = $test_num + 1

# "Silently" is a claim about what is NOT written, so this runs below the final retry, where no TPNOTACID message is
# due, and expects the process to have written nothing at all. The grep deliberately matches any message from the
# process rather than TPNOTACID ones, since a complaint about the rejected value need not be a TPNOTACID message.
echo "### Test ${test_num}: an unsupported gtm_tpnotacidtries reverts to the default silently"
echo '# Tests 4 and 5 showed that the default limit takes effect. Nothing may be said about the rejected value.'
foreach badvalue (3 101)
	setenv gtm_tpnotacidtries $badvalue
	set t = `date +"%b %e %H:%M:%S"`
	($gtm_dist/mumps -run gtm10098 single 0 >& notacid_silent${badvalue}.out &; echo $! >& pid_silent${badvalue}.out) >& bckg_silent${badvalue}.out
	set pid = `cat pid_silent${badvalue}.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
	echo "# With gtm_tpnotacidtries=${badvalue}, stdout and stderr hold this and nothing else:"
	cat notacid_silent${badvalue}.out
	sleep 1
	$gtm_tst/com/getoper.csh "$t" "" syslog_silent${badvalue}.txt
	echo "# Count of syslog messages of any kind from that process:"
	$grep -c "MUMPS\[\<$pid\>\]" syslog_silent${badvalue}.txt
end

# NOTE: a value that is not a number is outside the supported values too, but it does NOT revert to the default and
# is NOT silent about it. "ydb_trans_numeric" reports the variable as defined and hands back the 0 that STRTOUL
# returns for an unparseable string, and a defined 0 is exactly how audit mode is requested, so the run below turns
# auditing on instead. This contradicts the release note and needs an upstream ruling, like the note above Test 9.
echo '# A value that is not a number is read as 0, which requests audit mode rather than the default, so this run'
echo '# reverts neither to the default nor silently:'
setenv gtm_tpnotacidtries abc
set t = `date +"%b %e %H:%M:%S"`
($gtm_dist/mumps -run gtm10098 single 0 >& notacid_silentabc.out &; echo $! >& pid_silentabc.out) >& bckg_silentabc.out
set pid = `cat pid_silentabc.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
cat notacid_silentabc.out
$gtm_tst/com/getoper.csh "$t" "" syslog_silentabc.txt "" "MUMPS\[\<$pid\>\].*TPNOTACID"
$grep "MUMPS\[\<$pid\>\].*TPNOTACID" syslog_silentabc.txt |& sed "$filter"
echo "# Count of syslog messages of any kind from that process:"
$grep -c "MUMPS\[\<$pid\>\]" syslog_silentabc.txt
echo ""

@ test_num = $test_num + 1

# THIS TEST IS EXPECTED TO FAIL until the scoping of the TPNOTACID suppression state is fixed upstream. It asserts
# the behaviour the release note describes, which the code as merged does not produce.
#
# The release note says GT.M "suppresses TPNOTACID syslog warning messages that originate from the same action as
# the last prior message from a given process". In sr_port/tpnotacid_chk_inline.h the state that "the last prior
# message" is compared against, "last_caller" and "last_zpos_addr", is declared STATICDEF at file scope in the
# header. The header is included by 18 source modules, so each module holds its own copy and an operation is suppressed
# against any prior message from its own module rather than against the last prior message from the process.
#
# The measured effect, from the 2026-09-29 V7.1-004 runs, is that each of the three operations below reports once
# and then never again: 3 messages where the release note implies 6. See the YDBTest#747 discussion.
echo "### Test ${test_num}: TPNOTACID syslog messages are suppressed only when the operation does not change"
echo '# Restart a transaction 4 times, encountering HANG, LOCK and ZSYSTEM on each pass. Passes 0 through 2 are'
echo '# below the final retry and report nothing, so the passes at 3 and 4 RESTARTs are the reporting ones. On'
echo '# both of them every operation differs from the message immediately before it, so none may be suppressed.'
unsetenv gtm_tpnotacidtries
set t = `date +"%b %e %H:%M:%S"`
($gtm_dist/mumps -run gtm10098 cycle 4 >& notacid_cycle.out &; echo $! >& pid_cycle.out) >& bckg_cycle.out
set pid = `cat pid_cycle.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
cat notacid_cycle.out
# The process has already exited, so every message it was going to write has been written and only the syslog's own
# latency is left. A short sleep covers that. getoper.csh is deliberately not asked to wait for a message count,
# which would stall this test for its full 300 second timeout on every run until the fix lands.
sleep 2
$gtm_tst/com/getoper.csh "$t" "" syslog_cycle.txt
echo '# Expect HANG, LOCK and ZSYSTEM at 3 RESTARTs, and all three again at 4 RESTARTs'
$grep "MUMPS\[\<$pid\>\].*TPNOTACID" syslog_cycle.txt |& sed "$filter"
echo '# Count of TPNOTACID messages reported:'
$grep -c "MUMPS\[\<$pid\>\].*TPNOTACID" syslog_cycle.txt
echo ""

$gtm_tst/com/dbcheck.csh >& dbcheck.out
