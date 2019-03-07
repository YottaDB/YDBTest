#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# This test currently runs only with replication. This is because the reference file produced differs between
# the non-replic and replic runs. The replic runs have ##TEST_HOST##:##TEST_PATH## in the reference file whereas
# the non-replic runs have only ##TEST_PATH## (this is because there is no multi-host there so no need to identify
# which host the log file corresponds to). Because we do not want to have separate reference files of 500 lines or
# so for both cases separately, and because there is not a lot of additional code coverage in the non-replic case,
# it is decided to run this test in only replication mode for now. So test_replic is assumed to be 1 below.

## NOTE if a new env.variable is added: ##
# Steps to create reference file for the new env.variable, say gtm_new_env
# 1. Run the test and let it fail. (The only diff will be a single line saying test for gtm_new_env failed)
# 2. Check the file gtm_new_env/allerrors_gtm_new_env.logx and see if it is okay
# 3. Copy the file to D9I10002703.log and run unite.csh
# 4. Check the resulting D9I10002703.txt file. Make sure the host names are replaced with ##TEST_HOST_SHORT##
#    and not ##TEST_HOST## in it.
# 5. Move the resulting D9I10002703.txt file to outref/errors_gtm_new_env.txt
# 6. Rerun the test with all possible combinations to see if all of them pass.
#
if (! $?test_replic) then
	echo "This subtest needs to be run with -replic option. Exiting..."
	exit -1
endif

# Use minimum align size value to reduce the memory requirement to open all the journal files
# Note : New align value is just appended to the end, instead of modifying the already set value. It works.
setenv tst_jnl_str "$tst_jnl_str,align=4096"
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps

echo "# Start YottaDB updates in the background for the entire duration of the test"
$GTM << YDB_EOF
	do start^d002703
YDB_EOF

echo "# Allocate a portno to be used for gtcm-gnp and gtcm-omi servers"
source $gtm_tst/com/portno_acquire.csh >>& portno.out

echo "# Now determine list of YottaDB-specific environment variables from the header file ydb_logicals_tab.h"
# Remove duplicates (e.g. ydb_baktmpdir occurs in 2 lines) and empty strings
set envlist = `$tst_awk -F\" '/^YDBENVINDX_TABLE_ENTRY.*/ { var[1]=$2; var[2]=$4; for (i in var) { if ((var[i] == "") || (var[i] in vararray)) continue; printf "%s\n", var[i]; vararray[var[i]];}}' $gtm_inc/ydb_logicals_tab.h`
echo "$envlist" > envvar.list
set command0 = "$gtm_dist/mumps -direct"
set corecheck = "$tst_tcsh $gtm_tst/$tst/u_inref/D9I10002703_corecheck.csh"
set maxstr = `$gtm_dist/mumps -run %XCMD 'Set $ZPiece(x,"0",9999)="" Write x,!'`
echo $maxstr > maxstr.txt	# for debugging purposes
echo "-------------------------------------------------------------------------------------------"

