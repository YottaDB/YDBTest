#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# SRC.csh <replication flag> <portno> [time_stamp] [waitforconnect]
#               portno=unique number for each test
# if waitforconnect is passed on as $4 to this script then we wait for the source to connect to the receiver
# upto a specified period of time after starting it.
#
# Turn replication on and start source server
#

alias exit_checkhealth_error '\\
echo "Check the file $debuginfo_file for ps/ipcs/netstat/lsof -i details";#BYPASSOK;\\
echo "Could not check health of Active Source Server!"	>>&! $debuginfo_file;\\
$gtm_tst/com/capture_ps_ipcs_netstat_lsof.csh		>>&! $debuginfo_file;\\
exit 1;\\
'

if ( ("V4" == `echo $gtm_exe:h:t|cut -c1-2`) || ("V50000" == `echo $gtm_exe:h:t|cut -c1-6`) ) then
	# this means the current GT.M version is a pre-multisite_replic version and so we need to call
	# V4 counterpart of SRC.csh as this script will complain for new qualifiers with older GT.M version.
	$gtm_tst/com/v4_SRC.csh $argv
	exit
endif
setenv filter_arg ""
if ($2 == "") then
	echo "Needs port number to start source server!"
	exit 1
else
	set portno=$2
	echo "Using port $portno"
endif
if ($3 == "") then
	setenv time_stamp `date +%H_%M_%S`
else
	set time_stamp=$3
endif
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif

# Setup the -TLSID argument if SSL/TLS is enabled.
#
setenv tlsparm ""
setenv tls_reneg_parm ""
set ver = $gtm_exe:h:t
if (("TRUE" == $gtm_test_tls) && (`expr $ver ">" "V60003"`)) then
	if (`eval echo '$?gtmtls_passwd_'${gtm_test_cur_pri_name}`) then
		if ("$HOST:r:r:r:r" != "$tst_org_host:r:r:r:r" || "$remote_ver" != "$tst_ver") then
			# Reset the password, since
			# (a) The test is a multi-host test and we need to set the password on the remote machine based
			#     on the remote side's password parameters (inode of the mumps executable).
			# (b) The source and receiver are run with different versions both of which support TLS (like
			#     v61000 vs v990).
			set passwd = `echo gtmrocks | $gtm_exe/plugin/gtmcrypt/maskpass | cut -f3 -d ' '`
			setenv gtmtls_passwd_${gtm_test_cur_pri_name} $passwd
		endif
		set passwd = `eval echo '$gtmtls_passwd_'${gtm_test_cur_pri_name}`
		echo "Using SSL/TLS obfuscated password: $passwd"
		setenv tlsparm "-tlsid=$gtm_test_cur_pri_name"
		if ($?gtm_test_plaintext_fallback) then
			setenv tlsparm "$tlsparm -plaintext"
		endif
		if ($?gtm_test_tls_renegotiate) then
			setenv tls_reneg_parm "-renegotiate_interval=$gtm_test_tls_renegotiate"
		endif
	endif
endif

#
if (! $?gtm_test_rp_pp ) then
	setenv gtm_test_rp_pp ""
endif

if (`expr "$ver" "<=" "V62000"`) then
	# Prior vers get no arg, regardless
	set fileonlyarg=""
else
	if ($?gtm_test_jnlfileonly) then
		if ($gtm_test_jnlfileonly) then
			if ($$ % 3 == 2) then
				set fileonlyarg="-jnlf"
			else
				set fileonlyarg="-jnlfileonly"
			endif
		endif
	endif
	if (! $?fileonlyarg) then
		# Even pids get no arg, odd pids get negated arg.
		if ($$ % 3 == 0) set fileonlyarg=""
		if ($$ % 3 == 1) set fileonlyarg="-nojnlf"
		if ($$ % 3 == 2) set fileonlyarg="-nojnlfileonly"
	endif
endif

#in case dbcreate.csh is used outside test suite, and tst_rf_log is undefined
if( (!($?tst_rf_log))||("$tst_rf_log" == "")) setenv tst_rf_log  "log"
if ("$tst_rf_log" == "nolog") then
        setenv SRC_LOG_FILE "/dev/null"
else
	if ($?SRC_LOG_FILE == 0) then
		setenv SRC_LOG_FILE "$PRI_SIDE/SRC_${time_stamp}.log"
	endif
