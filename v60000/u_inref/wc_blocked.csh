#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Due to the configuration of the test, it is better to run this test only in BG mode.
source $gtm_tst/com/gtm_test_setbgaccess.csh
# This test needs to cause wc_blocked to be set to 1 and then kill the processes before they have
# a chance to do wcs_recover(). After that stage one of the following cases:

setenv gtm_white_box_test_case_number 4
setenv gtm_white_box_test_case_count 1

set save_test_replic = "$test_replic"
set save_gtm_repl_instance = "$gtm_repl_instance"
unsetenv test_replic
unsetenv gtm_repl_instance

# unset this to get consistent errors in case 4
unsetenv gtm_custom_errors

# remember the current directory to ensure we are seeing messages from our
# processes in the syslog and not someone else's
set cur_dir = `pwd`

#############################################################################
# Case 1.                                                                   #
# Start a GT.M process and do an update; there should be no error messages, #
# but wcs_recover() should get called.                                      #
#############################################################################
set case = 1
echo "Case ${case}. Start a GT.M process after a crash with wc_blocked."
echo

# create the database and set a long flush timer
$gtm_tst/com/dbcreate.csh mumps > dbcreate${case}.outx
$gtm_exe/dse >& "dse${case}.outx" << EOF
find -region=DEFAULT
change -fileheader -flush_time=6000
quit
EOF

# enable the white-box test
setenv gtm_white_box_test_case_enable 1

# remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# launch a GT.M process that would set wc_blocked and kill itself
($gtm_exe/mumps -run setWcBlockedAndKillSelf &) >&! setWcBlockedAndKillSelf${case}.out

# wait for the pid and save it
$gtm_tst/com/wait_for_log.csh -waitcreation -log pid.outx -duration 60
set pid = `cat pid.outx`

# wait for the process to die
$gtm_tst/com/wait_for_proc_to_die.csh $pid 60

# remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# clean up relinkctl shared memory
$gtm_exe/mupip rundown -relinkctl >&! mupip_rundown_rctl1.logx

# verify that WCBLOCKED message was printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "wcblocked${case}.txt" "" WCBLOCKED
$grep WCBLOCKED wcblocked${case}.txt | $grep "$cur_dir" >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL YDB-W-WCBLOCKED not found in operator log. Check wcblocked${case}.txt."
endif

# disable the white-box test
unsetenv gtm_white_box_test_case_enable

# remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# launch a GT.M process that should grab crit
$gtm_exe/mumps -direct >&! "gtm${case}.outx" << EOF
set ^b=1
EOF
sleep 1

# remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# verify that DBWCVERIFYSTART was printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "" "verifystart${case}.txt" "" DBWCVERIFYSTART
$grep DBWCVERIFYSTART verifystart${case}.txt | $grep "$cur_dir" >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL YDB-I-DBWCVERIFYSTART not found in operator log. Check verifystart${case}.txt."
endif

# verify that the database is fine
$gtm_tst/com/dbcheck.csh

$echoline

#############################################################################
# Case 2.                                                                   #
# Remove the shared memory and start a GT.M process; there should be a      #
# 'rundown required' message (journaling being disabled), but wcs_recover() #
# should not be invoked.                                                    #
#############################################################################
set case = 2
echo "Case ${case}. Remove shared memory and start a GT.M process after a crash with wc_blocked but no journaling."
echo

# remove the remnants of the previous case
\rm pid.outx >&! rm_pid${case}.outx
\rm mumps.{dat,gld,mjl} >&! rm_mumps${case}.outx

# make sure that journaling is turned off
setenv gtm_test_jnl NON_SETJNL

# create the database and set a long flush timer
$gtm_tst/com/dbcreate.csh mumps > dbcreate${case}.outx
$gtm_exe/dse >& "dse${case}.outx" << EOF
find -region=DEFAULT
change -fileheader -flush_time=6000
quit
EOF

# enable the white-box test
setenv gtm_white_box_test_case_enable 1

# remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# launch a GT.M process that would set wc_blocked and kill itself
($gtm_exe/mumps -run setWcBlockedAndKillSelf &) >&! setWcBlockedAndKillSelf${case}.out

# wait for the pid and save it
$gtm_tst/com/wait_for_log.csh -waitcreation -log pid.outx -duration 60
set pid = `cat pid.outx`

# wait for the process to die
$gtm_tst/com/wait_for_proc_to_die.csh $pid 60

# remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# clean up relinkctl shared memory
$gtm_exe/mupip rundown -relinkctl >&! mupip_rundown_rctl2.logx

