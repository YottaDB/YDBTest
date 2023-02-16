#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# RCVR.csh <replication flag> <portno> [time_stamp] [waitforconnect] [other qualifiers]
# Start receiver server, Turn replication on/off 1st depending on <flag>
#  if waitforconnect is requested then we wait for the receiver to actually connect
#
#

alias exit_checkhealth_error '\\
echo "Check the file $debuginfo_file for ps/ipcs/ss/lsof -i details";#BYPASSOK;\\
echo "Could not check health of Active Source Server or Receiver Server!"	>>&! $debuginfo_file;\\
$gtm_tst/com/capture_ps_ipcs_ss_lsof.csh					>>&! $debuginfo_file;\\
exit 1;\\
'
echo "In RCVR.csh..."
if ( ("V4" == `echo $gtm_exe:h:t|cut -c1-2`) || ("V50000" == `echo $gtm_exe:h:t|cut -c1-6`) ) then
	# this means the current GT.M version is a pre-multisite_replic version and so we need to call
	# V4 counterpart of RCVR.csh as this script will complain for new qualifiers with older GT.M version.
	$gtm_tst/com/v4_RCVR.csh $argv
	exit
endif
setenv repl_state "$1"
if ($2 == "") then
        echo "Needs port number to start receiver server!"
        exit 1
else
        set portno=$2
        echo "Using port $portno (passed in as arg 2)"
endif
if ($3 == "") then
        setenv time_stamp `date +%H_%M_%S`
else
        set time_stamp=$3
	shift
endif
if ("" != "$argv") shift
if ("" != "$argv") shift
if ("waitforconnect" == "$1") then	# i.e. the fourth argument
	set waitforconnect
	shift
endif
set other_qualifiers = "$argv"	# i.e. $4 and above
if ("$other_qualifiers" != "") then
	set other_qualifiers = "-$other_qualifiers"
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_pri_name"
endif

# Setup the -TLSID argument if SSL/TLS is enabled.
source $gtm_tst/com/set_var_tlsparm.csh $gtm_test_cur_sec_name	# sets "tlsparm" and "tls_reneg_parm" variables

set helper_parm=""
if ($?gtm_test_updhelpers) then
	if (0 != "$gtm_test_updhelpers") then
		set helper_parm="-helpers=$gtm_test_updhelpers"
	endif
endif
#
set debuginfo_file = "SRCSTART_${time_stamp}_failed.outx"
#in case dbcreate.csh is used outside test suite, and tst_rf_log is undefined
if ((!($?tst_rf_log))||("$tst_rf_log" == "")) setenv tst_rf_log  "log"

if ("$tst_rf_log" == "nolog") then
	setenv RCVR_LOG_FILE "/dev/null"
	setenv PASSIVE_LOG_FILE "/dev/null"
	unsetenv LOG_UPDATES
else
	if ($?RCVR_LOG_FILE == 0) then
		setenv RCVR_LOG_FILE "$SEC_SIDE/RCVR_${time_stamp}.log"
	endif
	if ($?PASSIVE_LOG_FILE == 0) then
		setenv PASSIVE_LOG_FILE "$SEC_SIDE/passive_${time_stamp}.log"
	endif
	if ($?UPD_LOG_FILE == 0) then
		setenv UPD_LOG_FILE "$SEC_SIDE/UPDPROC_${time_stamp}.log"
	endif
endif
# This is mainly for debugging (define it in .cshrc)
if ($?tst_updproc == 1)  then
	if ($tst_updproc == "log") setenv LOG_UPDATES $UPD_LOG_FILE
endif

# Decide if RCVR is supplementary instance
# The below decisions need to be made based on what test_replic_suppl_type is set to
# 1) Should replication instance file be created with -supplementary option [Needed for A->P and P->Q only i.e type 1 and 2]
#    Supplementary instance can also be created using the MSR framework, so check for this as well.
# 2) Should Passive source server for the current SRC be started [Needed for A->B and P->Q i.e type 0 and 2] or
#	    Dummy active source server for a non-existant rcvr be started [Needed for A->P i.e type 1]
# 3) Should receiver server be started with -updateresync=<bkupfromsrc.repl> option [Needed for A->P i.e type 1] and if $test_jnlseqno is set to 4G

