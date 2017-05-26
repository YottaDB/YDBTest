#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that MUMPS and LKE handle correctly control-C
#

$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.log
$gtm_dist/mupip set -lock=5000 -region "*" >>& dbcreate.log

# Use xterm
setenv TERM xterm

# Enable debugging? ATM, no
set debug = "-d" ; set debug = ""

# Start lockjob
$gtm_dist/mumps -run startlockjob^ctrlc

# Execute the test case trying 3 times to avoid an expect faiure on AIX
@ loop = 3
while ($loop > 0)
	# Leaving the following in for testing when I get back to it
	#${truss} -f -o ctrlc.strace.${loop} expect ${debug} -f $gtm_tst/$tst/inref/ctrlc.exp >& ctrlc.out
	expect ${debug} -f $gtm_tst/$tst/inref/ctrlc.exp >& ctrlc.out

	$grep -q "spawn id exp. not open" ctrlc.out
	if (0 == $status) then
		# On AIX, expect tends to bomb out for no reason
		mv ctrlc.out ctrlc.outx.${loop}
		@ loop--
		continue
	else
		# In the absence of that error, end the loop with -1. loop
		# being zero indicates that each iteration of the loop
		# failed due to MREP expect_spawn_id_expNN_not_open
		@ loop = -1
	endif

	$grep 'Verification' ctrlc.out
end

# Catch MREP expect_spawn_id_expNN_not_open as a rare failure
if (0 == $loop) then
        $grep 'spawn id exp. not open' ctrlc.outx.*
endif


# Stop lockjob
$gtm_dist/mumps -run stoplockjob^ctrlc

$gtm_tst/com/dbcheck.csh >& dbcheck.log
