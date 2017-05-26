#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that -resync=<strm_seqno> -rsync_strm=1 figures out the corresponding jnl_seqno and ensures no higher seqno
# corresponding to an update (irrespective of which stream that belongs to) is played forward but is considered a
# lost transaction.
#
# For example, if seqno 1,3,5,7,9,... are updates on local stream=0 in a.dat and seqno=2,4,6,8,... are updates on stream=1
# on b.dat, if the instance is at seqno 101 with strm_seqno[0]=51 and strm_seqno[1]=51, and the user says do a rollback
# -resync=31 -rsync_strm=1, the instance is taken back to seqno=61 and not anything lower or higher.
#

setenv test_specific_gde $gtm_tst/suppl_inst_C/inref/seqno.gde

source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2 2

$gtm_tst/com/dbcreate.csh mumps 1 125 1000

echo
echo "===>Start replication A->B, P->Q and A->P"
echo
setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

echo
echo "===>Do some updates on A and P and let them replicate to B, P and Q as appropriate"
echo
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/imptp.csh' >&! imptp_inst1_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfill "SLOWFILL" ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/imptp.csh' >&! imptp_inst3_1.out
$MSR RUN INST1 '$gtm_exe/mumps -run %XCMD "hang 0.2"'
$MSR RUN INST3 '$gtm_exe/mumps -run %XCMD "hang 0.2"'

#Stop updates on A and P
$MSR RUN INST1 'setenv gtm_test_jobid 1 ; setenv gtm_test_dbfillid 1 ; $gtm_tst/com/endtp.csh' >&! endtp_inst1_1.out
$MSR RUN INST3 'setenv gtm_test_jobid 2 ; setenv gtm_test_dbfillid 2 ; $gtm_tst/com/endtp.csh' >&! endtp_inst3_1.out

# Wait for ZERO backlog on A->P side
$MSR SYNC INST1 INST3
# Shut receiver side of A->P connection
$MSR STOPRCV INST1 INST3

# Shut source side of P->Q connection
$MSR STOPSRC INST3 INST4

# Shut source side of A->P connection
$MSR STOPSRC INST1 INST3

# Shut source side of A->B connection
$MSR STOPSRC INST1 INST2

set files = `$MSR RUN INST3 'set msr_dont_trace ; ls *.mjl'`
foreach file ($files)
	$MSR RUN INST3 "$MUPIP journal -extract -noverify -detail -for -fences=none $file" >&! jnlext_$file.outx
end

echo "Get the end seqno on INST3"

$MSR RUN INST3 '$grep SET *.mjf' >&! set.txt
$tst_awk -F\\ '$0 !~ /MULTISITE_REPLIC/ {print $7,$8,$9}' set.txt | sort -n >&! seqno.txt

set end_seqno = `$tail -n 1 seqno.txt`
@ end_seqno = $end_seqno[1]

# do rundown if needed before copying databases in a quiescent state.
$MSR RUN INST3 'set msr_dont_trace ; source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh '$0' ; mkdir rlbak fullbak ; cp *.* fullbak/'

# calculate the interesting points in seqno.txt. The interesting point is the switch between streams
# seqno.txt contains tuples in the form <seqno, strm_num, strm_seqno>
# In this test there are two streams 0 and 1. So interesting points are,
#  i) swtich from <seqno, 0, strm_seqno> to <seqno, 1, strm_seqno>
# ii) swtich from <seqno, 1, strm_seqno> to <seqno, 0, strm_seqno>

echo "Find out all the interesting points"

$tst_awk 'BEGIN {prev_strm_num=-1} (NR > '$end_seqno') {exit} ($2 != prev_strm_num) {print} {prev_strm_num = $2}' seqno.txt > points.txt

# Select any 4 interesting points randomly

echo "select 4 interesting points randomly"

@ total_points = `wc -l < points.txt`
echo "#Total number of points = GTM_TEST_DEBUGINFO $total_points"