# 1
set supplarg = ""
if ((1 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
	set supplarg = "-supplementary"
else
	if ($?gtm_test_msr_all_instances) then
		set inst_num = `echo $gtm_test_cur_sec_name | sed 's/[a-zA-Z]*//'`
		set is_supp = `eval echo '$'gtm_test_msr_SUPP$inst_num`
		if ("TRUE" == "$is_supp") then
			set supplarg = "-supplementary"
		endif
	endif
endif
# 2
set passive_flag = "true"
set dummy_source = "false"
if ((0 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
	set passive_flag = "true"
	set dummy_source = "false"
else
	set passive_flag = "false"
	set dummy_source = "true"
endif
# 3
set updateresyncarg = ""
set needupdateresyncarg = 0
if (1 == $test_replic_suppl_type) then
	set needupdateresyncarg = 1
endif
if ($?test_jnlseqno) then
	if ("4G" == $test_jnlseqno) set updateresyncarg = "-updateresync=$SEC_SIDE/srcinstback.repl -initialize"
endif

if !(-e mumps.repl) then
	$MUPIP replic -instance_create -name=$gtm_test_cur_sec_name $supplarg $gtm_test_qdbrundown_parms
	if ($needupdateresyncarg) set updateresyncarg = "-updateresync=$SEC_SIDE/srcinstback.repl -initialize"
endif

if ($?needupdatersync) set updateresyncarg = "-updateresync=$SEC_SIDE/srcinstback.repl -initialize"

# This section is meant for multisite_replic actions to decide about replication state of the database
if ( "decide" == $repl_state ) then
	set cur_state=`$DSE dump -fileheader|& $tst_awk '/Replication State/ {print $3}'`
	if ( "ON" == $cur_state ) then
		setenv repl_state "already_on"
	else
		setenv repl_state "on"
	endif
	# check to determine whether we need to start up passive source server.
	# since if an active source server (PP) is already running, we need not start a passive here.
	# we redirect it to .outx because we just need the output and in some case we get NOJNLPOOL which is expected
	# and that gets nagged at the end of the test output
	set receiver_chkhealth_file=RCVR_src_checkhealth_${time_stamp}_`date +%H%M%S`_$$.outx
	$MUPIP replic -source -checkhealth >&! $receiver_chkhealth_file
	set health_stat = $status
	if (! (-z $receiver_chkhealth_file)) then
		if (! $health_stat) then
			set passive_flag="false"
		else
			# In the below line we have to grep explicitly because fake ENOSPC code can cause non-zero status even though the
			# receiver server is alive
			if ("" != `$grep "server is alive" $receiver_chkhealth_file`) then
				set passive_flag="false"
			endif
		endif
	endif
endif
if ( "on" == $repl_state ) then
	echo "Turn replication on:"
	cd $SEC_SIDE
	$gtm_tst/com/jnl_on.csh $test_remote_jnldir -replic=on
	if ($gtm_test_repl_norepl == 1) then
		echo "$MUPIP set -replication=off -journal=disable -REG HREG"
		$MUPIP set -replication=off -journal=disable -REG HREG
	endif
	$gtm_tst/com/backup_for_mupip_rollback.csh	# take backup if needed by test for later mupip_rollback.csh invocations
endif
if ( ($test_replic == "MULTISITE") && !($?gtm_test_cur_sec_name) ) then
	echo "TEST-E-INSTANCE error.Issue setting up environment with incorrect instance name as $gtm_test_cur_sec_name"
	exit 1
endif

if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_pri_name"
endif

if ($?gtm_test_jnlpool_buffsize) then
	set jnlpoolsize = $gtm_test_jnlpool_buffsize
else
	set jnlpoolsize = $tst_buffsize
endif
if ("true" == $passive_flag) then
	echo "Using port $portno"
	echo "Running : $gtm_exe"
	echo "Using Global Directory $gtmgbldir"
	echo "Starting Passive Source Server in Host: $HOST:r:r:r:r"
	echo "In directory:`pwd`"
	$MUPIP replic -source -start $gtm_test_instsecondary -propagateprimary -buffsize=$jnlpoolsize -passive -log=$PASSIVE_LOG_FILE $tlsparm $tls_reneg_parm
	set start_status = $status
	set receiver_chkhealth_file=RCVR_src_checkhealth_${time_stamp}_`date +%H%M%S`_$$.outx
	$MUPIP replicate -source -checkhealth $gtm_test_instsecondary | & tee $receiver_chkhealth_file
	if (("" != `$grep "server is alive" $receiver_chkhealth_file`) && (0 == $start_status)) then
		echo "Passive Source Server have started"
		# this condition is for cases where receiver dies by itself and the no_passive file not getting removed
		# so we better check that if it exists and we are starting the passive for sure let's remove it.
		if (-e no_passive_$gtm_test_cur_pri_name.out) rm no_passive_$gtm_test_cur_pri_name.out
	else
		echo "Could not start Passive Source Server!"
		exit_checkhealth_error
	endif
else
	echo "PASSIVE SOURCE SERVER NOT STARTED FOR $gtm_test_instsecondary" | tee -a no_passive_$gtm_test_cur_pri_name.out
endif

if ("true" == "$dummy_source") then
	if (-e $SEC_DIR/portno_supp) then
		setenv portno_supp `cat $SEC_DIR/portno_supp`
	else
		setenv portno_supp `source $gtm_tst/com/portno_acquire.csh`
		echo $portno_supp >&! $SEC_DIR/portno_supp
	endif
	setenv gtm_test_instsecondary "-instsecondary=supp_${gtm_test_cur_sec_name}"
	setenv SRC_LOG_FILE_SUPP "$SEC_SIDE/SUPP_SRC_${time_stamp}.log"
	$MUPIP replic -source -start -secondary="$tst_now_secondary":"$portno_supp" -buffsize=$jnlpoolsize $gtm_test_instsecondary $tlsparm -log=$SRC_LOG_FILE_SUPP
	set receiver_chkhealth_file=RCVR_src_checkhealth_${time_stamp}_`date +%H%M%S`_$$.outx
	$MUPIP replicate -source -checkhealth $gtm_test_instsecondary | & tee $receiver_chkhealth_file
	if ("" != `$grep "server is alive"  $receiver_chkhealth_file`) then
		echo "Supplementary instance source server has started" | tee -a supp_${gtm_test_cur_sec_name}_dummy.out
	else
		echo "Could not start Supplementary Instance  Source Server!"
		exit_checkhealth_error
	endif
endif

set cmplvlstr = ""
if ($?gtm_test_repl_rcvr_cmplvl) then
	set cmplvlstr = "-cmplvl=$gtm_test_repl_rcvr_cmplvl"
endif
set autorollback = ""
if ($?gtm_test_autorollback == 1) then
	if ($gtm_test_autorollback == "TRUE") set autorollback = "-autorollback"
endif

echo "Starting Receiver Source Server"
setenv filter_arg ""
if($?gtm_tst_ext_filter_rcvr) then
    # If the quotes around the filter is not provided, include it. Otherwise rcvr start will fail with CLIERR for -RUN
    if ( '"' == `echo $gtm_tst_ext_filter_rcvr | cut -c 1` ) then
	    setenv filter_arg "-filter=$gtm_tst_ext_filter_rcvr"
    else
	    set filterwithquote = \""$gtm_tst_ext_filter_rcvr"\"
	    setenv filter_arg "-filter=$filterwithquote"
    endif
    echo "TEST-I-RCVR Turning on external filter ($filter_arg)..."
endif
set other_qual_arg = "$other_qualifiers ${cmplvlstr} ${autorollback}"
echo "$MUPIP replic -receiv -start -listenport=$portno -buffsize=$tst_buffsize $other_qual_arg -log=$RCVR_LOG_FILE $filter_arg $updateresyncarg $tlsparm $helper_parm"
$MUPIP replic -receiv -start -listenport=$portno -buffsize=$tst_buffsize $other_qual_arg -log=$RCVR_LOG_FILE $filter_arg $updateresyncarg $tlsparm $helper_parm
set start_status = $status

if (! $?gtm_test_repl_skiprcvrchkhlth) then
	set receiver_chkhealth_file=RCVR_rcvr_checkhealth_${time_stamp}_`date +%H%M%S`_$$.outx
	$MUPIP replicate -receiv -checkhealth | & tee $receiver_chkhealth_file
	if (("" != `$grep "server is alive" $receiver_chkhealth_file`) && (0 == $start_status)) then
		echo "Receiver Server have started"
	else
		echo "Could not start Receiver Server!"
		exit_checkhealth_error
	endif
else
	echo "Not checking health of Receiver Server"
endif
if ($?waitforconnect) then
	echo "Waiting to connect	" `date`
	$gtm_tst/com/wait_for_log.csh -log $RCVR_LOG_FILE -message "New History Content" -duration 300 -waitcreation
	echo "done waiting		" `date`
endif

echo "RCVR_START_SUCCESSFUL"
exit 0
