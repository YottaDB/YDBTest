#################################################################
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# This subtest traces the "clock_nanosleep()" calls through strace. But having auto relink enabled for $gtm_dist causes
# the "$GDE exit" invocation below to invoke `$ydb_dist/GDE.o` which would in turn go through auto relink shared memory
# and it is possible a "grab_latch()" call on that shared memory sleeps for a bit because another concurrently running
# test is holding that latch. This can cause false test failures due to extra "clock_nanosleep()" calls in Test 1a) and 1c)
# where we expect to see NO clock_nanosleep() calls. Therefore disable auto-relink in this subtest.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9424 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9410)

1) GDE attempts to avoid inappropriately creating a global directory by retrying its opening of an existing
   file a number of times; other components that read a global directory use the same technique to ensure a
   missing global directory is not a transient condition. These additional attempts take a fraction of a
   second, but one may perceive the additional time.

2) Writing a revised global directory has a short gap between the removal of the prior file and the replacement
   by the new/revised file, during which another process might find the global directory missing; previously
   this was unlikely but has been encountered. (GTM-9410)

##########################################################################################
Test 1 : Test 1st paragraph of release note
##########################################################################################
Note that paragraph (1) in GT.M release note caused .gld file creation to slow down noticeably (always took 0.5 seconds)
and so YottaDB made a fix (in commit YDB@b12abc1f) to address the slow creation in the most common case.
Therefore we are testing this modified YDB behavior below and not paragraph (1) of the GT.M change/release-note.
CAT_EOF

echo
cat << CAT_EOF | sed 's/^/# /;'
-----------------------------------------------------------------------------------------------------------------------------
Test 1a) Test that creating a new mumps.gld does not sleep unnecessarily when neither mumps.gldinprogress nor mumps.gld exist
-----------------------------------------------------------------------------------------------------------------------------
CAT_EOF

echo "# Run [strace -o trace1a.outx GDE exit] after ensuring mumps.gldinprogress and mumps.gld both don't exist"
rm -f mumps.gldinprogress mumps.gld
strace -o trace1a.outx $GDE exit
echo "# Run [grep clock_nanosleep trace1a.outx]"
echo "# Expect to see NO output below"
grep clock_nanosleep trace1a.outx

echo
cat << CAT_EOF | sed 's/^/# /;'
---------------------------------------------------------------------------------------------------------------------------
Test 1b) Test that creating a new mumps.gld sleeps 0.5 seconds when mumps.gldinprogress exists but mumps.gld does not exist
---------------------------------------------------------------------------------------------------------------------------
CAT_EOF

echo "# Run [strace -ttt -o trace1b.outx GDE exit] after ensuring mumps.gldinprogress exists but mumps.gld does not"
rm -f mumps.gld
touch mumps.gldinprogress
strace -ttt -o trace1b.outx $GDE exit
rm -f mumps.gldinprogress
echo "# Run [grep clock_nanosleep trace1b.outx] and, for each sleep, subtract the time of the call from the absolute"
echo "# wake-up time it asks for (GDE sleeps with TIMER_ABSTIME) to get the sleep it requested, in microseconds."
echo "# GDE waits for mumps.gldinprogress to be renamed by sleeping 1 millisecond at a time, at most 500 times."
echo "# Check the number of sleeps and what each asked for, not the time they took, as a loaded system can stretch"
echo "# each sleep. strace can also note a call late on a loaded system, which makes that one sleep look shorter, so"
echo "# check the median for the length of a sleep, and every sleep for not asking for more than 1 millisecond."
echo "# Expect 500 sleeps, none over 1 millisecond, and a median between 0.5 and 1 millisecond. The measured median"
echo "# is a little under 1 millisecond, as strace notes each call shortly after GDE reads the clock for its wake-up time."
echo "# The lower limit goes down to 0.5 millisecond to allow for system load, which can make strace note more calls late."
grep clock_nanosleep trace1b.outx | awk '{match($0, /\{[^}]*\}/); split(substr($0, RSTART, RLENGTH), a, /[^0-9]+/); printf "%.0f\n", ((a[2] + a[3] / 1e9) - $1) * 1e6}' \
	| sort -n | awk '{v[NR] = $1; if (1000 < $1) over++} END {med = v[int((NR + 1) / 2)]; printf "%d sleeps, %d over 1 millisecond, ", NR, over; \
		if ((500 <= med) && (1000 >= med)) print "median between 0.5 and 1 millisecond"; else printf "median %d microseconds\n", med}'

echo
cat << CAT_EOF | sed 's/^/# /;'
----------------------------------------------------------------------------------------------------------------------
Test 1c) Test that creating a new mumps.gld does not sleep when mumps.gld exists and mumps.gldinprogress exists or not
----------------------------------------------------------------------------------------------------------------------
CAT_EOF

echo "# Randomly (50% chance) decide to create mumps.gldinprogress"
set rand = `$gtm_tst/com/genrandnumbers.csh 1 0 1`
if (0 == $rand) then
	touch mumps.gldinprogress
endif
echo "# Run [strace -o trace1c.outx GDE exit] after ensuring mumps.gld exists"
strace -o trace1c.outx $GDE exit
if (0 != $rand) then
	rm -f mumps.gldinprogress
endif
echo "# Run [grep clock_nanosleep trace1c.outx]"
echo "# Expect to see NO output below"
grep clock_nanosleep trace1c.outx

echo
cat << CAT_EOF | sed 's/^/# /;'
##########################################################################################
Test 2 : Test 2nd paragraph of release note
##########################################################################################
CAT_EOF

echo "# Start 4 parallel sessions where GDE is executed to modify the gld file ([change -segment] in this case)"
@ numprocs = 4
@ index = 0
while ($index < $numprocs)
	(source $gtm_tst/$tst/u_inref/gtm9410_helper.csh &; echo $! >&! bg$index.pid) >&! bg$index.out
	@ index = $index + 1
end

echo "# Wait for the parallel invocations to finish"
@ index = 0
while ($index < $numprocs)
	set bgpid = `cat bg$index.pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $bgpid
	@ index = $index + 1
end

echo "# Check that some invocations of GDE encountered a %SYSTEM-E-ENO2 or %YDB-F-IONOTOPEN error due to missing gld file."
echo "# This verifies that this scenario is possible even now and in prior versions."
set numerrors = `cat bg_*.outx | $grep -cE "%SYSTEM-E-ENO2|%YDB-F-IONOTOPEN"`
if (0 < $numerrors) then
	echo "PASS : Found at least one %SYSTEM-E-ENO2 or %YDB-F-IONOTOPEN error in bg_*.outx files"
else
	echo "FAIL : Found NO %SYSTEM-E-ENO2 or %YDB-F-IONOTOPEN error in bg_*.outx files"
endif

if (-e GDEDUMP.DMP) then
	# This file gets generated by GDE in some cases and will disturb the test framework since it would contain
	# %YDB-E-IONOTOPEN errors. So rename this out of the test framework's view by avoiding *.DMP* match (in com/errors.csh)
	mv GDEDUMP.DMP GDEDUMP_DMP
endif

