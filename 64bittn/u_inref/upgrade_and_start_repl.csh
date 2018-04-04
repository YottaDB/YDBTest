#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
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

########################################################################################################
# the script upgrades the database to the test version and checks for some expected instance file errors
# before starting replication servers.
# Accepts two arguments - both optional
# arg1 - common timestamp to be suffixed in the name of the log files
# arg2 - one for qualifier like "updateresync"
# arg3 - "check_jnlbadlabel" - an option to check if YDB-E-JNLBADLABEL is seen in syslog
########################################################################################################
#
if ( "" != $1 ) then
	setenv timestamp "$1"
else
	setenv timestamp `date +%H_%M_%S`
endif
if ( "check_jnlbadlabel" == "$3" ) then
	setenv check_jnlbadlabel 1
endif
$gtm_tst/com/get_journal_label.csh $gtm_dist >& prior_ver_jnl_label.txt
echo "### Upgrade to the test version in secondary side ###"
$sv_curver
$gtm_tst/com/get_journal_label.csh $gtm_dist >& curr_ver_jnl_label.txt
echo "! qdbrundown if applicable"			>>&! curver.gde
if ($gtm_test_qdbrundown) then
	echo "template -region -qdbrundown"		>>&! curver.gde
	echo "change -region DEFAULT -qdbrundown"	>>&! curver.gde
endif
$GDE @curver.gde >&! gde.out
if ($gtm_test_qdbrundown) then
	$MUPIP set -region "*" -qdbrundown 		>&! set_qdbrundown_db.out
endif
echo "Start V5 replication servers in secondary site "
$MUPIP replic -editinstance -show mumps.repl >&! inst_replinstfmt.outx
$grep -q YDB-E-REPLINSTFMT inst_replinstfmt.outx
if ($status) then
	set updresyncstr=""	# No REPLINSTFMT error between the two versions. So -updateresync startup NOT needed.
	if ($gtm_test_qdbrundown) then
		$MUPIP replic -editinstance -qdbrundown mumps.repl >&! set_qdbrundown_replinst.out
	endif
else
	# REPLINSTFMT error exists between the two versions. So -updateresync startup IS needed.
	if ($2 == "") then
		set updresyncstr="updateresync"
	else
		set updresyncstr="updateresync=$2 -initialize"
	endif
	# save the original mumps.repl
	mv mumps.repl mumps.repl_orig
	$MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $gtm_test_qdbrundown_parms
	$MUPIP replic -editinstance -show mumps.repl >&! show_inst_${timestamp}.out
	if ($status) echo "TEST-E-SHOWINSTANCE FAILED"
endif
if ( "" != "$updresyncstr") then
	# We expect the receiver server to exit (due to the source server closing the connection due to the REPINSTNOHIST error).
	# RCVR.csh which starts the receiver server and then does a checkhealth to ensure it is up and running.
	# It is possible in rare cases that the receiver server exits (thereby cleaning up the receive pool) even before the checkhealth is attempted.
	# In this case,the checkhealth will error out with YDB-E-NORECVPOOL message. We do not want this to happen so we specifically ask RCVR.csh
	# to skip the checkhealth by setting the environment variable gtm_test_repl_skiprcvrchkhlth. It is unset right afterwards.
	if ("0" != "${gtm_test_updhelpers}") then
		# The helpers will issue the YDB-E-JNLBADLABEL here instead of below, so start the syslog search from here.
		set syslog_before = `$gtm_tst/com/mumps_curpro.csh -cur_routines -run timestampdh -1`
	endif
	setenv gtm_test_repl_skiprcvrchkhlth 1
	setenv RCVR_LOG_FILE "RCVR_${timestamp}_REPLINSTNOHIST.log"
	$gtm_tst/com/RCVR.csh "decide" $portno $timestamp >&! RCVR_${timestamp}_REPLINSTNOHIST.out
	unsetenv gtm_test_repl_skiprcvrchkhlth
	$gtm_tst/com/wait_for_log.csh -log $RCVR_LOG_FILE -message "REPLINSTNOHIST" -duration 120
	if !($status) then
		# because in this case on REPLINSTNOHIST the receiver shuts down after the error
		# so lets wait for it to shutdown and then restart down the line.
		$gtm_tst/com/wait_for_log.csh -log $RCVR_LOG_FILE -message "Receiver server exiting" -duration 120
		mv RCVR_${timestamp}_REPLINSTNOHIST.log RCVR_${timestamp}_REPLINSTNOHIST.logx
		# also shutdown the passive source server
		$MUPIP replic -source -shutdown -timeout=0 >&! passive_${timestamp}.out
	endif
endif

if ($gtm_test_freeze_on_error) then
	# If freeze on error is set, YDB-E-JNLBADLABEL would freeze the instance.
	# To prevent it, cut new journal files before starting reciever server.
	$MUPIP set $tst_jnl_str -noprevjnlfile -region "*" >>&! cutnewjnl.out
endif

if ($gtm_test_trigger) then
	# The below will cut new journal files (i.e updateprocess would not switch journals then)
	$MUPIP trigger -upgrade >&! update_trigger.out
endif

if (( "" == "$updresyncstr") || ("0" == "${gtm_test_updhelpers}")) then
	# Otherwise the syslog timestamp was set above.
	set syslog_before = `$gtm_tst/com/mumps_curpro.csh -cur_routines -run timestampdh -1`
endif
setenv RCVR_LOG_FILE "RCVR_${timestamp}.log"
$gtm_tst/com/RCVR.csh "decide" $portno "$timestamp" "$updresyncstr" >&! START_${timestamp}.out
if ( (! $gtm_test_freeze_on_error) && (! $gtm_test_trigger) ) then
	set prior_jnl_label = `cat prior_ver_jnl_label.txt`
	set curr_jnl_label = `cat curr_ver_jnl_label.txt`
	# If journal labels are mismatched, new journals are not cut, updateprocess would switch journals and log YDB-E-JNLBADLABEL in syslog
	if ($?check_jnlbadlabel && "${prior_jnl_label}" != "${curr_jnl_label}") then
		$gtm_tst/com/getoper.csh "$syslog_before" "" jnlbadlabel.txt "" "JNLBADLABEL"
	else
		cat *_ver_jnl_label.txt > jnlbadlabel.txt
	endif
else
	echo "not checked gtm_test_trigger=$gtm_test_trigger gtm_test_freeze_on_error=$gtm_test_freeze_on_error" > jnlbadlabel.txt
endif
