#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

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

echo "# Run [strace -o trace1b.outx -T GDE exit] after ensuring mumps.gldinprogress exists but mumps.gld does not"
rm -f mumps.gld
touch mumps.gldinprogress
strace -o trace1b.outx -T $GDE exit
rm -f mumps.gldinprogress
echo "# Run [grep clock_nanosleep trace1b.outx] and count the time taken in each call (last field in strace -T output) and sum it"
echo "# Expect to see a number around 0.5."
echo "# Hence the %.1f usage below to avoid lower order decimal values as they can be non-deterministic."
echo "# Expect to see 0.5 output below. But allow up to 0.9 seconds due to system load issues."
echo "# On slow ARMV6L, allow up to 9.9 seconds."
grep clock_nanosleep trace1b.outx | awk '{print $NF}' | sed 's/<//;s/>//;' | awk '{sum += $1;} END {printf "%.1f\n", sum}'

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

