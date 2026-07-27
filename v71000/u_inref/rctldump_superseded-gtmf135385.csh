#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
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
GTM-F135385 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-F135385)

MUPIP RCTLDUMP reports the number of times a routine has been superseded (rtnsupersede) in the autorelink cache. Previously,
MUPIP RCTLDUMP did not record this value, and only recorded the number of times a routine has been referenced. (GTM-F135385)
CAT_EOF
echo ''

# We do not want autorelink-enabled directories that have been randomly assigned by the test system
# because we will assign the autorelink directory here.
source $gtm_tst/com/gtm_test_disable_autorelink.csh
setenv ydb_msgprefix "GTM"
echo '# Create routine directories `obj` and `src`'
mkdir obj src
echo '# Set gtmroutines to use routine directories with autorelink enabled'
setenv gtmroutines "obj*(src) $gtmroutines"
echo ''
echo '# Generate the first test routine version in src/gtmf135385.m'
echo 'runTest write $zroutines set $ZINTERRUPT="zhalt 1" for i=1:1  hang 1' > src/gtmf135385.m
echo '# Precompile src/gtmf135385.m into src/gtmf135385.o to ensure compilation completes before new routine'
echo '#   versions are compiled in the loop below. This is done to prevent a rare failure case where the above'
echo '#   version of the routine completes compilation after a subsequent version of the routine is compiled in'
echo '#   the below foreach loop. In that case, the above M code will execute more than once, causing multiple'
echo '#   mumps processes to hang indefinitely. In turn, this will prevent the below `foreach` loop from exiting'
echo '#   causing the test to hang indefinitely and thus to fail with a test execution timeout.'
cd obj
$gtm_exe/mumps ../src/gtmf135385.m
cd ..
echo '# Run the first version of the test routine in the background and capture the PID in gtmf135385-v0.pid'
($gtm_exe/mumps -run runTest^gtmf135385 & ; echo $! >&! gtmf135385-v0.pid) >&! gtmf135385-v0.out
set v0PID = `cat gtmf135385-v0.pid`
echo '# Wait up to 300 seconds for the backgrounded mumps process to link gtmf135385 and register it in'
echo '#   the relinkctl file. Checking only that the PID is alive is not enough: the process exists from'
echo '#   the instant the shell forks it, long before it has done the (auto)relink that creates the record'
echo '#   dumped below. Proceeding early loses the first rec#1 line, and if the foreach loop rewrites'
echo '#   src/gtmf135385.m first, the backgrounded process links that short-lived version and exits,'
echo '#   which deletes the relinkctl file for the rest of the test.'
set max_wait = 3000
while ($max_wait > 0)
	$gtm_exe/mupip rctldump >&! rctldump_wait.out
	grep 'rtnname: gtmf135385' rctldump_wait.out >& /dev/null
	if (0 == $status) break
	$gtm_tst/com/is_proc_alive.csh $v0PID
	if (0 != $status) then
		echo "TEST-E-RCTLDUMP : process $v0PID died before linking gtmf135385"
		break
	endif
	@ max_wait = $max_wait - 1
	sleep 0.1
end
if (0 == $max_wait) echo "TEST-E-RCTLDUMP : timed out waiting for gtmf135385 to appear in MUPIP RCTLDUMP output"
echo '# Run MUPIP RCTLDUMP to get the initial `superseded` value'
$gtm_exe/mupip rctldump >& rctldump.out
echo ''
echo '# Generate and run new versions of the test routine, and run MUPIP RCTLDUMP after each routine exits'
echo '# Wait for each new mumps process to exit before running MUPIP RCTLDUMP to ensure the routine version was updated'
foreach i (`seq 1 5`)
	echo "runTest write $i" >& src/gtmf135385.m
	$gtm_exe/mumps -run runTest^gtmf135385 >&! gtmf135385-v$i.out
	$gtm_exe/mupip rctldump >>& rctldump.out
end
echo ''
echo '# Check if `superseded` values are present and incremented in the output from the preceding MUPIP RCTLDUMP calls'
cat rctldump.out | grep 'superseded:' | sed 's/\(.*\)objhash: [a-z0-9]*  numvers: [0-9]*  objlen: [a-z0-9]*  shmlen: [a-z0-9]*/\1objhash: HASH  numvers: NUM  objlen: LEN shmlen: LEN/g'
echo '# Terminate the initial test process using MUPIP INTRPT'
$gtm_exe/mupip intrpt $v0PID >>& gtmf135385-v0.out
echo '# Wait for the initial test process to die using wait_for_proc_to_die.csh'
$gtm_tst/com/wait_for_proc_to_die.csh $v0PID