set linenos = `seq $total_points`	# Generate list of numbers: 1..$total_points
set picked = ()
while ( (${#picked} < 4) && (${#linenos} > 0) )
	@ lineno = `$gtm_exe/mumps -run rand ${#linenos}` + 1
	set picked = ($picked ${linenos[${lineno}]})
	# Remove selected line number so it isn't picked again
	@ x = $lineno - 1
	@ y = $lineno + 1
	set linenos = ( $linenos[-$x] $linenos[$y-] )
end
set pickedpat = "$picked"		# Convert list to single element with spaces
set pickedpat = "$pickedpat:as/ /|/"
$tst_awk 'NR ~ /^('$pickedpat')$/ {print "\"" $0 "\""}' points.txt > points_selected.txt
eval "set points = (`cat points_selected.txt`)"

echo "verify the rollback is happening correctly"
foreach point ( $points:q )
	set seqno_tuple = ( $point )
	@ resync_seqno = $seqno_tuple[1]
	@ strm_num = $seqno_tuple[2]
        @ strm_seqno = $seqno_tuple[3]
	@ value++
	echo "point under processing is $seqno_tuple" >&! iter_$value.log
	echo "Trying rollback with -resync=$resync_seqno on INSTANCE3" >>&! iter_$value.log
        echo "$gtm_tst/com/mupip_rollback.csh -lost=x_$resync_seqno.los -resync=$resync_seqno ""*"" on INSTANCE3" >>&! iter_$value.log
	$MSR RUN INST3 "$gtm_tst/com/mupip_rollback.csh -lost=x_$resync_seqno.los -resync=$resync_seqno"' "*"'" >>& rollback_$resync_seqno.log" >>&! iter_$value.log
	$MSR RUN INST3 '$grep "Rollback successful"'" rollback_$resync_seqno.log" >>&! iter_$value.log
	$MSR RUN INST3 '$grep -E "RLBKJNSEQ|RLBKSTRMSEQ"'" rollback_$resync_seqno.log >& rollback_$resync_seqno.outx" >>&! iter_$value.log
	$MSR RUN INST3 "mkdir bk_$value ; cp *.* bk_$value ; mv rollback_*.log rlbak ; rm *.* ; cp fullbak/* ." >>&! iter_$value.log

	echo "Rollback with -resync=$strm_seqno -rsync_strm=$strm_num on INSTANCE3" >>&! iter_$value.log
	echo "$gtm_tst/com/mupip_rollback.csh -lost=x_${strm_seqno}_${strm_num}.los -resync=$strm_seqno -rsync_strm=$strm_num ""*"" on INSTANCE3"  >>&! iter_$value.log
        $MSR RUN INST3 "$gtm_tst/com/mupip_rollback.csh -lost=x_${strm_seqno}_${strm_num}.los -resync=$strm_seqno -rsync_strm=$strm_num"' "*" >>& '"rollback_${resync_seqno}_strm_${strm_num}.log" >>&! iter_$value.log
	$MSR RUN INST3 '$grep "Rollback successful"'" rollback_${resync_seqno}_strm_${strm_num}.log" >>&! iter_$value.log
	$MSR RUN INST3 '$grep -E "RLBKJNSEQ|RLBKSTRMSEQ"'" rollback_${resync_seqno}_strm_${strm_num}.log >& rollback_${resync_seqno}_strm_${strm_num}.outx " >>&! iter_$value.log
        $MSR RUN INST3 'mv rollback_*.log rlbak' >>&! iter_$value.log
	$MSR RUN INST3 '$grep -v NOSELECT *.outx; mv *.outx rlbak' >>&! iter_$value.log
end

$MSR RUN INST3 'mkdir last_run ; cp *.* last_run/ ; rm *.* ; cp fullbak/* .'
echo
echo "===>Stop all links"
echo
$MSR STOP ALL_LINKS

$gtm_tst/com/dbcheck.csh -extract
