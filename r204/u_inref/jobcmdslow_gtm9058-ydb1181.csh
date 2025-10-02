#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# -----------------------------------------------------------------------------------------------"
echo "# Test1) Test JOB command performance slowdown regression in GT.M V6.3-007 (as part of GTM-9058)"
echo "# -----------------------------------------------------------------------------------------------"
echo "# The cause of the performance slowdown was that the middle child used to wait for a message from"
echo '# the grandchild that indicated whether it was able to invoke the M entryref fine or not.'
echo '# This would show up as a read() call right after a sendto() call in an strace output where the'
echo '# sendto() call sent 8264 bytes (8 job parameters approximately 1Kib each).'
echo '# The fix of the performance slowdown was to REMOVE the read() call and so we test that there is'
echo '# NO read() after the sendto() call of 8264 bytes.'
echo "# -----------------------------------------------------------------------------------------------"
echo '# Create [test1.m] which does nothing but a [quit]'
echo " quit" > test1.m
echo '# Run [job ^test1] through [mumps -direct] and [strace -T -ff] to trace the system calls invoked.'
echo '# The [-ff] will cause all forked child/grandchild processes to also be traced and each would'
echo '# create a [trace.out.PID] file. There will be a total of 3 such files and the file corresponding'
echo '# to the middle child would be the middle of those in a [ls -1 trace.out.*] output.'
echo '# Run [grep -A 1 -n "sendto("] on that middle [trace.out.*] file'
echo '# Expect to see NO read() call line AFTER the sendto() line which returned 8264'
echo '# When run without the fix, one would see a read() call show up and the time taken (due to "-T")'
echo '# would be significantly higher than the time taken by the sendto() calls. If the sendto() calls'
echo '# take the order of 20 to 50 microseconds, the read() call would take 65,000 microseconds.'
echo '# The reference file allows for up to 100 microseconds for the sendto() calls. While this is okay on'
echo '# x86_64, on aarch64 this can take even 1000 microseconds or more so run this only on x86_64.'
if ("x86_64" == `uname -m`) then
	echo "job ^test1" | strace -o trace.out -T -ff $gtm_dist/mumps -direct
	grep -A 1 "sendto(" `ls -1 trace.out.* | head -2 | tail -1` | grep -B 1 -A 1 "sendto.* = 8264"
endif
echo

setenv gtmroutines ".*"	# Needed by test of the tests below

echo "# ----------------------------------------------------------------------------------------------------------------"
echo "# Test2) Test that JOB command middle child is no longer attached to relinkctl shared memory in case of no errors"
echo "# ----------------------------------------------------------------------------------------------------------------"
echo '# This is a test where we set [gtmroutines=".*"], then run [job ^test2], wait for the jobbed off child to terminate'
echo '# and then run [zprint ^test2] to attach to the relinkctl shared memory and then run [zshow "a"]. With an incomplete'
echo '# fix we used to see 2 processes attached (the current process as well as the middle child of the JOB command which'
echo '# has long terminated) whereas we expect to only see 1 (the current process).'
echo " quit" > test2.m
cat > test2.inp << CAT_EOF
job ^test2
for  quit:'\$zgetjpi(\$zjob,"ISPROCALIVE")  hang 0.001
zprint ^test2
zshow "a"
CAT_EOF
$gtm_dist/mumps -direct < test2.inp >& test2.out
echo '# Run [grep "#" test2.out]. We expect to see [# of attached processes] equal to 1, [# of routines] equal to 1,'
echo '# one line listing [Rtnobj shared memory # 1] and one line listing [test2] as the rtnname.'
grep '#' test2.out
echo

