#!/usr/local/bin/tcsh -f
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
# This module is derived from FIS GT.M.
#################################################################

# this script tests all commands that makes use of instsecondary qualifier
# various correct and incorrect combinations of instsecndary will be specified as argument to this script
#
# usage:
# replic_source_commands.csh receiver [instsecvalue] [errormessage] [additional qual]
#
# arg1 - to know on which receiver it has to work on.
# arg2 (optional) - for instsecondary qualifier which may or may not be given based on the scenario we are interested to test
# arg3 (optional) - that takes the name of the error message when the script is invoked to check for certain errors.This will help in filtering the known messages so that it can be avoided at the end of the test
# arg4 (optional) -  can be the name of the qualifier like "needrestart" etc. If it is more than one it has to be
# comma separated and the script will NOT check for the error for those qualifiers alone. Rest of them will be checked for.
#
if ( 0 == $#argv ) then
	echo "MSR-E-NOARG error. Pls. specify the receiver node to work on"
	echo "Sample usage:"
	echo "$gtm_tst/$tst/u_inref/replic_source_commands.csh RCV=INST2 <instsecondary qualifier-optional> <error message-optional> <name of the qualifiers as comma separated-optional>"
	exit 1
endif
set UNSET="unsetenv instsecvar gtm_tst_ext_filter_src filter_arg time_stamp SRC_LOG_FILE run_files stat shutinst"
set RCVARG = $1
setenv instsecvar  "$2"
setenv gtm_tst_ext_filter_src \""$gtm_exe/mumps -run ^extfilter"\"
setenv filter_arg "-filter=$gtm_tst_ext_filter_src"
setenv time_stamp `date +%H_%M_%S`
setenv SRC_LOG_FILE "$PRI_SIDE/SRC_${time_stamp}.log"
setenv run_files
#
# if its an error case lets process the script as to not scream and say as expected instead
if ( "" != "$3" ) then
	setenv stat "set msr_dont_chk_stat"
else
	setenv stat
endif
# get a global variable name for every call
setenv global_name "INST1toINST3"$$
$MSR RUN SRC=INST1 $RCVARG ''$stat';$MUPIP replic -source -checkhealth $instsecvar'
if ( 0 == `echo "$4"|$grep "checkhealth"|wc -l ` ) setenv run_files "$run_files $msr_execute_last_out"
$MSR RUN SRC=INST1 $RCVARG ''$stat';$MUPIP replic -source -showbacklog $instsecvar'
if ( 0 == `echo "$4"|$grep "showbacklog"|wc -l ` ) setenv run_files "$run_files $msr_execute_last_out"
$MSR RUN SRC=INST1 $RCVARG ''$stat';$MUPIP replic -source -needrestart $instsecvar'
if ( 0 == `echo "$4"|$grep "needrestart"|wc -l ` ) setenv run_files "$run_files $msr_execute_last_out"
$MSR RUN SRC=INST1 $RCVARG ''$stat';$MUPIP replic -source -changelog -log=123.log $instsecvar'
if ( 0 == `echo "$4"|$grep "changelog"|wc -l ` ) setenv run_files "$run_files $msr_execute_last_out"
$MSR RUN SRC=INST1 $RCVARG ''$stat';$MUPIP replic -source -statslog=ON $instsecvar'
if ( 0 == `echo "$4"|$grep "statslog"|wc -l ` ) setenv run_files "$run_files $msr_execute_last_out"
$MSR RUN SRC=INST1 $RCVARG ''$stat';$MUPIP replic -source -deactivate $instsecvar -rootprimary'
set deact_stat=$status
if ( 0 == `echo "$4"|$grep "deactivate"|wc -l ` ) setenv run_files "$run_files $msr_execute_last_out"
if !($deact_stat) then
	# sleep for a minimum time to make sure deactivate process above completes
	sleep 2
	# check updates goes only to INST3 and not to INST2
	cd $gtm_test_msr_DBDIR1
$GTM << gtm_eof
set ^$global_name="Passedon$global_name"
halt
gtm_eof
	# let's wait for some minimum time and ensure backlog is cleared for INST1->INST3
	if ($?gtm_test_instsecondary) then
		setenv save_gtm_test_instsecondary $gtm_test_instsecondary
	endif
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_msr_INSTNAME3"
	$MSR RUN INST1 '$gtm_tst/com/wait_until_src_backlog_below.csh 0 20'
	$MSR RUN INST3 'set msr_dont_trace; $gtm_tst/com/wait_until_rcvr_backlog_clear.csh'
	# restore gtm_test_instsecondary after the check
	if ($?save_gtm_test_instsecondary) then
		setenv gtm_test_instsecondary $save_gtm_test_instsecondary
		unsetenv save_gtm_test_instsecondary
	else
		unsetenv gtm_test_instsecondary
	endif
	cd $gtm_test_msr_DBDIR3;pwd
$GTM << gtm_eof
if (0=\$DATA(^$global_name)) write "TEST-E-EXPECTED, updates did not reach INST3. ^$global_name not found."
halt
gtm_eof
	cd $gtm_test_msr_DBDIR2;pwd
$GTM << gtm_eof
if (\$DATA(^$global_name)) write "TEST-E-UNEXPECTED, ^$global_name update not expected to reach INST2 but found"
halt
gtm_eof
	$MSR RUN SRC=INST1 $RCVARG '$MUPIP replic -source -activate $instsecvar -secondary=__RCV_HOST__:__RCV_PORTNO__'
	# we need this check because shutdown command will not act based on $ydb_repl_instsecondary/$gtm_repl_instsecondary
	if ("" == $instsecvar) then
		if ($?ydb_repl_instsecondary) then
			setenv shutinst "-instsecondary=$ydb_repl_instsecondary"
		else
			setenv shutinst "-instsecondary=$gtm_repl_instsecondary"
		endif
	else
		setenv shutinst "$instsecvar"
	endif
	$MSR RUN SRC=INST1 $RCVARG '$MUPIP replic -source -shutdown $shutinst -timeout=0'
	$MSR RUN SRC=INST1 $RCVARG '$MUPIP replic -source -start $filter_arg -secondary=__RCV_HOST__:__RCV_PORTNO__ -log=$SRC_LOG_FILE -buff=$tst_buffsize $instsecvar'
	$MSR RUN SRC=INST1 $RCVARG 'set msr_dont_trace; $gtm_tst/com/wait_until_src_backlog_below.csh 0 300'
	$MSR RUN $RCVARG SRC=INST1 'set msr_dont_trace; $gtm_tst/com/wait_until_rcvr_backlog_clear.csh'
	$MSR RUN INST1 '$MUPIP replic -source -stopsourcefilter $instsecvar'
	# let's check here whether the update above has reached INST2 after activation
	cd $gtm_test_msr_DBDIR2;pwd
$GTM << gtm_eof
if (0=\$DATA(^$global_name)) write "TEST-E-EXPECTED, updates did not reach INST2. ^$global_name not found."
halt
gtm_eof
endif
cd $tst_working_dir
if ( "" != "$3") then
	foreach filex ($run_files)
		$msr_err_chk $filex $3
	end
endif
$UNSET
#
