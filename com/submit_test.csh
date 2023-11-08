#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#############################################################################################
# If $tst_stdout is 0 (no -stdout), it means that the output is redirected to
# a file. In that case, we would like the verbosity for later debugging.
# If $tst_stdout is 3, the user specifically asked for verbosity -stdout 3
# If $tst_stdout is 2, the user asked for diff files of failed subtests
# If $tst_stdout is 1, the user asked for limited verbosity.
if ("$tst_stdout" == "3" || "$tst_stdout" == "0") then
	set echo
	set verbose
else
	unset echo
	unset verbose
endif
# If any settings/configuration needs to be overridden AFTER the test has started, it should go in ~/.gtmtest_settings_override.csh
if (-e  ~/.gtmtest_settings_override.csh) source  ~/.gtmtest_settings_override.csh
umask 002
set short_host = $HOST:r:r:r:r
$gtm_tst/com/chkPWDnoHome.csh
if ($status == "6") then
	set tmp_exit_stat = "6"
	# atlhxit* has some issues due to which it switches to home directory randomly with
	# "pwd: No such file or directory" error in the log
	# In such case, check if we can get back to tst_working_dir and if so, proceed
	# Not limiting this check to atlhxit*, since it doesn't harm doing everywhere.
	if !($?tst_working_dir) then
		echo "chkPWDnoHome.csh returned status 6 AND <tst_working_dir> does not exist" >>! $tst_general_dir/diff.log
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit $tmp_exit_stat
	endif
	if !(-d $tst_working_dir) then
		echo "chkPWDnoHome.csh returned status 6 AND <tst_working_dir> exists but is not a directory" >>! $tst_general_dir/diff.log
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit $tmp_exit_stat
	endif
	cd $tst_working_dir
	if ($status) then
		echo "chkPWDnoHome.csh returned status 6 AND <tst_working_dir> exists and is a directory but cd to it failed (e.g. permissions)" >>! $tst_general_dir/diff.log
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit $tmp_exit_stat
	endif
endif

if ("$test_want_concurrency" == "yes") then
	pushd $test_load_dir
	set old_gtmroutines = "$gtmroutines"
	setenv gtmroutines "."
	setenv gtmgbldir load.gld
	$gtm_exe/mumps -direct << GTMEOF
	d ^load("$tst","$short_host",$$,$tst_num)
GTMEOF
	setenv gtmroutines "$old_gtmroutines"
	popd
endif

setenv gtmgbldir mumps.gld
setenv DO_FAIL_OVER "source $gtm_tst/com/fail_over.csh"
setenv GTM "$gtm_exe/mumps -direct"
setenv YDB "$gtm_exe/mumps -direct"
setenv MUPIP "$gtm_exe/mupip"
setenv LKE "$gtm_exe/lke"
setenv DSE "$gtm_exe/dse"
setenv GDE "$gtm_exe/mumps -run GDE"
setenv GDE_SAFE "$gtm_tst/com/pre_V54002_safe_gde.csh"
setenv tst_tslog_filter
if ($?gtm_test_tslog) then
	setenv tst_tslog_filter '|& $tst_awk '"'"'{print $0 ; print strftime(),$0 >> "'"'"'$tst_tslog_file'"'"'"}'"'"
endif
source $gtm_tst/com/set_gtmroutines.csh "M"
# This is for clarity in output and reference file neatness. Can use this variable in all subtests
setenv echoline 'echo ###################################################################'
setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_crash 0
setenv gtm_test_jobcnt 5
setenv gtm_test_repl_norepl 0
setenv gtm_test_jobid 0
setenv gtm_test_dbfillid 0
setenv gtm_test_is_gtcm 0
setenv gtm_test_is_unicode_aware "FALSE" # this flag is for individual tests to reset when they use existing com files for UTF-8 specific operations
# Reset default coredump_filter mask to include file-backed mapped memory for tests (default is 0x33).
echo 0x3F > /proc/self/coredump_filter

source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# defines "gtm_test_libyottadb_asan_enabled" env var

##
# Determine if the memory footprint for this machine supports 64GiB journal and receiver pools. This awk invocation will
# take care of determining if this test can run restricted 64GiB journal/receiver pool tests or not.
setenv ydb_allow64GB_jnlpool `free -g | $tst_awk -f $gtm_tst/com/jnlpool_64GB_OK.awk`

###########################################################################################################
#### set various random test options. This might change the environment variables set above this point
# submit_test.csh is called with echo and verbose set.  But, we don't want the do_random_settings.csh and set_encrypt_env.csh
# execution to be done with those, so we unset & re-set them once we are done.
unset echo
unset verbose
if !($?test_norandomsettings) then
	source $gtm_tst/com/do_random_settings.csh
else
	echo "do_random_settings not being called"  >>&! $tst_general_dir/settings.csh
	setenv ydb_test_4g_db_blks 0	# Define this env var so we don't need to use "$?ydb_test_4g_db_blks" in all later usages
endif

# Now set some environment variables based on the random settings done above
# Set gtmcompile now that gtm_test_dynamic_literals has been determined
setenv gtmcompile ""
if ($gtm_test_nolineentry == "NOLINE") then
	setenv gtmcompile "$gtmcompile -noline_entry"
endif
if ($?gtm_test_dynamic_literals) then
	if ($gtm_test_dynamic_literals == "DYNAMIC_LITERALS") then
		setenv gtmcompile "$gtmcompile -dynamic_literals"
	endif
endif
if ($?gtm_test_embed_source) then
	if ($gtm_test_embed_source == "TRUE") then
		setenv gtmcompile "$gtmcompile -embed_source"
	endif
endif
if ("$gtmcompile" == "") then
	unsetenv gtmcompile
endif
# qdbrundown paramenter to be passed in various scripts
if ($gtm_test_qdbrundown) then
	setenv gtm_test_qdbrundown_parms "-qdbrundown"
else
	setenv gtm_test_qdbrundown_parms ""
endif

setenv test_jnldir     $tst_general_dir/tmp
setenv test_bakdir     $tst_general_dir/tmp/bak
chmod g+w $test_jnldir

set path = ($path_base $gtm_tst/$tst/inref $gtm_tst/$tst/u_inref $gtm_tst/com .)

if ( ($?test_replic) && ($?test_gtm_gtcm_one) ) then
    	echo "TEST-E-REPLIC_GTCM REPLICATION AND GT.CM should not be specified together" >>! $tst_general_dir/diff.log
	cat $tst_general_dir/diff.log
	$gtm_tst/com/write_logs.csh FAILED
	if (!($?tst_dont_send_mail)) then
		$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
	endif
	exit 1
endif
if ("$tst_stdout" == "3" || "$tst_stdout" == "0") then
	set echo
	set verbose
endif
set se_buddy1 = `$gtm_tst/com/get_buddy_server.csh SE1`
set se_buddy2 = `$gtm_tst/com/get_buddy_server.csh SE2`
set re_buddy1 = `$gtm_tst/com/get_buddy_server.csh RE`
if ("NA" == "$re_buddy1") then
	# If remote endian buddy is the special string "NA", then use same endian buddy for $test_replic_mh_type=2 tests
	set re_buddy1 = $se_buddy1