# verify that WCBLOCKED message was printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "wcblocked${case}.txt" "" WCBLOCKED
$grep WCBLOCKED wcblocked${case}.txt | $grep "$cur_dir" >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL YDB-W-WCBLOCKED not found in operator log. Check wcblocked${case}.txt."
endif

# disable the white-box test
unsetenv gtm_white_box_test_case_enable

# get the shared memory id
set shmid = `$MUPIP ftok mumps.dat | $grep "mumps.dat" | $tst_awk '{print $6}'`

# delete shared memory
$gtm_tst/com/ipcrm -m $shmid

# launch a GT.M process
$gtm_exe/mumps -direct >& "gtm${case}a.outx" << EOF
set ^b=1
EOF

# verify that REQRUNDOWN message was printed in the GT.M prompt
$grep REQRUNDOWN gtm${case}a.outx
if ($status) then
	echo "TEST-E-FAIL YDB-E-REQRUNDOWN not issued. Check gtm${case}a.outx."
endif

# remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# do a MUPIP RUNDOWN on all regions
$MUPIP rundown -region "*" -override >& rundown${case}.outx
if ($? != 0) then
	echo "Error in mupip rundown. Check rundown${case}.outx."
endif

# remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# verify that DBWCVERIFYSTART was NOT printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "verifystart${case}.txt" ""
$grep DBWCVERIFYSTART verifystart${case}.txt | $grep "$cur_dir" >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL YDB-I-DBWCVERIFYSTART found in operator log. Check verifystart${case}.txt."
endif

echo

# verify that the database is fine
$gtm_tst/com/dbcheck.csh

# launch a GT.M process that should grab crit
$gtm_exe/mumps -direct >& "gtm${case}b.outx" << EOF
set ^b=1
EOF

# verify that REQRUNDOWN message was NOT printed in the GT.M prompt
$grep REQRUNDOWN gtm${case}b.outx
if (! $status) then
	echo "TEST-E-FAIL YDB-E-REQRUNDOWN issued. Check gtm${case}b.outx."
endif

$echoline

#############################################################################
# Case 3.                                                                   #
# Remove the shared memory and start a GT.M process; there should be a      #
# 'recover required' message (journaling being enabled), but wcs_recover()  #
# should not be invoked.                                                    #
#############################################################################
set case = 3
echo "Case ${case}. Remove shared memory and start a GT.M process after a crash with wc_blocked and journaling."
echo

# remove the remnants of the previous case
\rm pid.outx >&! rm_pid${case}.outx
\rm mumps.{dat,gld,mjl} >&! rm_mumps${case}.outx

# make sure that random journaling is turned off
setenv gtm_test_jnl NON_SETJNL

# create the database with journaling and set a long flush timer
$gtm_tst/com/dbcreate.csh mumps > dbcreate${case}.outx
$MUPIP set -journal=enable,on,before -reg "*" >&! mupip_set${case}.outx
$gtm_exe/dse >& "dse${case}.outx" << EOF
find -region=DEFAULT
change -fileheader -flush_time=6000
quit
EOF

# enable the white-box test
setenv gtm_white_box_test_case_enable 1

# remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# launch a GT.M process that would set wc_blocked and kill itself
($gtm_exe/mumps -run setWcBlockedAndKillSelf &) >&! setWcBlockedAndKillSelf${case}.out

# wait for the pid and save it
$gtm_tst/com/wait_for_log.csh -waitcreation -log pid.outx -duration 60
set pid = `cat pid.outx`

# wait for the process to die
$gtm_tst/com/wait_for_proc_to_die.csh $pid 60

# remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# clean up relinkctl shared memory
$gtm_exe/mupip rundown -relinkctl >&! mupip_rundown_rctl3.logx

# verify that WCBLOCKED message was printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "wcblocked${case}.txt" "" WCBLOCKED
$grep WCBLOCKED wcblocked${case}.txt | $grep "$cur_dir" >&! /dev/null
if ($status) then
	echo "TEST-E-FAIL YDB-W-WCBLOCKED not found in operator log. Check wcblocked${case}.txt."
endif

# disable the white-box test
unsetenv gtm_white_box_test_case_enable

# get the shared memory id
set shmid = `$MUPIP ftok mumps.dat | $grep "mumps.dat" | $tst_awk '{print $6}'`

# delete shared memory
$gtm_tst/com/ipcrm -m $shmid

# launch a GT.M process
$gtm_exe/mumps -direct >& "gtm${case}a.outx" << EOF
set ^b=1
EOF

