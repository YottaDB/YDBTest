#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh hugepages triggers tls

# We just need 2 instances
$MULTISITE_REPLIC_PREPARE 2

if (! $?gtm_test_replay) then
	set remote_prior_ver = `$gtm_tst/com/random_ver.csh -gte V53004 -lte V60003`
	if ("$remote_prior_ver" =~ "*-E-*") then
		echo "No prior versions available: $remote_prior_ver"
		exit -1
	endif
	echo "setenv remote_prior_ver $remote_prior_ver"	>>&! settings.csh
	# Randomly decide if the primary or the secondary will be the prior version.
	set inst = `$gtm_exe/mumps -run chooseamong "INST1" "INST2"`
	echo "setenv inst $inst"				>>&! settings.csh
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $remote_prior_ver

echo "$inst will run with prior version $remote_prior_ver" >>&! priorver_on_inst.txt
setenv gtm_test_repl_skipsrcchkhlth
setenv gtm_test_repl_skiprcvrchkhlth

# Now change the version for the random instance
cp msr_instance_config.txt msr_instance_config.bak
$tst_awk '{if("'$inst'" == $1){if("VERSION:" == $2){sub("'$tst_ver'","'$remote_prior_ver'")}};print}' msr_instance_config.bak	\
												>&! msr_instance_config.txt
$MULTISITE_REPLIC_ENV

# Remove existing .o files to avoid INVOBJ errors due to prior versions being involved.
rm -f *.o >& /dev/null

# Since the test involes random prior version on either INSTANCE1 or INSTANCE2, redirect the dbcreate output to a separate file
# to avoid having to deal with reference file issues.
$gtm_tst/com/dbcreate.csh mumps 1	>&! dbcreate.log
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set src_logfile = SRC_${time_msr}.log
# The receiver server might terminate before we get to do the checkhealth, so disregard the exit status.
setenv gtm_test_repl_skiprcvrchkhlth 1
$MSR STARTRCV INST1 INST2
unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
set rcv_logfile = RCVR_${time_msr}.log

# At this point, depending on which instance is running the latest version, the REPLNOTLS error may be found either in the Source
# or Receiver log files.
if ("INST1" == "$inst") then
	set target_inst = "INST2"
	set logfile = $rcv_logfile
else
	set target_inst = "INST1"
	set logfile = $src_logfile
endif
$MSR RUN $target_inst "set msr_dont_trace; $gtm_tst/com/wait_for_log.csh -log $logfile -message REPLNOTLS"
$MSR RUN $target_inst "set msr_dont_trace; $msr_err_chk $logfile 'YDB-E-REPLNOTLS'" >&! capture_REPLNOTLS.logx

# Filter out randomness and print only what matters.
# sed 's/RCVR.*log/##FILTERED##/g' capture_REPLNOTLS.logx | sed 's/SRC.*log/##FILTERED##/g' | sed 's/Receiver/##FILTERED##/g'	\
# 											  | sed 's/Source/##FILTERED##/g'
#
$tst_awk '{gsub(/((RCVR|SRC)[_0-9]*.log|Receiver|Source)/,"##FILTERED##");print}' capture_REPLNOTLS.logx

# Get rid of the -E-REPLNOTLS from the last MSR script that was executed as well as from the multisite_replic.log.
$gtm_tst/com/knownerror.csh $msr_execute_last_out "YDB-E-REPLNOTLS"
$gtm_tst/com/knownerror.csh multisite_replic.log "YDB-E-REPLNOTLS"

if ("INST1" == "$target_inst") then
	# The source server would have exited, leaving behind ipcs. Manually remove them
	$MSR RUN INST1 'set msr_dont_trace ; $MUPIP rundown -region "*" >&! inst1_rundown.out'
else
	# Just the receiver would have exited with the above error. Shutdown everything else, but don't check for the status
	setenv msr_dont_chk_stat
	$MSR STOPRCV INST1 INST2 >&! inst2_stop.outx
	unsetenv msr_dont_chk_stat
endif
# Refresh the links, since one side would have exited
$MSR REFRESHLINK INST1 INST2
# Since the test involes random prior version on either INSTANCE1 or INSTANCE2, redirect the dbcheck output to a separate file
# to avoid having to deal with reference file issues.
# Also do not attempt sync since one of the servers would be dead anyway
setenv gtm_test_norfsync
$gtm_tst/com/dbcheck.csh	>&! dbcheck.log
