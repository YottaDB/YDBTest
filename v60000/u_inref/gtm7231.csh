#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
## Test the mupip journal extract on a journal file which has the database with the csd->wc_blocked bit set
echo "Test 1: set wc_blocked as 1, then starts the journal extraction process"
$echoline
setenv gtm_white_box_test_case_number 4
setenv gtm_white_box_test_case_count 1
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP set $tst_jnl_str -region DEFAULT >& journal_on_before.out

# create the database and set a long flush timer
$gtm_exe/dse >& "dse.outx" << EOF
find -region=DEFAULT
change -fileheader -flush_time=6000
quit
EOF

# enable the white-box test
setenv gtm_white_box_test_case_enable 1
# launch a GT.M process that would set wc_blocked and kill itself
$gtm_exe/mumps -run setWcBlockedAndKillSelf >&! setWcBlockedAndKillSelf.out

echo "Start extracting journal file"
$MUPIP journal -extract=mumps.mjf -noverify -detail -forward -fences=none mumps.mjl
unsetenv gtm_white_box_test_case_enable
$gtm_tst/com/dbcheck.csh
rm *.gld *.dat *.mjf *.mjf_*

echo ""
echo "Test 2: create a database with crash, then start the journal extraction process"
$echoline

$gtm_tst/com/dbcreate.csh mumps 1
# Enable the white-box test setup to avoid an assert failure due to the crash.
setenv gtm_white_box_test_case_number 29
setenv gtm_white_box_test_case_enable 1
# In the following wc_blocked won't be set, just let a gtm process kill itself
$gtm_exe/mumps -run setWcBlockedAndKillSelf >>&! setWcBlockedAndKillSelf.out
($MUPIP journal -extract=mumps.mjf -noverify -detail -forward -fences=none mumps.mjl &; echo $! >&! extra1.pid) >&! extra1.log
set extra1_pid=`cat extra1.pid`
$gtm_tst/com/wait_for_proc_to_die.csh $extra1_pid 120
$MUPIP journal -extract=mumps.mjf -noverify -detail -forward -fences=none mumps.mjl >&! extra2.log

$tail -3 mumps.mjf | $tst_awk '{print $5}' | $tst_awk 'BEGIN {FS="\\\\"} ; {print $5}' >& last_process.log

echo "## The extraction process id should not appear in the extracted mjf file"
$grep extra1_pid last_process.log

# Clean up the relinkctl shared memory segments.
$MUPIP rundown -relinkctl >&! mupip_rundown_rctl.logx

# Clean up expected orphaned shared memory segment and semaphore
# Note that even the MUPIP rundown here requires the white-box test setup to avoid assert failures
# hence the "unsetenv gtm_white_box_test_case_enable" happens at the end of this script.
$MUPIP rundown -override -region "*" >&! mupip_rundown.logx

unsetenv gtm_white_box_test_case_enable
