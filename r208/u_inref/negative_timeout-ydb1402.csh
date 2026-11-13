#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#--------------------------------------------------------------------------------------------------------#"
echo '# [YDB#1402] Test that LOCK, ZALLOCATE, and READ with a negative timeout return at once with $TEST=0     #'
echo '# GT.M treats a negative timeout as 0. In YottaDB, a negative timeout that an integer mval holds, which  #'
echo '# includes values with up to three decimal places, waited indefinitely, because the conversion to        #'
echo '# nanoseconds tested the sign of an unsigned value. A process holds LOCK l and ZALLOCATE l. Each command #'
echo '# below tries them, or a READ from a PIPE device that writes nothing, with the timeouts -1, -1.5, -0.125 #'
echo '# (three decimal places), and -0.0001 (four decimal places, which already returned at once).             #'
echo "#--------------------------------------------------------------------------------------------------------#"
echo

$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
cp $gtm_tst/$tst/inref/negtmo1402.m .

echo "# Start a process that holds LOCK l and ZALLOCATE l"
echo "# mumps -run start^negtmo1402"
$gtm_dist/mumps -run start^negtmo1402
echo

# OPEN, JOB, and the WRITE /WAIT, /PASS, /ACCEPT, and /TLS socket controls convert their timeouts with the same
# function as LOCK, ZALLOCATE, and READ, mv_force_nstimeout() in sr_port/tpnotacid_chk_inline.h, so they are not
# tested separately.
echo '# Each command runs in its own process, which is stopped if the command has not returned within 30 seconds'
echo '# Expect $TEST=0, returned within 5 seconds, for each'
foreach cmd (LOCK ZALLOCATE READ)
	foreach tmo (-1 -1.5 -0.125 -0.0001)
		echo "# mumps -run try^negtmo1402 $cmd $tmo"
		timeout 30 $gtm_dist/mumps -run try^negtmo1402 $cmd $tmo >& try_${cmd}_${tmo}.out
		if (124 == $status) then
			echo "FAIL : $cmd with timeout $tmo did not return within 30 seconds"
		else
			cat try_${cmd}_${tmo}.out
		endif
	end
end
echo

echo "# Stop the process that holds LOCK l and ZALLOCATE l"
echo "# mumps -run stop^negtmo1402"
$gtm_dist/mumps -run stop^negtmo1402

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
