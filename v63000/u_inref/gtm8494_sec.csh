#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "`date` : sec : start gtm8494_dsecrit.csh in the background"
$gtm_tst/$tst/u_inref/gtm8494_dsecrit.csh >& dsecrit.out &
@ dsecrit_job = $!

if (1 == $test_replic_suppl_type) then
	set pri_hist_seqno = "Start Sequence Number"			# Extract the Start Seqno history on the primary
	set sec_hist_seqno = "Stream Sequence Number"			# Extract the Sream Seqno history on the secondary
	set sec_header_seqno = "HDR STRM  1: Journal Sequence Number"	# Compare the Journal Seqno of the stream from the primary
	set compare_fields = "NF"					# Just pick the sequence number because on the primary it is "Start seqno" on secondary it is "Stream seqno"
	set sec_hist_start = 2						# The first history record is always of the local supplementary source server
else
	set pri_hist_seqno = "Start Sequence Number"
	set sec_hist_seqno = "Start Sequence Number"
	set sec_header_seqno = "HDR Journal Sequence Number"
	set compare_fields = "0"					# The entire record should be similar on the primary and secondary
	set sec_hist_start = 1						# Check all the history records
endif
echo "`date` : sec : start the backups in a loop"
@ cnt = 0
@ start_time = `date +%s`
@ elapsed_time = 0
# From multiple runs on all servers without the code fix, it was observed that this would fail consistently within 60 seconds or 10 backups
# So, run it for a maximum of 60 seconds or 15 backups or until the primary timed out
while ( (! -e test.end) && (60 > $elapsed_time) && (15 > $cnt) )
	@ cnt = $cnt + 1
	set bakdir = "bak"_$cnt
	echo "`date` : sec : backup at $bakdir"
	mkdir -p $bakdir
	$MUPIP backup -replinst=$bakdir "*" $bakdir

	# Get replication history information from the Primary side
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $MUPIP replic -editinstance -show mumps.repl >& replshow.out"
	if ($tst_now_primary:ar == $tst_now_secondary:ar) then
		cp $PRI_SIDE/replshow.out $bakdir/replshow_pri.out
	else
		$rcp ${tst_now_primary}:$PRI_SIDE/replshow.out $bakdir/replshow_pri.out
	endif
	$MUPIP replic -editinstance -show $bakdir/mumps.repl >&! $bakdir/replshow_sec.out

	echo "# Get just the history records from the primary and secondary"
	$grep -E "$pri_hist_seqno" $bakdir/replshow_pri.out | tr -d '[]' >& $bakdir/replshow_pri_filtered.out
	$grep -E "$sec_hist_seqno" $bakdir/replshow_sec.out | tr -d '[]' >& $bakdir/replshow_sec_filtered.out

	echo "# Note down the Journal Sequence number from the backup instance"
	set sec_seqno = `$grep "$sec_header_seqno" $bakdir/replshow_sec.out |& $tst_awk '{print $NF}' | tr -d '[]'`
	if (""  == "$sec_seqno") then
		# It is possible that the SRC-RCVR connection did not get established at this point. Skip this backup and continue
		echo "# `date` : sec_seqno is null, probably connection wasn't esablished. Will continue with the next backup"
		continue
	endif

	echo "# Secondary journal sequence number : $sec_seqno"
	echo "# Filter out the history records until (not including $sec_seqno) both from the primary and secondary"
	$tst_awk '{if (($NF != "'$sec_seqno'") && (NR >= '$sec_hist_start')) { print $'$compare_fields'}}' $bakdir/replshow_sec_filtered.out > $bakdir/hist_sec.out
	$tst_awk '(strtonum($NF) < strtonum('$sec_seqno')) {print $'$compare_fields'}' $bakdir/replshow_pri_filtered.out >& $bakdir/hist_pri.out

	echo "# The expectation is that the history records should be identical"
	echo "# diff $bakdir/hist_pri.out $bakdir/hist_sec.out"
	diff $bakdir/hist_pri.out $bakdir/hist_sec.out
	set diffstatus = $status
	@ curr_time = `date +%s`
	@ elapsed_time = $curr_time - $start_time

	if ($diffstatus) then
		echo "# `date` : BACKUP-E-HISTORY : The history records $bakdir/hist_pri.out $bakdir/hist_sec.out differs  - count : $cnt ; Elapsed time : $elapsed_time"
		echo "# `date` : The history records $bakdir/hist_pri.out $bakdir/hist_sec.out differs  - $bakdir" >> test.end
		break
	else
		echo "# `date` : The history records of $bakdir/hist_pri.out $bakdir/hist_sec.out are identical"
	endif
end

echo "`date` : gtm8494_sec.csh ends : elapsed_time = $elapsed_time ; cnt = $cnt" >> test.end
# Signal the script on the primary to stop
if ($tst_now_primary:ar == $tst_now_secondary:ar) then
	cp test.end $PRI_SIDE/test.end
else
	$rcp test.end ${tst_now_primary}:$PRI_SIDE/test.end
endif

echo "# `date` : wait for gtm8494_dsecrit.csh ($dsecrit_job) to exit"
$gtm_tst/com/wait_for_proc_to_die.csh $dsecrit_job
