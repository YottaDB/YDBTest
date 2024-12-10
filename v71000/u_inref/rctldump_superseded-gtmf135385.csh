#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
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
echo '# Run the first version of the test routine in the background and capture the PID in gtmf135385-v1.pid'
($gtm_exe/mumps -run runTest^gtmf135385 & ; echo $! >&! gtmf135385-v1.pid) >&! gtmf135385-v1.out
set v1PID = `cat gtmf135385-v1.pid`
echo '# Wait up to 300 seconds for backgrounded mumps process to start'
set max_wait = 3000
$gtm_tst/com/is_proc_alive.csh $v1PID
while ((1 == $status) && ($max_wait > 0))
	sleep 0.1
	@ max_wait = $max_wait - 1
	$gtm_tst/com/is_proc_alive.csh $v1PID
end
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
$gtm_exe/mupip intrpt $v1PID >>& gtmf135385-v1.out
echo '# Wait for the initial test process to die using wait_for_proc_to_die.csh'
$gtm_tst/com/wait_for_proc_to_die.csh $v1PID
