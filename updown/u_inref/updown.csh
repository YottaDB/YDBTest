#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Updown Starts..."
if ($LFE == "L") then
	set iteration = 1
else if ($LFE == "F") then
	set iteration = 5
else
	set iteration = 25
endif
set counter = 0
while ($counter < $iteration)
	@ counter++
	set outputfile1 = "round_${counter}.out"
	set outputfile2 = "round_${counter}.cmp"
	set difffile = "round_${counter}.diff"
	setenv gtm_test_sprgde_id "ID$counter"	# to differentiate multiple dbcreates done in the same subtest
	$gtm_tst/$tst/u_inref/upndown_once.csh >& $outputfile1
	set outref_txt = "$gtm_tst/$tst/outref/counter.txt"
	$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $outputfile1 $outref_txt >&! $outputfile2
	diff $outputfile2 $outputfile1 > $difffile
	set severity = $status
	if ($severity) then
		echo "FAIL : round_${counter}.diff"
	else
		echo "PASS from round_${counter}"
	endif
end
echo "Updown Done."
