#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test launches one DSE process in the background and leaves in a "open terminal" state (after db_init() is done and all
# semaphores are unlocked, but not not deleted). Next, a second DSE process is launched, which holds onto both access and control
# semaphore. Finally, a third {DSE,LKE} process is launched and did some operation after bypassing both semaphores held by the
# second process.

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and affects the calculations of this very sensitive test. So disable counter overflows.
unsetenv gtm_db_counter_sem_incr

# Turn off statshare related env var as it causes test hang due to this being a white-box test case
# and is not considered worth the effort to fix the test and/or code to test this with statshare as well.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

$gtm_tst/com/dbcreate.csh mumps 1 -block_size=4096

@ i = 1
# Commands that will be executed by bypasser process are given int following line
foreach bypassercmd ("dse change -fileheader -record_max_size=1024" "lke show")
	echo "#Launch first process and wait after db_init()"
$GTM <<EOF
	do runregular^hangit($i)
	quit
EOF
	$gtm_tst/com/wait_for_log.csh -log regularout_$i -message "start"
	echo "#Launch second process"
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number 60
	setenv gtm_white_box_test_case_count 1
	($gtm_exe/dse exit >&! ftok_halt.out_$i; echo "DSE DONE" &) >&! ftok_halt.log_$i
	$gtm_tst/com/wait_for_log.csh -log ftok_halt.out_$i -message "Holding semaphores"

	echo "#Launch third and bypasser process: " $bypassercmd
	set syslog_before = `date +"%b %e %H:%M:%S"`
	$gtm_exe/$bypassercmd
	$gtm_tst/com/getoper.csh "$syslog_before" "" syslog${i}_1.txt "" "RESRCWAIT"
	$grep "RESRCWAIT.*$PWD" syslog${i}_1.txt

	unsetenv gtm_white_box_test_case_enable
	unsetenv gtm_white_box_test_case_number
	unsetenv gtm_white_box_test_case_count

	echo "#Allow the first process to go"
	set firstpid = `$head -n 1 regularout_$i`
	$gtm_exe/mupip intrpt  $firstpid
	echo "#Wait for all processes to quit"
	#wait for the first process
	$gtm_tst/com/wait_for_proc_to_die.csh $firstpid 120
	#wait for the second process
	$gtm_tst/com/wait_for_log.csh -log ftok_halt.log_$i -message "DSE DONE"
	$gtm_tst/com/getoper.csh "$syslog_before" "" syslog${i}_2.txt "" "RESRCINTRLCKBYPAS"
	$grep -q "RESRCINTRLCKBYPAS" syslog${i}_2.txt
	if ($? != 0) then
	    echo "TEST-E-FAIL RESRCINTRLCKBYPAS not found in operator log. Check syslog.txt."
	endif
	$MUPIP rundown -reg "*"
	@ i += 1
	#Let's check if DSE changes are applied and LKE sees the same changes
	$gtm_exe/mumps -run %XCMD 'write $$^%PEEKBYNAME("sgmnt_data.max_rec_size","DEFAULT"),!'
end

$gtm_tst/com/dbcheck.csh