endif
if ($?test_replic) then
	if ("MULTISITE" == "$test_replic") then
		if (2 == $test_replic_mh_type) then
			setenv tst_other_servers_list_ms "$re_buddy1 $se_buddy2"
		else
			setenv tst_other_servers_list_ms "$se_buddy1 $se_buddy2"
		endif
		set allsrvrs = ($tst_other_servers_list_ms $tst_org_host)
	else
		if (1 == $test_replic_mh_type) then
			setenv tst_remote_host $se_buddy1
		else if (2 == $test_replic_mh_type) then
			setenv tst_remote_host $re_buddy1
		endif
		if ( 0 < $test_replic_mh_type) set allsrvrs = ($tst_remote_host $tst_org_host)
	endif
	if ($?allsrvrs) then
		set uniqsrvrs = `echo $allsrvrs | $tst_awk '{for (i=0;++i<=NF;) srvr[$i]++} END {for (s in srvr) print s}'`
		if ($#allsrvrs != $#uniqsrvrs) then
			echo "remote servers should be uniq and different from tst_org_host in : $allsrvrs" >>! $tst_general_dir/diff.log
			echo "Not submitting the multi-host test $tst" >>! $tst_general_dir/diff.log
			cat $tst_general_dir/diff.log
			$gtm_tst/com/write_logs.csh FAILED
			if (!($?tst_dont_send_mail)) then
				$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
			endif
			exit 4
		endif
	endif
endif
# check if the remote servers have the setup done properly
set serverstocheck = ""
if ($?test_gtm_gtcm_one) then
	# If it is a GT.CM test, tst_gtcm_remote_host has to be different.
	# If it is not specified to be different, change it
	source $gtm_tst/com/gtcm_server_check.csh
	if ($status) then
		echo "$gtm_tst/com/gtcm_server_check.csh failed with the above"
		echo "$gtm_tst/com/gtcm_server_check.csh failed" >>! $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit 4
	endif
	set serverstocheck = "$tst_gtcm_server_list"
	# Generate a list of random boolean values, one per gtcm host. This will later be used by dbcreate_multi.awk
	# to add a "@" prefix to the <hostname>:<filename> syntax for remote file name specified in gtcm tests.
	setenv tst_gtcm_server_at_prefix_list ""
	foreach srvr ($serverstocheck)
		set rand_no = `date | $tst_awk '{srand() ; print (int(rand() * 2))}'`
		setenv tst_gtcm_server_at_prefix_list "$tst_gtcm_server_at_prefix_list $rand_no"
	end
else if ($?test_replic) then
	if ("MULTISITE" == "$test_replic") then
		set serverstocheck = "$tst_other_servers_list_ms"
	else if ($tst_org_host != $tst_remote_host) then
		set serverstocheck = "$tst_remote_host"
	endif
endif
unset check_setup_failed
foreach server ($serverstocheck)
	set stat = `$rsh $server "setenv gtm_test_serverconf_file $gtm_test_serverconf_file ; source $gtm_test_com_individual/check_setup_dependencies.csh $gtm_test_com_individual"`
	if ("0" != "$stat") then
		set check_setup_failed
		echo "SETUP-E-FAIL Check for setup dependencies failed on the server $server with status $stat" >>! $tst_general_dir/diff.log
	endif
end
if ($?check_setup_failed) then
	# Can we switch to single-host at this point if it was randomly chosen?
	cat $tst_general_dir/diff.log
	$gtm_tst/com/write_logs.csh FAILED
	if (!($?tst_dont_send_mail)) then
		$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
	endif
	exit 1
endif

set cleanup_script = $tst_dir/$gtm_tst_out/cleanup.csh
if ($?test_replic) then
	if ("$tst_remote_dir" == "default") then
		eval 'set is_remote_dir_list = ($?gtm_tstdir_'${tst_remote_host}')'
		if ($is_remote_dir_list) then
			eval 'set remote_dir_list = ($gtm_tstdir_'${tst_remote_host}')'
			setenv tst_remote_dir "$remote_dir_list[2]/$USER"
		else
			setenv tst_remote_dir "$tst_dir/remote"
		endif
	endif
	if ($tst_org_host == $tst_remote_host) then
		setenv tst_remote_dir `mkdir -p $tst_remote_dir >& /dev/null && cd $tst_remote_dir && pwd`
	else
		setenv tst_remote_dir `$rsh $tst_remote_host "mkdir -p $tst_remote_dir >& /dev/null && cd $tst_remote_dir && pwd"`
	endif
	if ("$tst_remote_dir" == "") then
		echo "TEST-E-REMOTE Remote directory could not be created. Exiting." >>! $tst_general_dir/diff.log
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit 61
	endif
endif

# Now that tst_dir and tst_remote_dir have been set to appropriate values, check if it is okay to enable "ydb_test_4g_db_blks"
# if it was enabled as part of a prior do_random_settings.csh call.
if (0 != $ydb_test_4g_db_blks) then
	# If this is a non-replic test OR replic test, check if $tst_dir is a xfs or zfs file system.
	# If so it is okay to enable. If not, disable.
	set fstype = `source $gtm_tst/com/get_filesystem_type.csh $tst_dir`
	if (("xfs" != "$fstype") && ("zfs" != "$fstype")) then
		echo "# ydb_test_4g_db_blks is set to 0 (since test is non-replic and fstype of $tst_dir is [$fstype], which is not xfs or zfs)" >>! $tst_general_dir/settings.csh
		setenv ydb_test_4g_db_blks 0
		echo "setenv ydb_test_4g_db_blks $ydb_test_4g_db_blks"		>>&! $tst_general_dir/settings.csh
	endif
	if ((0 != $ydb_test_4g_db_blks) && ($?test_replic)) then
		# If this is a replic test, check if $tst_remote_dir is a xfs or zfs file system.
		# If so it is okay to enable as these file systems support huge file sizes that are needed by the scheme.
		#If not, disable the scheme.
		set fstype = `source $gtm_tst/com/get_filesystem_type.csh $tst_remote_dir`
		if (("xfs" != "$fstype") && ("zfs" != "$fstype")) then
			echo "# ydb_test_4g_db_blks is set to 0 (since test is replic and fstype of $tst_remote_dir is [$fstype], which is not xfs or zfs)" >>! $tst_general_dir/settings.csh
			setenv ydb_test_4g_db_blks 0
			echo "setenv ydb_test_4g_db_blks $ydb_test_4g_db_blks"		>>&! $tst_general_dir/settings.csh
		endif
	endif
endif

if ("$tst_jnldir" == "default") setenv tst_jnldir "$tst_dir"
if ("$tst_bakdir" == "default") setenv tst_bakdir "$tst_dir"
if ("$tst_remote_jnldir" == "default") setenv tst_remote_jnldir "$tst_remote_dir"
if ("$tst_remote_bakdir" == "default") setenv tst_remote_bakdir "$tst_remote_dir"
# Remove trailing / if it exists
if ("${tst_dir:t}" == "") setenv tst_dir ${tst_dir:h}
if ("${tst_remote_dir:t}" == "") setenv tst_remote_dir ${tst_remote_dir:h}
if ("${tst_jnldir:t}" == "") setenv tst_jnldir ${tst_jnldir:h}
if ("${tst_remote_jnldir:t}" == "") setenv tst_remote_jnldir ${tst_remote_jnldir:h}
if ("${tst_bakdir:t}" == "") setenv tst_bakdir ${tst_bakdir:h}
if ("${tst_remote_bakdir:t}" == "") setenv tst_remote_bakdir ${tst_remote_bakdir:h}

if ($?test_replic) then
	setenv tst_now_primary $tst_org_host
	setenv tst_now_secondary $tst_remote_host
	setenv PRI_DIR "$tst_dir/$gtm_tst_out/$testname/tmp"
	setenv SEC_DIR "$tst_remote_dir/$gtm_tst_out/$testname/tmp"
	setenv test_remote_jnldir "$tst_remote_jnldir/$gtm_tst_out/$testname/tmp"
	setenv test_remote_bakdir "$tst_remote_bakdir/$gtm_tst_out/$testname/tmp/bak"
	setenv PRI_SIDE "$tst_dir/$gtm_tst_out/$testname/tmp"
	setenv SEC_SIDE "$tst_remote_dir/$gtm_tst_out/$testname/tmp"
	setenv gtm_test_cur_pri_name "INSTANCE1"
	setenv gtm_test_cur_sec_name "INSTANCE2"
	setenv tst_sec_general_dir "$tst_remote_dir/$gtm_tst_out/$testname"
	setenv pri_getenv ""
	setenv pri_shell "$tst_tcsh -c "

	if ($tst_org_host == $tst_remote_host) then
		\mkdir -p $SEC_DIR
		\chmod g+w $SEC_DIR
		chmod g+w $tst_remote_dir/$gtm_tst_out
		\mkdir -p $test_remote_jnldir
		\chmod g+w $test_remote_jnldir
		if ($tst_ver != $remote_ver || $tst_image != $remote_image) then
			setenv sec_getenv "source $gtm_tst/com/getenv.csh"
		else
			setenv sec_getenv ""
		endif
		setenv sec_shell "$tst_tcsh -c"
		echo "LOCAL $tst_dir/$gtm_tst_out" 			>> $tst_remote_dir/$gtm_tst_out/primary_dir
		echo "setenv local_dir  $tst_dir/$gtm_tst_out" 		>> $tst_dir/$gtm_tst_out/testdirs
		echo "setenv remote_dir $tst_remote_dir/$gtm_tst_out"	>> $tst_dir/$gtm_tst_out/testdirs
		cp -p $tst_dir/$gtm_tst_out/testdirs $tst_remote_dir/$gtm_tst_out/testdirs
		foreach dir ($tst_remote_dir $tst_remote_jnldir $tst_remote_bakdir)
			$grep -q "$dir/$gtm_tst_out" $cleanup_script
			if ($status) then
				echo "rm -rf $dir/$gtm_tst_out"	>>&! $cleanup_script
			endif
		end
	else
		setenv sec_getenv "source $gtm_tst/com/remote_getenv.csh $SEC_DIR"
		setenv sec_shell "$rsh $tst_remote_host "
		$rsh $tst_remote_host "\mkdir -p $SEC_DIR ; chmod g+w $SEC_DIR"
		$rsh $tst_remote_host "echo primary $tst_org_host $tst_dir/$gtm_tst_out >>! $tst_remote_dir/$gtm_tst_out/primary_dir"
		foreach dir ($tst_remote_dir $tst_remote_jnldir $tst_remote_bakdir)
			$grep -q "$rsh $tst_remote_host 'rm -rf $dir/$gtm_tst_out'" $cleanup_script
			if ($status) then
				echo "$rsh $tst_remote_host 'rm -rf $dir/$gtm_tst_out'"	>>&! $cleanup_script
			endif
		end
	endif
	if ("MULTISITE" == "$test_replic") then
		set xcnt = 1
		foreach host_rmtx ($tst_other_servers_list_ms)
			set host_rmt = tst_remote_host_ms_$xcnt
			setenv $host_rmt $host_rmtx
			set dir_rmt = tst_remote_dir_ms_$xcnt
			eval 'set this_host_dir = (${gtm_tstdir_'${host_rmtx:r:r:r:r:q}'})' #' keep vim highlighting happy
			# if test output directory includes version, include it in remote directories as well
			set dirn = $this_host_dir[$#this_host_dir]/$USER
			if ($tst_dir =~ *$tst_ver*) set dirn = $dirn/$tst_ver
			setenv $dir_rmt $dirn
			@ xcnt = $xcnt + 1
		end
		set cnt = `setenv | $grep -E "tst_remote_dir_ms_[0-9]" | wc -l`
		set cntx = 1
		while ($cntx <= $cnt)
			eval 'set tst_remote_hostx = $tst_remote_host_ms_'${cntx:q}
			eval 'set tst_remote_dirx = $tst_remote_dir_ms_'${cntx:q}
			$rsh $tst_remote_hostx "mkdir -p $tst_remote_dirx/$gtm_tst_out/$testname; chmod g+w $tst_remote_dirx/$gtm_tst_out/$testname"
			echo "Creating multisite remote directory $tst_remote_dirx/$gtm_tst_out/$testname in $tst_remote_hostx"
			$grep -q "$rsh $tst_remote_hostx 'rm -rf $tst_remote_dirx/$gtm_tst_out'" $cleanup_script
			if ($status) then
				echo "$rsh $tst_remote_hostx 'rm -rf $tst_remote_dirx/$gtm_tst_out'" >>! $cleanup_script
			endif
			$rsh $tst_remote_hostx "(echo primary $tst_org_host $tst_dir/$gtm_tst_out ; echo `setenv | $grep tst_remote_host_ms_`; echo `setenv | $grep tst_remote_dir_ms_`) >>! $tst_remote_dirx/$gtm_tst_out/primary_dir"
			@ cntx = $cntx + 1
		end
	endif
endif

if ($?test_gtm_gtcm_one) then
	set gtcm_dir_error = 0
	source $gtm_tst/com/gtcm_command.csh "echo Creating TST_REMOTE_DIR_GTCM/$gtm_tst_out/$testname in TST_REMOTE_HOST_GTCM"
	source $gtm_tst/com/gtcm_command.csh "SEC_SHELL_GTCM mkdir -p TST_REMOTE_DIR_GTCM/$gtm_tst_out/$testname"
	############################################################
	# determine the remote directory names taking into account soft links,
	#	if any are null, or a "non-allowed" directory error out
	set total_rmt_dir_gtcm = (`source $gtm_tst/com/gtcm_command.csh "SEC_SHELL_GTCM  cd TST_REMOTE_DIR_GTCM; pwd"`)
	setenv tst_remote_dir_gtcm_total "$total_rmt_dir_gtcm"
	set xcnt = `echo $tst_other_servers_list| wc -w`
	# check if any are null
	if ($xcnt != $#total_rmt_dir_gtcm ) then
		echo "TEST-E-GTCM-CREATE Some of the GT.CM Server directories could not be created. All the GT.CM tests will fail." >>! $tst_general_dir/diff.log
		echo "Check the permissions to the following directories on the hosts:" >>! $tst_general_dir/diff.log
		setenv | $grep -E "tst_remote_dir_[0-9]" >>! $tst_general_dir/diff.log
		setenv | $grep -E "tst_remote_host_[0-9]" >>! $tst_general_dir/diff.log
		echo "Actual output: $total_rmt_dir_gtcm" >>! $tst_general_dir/diff.log
		set gtcm_dir_error = 1
	endif
	set dir_error = 0
	if !($gtcm_dir_error) then
		while (1 <= $xcnt)
			setenv tst_remote_dir_$xcnt $total_rmt_dir_gtcm[$xcnt] # correct the remote directory names for any soft links.
			set dir_gtcm = tst_remote_dir_gtcm_$xcnt
			set curvalue = $total_rmt_dir_gtcm[$xcnt]
			eval 'set curvalue_host = $tst_remote_host_'${xcnt:q}
			setenv $dir_gtcm  $total_rmt_dir_gtcm[$xcnt]
			echo "GT.CM Server "$xcnt":" $curvalue_host $curvalue"/"$gtm_tst_out >>&! $tst_dir/$gtm_tst_out/primary_dir
			##################
			# check if it is "non-allowed"
			if (`echo $curvalue | $tst_awk -F/ '$2 ~/gtc/ || $2 ~/usr/ || $3 ~/gtc/ {print "1"}'`) then
			   echo "TEST-E-DIR_REMOTE Will not submit the test in $curvalue (on $curvalue_host)" >>! $tst_general_dir/diff.log
			   echo "Please specify a non-/gtc/ non-/usr/ directory to run the tests" >>! $tst_general_dir/diff.log
			   echo "The directory $curvalue/$gtm_tst_out has been created on host $curvalue_host. Please remove it." >>! $tst_general_dir/diff.log
			   set dir_error = 1
			endif
			########################
			@ xcnt = $xcnt - 1
		end
	else
		set dir_error = 1
	endif
	if ($dir_error) then
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit 6
	endif
	echo "primary $tst_org_host $tst_dir/$gtm_tst_out" >>&! $tst_dir/$gtm_tst_out/primary_dir
	echo "setenv local_dir  $tst_dir/$gtm_tst_out" >>&! $tst_dir/$gtm_tst_out/testdirs
	source $gtm_tst/com/gtcm_command.csh "$rcp $tst_dir/$gtm_tst_out/primary_dir TST_REMOTE_HOST_GTCM:TST_REMOTE_DIR_GTCM/$gtm_tst_out/primary_dir_gtcm"
	source $gtm_tst/com/gtcm_command.csh "SEC_SHELL_GTCM  cd TST_REMOTE_DIR_GTCM/$gtm_tst_out; cat primary_dir_gtcm >> primary_dir ; rm primary_dir_gtcm"
	rm $tst_dir/$gtm_tst_out/primary_dir
	############################################################
	# the AWK and XXX trick is necessary because the above line does not have any newlines
	set xtmp = `source $gtm_tst/com/gtcm_command.csh "echo $rsh TST_REMOTE_HOST_GTCM 'rm -rf TST_REMOTE_DIR_GTCM/$gtm_tst_out'XXX"`
	# Split the cleanup commands separated by XXX into multilines and redirect to a tmp file
	# Check if the cleanup line already exists in cleanup script
	echo "$xtmp " |& $tst_awk -F 'XXX ' '{{for ( i=1 ; i < NF ; i++ ) { new=system("$grep -q \""$i"\" '$cleanup_script'") ; if (new==1) print $i}}}' >>&! $cleanup_script
	setenv PRI_DIR $tst_dir/$gtm_tst_out/$testname/tmp
	setenv sec_shell "source $gtm_tst/com/gtcm_command.csh"
	$sec_shell "SEC_SHELL_GTCM \mkdir -p SEC_DIR_GTCM ; chmod g+w SEC_DIR_GTCM"
endif

if !($?test_norandomsettings) then
	# Set ipv6 host names if randomly chosen by do_random_settings
	source $gtm_tst/com/gtm_test_ipv6_random.csh
endif

# If encryption is turned on, setup its environment now
if ($?test_encryption) then
	if ("ENCRYPT" == "$test_encryption") then
		source $gtm_tst/com/set_encrypt_env.csh $tst_general_dir $gtm_dist $tst_src >>! $tst_general_dir/set_encrypt_env.log
		$gtm_tst/com/multihost_encrypt_settings.csh
		# If there is an encryption setup issue, encryption will be automatically disabled by set_encrypt_env.csh by setting
		# test_encryption to "NON_ENCRYPT".  In that case, report it once.
		if (("NON_ENCRYPT" == "$test_encryption") && (!(-e $tst_dir/$gtm_tst_out/encryption_issue.txt))) then
			cat $tst_general_dir/set_encrypt_env.log >>! $tst_dir/$gtm_tst_out/encryption_issue.txt
			echo "The tests that try to run with encryption will have it disabled anyway (unless the issue is fixed)." 	\
											>>! $tst_dir/$gtm_tst_out/encryption_issue.txt
			echo "This is the only warning that will be sent." 								\
											>>! $tst_dir/$gtm_tst_out/encryption_issue.txt
			echo "Version: $tst_ver ($tst_image)"				>>! $tst_dir/$gtm_tst_out/encryption_issue.txt
			echo "Test: $tst"						>>! $tst_dir/$gtm_tst_out/encryption_issue.txt
			echo "Test directory: $tst_general_dir"				>>! $tst_dir/$gtm_tst_out/encryption_issue.txt
			if (!($?tst_dont_send_mail)) then
				set subject = "Host $short_host will run with encryption disabled due to encryption setup issue."
				cat $tst_dir/$gtm_tst_out/encryption_issue.txt | mailx -s "$subject" $mailing_list
			endif
		endif
	endif
endif

if ($?gtm_test_tls) then
	if ("TRUE" == $gtm_test_tls) then
		source $gtm_tst/com/set_tls_env.csh
	endif
endif
##########################################################################################################################
# determine unicode support on remote servers here before submitting the tests to let the random decision for chset
# if no support identified on remote hosts let them run on "M" mode only.
set hostn = $HOST:r:r:r
if ($?test_replic) then
	if ("MULTISITE" == $test_replic) then
		# make sure tool exists on remote host first
		setenv h1_check `$rsh $tst_other_servers_list_ms[1] file $gtm_exe $gtm_tools/check_utf8_support.csh |& $grep -E 'cannot open|Connection'`
		if ( "" != "$h1_check" ) then
			# output the actual error found first
			echo $h1_check >>! $tst_general_dir/diff.log
			echo "Problem with $gtm_ver on $h1 or Connection problem - exiting!" >>! $tst_general_dir/diff.log
			cat $tst_general_dir/diff.log
			$gtm_tst/com/write_logs.csh FAILED
			if (!($?tst_dont_send_mail)) then
				$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
			endif
			exit 2
		endif
		set cmd1=`$rsh $tst_other_servers_list_ms[1] "$gtm_tools/check_utf8_support.csh"`
		setenv h1_utf8 "$cmd1"
		# make sure tool exists on remote host first
		setenv h2_check `$rsh $tst_other_servers_list_ms[2] file $gtm_exe $gtm_tools/check_utf8_support.csh |& $grep -E 'cannot open|Connection'`
		if ( "" != "$h2_check" ) then
			# output the actual error found first
			echo $h2_check >>! $tst_general_dir/diff.log
			echo "Problem with $gtm_ver on $h2 or Connection problem - exiting!" >>! $tst_general_dir/diff.log
			cat $tst_general_dir/diff.log
			$gtm_tst/com/write_logs.csh FAILED
			if (!($?tst_dont_send_mail)) then
				$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
			endif
			exit 2
		endif
		set cmd2=`$rsh $tst_other_servers_list_ms[2] "$gtm_tools/check_utf8_support.csh"`
		setenv h2_utf8 "$cmd2"

		if ( "FALSE" == "$h1_utf8" || "FALSE" == "$h2_utf8" ) setenv tst_remote_nonunicode
	else
		if ($tst_org_host != $tst_remote_host) then
			set cmd3=`$rsh $tst_remote_host "$gtm_tools/check_utf8_support.csh"`
			if ("FALSE" == "$cmd3") setenv tst_remote_nonunicode
		endif
	endif
endif
##########################################################################################################################
if (( "TRUE" != $gtm_test_unicode_support ) || ($?tst_remote_nonunicode)) then
	# for platforms that has no unicode support, ignore the randomness of do_random_settings and force M mode
	setenv gtm_chset "M"
	echo "# @submit_test : gtm_chset can only be M because of non-unicode support in this server or in its remote"	>>! $tst_general_dir/settings.csh
	echo "setenv gtm_chset M"							>>! $tst_general_dir/settings.csh
endif
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) then
		# all modules are compiled under M mode.
		# If we change to utf-8 in the test then the library routines and GDE will croak on looking at M
		# compiled objects. So instruct the gtmroutines to look at the utf8 subdir inside gtm_exe
		source $gtm_tst/com/set_gtmroutines.csh "UTF8"
		\rm *.o >&! rm_chsetobjs_subtest.log # remove all objs that are compiled under M mode till this point from the test directory
	endif
endif
setenv switch_chset "source $gtm_tst/com/switch_chset.csh"
# add for the logs directory
setenv gtm_test_log_dir  $ggdata/tests/timinginfo/$tst_src/$tst
if ($?test_replic) then
   setenv gtm_repl_instance mumps.repl
   setenv MULTISITE_REPLIC_PREPARE "source $gtm_tst/com/multisite_replic_prepare.csh"
   setenv remote_gtm_exe `$sec_shell "setenv gtm_ver_noecho; source $gtm_tst/com/set_active_version.csh $remote_ver $remote_image;"'echo $gtm_exe'`
   if !($?gtm_tools) setenv remote_gtm_exe $gtm_exe
else if ("GT.CM" == $test_gtm_gtcm) then
   # no capability to have different versions for remote GT.M version yet
   setenv remote_gtm_exe `$tst_tcsh -c "setenv gtm_ver_noecho; source $gtm_tst/com/set_active_version.csh $remote_ver $remote_image;"'echo $gtm_exe'`

else
	setenv MULTISITE_REPLIC_PREPARE "echo Is this MULTISITE test then pls. resubmit it with -replic option"
endif

if (($?test_replic)||("GT.CM" == $test_gtm_gtcm)) then
	set exewc = `echo $remote_gtm_exe | wc -w`
	if (1 != $exewc) then
		echo "TEST-E-REMOTE_GTM_EXE not a single word" >>! $tst_general_dir/diff.log
		echo "Check that the remote gtm version exists" >> $tst_general_dir/diff.log
		echo "remote_gtm_exe: $remote_gtm_exe" >> $tst_general_dir/diff.log
		echo "#################################################" >> $tst_general_dir/diff.log
		$sec_shell "hostname; ls -l $gtm_root/$remote_ver/" >>& $tst_general_dir/diff.log
		echo "#################################################" >> $tst_general_dir/diff.log
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		$gtm_test_com_individual/clean_and_exit.csh
		\rm -r $tst_working_dir
		source $gtm_tst/com/create_resolution.csh
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit 40
	endif
endif

if (($?test_replic) || ("GT.CM" == $test_gtm_gtcm)) then
   setenv remote_image `basename $remote_gtm_exe`
   setenv remote_ver `basename ${remote_gtm_exe:h}`
else
   unsetenv gtm_repl_instance
endif
############################################
set testfilesdir = $tst_general_dir/testfiles
if (! -e $testfilesdir) mkdir -p $testfilesdir

#Collation setup
source $gtm_tst/com/collation_setup.csh
##########################
if ("$tst_stdout" == "3" || "$tst_stdout" == "0") then
	echo " "
	echo '$gtmgbldir: ' $gtmgbldir
	echo '$YDB: ' $YDB
	echo '$MUPIP: ' $MUPIP
	echo '$DSE: ' $DSE
	echo '$GDE: ' $GDE
	echo '$LKE: ' $LKE
	echo '$gtmroutines: ' "$gtmroutines"
	echo " "
	echo Testing $tst
	if (($?test_replic)||("GT.CM" == $test_gtm_gtcm)) then
		 echo " "
		 echo "Original Host YDB:$gtm_exe"
		 echo "Remote Host   YDB:$remote_gtm_exe"
		 echo " "
	endif
	echo `pwd`
endif

echo "ENVIRONMENT OF CURRENT TEST" 			>  $tst_general_dir/config.log
echo "submit_test.csh PID :	$$"			>> $tst_general_dir/config.log
echo "PRODUCT:		$test_gtm_gtcm" 		>> $tst_general_dir/config.log
echo "VERSION:		`basename $gtm_ver`" 		>> $tst_general_dir/config.log
echo "SOURCE: 		`dirname $gtm_ver`" 		>> $tst_general_dir/config.log
echo "IMAGE:    		`basename $gtm_dist`" 	>> $tst_general_dir/config.log
echo "TEST SOURCE:		$gtm_tst" 		>> $tst_general_dir/config.log
echo "TEST:			$tst" 			>> $tst_general_dir/config.log
echo "HOST:			$short_host" 		>> $tst_general_dir/config.log
echo "HOSTOS:			$HOSTOS" 		>> $tst_general_dir/config.log
echo "USER:			$USER" 			>> $tst_general_dir/config.log
echo "MAIL TO:		$mailing_list" 			>> $tst_general_dir/config.log
echo "COMPILE OPTION:		$gtm_test_nolineentry" 	>> $tst_general_dir/config.log
echo "LIGHT/FULL/EXTENDED:	$LFE" 			>> $tst_general_dir/config.log
 echo "NICE/UNNICE:             $test_nice" 		>> $tst_general_dir/config.log
echo "REORG/NON_REORG:	$test_reorg" 			>> $tst_general_dir/config.log
echo "JOURNAL:		$tst_jnl_str" 			>> $tst_general_dir/config.log
if ($?test_replic) then
   if ("MULTISITE" == "$test_replic") then
	   echo "REPLICATION:          	MULTISITE" 		>> $tst_general_dir/config.log
	   echo "TEST REMOTE DIRS:     	`setenv | $grep tst_remote_dir_`" >> $tst_general_dir/config.log
	   echo "REMOTE HOSTS:         	`setenv | $grep tst_remote_host_`" >> $tst_general_dir/config.log
   else
	   echo "REPLICATION" 					>> $tst_general_dir/config.log
	   echo "TEST REMOTE DIR:	$tst_remote_dir" 	>> $tst_general_dir/config.log
	   echo "REMOTE HOST:          	$tst_remote_host" 	>> $tst_general_dir/config.log
   endif
   echo "gtm_repl_instance:	$gtm_repl_instance" 	>> $tst_general_dir/config.log
   echo "BUFFSIZE:            	$tst_buffsize" 		>> $tst_general_dir/config.log
   echo "LOG:                 	$tst_rf_log" 		>> $tst_general_dir/config.log
   echo "JOURNAL:              	$tst_jnl_str" 		>> $tst_general_dir/config.log
else
   echo "REPLICATION:		$test_repl" 		>> $tst_general_dir/config.log
endif
if (($?test_replic)||("GT.CM" == $test_gtm_gtcm)) then
   echo "REMOTE VERSION:       	$remote_ver" 		>> $tst_general_dir/config.log
   echo "REMOTE IMAGE:         	$remote_image" 		>> $tst_general_dir/config.log
   echo "REMOTE USER:          	$tst_remote_user" 	>> $tst_general_dir/config.log
endif
if ("GT.CM" == $test_gtm_gtcm) then
   echo "REMOTE HOST:          	$tst_remote_host" 	>> $tst_general_dir/config.log
   echo "TEST GT.CM SERVERS:          $tst_gtcm_server_list" >> $tst_general_dir/config.log
   echo "TEST GT.CM DIRECTORIES:      $tst_remote_dir_gtcm_total" >> $tst_general_dir/config.log
endif
# Note that the test might override the following
if ($?gtm_chset) then
	set gtm_chsettmp = $gtm_chset
else
	set gtm_chsettmp = "undefined"
endif
if ($?gtm_test_dbdata) then
	set gtm_test_dbdatatmp = $gtm_test_dbdata
else
	set gtm_test_dbdatatmp = "undefined"
endif
echo "UNICODE gtm_chset:	$gtm_chsettmp"		>>$tst_general_dir/config.log
echo "UNICODE gtm_test_dbdata:$gtm_test_dbdatatmp"	>>$tst_general_dir/config.log
echo "" 						>> $tst_general_dir/config.log


if (!( -d $gtm_tst/$tst)) then
	echo "Could not find the test directory for test $tst" >>! $tst_general_dir/outstream.log
	echo "Exiting" >>! $tst_general_dir/outstream.log
	echo "Could not find the test directory for test $tst" >>! $tst_general_dir/diff.log
	echo "Exiting" >>! $tst_general_dir/diff.log
	cat $tst_general_dir/diff.log
	$gtm_tst/com/write_logs.csh FAILED
	$gtm_test_com_individual/clean_and_exit.csh
	\rm -r $tst_working_dir
	if (!($?tst_dont_send_mail)) then
		$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
	endif
	exit 50
endif
#########################################################################
# prepare cleanup.csh
set cleanup_script = $tst_general_dir/cleanup.csh
echo "#\!/usr/local/bin/tcsh -f" >>! $cleanup_script
chmod +x $cleanup_script

if ($?test_replic) then
	if ($tst_org_host == $tst_remote_host) then
		set rmstrpre = ""
		set rmstrpost = " >& /dev/null"
	else
		$gtm_tst/com/send_env.csh
		set rmstrpre = "$rsh $tst_remote_host '"
		set rmstrpost = "' >& /dev/null"
	endif
	echo "$rmstrpre rm -rf $tst_remote_dir/$gtm_tst_out/$testname $rmstrpost" >>! $cleanup_script
	if ($SEC_SIDE != $test_remote_jnldir) then
		echo "$rmstrpre rm -rf $tst_remote_jnldir/$gtm_tst_out/$testname $rmstrpost" >>! $cleanup_script
	endif
	if ($SEC_SIDE != $test_remote_bakdir:h) then
		echo "$rmstrpre rm -rf $tst_remote_bakdir/$gtm_tst_out/$testname $rmstrpost" >>! $cleanup_script
	endif
	if ("MULTISITE" == "$test_replic") then

		# we need to remove the directories on the other hosts as well
		set cnt = `setenv | $grep -E "tst_remote_dir_ms_[0-9]" | wc -l`

		set cntx = 1
		while ($cntx <= $cnt)
			set tst_remote_hostx = `echo "" | $tst_awk '{system("echo $tst_remote_host_ms_"'$cntx')}'`
			set tst_remote_dirx  = `echo "" | $tst_awk '{system("echo $tst_remote_dir_ms_"'$cntx')}'`
			echo "$rsh $tst_remote_hostx 'rm -rf $tst_remote_dirx/$gtm_tst_out/$testname >& /dev/null'" >>! $cleanup_script
			@ cntx = $cntx + 1
		end
	endif

else if ("GT.CM" == $test_gtm_gtcm) then
	$gtm_tst/com/send_env.csh
	# the awk and XXX trick is necessary because the above line does not have any newlines
	set x = `$sec_shell "echo $rsh TST_REMOTE_HOST_GTCM 'rm -rf TST_REMOTE_DIR_GTCM/$gtm_tst_out/$testname' XXX"`
	echo $x | $tst_awk '{gsub("XXX","\n");print}' >>! $cleanup_script
endif
if ($tst_working_dir != $test_jnldir) then
	echo "rm -rf $tst_jnldir/$gtm_tst_out/$testname >& /dev/null" >>! $cleanup_script
endif
if ($tst_working_dir != $test_bakdir:h) then
echo "rm -rf $tst_bakdir/$gtm_tst_out/$testname >& /dev/null"  >>! $cleanup_script
endif
# take care of the renaming (test assignments) in cleanup.csh:

sed 's,\(_[0-9][0-9][0-9][0-9][0-9][0-9]\)/,\1/*__,;s,^ [ ]*,,g' $cleanup_script >! ${TMP_FILE_PREFIX}_cleanup_csh
$tst_awk '{ print; if ($0 ~ /(rm|chmod) /) {gsub("\\*__","");print}}' ${TMP_FILE_PREFIX}_cleanup_csh | uniq >! $cleanup_script

#########################################################################
# check if there is enough space, and exit if not
if (! $?gtm_test_dryrun) then
	$gtm_tst/com/check_space.csh >&! $tst_general_dir/check_space.out
	if !($status) then
		#rm $tst_general_dir/check_space.out
	else
		echo "TEST-E-SPACE, Will not run test $tst due to lack of space:" >>&! $tst_general_dir/diff.log
		cat $tst_general_dir/check_space.out >>&! $tst_general_dir/diff.log
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		# disk_space_mailed.txt shows whether another test encountered the problem earlier
		if (!(-e $tst_dir/$gtm_tst_out/disk_space_mailed.txt)) then
			touch $tst_dir/$gtm_tst_out/disk_space_mailed.txt
			if (!($?tst_dont_send_mail)) then
				echo "Any test that requires the above full disk will not run until the disk is freed up. This will be the only warning that will be sent." >>&! $tst_general_dir/diff.log
				$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
			endif
		endif
		exit 50
	endif
endif
#########################################################################
# check if $gtm_exe is proper on the remote hosts
if ($?test_replic) then
	## check if remote version is actually healthy
	if ($tst_org_host != $tst_remote_host) then
		set vercheck = `$sec_shell "$sec_getenv;  if (-x "'$gtm_exe'"/mumps) echo 1"`
		if ("1" != "$vercheck") then
			echo "TEST-E-REMOTE_GTM_EXE no executable" >>! $tst_general_dir/diff.log
			echo "Check that the remote gtm version exists" >> $tst_general_dir/diff.log
			echo "vercheck: $vercheck" >> $tst_general_dir/diff.log
			cat $tst_general_dir/diff.log
			$gtm_tst/com/write_logs.csh FAILED
			$gtm_test_com_individual/clean_and_exit.csh
			source $gtm_tst/com/create_resolution.csh
			if (!($?tst_dont_send_mail)) then
				$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
			endif
			exit 40
		endif
	endif
	# we currently do not check the remote hosts for MULTISITE
else if ("GT.CM" == $test_gtm_gtcm) then
	# check if the remote versions are actually healthy
	($sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; if( -x "'$gtm_exe'"/mumps) echo MUMPS_IS_EXE")  >& $tst_working_dir/gtcm_version_check.txt
	if ($HOSTOS == "SunOS") then
		# if running in UTF-8 locale, punctuation marks get displayed as their octal equivalents due to some tcsh bug
		# this happens with a plain setenv
		# to work around this until tcsh is fixed, we transform such an output to what it should normally be.
		set vers = `setenv | $grep remote_ver_gtcm_ | sed 's/\\\075/=/g' | sed 's/.*=//g' | $tst_awk '{printf $0 "|"} END {printf "\n"}' | sed 's/|$//g'`
	else
		set vers = `setenv | $grep remote_ver_gtcm_ | sed 's/.*=//g' | $tst_awk '{printf $0 "|"} END {printf "\n"}' | sed 's/|$//g'`
	endif
	echo "remote versions are: $vers"
	set lc = `$grep -E "^MUMPS_IS_EXE" $tst_working_dir/gtcm_version_check.txt | wc -l`
	if (2 != $lc) then
		echo "TEST-E-REMOTE_GTM_EXE no executable" >>! $tst_general_dir/diff.log
		echo "Check that the remote gtm version exists" >> $tst_general_dir/diff.log
		echo "Check $tst_working_dir/gtcm_version_check.txt for more info" >> $tst_general_dir/diff.log
		cat $tst_general_dir/diff.log
		$gtm_tst/com/write_logs.csh FAILED
		$gtm_test_com_individual/clean_and_exit.csh
		source $gtm_tst/com/create_resolution.csh
		if (!($?tst_dont_send_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh "FAILED"
		endif
		exit 40
	endif
endif
#########################################################################

# Use prctl to detect unaligned memory access on Linux/ia64 boxes
if (("ia64" == "$MACHTYPE") && ($HOSTOS == "Linux")) then
    set prctl_comm = "prctl --unaligned=signal"
else
    set prctl_comm = ""
endif

#########################################################################
set instream = $gtm_tst/$tst/instream.csh.$tst_ver
if (-f $instream) then
   set instream =  $gtm_tst/$tst/instream.csh.$tst_ver
else
   set instream =  $gtm_tst/$tst/instream.csh
endif
echo "USING SCRIPT: 		$instream" >> $tst_general_dir/config.log

set outref_txt = $gtm_tst/$tst/outref/outref.txt.$tst_ver
if (-f $outref_txt) then
   echo "Using version specific outref.txt.$tst_ver"
else
   set  outref_txt = $gtm_tst/$tst/outref/outref.txt
endif
echo "USING REFERENCE FILE: 	$outref_txt" >> $tst_general_dir/config.log

################# create timing_info_dir if required ####################
if ($?testtiming_log) then
	set timing_info_dir = $gtm_test_log_dir:h
	set timing_info_file = "$timing_info_dir/${tst}_timing.info"
	echo "timing_info_dir is $timing_info_dir"
	if (! -d $timing_info_dir) then
		mkdir -p $timing_info_dir
		if ($status) then
			echo "TEST-E-LOGDIR, Could not create log directory $timing_info_dir"  >>! $tst_general_dir/outstream.log
		else
			touch $timing_info_file
			chmod 775 $timing_info_dir >& /dev/null
			chmod 664 $timing_info_file >& /dev/null
		endif
	endif
	if ((-e $timing_info_file) && (! -w $timing_info_file)) then
		echo "TEST-E-TIMING_LOG, Do not have write permission to logfile $timing_info_file" >>! $tst_general_dir/outstream.log
	endif
endif
#########################################################################

set format="%Y %m %d %H %M %S %Z"
set before = `date +"$format"`

#########################################################################
# Copy settings.csh file from the test level directory to tmp directory (will be required if submit_subtest.csh isn't used)
if (-e settings.csh) then
	# if it already exists, maintain the correct order in the latest settings.csh file
	cp settings.csh settings.csh.tmp
	cp $tst_general_dir/settings.csh settings.csh
	cat settings.csh.tmp >> settings.csh
	\rm settings.csh.tmp
else
	cp $tst_general_dir/settings.csh settings.csh
endif

setenv > env_begin.txt
$grep submit_subtest $instream >& /dev/null
set dryrun_subtest = $status

# do call instream if not dryrun, or dryrun and subtests exist
if ((! $?gtm_test_dryrun) || (! $dryrun_subtest)) then
  	source $gtm_tst/com/mm_nobefore.csh	  # Force NOBEFORE image journaling with MM
	setenv tst_tslog_file $tst_general_dir/outstream.log_ts
	unset echo; unset verbose
	(source $gtm_tst/com/gtm_test_watchdog.csh $tst_general_dir/tmp & ; echo $! >&! gtm_test_watchdog.pid) >&! gtm_test_watchdog.out
	set watchdogpid = `cat gtm_test_watchdog.pid`
	if ("$tst_stdout" == "3" || "$tst_stdout" == "0") then
	  set echo
	  set verbose
	endif
	if ($tst_stdout > 0) then
	   # tst_tslog_filter may have a pipe in it, so use eval to interpret it properly.
	   # -e flag added to fix issue with imptp.csh(YDBTest#431) invocations by stopping the test flow after the first point of error.
	   eval "$prctl_comm $tst_tcsh -e $instream $tst_tslog_filter |& tee $tst_general_dir/outstream.log"
	else
	   # tst_tslog_filter may have a pipe in it, so use eval to interpret it properly.
           # -e flag added to fix issue with imptp.csh(YDBTest#431) invocations by stopping the test flow after the first point of error.
	   eval "$prctl_comm $tst_tcsh -e $instream $tst_tslog_filter >& $tst_general_dir/outstream.log"
	endif
	if ($status != 0 ) then
	   echo "Possible error!" >> $tst_general_dir/outstream.log
	endif
	# submit_subtest might take control away from $tst_working_dir
	cd $tst_working_dir
	touch $tst_general_dir/tmp/watchdog_$testname.stop
	$gtm_tst/com/wait_for_proc_to_die.csh $watchdogpid
	# take it through a filter to filter out most common run-specific outputs
	if (-e priorver.txt) then	# for tests that use a random prior version
		set priorver = `cat priorver.txt`
	else
		set priorver = "IMPOSSIBLEVERNAME"
	endif
	set mask_jnleod = 1
	if (-f dont_mask_jnleod.txt) set mask_jnleod = 0 # The test specifically asks for NOT masking the 'End of Data' field
	mv $tst_general_dir/outstream.log $tst_general_dir/outstream.log_actual

	$gtm_tst/com/do_outstream_m_filter.csh $tst_general_dir/outstream.log_actual $tst_general_dir/outstream.log_m
	$tst_awk -f $gtm_tst/com/outstream.awk -v priorver=$priorver -v mask_jnleod=$mask_jnleod \
			$tst_general_dir/outstream.log_m > $tst_general_dir/outstream.log
else
	echo "TEST-E-Test system does not support -dryrun option for tests without subtests yet"
	echo "TEST-E-Test system does not support -dryrun option for tests without subtests yet" > $tst_general_dir/outstream.log
	if ("$tst_stdout" == "1") echo "TEST-E-Test system does not support -dryrun option for tests without subtests yet"
endif
set after = `date +"$format"`
setenv test_time  `echo $before $after | $tst_awk -f $gtm_tst/com/diff_time.awk -v full=1`
echo $test_time


######
# If settings.csh is seen in $tst_general_dir/tmp/, it means submit_subtest.csh was not invoked. Copy the settings.csh to save dir as well as to $tst_general_dir
# settings.csh.$tst is sourced by write_logs.csh to log the settings after modifications done by instream.csh
if (-e $tst_general_dir/tmp/settings.csh) then
	cp $tst_general_dir/tmp/settings.csh $gtm_test_debuglogs_dir/${testname}_instream_settings.csh
	cp $tst_general_dir/tmp/settings.csh $tst_general_dir/settings.csh.$tst
endif
##############

setenv > env.txt
# Rely on outstream.cmp generated by submit_subtest.csh if $outref_txt is not present
if (-e $outref_txt) then
	if ($?gtm_test_st_list) then
		# only a subset of the subtests were submitted, modify outstream.cmp accordingly
		#$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $tst_general_dir/outstream.log $outref_txt | $tst_awk '{if ("PASS" == $1){if ("'$gtm_test_st_list'" ~ $3) print} else print}' >&! $tst_general_dir/outstream.cmp
		echo $gtm_test_st_list
		$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $tst_general_dir/outstream.log $outref_txt | $tst_awk -f $gtm_tst/com/outref_st.awk -v gtm_test_st_list="$gtm_test_st_list" >&! $tst_general_dir/outstream.cmp
	else
		$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $tst_general_dir/outstream.log $outref_txt >&! $tst_general_dir/outstream.cmp
	endif
endif
#
if ($?gtm_test_dryrun) then
	echo "THIS WAS A DRY RUN! NO SUBTESTS ACTUALLY RAN." >>! $tst_general_dir/outstream.log
	echo "THIS WAS A DRY RUN! NO SUBTESTS ACTUALLY RAN." >>! $tst_general_dir/outstream.cmp
endif
if ($?gtm_test_st_list) then
	echo "ONLY A SUBSET OF THE SUBTESTS WERE REQUESTED." >>! $tst_general_dir/outstream.log
	echo "ONLY A SUBSET OF THE SUBTESTS WERE REQUESTED." >>! $tst_general_dir/outstream.cmp
endif

# To cope with the different style of error messages in OS/390
if ( "OS/390" == $HOSTOS ) then
	\mv $tst_general_dir/outstream.log $tst_general_dir/outstream.log_edc
	\mv $tst_general_dir/outstream.cmp $tst_general_dir/outstream.cmp_edc
#	We don't want the following lines in log files. Test sysmtem will treat "%SYSTEM-E-EN" as error
	unset echo
	unset verbose
	cat $tst_general_dir/outstream.log_edc | sed 's/%SYSTEM-E-EN.*,//g' | sed 's/EDC[0-9][0-9][0-9][0-9][A-Z] \(.*\)\./\1/g' > $tst_general_dir/outstream.log
	cat $tst_general_dir/outstream.cmp_edc | sed 's/%SYSTEM-E-EN.*,//g' | sed 's/EDC[0-9][0-9][0-9][0-9][A-Z] \(.*\)\./\1/g' > $tst_general_dir/outstream.cmp
	if ("$tst_stdout" == "3" || "$tst_stdout" == "0") then
	  set echo
	  set verbose
	endif
endif

if ($?LC_CTYPE) then
	if ("C" != $LC_CTYPE) then
		set save_lc_ctype=$LC_CTYPE
		# This is because at least in HP-UX we have trouble in diff command
		# when one of the file in question is not ascii text
		setenv LC_CTYPE "C"
	endif
endif
# errors.csh prints ERRORS-E-CORE_RENAME when it renames cores by dbx or tcsh. (check the reason for rename in errors.csh).
# Remove those messages before doing a diff. If there is no other diff, continue to ignore the ERRORS-E-CORE_RENAME message and let the subtest pass
$grep "ERRORS-.-CORE_RENAME" $tst_general_dir/outstream.log >>&! check_rename_messages.outx
if !($status) then
	\mv $tst_general_dir/outstream.log $tst_general_dir/outstream.log_rename_messages
	$grep -v "ERRORS-.-CORE_RENAME" $tst_general_dir/outstream.log_rename_messages >&! $tst_general_dir/outstream.log
	cmp -s $tst_general_dir/outstream.cmp $tst_general_dir/outstream.log
	if ($status) then
		# It means there were failures. So retain the ERRORS-E-CORE_RENAME message too in the diff file
		\mv $tst_general_dir/outstream.log_rename_messages $tst_general_dir/outstream.log
	endif
endif

\diff $tst_general_dir/outstream.cmp $tst_general_dir/outstream.log >>& $tst_general_dir/diff.log
set stat = "$status"
# restore LC_CTYPE here
if ($?save_lc_ctype) then
	setenv LC_CTYPE $save_lc_ctype
endif
#
set timestamp = `date +%Y%m%d_%H%M%S`
if ($stat) then
	date >>! $tst_dir/$gtm_tst_out/ps.list	#BYPASSOK
	echo "After the test:" >>! $tst_dir/$gtm_tst_out/ps.list #BYPASSOK
	$ps  | $grep $USER >>! $tst_dir/$gtm_tst_out/ps.list
	echo "------------------------------------" >>! $tst_dir/$gtm_tst_out/ps.list #BYPASSOK
	$gtm_tst/com/check_rare_failures.csh $testname . $tst_general_dir/diff.log
	echo "#####Check the errors in time sorted fashion in logfile: <errs_found.logx>#####" >>! $tst_general_dir/diff.log
	source $gtm_tst/com/create_resolution.csh
endif
#
#
if ("$test_want_concurrency" == "yes") then
	pushd $test_load_dir
	set old_gtmroutines = "$gtmroutines"
	setenv gtmroutines "."
	setenv gtmgbldir load.gld
	$gtm_exe/mumps -direct << GTMEOF
	d ^unload("$tst","$short_host",$$,$tst_num)
GTMEOF
	setenv gtmroutines "$old_gtmroutines"
	popd
endif

##################### LOG ##################################

if ( $stat == 0 ) then
   set log_line_stat = "PASSED"
else
   set log_line_stat = "FAILED"
endif
# source below so that env variables set there can be reused below
source $gtm_tst/com/write_logs.csh $log_line_stat
############################################################

set st_passed = `$grep -c "PASS from" $tst_general_dir/outstream.log`
set st_failed = `$grep -c "FAIL from" $tst_general_dir/outstream.log`
set st_disabled = `$grep -wc "$testname" $gtm_test_local_debugdir/excluded_subtests.list`
echo "$testname	$st_passed	$st_failed	$st_disabled" >> $gtm_test_local_debugdir/test_subtest.info

############# Routine to display failed subtest diff files ############
if ($tst_stdout == 2 || $tst_stdout == 3) then
	foreach file (`$tst_awk '/^FAIL from / { print $6}' $tst_general_dir/outstream.log` )
		cat $tst_general_dir/$file
	end
endif

################	Routine to send mail 	##############

if (!($?tst_dont_send_mail)) then
	if ( $stat == 0 ) then
		if (!($?gtm_test_fail_mail)) then
			$gtm_tst/com/gtm_test_sendresultmail.csh PASSED
		endif
	else
		if ($?gtm_test_fail_mail) then
			echo "$tst" >> $tst_dir/$gtm_tst_out/failmail.cnt
			set tst_fail_mail_count = `wc -l $tst_dir/$gtm_tst_out/failmail.cnt | $tst_awk '{print $1}'`
			if ($tst_fail_mail_count <= $gtm_test_fail_mail) then
				set send_mail = 1
			else
				set send_mail = 0
			endif
		else
			set send_mail = 1
		endif
		if ($send_mail) then
			$gtm_tst/com/gtm_test_sendresultmail.csh FAILED
		endif
	endif
endif

############################################################
# Flag GT.CM directories for the failure (for the automation
if ($stat) then
	 if ("GT.CM" == $test_gtm_gtcm) then
	   $sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; cd SEC_DIR_GTCM/..; echo This is just to flag the FAILURE. >! diff.log"
	 endif
endif
############################################################

if ( $stat == 0 ) then
	cd $tst_general_dir
	if (-z $tst_general_dir/diff.log) \rm -f $tst_general_dir/diff.log
	if (!($?tst_keep_output)) then
		\rm -f $tst_general_dir/outstream.cmp
		if ( "OS/390" == $HOSTOS ) then
			\rm -f $tst_general_dir/outstream.cmp_edc
		endif
		\rm -rf $tst_working_dir/
		if (-d $test_jnldir) \rm -rf $test_jnldir
		if (-d $test_bakdir) \rm -rf $test_bakdir
		if ($?test_replic) then
			if ("MULTISITE" != "$test_replic") then
				$sec_shell "\rm -rf $SEC_DIR; if (-d $test_remote_jnldir) \rm -rf $test_remote_jnldir; if (-d $test_remote_bakdir) \rm -rf $test_remote_bakdir"
			else
				# cleanup.csh is well-maintained, use it:
				source cleanup.csh
			endif
		else  if ("GT.CM" == $test_gtm_gtcm) then
			$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; rm -rf SEC_DIR_GTCM"
		endif
	else
		foreach dir ($tst_working_dir $test_jnldir $test_bakdir)
			if (! -d $test_bakdir) then
				continue
			endif
			\chmod -R g+w $dir
		end
		if ($?test_replic) then
			$sec_shell "\chmod -R g+w $SEC_DIR $test_remote_jnldir $test_remote_bakdir"
		else if ("GT.CM" == $test_gtm_gtcm) then
			$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; \chmod -R g+w SEC_DIR_GTCM"
		endif
	endif
endif


if (-d $tst_working_dir) then
	$gtm_tst/com/zip_output.csh $tst_working_dir
	if ($tst_working_dir != $test_jnldir) $gtm_tst/com/zip_output.csh $test_jnldir
	if ($tst_working_dir != $test_bakdir:h) $gtm_tst/com/zip_output.csh $test_bakdir
	if ($?test_replic) then
		if ("MULTISITE" != "$test_replic") then
			$sec_shell "$sec_getenv; $gtm_tst/com/zip_output.csh $SEC_SIDE; if ($SEC_SIDE != $test_remote_jnldir) $gtm_tst/com/zip_output.csh $test_remote_jnldir; if ($SEC_SIDE != $test_remote_bakdir:h) $gtm_tst/com/zip_output.csh $test_remote_bakdir"
		else
			foreach instx (`echo $gtm_test_msr_all_instances | sed 's/INST1 //g;s/INST1$//g'`)
				$MSR RUN RCV=$instx SRC=INST1 'set msr_dont_trace; $gtm_tst/com/zip_output.csh __RCV_DIR__'
			end
		endif
	else if ("GT.CM" == $test_gtm_gtcm) then
		$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM ; $gtm_tst/com/zip_output.csh SEC_DIR_GTCM"
	endif
endif


######################TIMING LOG####################################
if ($?testtiming_log) then
	set timing_info = "$tim $testname $short_host $tst_ver $tst_image $LFE | $timinglog_info | $log_line_stat @$gtm_tst_out V1"
	echo $timing_info >>! $timing_info_file
	if (-e $tst_general_dir/timing.subtest) then
		sed 's/^/  : /;s/$/ '"@$gtm_tst_out\/$testname"'/' $tst_general_dir/timing.subtest >>&! $timing_info_file
		set subtest_timing_dir = $tst_dir/$gtm_tst_out/debugfiles/
		if (! -e $subtest_timing_dir) mkdir -p $subtest_timing_dir
		cp $tst_general_dir/timing.subtest $subtest_timing_dir/$testname.timing.subtest
	endif
endif
############################################################
if ($?test_distributed) then
	set donefile = ${test_distributed}.done
	# Note down in the file that this test is done
	$test_distributed_srvr "$gtm_tst/com/distributed_test_pick.csh donetest $testname $short_host $log_line_stat $donefile $gtm_tst"
endif
if (1 == $stat) then
	# Lets signal a "test failure" to the caller (differentiate with the other exit 1 states)
	exit 99
else
	exit $stat
endif