endif
# Decide if SRC is supplementary instance
# The below decisions need to be made based on what test_replic_suppl_type is set to
# 1) Should replication instance file be created with -supplementary option [Needed for P->Q only i.e type 2]
#    Supplementary instance can also be created by the MSR framework, so check this as well.
# 2) Should source server start with -updok [Needed for A->P only i.e type 1]
#    This is actually only used for the the source server on the secondary side, as the source server on the primary side is controlled
#    by the $gtm_test_rp_pp environment variable.  That is why we only look for type 1 replication here, as it is the only case where
#    the secondary's source server need to allow updates.
# 3) Should the backup of replication instance file be shipped [Needed for A->P only i.e type 1] and if $test_jnlseqno is set to 4G

# 1
set supplarg = ""
set updokarg = ""
set shipreplfile = 0
if (2 == $test_replic_suppl_type) then
	set supplarg = "-supplementary"
else
	if ($?gtm_test_msr_all_instances) then
		set inst_num = `echo $gtm_test_cur_pri_name | sed 's/[a-zA-Z]*//'`
		set is_supp = `eval echo '$'gtm_test_msr_SUPP$inst_num`
		if ("TRUE" == "$is_supp") then
			set supplarg = "-supplementary"
		endif
	endif
endif
if ($?needupdatersync) then
	set shipreplfile = 1
endif
# 2
if (1 == $test_replic_suppl_type) then
	set updokarg = "-updok"
endif
# 3
if (1 == $test_replic_suppl_type) then
	set shipreplfile = 1
else if ($?test_jnlseqno) then
	if ("4G" == $test_jnlseqno) set shipreplfile = 1
endif

if !(-e mumps.repl) then
	$MUPIP replic -instance_create -name=$gtm_test_cur_pri_name $supplarg $gtm_test_qdbrundown_parms
endif
setenv repl_state "$1"
# This section is meant for multisite_replic actions to decide about replication state of the database
if ( "decide" == $repl_state ) then
	# Note that replication state could be OFF, ON and WAS_ON. Treat the last two cases as ON.
	# Hence the $NF done in the awk script below.
	set cur_state=`$DSE dump -fileheader |& $tst_awk '/Replication State/ {if ($3 == "[WAS_ON]") {print "ON"} else {print $3}}'`
	if ( "ON" == $cur_state ) then
		setenv repl_state "already_on"
	else
		setenv repl_state "on"
	endif
endif
if ( "on" == $repl_state ) then
	cd $PRI_SIDE
	$gtm_tst/com/jnl_on.csh $test_jnldir -replic=on
	if ($gtm_test_repl_norepl == 1) then
		echo "$MUPIP set -replication=off -journal=disable -REG HREG"
		$MUPIP set -replication=off -journal=disable -REG HREG
	endif
	$gtm_tst/com/backup_for_mupip_rollback.csh	# take backup if needed by test for later mupip_rollback.csh invocations
endif
echo "Using port $portno"
echo "Running : $gtm_exe"
echo "Using Global Directory $gtmgbldir"
echo "Starting Active Source Server in Host: $HOST:r:r:r:r"
echo "In directory:`pwd`"
# If the quotes around the filter is not provided, include it. Otherwise src start will fail with CLIERR for -RUN
if($?gtm_tst_ext_filter_src) then
    if ( '"' == `echo $gtm_tst_ext_filter_src | cut -c 1` ) then
    	setenv filter_arg "-filter=$gtm_tst_ext_filter_src"
    else
        set filterwithquote = \""$gtm_tst_ext_filter_src"\"
    	setenv filter_arg "-filter=$filterwithquote"
    endif
    echo "TEST-I-SRC Turning on external filter ($filter_arg)..."
endif

if ($?gtm_test_repl_src_cmplvl) then
	set cmplvlstr = "-cmplvl=$gtm_test_repl_src_cmplvl"
else
	set cmplvlstr = ""
endif

# Make sure we can talk IPv6 to the secondary, and scrub the v6 suffix if we can't.
if ($?test_no_ipv6_ver) then
	# Both v6 and v46 may be an issue, so drop all suffixes
	if ($tst_now_secondary != $tst_now_secondary:r:r:r:r) then
		echo "Removing suffixes from secondary '$tst_now_secondary' due to non-IPv6 prior version."
		setenv tst_now_secondary $tst_now_secondary:r:r:r:r
	endif