echo "# --------------------------------------------------------------------------------------------------------------------------------"
echo "# Test3) Test that JOB command middle child is no longer attached to relinkctl shared memory in case of JOBFAIL/FILENOTFND errors"
echo "# --------------------------------------------------------------------------------------------------------------------------------"
echo '# This is a test where we set [gtmroutines=".*"], then run [job ^test3], where test3.m does not exist (FILENOTFND error),'
echo '# and then run [zprint ^test3] to attach to the relinkctl shared memory and then run [zshow "a"]. With an incomplete'
echo '# fix we used to see 2 processes attached (the current process as well as the middle child of the JOB command which'
echo '# has long terminated) whereas we expect to only see 1 (the current process).'
cat > test3.inp << CAT_EOF
job ^test3
zprint ^test3
zshow "a"
CAT_EOF
$gtm_dist/mumps -direct < test3.inp >& test3.out
echo '# Run [cat test3.out]'
echo '# Expecting JOBFAIL error from JOB command'
echo '# Expecting ZLINKFILE/FILENOTFOUND errors for [test3.m]'
echo '# Expecting [# of routines] to be 0'
echo '# Expecting [# of attached processes] to be 1'
echo '# Expecting no line of output indicating test3 as rtnname (like test2 showed up in Test 2 stage)'
cat test3.out
# Now that we printed the expected errors from test3.out, move those out of the way so test framework only catches
# any other errors than the known errors.
mv test3.out test3.outx
grep -vE "JOBFAIL|ZLINKFILE|FILENOTFND" test3.outx > test3.out
echo '# Run [cat test3.mje]. We expect to see ZLINKFILE/FILENOTFND error in this file too'
cat test3.mje
mv test3.mje test3.mjex	# Move .mje to .mjex now that it has been displayed (do not want test framework to catch it again)
echo

echo "# ---------------------------------------------------------------------------------------------------------------------------------"
echo "# Test4) Test that JOB command middle child does not leave relinkctl shared memory lying around in case of JOBFAIL/RTNLABOFF error"
echo "# ---------------------------------------------------------------------------------------------------------------------------------"
echo '# This is a test where we set [gtmroutines=".*"], then run [job child^test4], where test4.m does exist but child label'
echo '# does not, and then run [zprint ^test4] to attach to the relinkctl shared memory and then run [zshow "a"]. With an'
echo '# incomplete fix we used to see 2 processes attached (the current process as well as the middle child of the JOB command'
echo '# which has long terminated) whereas we expect to only see 1 (the current process).'
echo " quit" > test4.m
cat > test4.inp << CAT_EOF
job child^test4
zprint ^test4
zshow "a"
CAT_EOF
$gtm_dist/mumps -direct < test4.inp >& test4.out
echo '# Run [cat test4.out]'
echo '# Expecting JOBFAIL error from JOB command'
echo '# Expecting [# of routines] to be 1'
echo '# Expecting [# of attached processes] to be 1'
echo '# Expecting 1 line of output indicating test4 as rtnname'
cat test4.out
# Now that we printed the expected error from test4.out, move those out of the way so test framework only catches
# any other errors than the known error.
mv test4.out test4.outx
grep -vE "JOBFAIL" test4.outx > test4.out
echo '# Run [cat test4.mje]. We expect to see RTNLABOFF error in this file'
cat test4.mje
mv test4.mje test4.mjex	# Move .mje to .mjex now that it has been displayed (do not want test framework to catch it again)
echo

echo "# ---------------------------------------------------------------------------------------------------------------------------------"
echo "# Test5) Test that JOB command middle child does not leave relinkctl shared memory lying around in case of JOBFAIL/RTNLABOFF error"
echo "# ---------------------------------------------------------------------------------------------------------------------------------"
echo '# This is a test where we set [gtmroutines=".*"], then run [job child+10^test5], where test5.m does exist and [child] label'
echo '# exists but line number [child+10] does not, and then run [zprint ^test5] to attach to the relinkctl shared memory and then'
echo '# run [zshow "a"]. With an incomplete fix we used to see 2 processes attached (the current process as well as the middle'
echo '# child of the JOB command which has long terminated) whereas we expect to only see 1 (the current process).'
echo "child\n quit" > test5.m
cat > test5.inp << CAT_EOF
job child+10^test5
zprint ^test5
zshow "a"
CAT_EOF
$gtm_dist/mumps -direct < test5.inp >& test5.out
echo '# Run [cat test5.out]'
echo '# Expecting JOBFAIL error from JOB command'
echo '# Expecting [# of routines] to be 1'
echo '# Expecting [# of attached processes] to be 1'
echo '# Expecting 1 line of output indicating test5 as rtnname'
cat test5.out
# Now that we printed the expected error from test5.out, move those out of the way so test framework only catches
# any other errors than the known error.
mv test5.out test5.outx
grep -vE "JOBFAIL" test5.outx > test5.out
echo '# Run [cat test5.mje]. We expect to see RTNLABOFF error in this file'
cat test5.mje
mv test5.mje test5.mjex	# Move .mje to .mjex now that it has been displayed (do not want test framework to catch it again)
echo