# verify that REQRECOV message was printed in the GT.M prompt
$grep REQRECOV gtm${case}a.outx
if ($status) then
	echo "TEST-E-FAIL YDB-E-REQRECOV not issued. Check gtm${case}a.outx."
endif

# remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# do a MUPIP RUNDOWN on all regions
$MUPIP rundown -region "*" -override >& rundown${case}.outx
if ($? != 0) then
	echo "Error in mupip rundown. Check rundown${case}.outx."
endif

# remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# verify that DBWCVERIFYSTART was NOT printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "verifystart${case}.txt" ""
$grep DBWCVERIFYSTART verifystart${case}.txt | $grep "$cur_dir" >&! /dev/null
if (! $status) then
	echo "TEST-E-FAIL YDB-I-DBWCVERIFYSTART found in operator log. Check verifystart${case}.txt."
endif

echo

# verify that the database is fine
$gtm_tst/com/dbcheck.csh

# launch a GT.M process that should grab crit
$gtm_exe/mumps -direct >& "gtm${case}b.outx" << EOF
set ^b=1
EOF

# verify that REQRECOV message was NOT printed in the GT.M prompt
$grep REQRECOV gtm${case}b.outx
if (! $status) then
	echo "TEST-E-FAIL YDB-E-REQRECOV issued. Check gtm${case}b.outx."
endif

# reenable replication before using MSR framework
setenv test_replic "$save_test_replic"
setenv gtm_repl_instance "$save_gtm_repl_instance"

$echoline

#############################################################################
# Case 4.                                                                   #
# Remove the shared memory and start a GT.M process; there should be a      #
# 'rollback required' message (replication being used), but wcs_recover()   #
# should not be invoked.                                                    #
#############################################################################
set case = 4
echo "Case ${case}. Remove shared memory and start a GT.M process after a crash with wc_blocked, journaling, and replication."
echo

# remove the remnants of the previous case
\rm pid.outx >&! rm_pid${case}.outx
\rm mumps.{dat,gld,mjl} >&! rm_mumps${case}.outx

# make sure we have before image journaling
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=5"
source $gtm_tst/com/gtm_test_setbeforeimage.csh

# prepare to use MSR framework with two instances
$MULTISITE_REPLIC_PREPARE 2

# create the database with journaling and set a long flush timer
$gtm_tst/com/dbcreate.csh mumps > dbcreate${case}.outx

# start both instances
$MSR START INST1 INST2 RP

echo

# launch a GT.M process to write some updates
$gtm_exe/mumps -direct >& "gtm${case}a.outx" << EOF
set ^b=1
EOF

# Before crashing the receiver side, make sure the source side instance information is committed to the receiver side instance file
# This is necessary to avoid INSUNKNOWN errors later when the receiver is restarted (and when no errors are expected).
get_msrtime	# sets "time_msr" variable to most recent $MSR command.
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_'$time_msr'.log.updproc -message "New History Content" -duration 300'

# crash secondary and take the backup of crashed database
$MSR CRASH INST2

echo

# launch a GT.M process to write more updates while the secondary is down
$gtm_exe/mumps -direct >& "gtm${case}b.outx" << EOF
set ^c=1
EOF

# try to start the receiver; should get an error message
$MSR STARTRCV INST1 INST2

# verify that REQROLLBACK message was printed in the START_* file
set last_start_log = `ls -ltr $SEC_SIDE/START_* | $tail -1 | $tst_awk '{print $9}'`
$gtm_tst/com/check_error_exist.csh $last_start_log REPLREQROLLBACK ENO JNL_ON-E-MUPIP
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/jnl.log REQROLLBACK

# also try to start a GT.M process; should get the same error message
$MSR RUN INST2 '$gtm_exe/mumps -run %XCMD "set ^c=1" >&! gtm'${case}'c.out'

# verify that REQROLLBACK message was printed in the GT.M prompt
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/gtm${case}c.out REQROLLBACK ENO
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/jnl.log ENO MUNOFINISH JNL_ON-E-MUPIP

# do a MUPIP ROLLBACK on secondary
$MSR RUN INST2 '$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >>&! rollback'${case}'.outx'

echo

# try to start another GT.M process on secondary; should not get any error
$MSR RUN INST2 '$gtm_exe/mumps -run %XCMD "set ^c=1" >&! gtm'${case}'d.outx'

echo

# try to start the receiver again; this time should not get any error messages
$MSR STARTRCV INST1 INST2

echo

# stop both instances
$MSR STOP INST1 INST2

echo

# verify that the database is fine
$gtm_tst/com/dbcheck.csh