foreach var ($envlist)
	setenv envvar "$var:s/$//"	# Remove leading $ from env var name
	if ($envvar == "PATH") then
		# Setting PATH to a long string causes issues with invoking executables in this test script so
		# skip just this env var.
		continue
	endif
	# We do not want different output for $gtm_autorelink_keeprtn on platforms that support it and on those that do not.
	if (("gtm_autorelink_keeprtn" == $envvar) && (! $?gtm_test_autorelink_support)) then
		continue
	endif
	# Skip dbg-only env vars in pro testing as their output will be different for dbg vs pro and we do not want
	# to maintain two different reference files for the same env var.
	if (("pro" == "$tst_image") && ("ydb_dbgflags" == $envvar)) then
		break
	endif
	echo "Testing buffer overflow for environment variable : <$envvar>"
	mkdir $envvar
	set oldvalue = `env | $grep "^$envvar="`
	if ("$oldvalue" == "") then
		set varwasdefined = 0
	else
		set varwasdefined = 1
		set oldvalue = `echo "$oldvalue" | sed 's/^'$envvar'=//g'`
	endif
	setenv $envvar "$maxstr"
	if ($envvar == "gtm_ipv4_only") then
		# Currently in do_random_settings.csh (test framework), the only env var that is randomly set
		# is ydb_ipv4_only/gtm_ipv4_only. That means it is possible "ydb_ipv4_only" is defined at this point
		# (by the test framework) and so if we want to test "gtm_ipv4_only", whatever value we give it will
		# not be honored because "ydb_ipv4_only" overrides it. Therefore temporarily unsetenv the ydb* env var
		# until gtm_ipv4_only testing is complete.
		if ($?ydb_ipv4_only) then
			set save_ydb_ipv4_only = $ydb_ipv4_only
			unsetenv ydb_ipv4_only
		endif
	endif
	# Test mumps
	rm -f d002703.o	# just in case it was compiled with a different chset
	$gtm_exe/mumps -run smallupd^d002703 >&! $envvar/${envvar}_YDB.log
	$corecheck "ydb"
	# Test DSE
	$DSE dump -file -all >&! $envvar/${envvar}_DSE.log
	$corecheck "dse"
	# Test MUPIP INTEG
	$MUPIP integ -reg "*" >&! $envvar/${envvar}_MUPIP_INTEG.log
	$corecheck "mupip_integ"
	# Test MUPIP BACKUP
	mkdir bakdir_${envvar}
	$MUPIP backup "*" bakdir_${envvar} >&! $envvar/${envvar}_MUPIP_BACKUP.log
	$corecheck "mupip_backup"
	# Test MUPIP REPLIC -SOURCE -SHOWBACKLOG
	$MUPIP replic -source -showbacklog >&! $envvar/${envvar}_MUPIP_REPLIC_SHOWBACKLOG.log
	$corecheck "mupip_replic_showbacklog"
	# Test MUPIP JOURNAL -ROLLBACK
	# Below backward rollback invocation is expected to fail. Therefore pass "-backward" explicitly to mupip_rollback.csh
	# (and avoid implicit "-forward" rollback invocation that would otherwise happen by default.
	$gtm_tst/com/mupip_rollback.csh -backward -lost=rollback_${envvar}.los "*" >&! $envvar/${envvar}_MUPIP_JOURNAL_ROLLBACK.log
	set logfile = $envvar/${envvar}_MUPIP_JOURNAL_ROLLBACK.log
	# Depending on whether the environment variable, that is being tested in this iteration, is encountered in gtm_env_init*.c
	# or not, we might either see ROLLBACK failing with LOGTOOLONG error or continuing with the full ROLLBACK which will fail
	# with MUJPOOLRNDWNFL error message. Filter that out here instead of changing it in more than 50 reference files.
	set logx = $envvar/${envvar}_MUPIP_JOURNAL_filter.logx
	$gtm_tst/com/check_error_exist.csh $logfile "YDB-E-MUJPOOLRNDWNFL" >& $logx
	$corecheck "mupip_journal_rollback"
	# Test MUPIP RUNDOWN
	$MUPIP rundown -reg "*" -override >&! $envvar/${envvar}_MUPIP_RUNDOWN.log
	set logfile = $envvar/${envvar}_MUPIP_RUNDOWN.log
	# Depending on whether or not someone else is holding the ftok lock on the instance file at the same time,
	# 	occasionally we see one of the following sets of messages.
	# 	a) %YDB-E-CRITSEMFAIL, %YDB-E-SYSCALL and %SYSTEM-E-ENOxx messages
	#	b) %SYSTEM-E-ENO11 Resource temporarily unavailable
	# Filter these out.
	# Since the errors should not be caught by the error catching test framework, redirect the output to .logx (not .log)
	# as otherwise we will see TEST-E-ERRORNOTSEEN messages.
	set logx = $envvar/${envvar}_MUPIP_RUNDOWN_filter1.logx
	$gtm_tst/com/check_error_exist.csh $logfile "YDB-E-CRITSEMFAIL" "YDB-E-SYSCALL" "SYSTEM-E-ENO" >& $logx
	set logx = $envvar/${envvar}_MUPIP_RUNDOWN_filter2.logx
	$gtm_tst/com/check_error_exist.csh $logfile "SYSTEM-E-ENO11" >& $logx
	set logx = $envvar/${envvar}_MUPIP_RUNDOWN_filter3.logx
	$gtm_tst/com/check_error_exist.csh $logfile "YDB-E-MUJPOOLRNDWNFL" >& $logx
	$corecheck "mupip_rundown"
	# Test MUPIP UPGRADE
	echo "yes" | $MUPIP upgrade  "*" >&! $envvar/${envvar}_MUPIP_UPGRADE.log
	$corecheck "mupip_upgrade"
	# Test MUPIP DOWNGRADE
	echo "yes" | $MUPIP downgrade "*" >&! $envvar/${envvar}_MUPIP_DOWNGRADE.log
	$corecheck "mupip_downgrade"
	# Test MUPIP EXTRACT
	$MUPIP extract muext_${envvar}.ext  >&! $envvar/${envvar}_MUPIP_EXTRACT.log
	$corecheck "mupip_extract"
	# Test MUPIP REORG
	$MUPIP reorg -region "*" >&! $envvar/${envvar}_MUPIP_REORG.log
	$corecheck "mupip_reorg"
	# Test GTMSECSHR
	$gtm_exe/gtmsecshr >&! $envvar/${envvar}_GTMSECSHR_START.log
	$gtm_com/IGS $gtm_exe/gtmsecshr "STOP" >&! $envvar/${envvar}_IGS.log # Stop gtmsecshr that was started
	$corecheck "gtmsecshr"
	# Test LKE
	$LKE show -all >&! $envvar/${envvar}_LKE.log
	$corecheck "lke"
	# Test DBCERTIFY
	$gtm_exe/dbcertify scan -outfile=dbcertify_scanreport.txt DEFAULT >&! $envvar/${envvar}_DBCERTIFY.log
	$corecheck "dbcertify"
	# Test GTCM GNP server
	set logfile=$envvar/${envvar}_GTCM_GNP_SERVER2.log
	if ( "os390" == $gtm_test_osname ) then
		touch $logfile
		chtag -tc ISO8859-1 $logfile
	endif
	$gtm_exe/gtcm_gnp_server -service=$portno -log=$logfile -trace >&! $envvar/${envvar}_GTCM_GNP_SERVER.log
	if (0 == $status) then
		# server was started. shut it down. pid can be found in log file.
		$gtm_tst/com/wait_for_log.csh -log $logfile -message "pid :" -waitcreation
		# Since gtm_dist is set to a large string of zeroes, the following must use
		# head rather that $head as gtm would to fail while trying to execute head.m
		head -n 1 $logfile | sed 's/].*//g' | $tst_awk '{print $NF}' >! $envvar/${envvar}_gtcm_gnp_server.pid # BYPASSOK
		@ gtcmgnp_pid = `cat $envvar/${envvar}_gtcm_gnp_server.pid`
		if (0 == $gtcmgnp_pid) then
			echo "Could not find gtcm_gnp pid from log file $logfile"
		else
			$kill -15 $gtcmgnp_pid
			$gtm_tst/com/wait_for_proc_to_die.csh $gtcmgnp_pid 300
		endif
	endif
	$corecheck "gtcm_gnp_server"
	# Test GTCM OMI server
	set logfile=$envvar/${envvar}_GTCM_SERVER2.log
	if ( "os390" == $gtm_test_osname ) then
		touch $logfile
		chtag -tc ISO8859-1 $logfile
	endif
	$gtm_exe/gtcm_server -service $portno -log $logfile -hist >&! $envvar/${envvar}_GTCM_SERVER.log
	if (0 == $status) then
		$gtm_tst/com/wait_for_log.csh -log $logfile -message "GTCM_SERVER pid :" -waitcreation
		# server was started. shut it down. pid can be found in log file.
		$tst_awk '{print $NF;exit;}' $logfile >! $envvar/${envvar}_gtcm_omi_server.pid
		@ gtcmomi_pid = `cat $envvar/${envvar}_gtcm_omi_server.pid`
		if (0 == $gtcmomi_pid) then
			echo "Could not find gtcm_omi pid from log file $logfile"
		else
			$kill -15 $gtcmomi_pid
			$gtm_tst/com/wait_for_proc_to_die.csh $gtcmomi_pid 300
		endif
	endif
	$corecheck "gtcm_omi_server"
	# Restore envvar
	if ($varwasdefined == 0) then
		unsetenv $envvar
	else
		setenv $envvar "$oldvalue"
	endif
	if ($envvar == "gtm_ipv4_only") then
		# Restore "ydb_ipv4_only" to its original value (what it had before we came into
		# this "gtm_ipv4_only" iteration of the for loop).
		if ($?save_ydb_ipv4_only) then
			setenv ydb_ipv4_only $save_ydb_ipv4_only
			unset save_ydb_ipv4_only
		endif
	endif
	if ("ENCRYPT" == "$test_encryption") then
		if ($gtm_gpg_use_agent) then
			# With GnuPG 2.x, DSE and DBCERTIFY can fail early with a CRYPTKEYFETCHFAILED error because of
			# errors related to obtaining password via pinentry which is an M program and is bound to fail
			# due to the bad environment that this test intentionally creates. Filter out these errors.
			# See <GTM_7546_CRYPTKEYFETCHFAILED_v53003_D9I10002703> for more details.
			$grep -q "Incorrect password" $envvar/${envvar}_DSE.log
			if (! $status) then
				$gtm_tst/com/check_error_exist.csh $envvar/${envvar}_DSE.log CRYPTKEYFETCHFAILED	\
					>&! $envvar/${envvar}_DSE_CRYPTKEYFETCHFAILED_expected.logx
			endif
			$grep -q "Incorrect password" $envvar/${envvar}_DBCERTIFY.log
			if (! $status) then
				$gtm_tst/com/check_error_exist.csh $envvar/${envvar}_DBCERTIFY.log CRYPTKEYFETCHFAILED	\
					>&! $envvar/${envvar}_DBCERTIFY_CRYPTKEYFETCHFAILED_expected.logx
			endif
		endif
	endif
	cd $envvar
	$gtm_tst/com/errors.csh ${envvar}_errorlog >&! allerrors_${envvar}.logx
	set reffile = $gtm_tst/$tst/outref/errors_${envvar}.txt
	if (! -e $reffile) then
		# If env-var-specific reference file does not exist, check if it is a ydb* or gtm* env var
		# If ydb* or generic env var (e.g. SHELL, HOME etc.), then use errors_template.txt as the reference file.
		# A simple way of identifying these is by checking if the env var beings with gtm or GTM and if not
		# assume it is ydb* or the generic env var.
		if (($envvar !~ "gtm*") && ($envvar !~ "GTM*")) then
			set reffile = $gtm_tst/$tst/outref/errors_template.txt
		else
			# Env var is gtm* env var. Find corresponding ydb* env var and use that env var reference file
			# since the output for the gtm* env var and its corresponding ydb* env var should be identical.
			# Since this for loop is structured such that the ydb* env var comes first and the corresponding
			# gtm* env var comes next in the loop, all we need is to use $lastreffile (set in previous iteration).
			set reffile = $lastreffile
		endif
	endif
	$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk allerrors_${envvar}.logx $reffile >&!  allerrors_${envvar}.cmp
	$tst_cmpsilent allerrors_${envvar}.cmp allerrors_${envvar}.logx
	if ($status) then
		echo "diff allerrors_${envvar}.cmp allerrors_${envvar}.logx" > ../$envvar.diff
		diff allerrors_${envvar}.cmp allerrors_${envvar}.logx >> ../$envvar.diff
		echo "	--> FAIL : Check $envvar.diff"
	endif
	$tst_gzip_quiet *.*
	set lastreffile = $reffile	# Note down ydb* reference file for later use by gtm* env var
	cd -
end
echo "# Stop background YottaDB updates"
rm -f d002703.o	# just in case it was compiled with a different chset
$GTM << YDB_EOF
	do stop^d002703
YDB_EOF

echo "# Remove portno allocation file"
$gtm_tst/com/portno_release.csh

echo "# Do dbcheck"
$gtm_tst/com/dbcheck.csh -extract