else
	eval 'if (\! $?host_ipv6_support_'${HOST:r:r:r:r}') set host_ipv6_support_'${HOST:r:r:r:r}'=0'
	if (! `eval echo '$host_ipv6_support_'$tst_now_primary:r:r:r:r`) then
		if ($tst_now_secondary =~ *.v6*) then
			echo "Removing v6 from secondary '$tst_now_secondary' due to missing IPv6 on primary '$tst_now_primary'"
			setenv tst_now_secondary ${tst_now_secondary:s/.v6//}
		endif
	endif
endif

set temp_save_secondary="$tst_now_secondary"
# We cannot use IPv6 address format if the test involves old GT.M version
if ("$tst_now_primary" == "$tst_now_secondary") then
	if (! $?test_no_ipv6_ver) then
		setenv tst_now_secondary `$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
		echo "Allow IPv6 address: $tst_now_secondary" >& sec_addr_${time_stamp}.out
	else
		echo "No IPv6 address: $tst_now_secondary" >& sec_addr_${time_stamp}.out
	endif
endif
if ($?gtm_test_jnlpool_buffsize) then
	set jnlpoolsize = $gtm_test_jnlpool_buffsize
else
	set jnlpoolsize = $tst_buffsize
endif
echo $MUPIP replic -source -start -secondary="$tst_now_secondary:q":"$portno" ${cmplvlstr} -buffsize=$jnlpoolsize $gtm_test_instsecondary $gtm_test_rp_pp $filter_arg -log=$SRC_LOG_FILE $updokarg $tlsparm $tls_reneg_parm $fileonlyarg
# Prepare the source server startup command. Set an environment variable as we want this to be accessible from within "sh" below.
setenv srcstartcmd "$MUPIP replic -source -start -secondary="$tst_now_secondary:q":"$portno" ${cmplvlstr} -buffsize=$jnlpoolsize $gtm_test_instsecondary $gtm_test_rp_pp $filter_arg -log=$SRC_LOG_FILE $updokarg $tlsparm $tls_reneg_parm $fileonlyarg"
if (! $?src_srvr_stdin_is_terminal) then
	# Start the source server
	$srcstartcmd
else
	# src_srvr_stdin_is_terminal is set implying the subtest (currently only r122/ydb210) wants to start the source server
	# with stdin/stdout/stderr as the terminal. This is needed to exercise the issue fixed by #210.
	# Due to redirections happening at various levels of caller scripts, it is most often the case that stdout/stderr
	# is a file at this point even though stdin might be a terminal. Therefore repoint stdout/stderr to the terminal too
	# just for the source server startup command. This can be easily done with sh (tcsh has no such facility) so use
	# that temporarily. In this case though, we are guaranteed stdin is a terminal so check that first. And then redirect
	# stdout/stderr to point to stdin.
	set stdinfd = `ls -l /proc/self/fd | grep " 0 -> " | grep "dev/pts"`
	if ($status != 0) then
		echo "src_srvr_stdin_is_terminal env var is set so expecting stdin to be terminal but it is not."
		echo "ls -l /proc/self/fd output below. Exiting $0 with error"
		ls -l /proc/self/fd
		exit 1
	endif
	sh -c '$srcstartcmd 1>&0 2>&0'
endif
unsetenv srcstartcmd

set start_status = $status
setenv tst_now_secondary "$temp_save_secondary"

set debuginfo_file = "SRCSTART_${time_stamp}_failed.outx"
if (! $?gtm_test_repl_skipsrcchkhlth) then
	set source_chkhealth_file=SRC_checkhealth_${time_stamp}_`date +%H%M%S`.outx
	$MUPIP replicate -source -checkhealth $gtm_test_instsecondary | & tee $source_chkhealth_file
	if (("" != `$grep "server is alive" $source_chkhealth_file`)  && (0 == $start_status)) then
		echo "Active Source Server started"
	else
		echo "Could not check health of Active Source Server!"
		exit_checkhealth_error
	endif
else
	echo "Not checking health of Active Source Server"
endif

if ($shipreplfile) then
	\rm -f srcinstback.repl
	$MUPIP backup -replinstance=srcinstback.repl
	if ( $tst_now_primary != $tst_now_secondary ) then
		$rcp srcinstback.repl "$tst_now_secondary":"$SEC_SIDE/srcinstback.repl"
	else
		cp srcinstback.repl $SEC_SIDE/srcinstback.repl
	endif
endif

if ( `echo $4|$grep "waitforconnect"|wc -l` ) then
	set waitforconnect
endif

if ($?waitforconnect) then
	echo "Waiting to connect	" `date`
	$gtm_tst/com/wait_for_log.csh -log $SRC_LOG_FILE -message "Connected to secondary" -duration 300 -waitcreation
	echo "done waiting		" `date`
endif

echo "SRC_START_SUCCESSFUL"
exit 0
