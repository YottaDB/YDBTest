#!/usr/loca/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# v5cbsu test is chosen only randomly (50% chance) everytime
# The script output WILL NOT BE DISPLAYED in the reference file as there is only a random chance for its execution
# TEST-E-ERROR messages are thrown at every juncture where the test has behaved differently and this will be searched for correctness in the actual reference file
#
echo "v5cbsu run,should issue DBCBADFILE error here as valid phase1 file is not fed for v5cbsu"
cp $v5cbsupath/v5cbsu.m .
$gtm_exe/mumps -run ^v5cbsu mumps.dat >>&! badfile_v5cbsu.log
if ( 0 != $status || 0 == `grep "DBCBADFILE"  badfile_v5cbsu.log|wc -l` ) then
	echo "TEST-E-ERROR.DBCBADFILE expected but not received"
endif
cat badfile_v5cbsu.log;rm -f badfile_v5cbsu.log
cp -f dbcertify_report1.scan dbcertify_report2.scan
#

# Get the contents of the scan file by invoking dump entryref
$gtm_exe/mumps -run dump^v5cbsu dbcertify_report2.scan >&! dump_v5cbsu.out
set noof_gvt_leaf = `$tst_awk 'BEGIN { n=0 } /GVT-Leaf/ {n++} END {print n}' dump_v5cbsu.out`

set killglobal=0
# rand.o might already exist and sometime we see %YDB-E-INVOBJ, error.
\rm -f rand.o >&! /dev/null
set kill_rand=`$gtm_exe/mumps -run rand 2`
if (1 == $kill_rand) then
	echo "Randomly choose to kill a global"
	if (2 <= "$noof_gvt_leaf") then
		echo "There are at least 2 leaf blocks that will be processed by v5cbsu"
		echo "Let us kill one global to test if it passes it to certify instead of just discarding it"
		set killglobal=1
	else
		echo "There is only one leaf level data block that will be processed by v5cbsu"
		echo "Killing that one block will fail the rest of the test. So the kill section of the test is skipped"
	endif
else
	echo "Randomly choose not to kill any globals"
endif

if ( 1 == $killglobal) then
	set globaltokill = `$tst_awk '/GVT-Leaf/ {print $4}' dump_v5cbsu.out | $tail -n 1`
	echo "global to kill - $globaltokill"
$GTM << EOF
set file="value_of_killed_global.out"
open file use file write $globaltokill close file
write "kill the global $globaltokill"
kill $globaltokill
EOF

	echo "A global is killed. So let's not run the background verification process"
else
	echo "Start the verification process  in the background"
	($gtm_exe/mumps -run ^onlnread < /dev/null >>& onlnread_v5cbsu.out &) >&! bgid2.out
	$gtm_tst/$tst/u_inref/wait_for_onlnread_to_start.csh 60
endif

# Take ls listing before v5cbsu
ls -a | $grep -v "ls_before_v5cbsu.out" >&! ls_before_v5cbsu.out

echo "v5cbsu run, should display block numbers that gets fixed"
$gtm_exe/mumps -run v5cbsu dbcertify_report2.scan >>&! run_v5cbsu.log
set v5cbsu_status = $status

# Take ls listing after v5cbsu
ls -a | $grep -vE "ls_before_v5cbsu.out|ls_after_v5cbsu.out|run_v5cbsu.log|dbcertify_report2.scan_orig" >&! ls_after_v5cbsu.out

set records_processed = `$grep -E "There are no GVT leaf \(level 0\) blocks to process in this database|records processed: [1-9]" run_v5cbsu.log|wc -l`
if ( 0 != $v5cbsu_status || 0 == "$records_processed") then
	echo "TEST-E-ERROR v5cbsu failed"
	exit 1
endif
cat run_v5cbsu.log

# Test if there are no new files (other than the scan_orig) created/leftover by v5cbsu utility
diff ls_before_v5cbsu.out ls_after_v5cbsu.out
if ($status) then
	echo "TEST-E-ERROR. There were some files leftover by v5cbsu utility. Check ls_before_v5cbsu.out and ls_after_v5cbsu.out"
endif

# Get the contents of the scan file by invoking dump entryref. Check if the scan file is not corrupted
$gtm_exe/mumps -run dump^v5cbsu dbcertify_report2.scan >&! dump2_v5cbsu.out

set is_noGVT = `$grep -E "There are no GVT leaf \(level 0\) blocks to process in this database" run_v5cbsu.log | wc -l`
if !($is_noGVT) then
	# Test if the file was renamed to _orig and it doesn't differ from the original file
	echo "diff dbcertify_report2.scan_orig dbcertify_report1.scan"
	diff dbcertify_report2.scan_orig dbcertify_report1.scan
	if ($status) then
		cp dbcertify_report1.scan dbcertify_report1.scan.copied
		echo "TEST-E-ERROR. The saved scan file differs from the original scan file. Check dbcertify_report2.scan_orig and dbcertify_report1.scan.copied"
		exit 1
	endif
	echo "diff dbcertify_report2.scan_orig dbcertify_report2.scan"
	diff dbcertify_report2.scan_orig dbcertify_report2.scan
endif

$DBCERTIFY scan -report_only DEFAULT
if ( 0 != $status || 0 != `$DBCERTIFY scan -report_only DEFAULT|$tst_awk ' /GVT leaf/ {print $7}'` ) then
	echo "TEST-E-ERROR GVT. leaf has non-zero value even after v5cbsu run"
	exit 1
endif
#
if (1 == $killglobal) then
	echo "# A global was killed. Restore it now"
	$GTM << gtm_eof
set file="value_of_killed_global.out"
open file use file read value close file
write "set $globaltokill to ",value,!
set $globaltokill=value
gtm_eof
#
else
	echo "# Stop the background verification job"
	$GTM << gtm_eof
set ^stop=1
halt
gtm_eof
#
	set pid = `cat concurrent_job.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid -1
	rm -f concurrent_job.out
	if (`grep -v "PASS" onlnread_v5cbsu.out|grep -i "[a-z]"|wc -l`) then
		echo "TEST-E-ERROR Verification failed for GT & DT.Pls. check onlnread_v5cbsu.out"
		exit 1
	endif
endif
# In any case (kill done or not done) do the verification
$GTM << EOF
do verify^upgrdtst
EOF

# move the latest dbcertify scan report file
mv dbcertify_report1.scan dbcertify_report_bak.scan
mv dbcertify_report2.scan dbcertify_report1.scan
#
