#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#this should be sourced, I think. So that all environment variables set here will be effective outside
# usage would be : source com_gtcm "command to run"

# should be able to handle: source com.csh ls $SEC_DIR, where SEC_DIR is dynamic
# for simplicity, the $ sign in front of the env. variable is simply dropped, so ls SEC_DIR_GTCM will be changed into ls $SEC_DIR_GTCM, dynamically.


# sample usage:
# source gtcm_command.csh "SEC_SHELL_GTCM SEC_GETENV_GTCM ; ls SEC_DIR_GTCM"
# x may be used to define tst_remote_dir_gtcm_1(,2,3...) env. var.'s
# to access $alfa_x where x is a variable, use
# eval 'echo $alfa_'$x
#
# $tst_remote_host_gtcm is determined from $tst_gtcm_server_list
# The env.var.s taken care of by this routine are:
# PORTNO_GTCM 		to $portno_gtcm
# TST_REMOTE_DIR_GTCM 	to $tst_remote_dir_gtcm ($tst_remote_dir_gtcm_x should have been setup already)
# SEC_DIR_GTCM 		to $sec_dir_gtcm
# SEC_GETENV_GTCM	to $sec_getenv_gtcm
# 			   $sec_shell_gtcm

set x = 1
set stamp = "`date +%Y/%m/%d` `date +%H:%M:%S`"
set datefmt = `date +%H_%M_%S`
set scriptlog = ${tst_dir}/${gtm_tst_out}/gtcm_command.log

echo "New command - '$argv' - $stamp" >>&! $scriptlog
# get local tst_dir directory structure
setenv host_test_dir `echo $tst_dir | sed 's/^\/testarea[0-9]*\/[A-Za-z0-9]*[/]*//'`
#
foreach gtcm_server ($tst_gtcm_server_list)
	# note down the remote server
	echo "Target host is : $gtcm_server" >>& $scriptlog

	set argv_new = "$argv"
	# get tst_remote_dir_gtcm_x
	eval 'setenv tst_remote_dir_gtcm $tst_remote_dir_'$x
	if ($?testname) then
		if ($?test_subtest_name) then
			setenv sec_dir_gtcm $tst_remote_dir_gtcm/$gtm_tst_out/$testname/$test_subtest_name
		else
			setenv sec_dir_gtcm $tst_remote_dir_gtcm/$gtm_tst_out/$testname/tmp
		endif
		set argv_new = `echo "$argv_new" | sed "s,SEC_DIR_GTCM,$sec_dir_gtcm,g"`
		setenv SEC_DIR_GTCM_$x $sec_dir_gtcm
		setenv sec_getenv_gtcm "source $gtm_tst/com/remote_getenv.csh $sec_dir_gtcm"
		set argv_new = `echo "$argv_new" | sed "s,SEC_GETENV_GTCM,$sec_getenv_gtcm,g" `
	endif
	# Make sure we can talk IPv6 to the secondary, and scrub the v6 suffix if we can't.
	eval 'if (\! $?host_ipv6_support_'${HOST:r:r:r:r}') set host_ipv6_support_'${HOST:r:r:r:r}'=0'
	if (! `eval echo \$host_ipv6_support_${HOST:r:r:r:r}`) then
		if ($gtcm_server =~ *.v6*) then
			echo "Removing v6 from gtcm_server '$gtcm_server' due to missing IPv6 on current host '$HOST'" >>& $scriptlog
			set gtcm_server=${gtcm_server:s/.v6//}
		endif
	endif
	setenv sec_shell_gtcm "$rsh $gtcm_server "
	setenv tst_remote_host_gtcm "$gtcm_server"
	# the _x versions of the above:
	setenv tst_remote_dir_gtcm_$x $tst_remote_dir_gtcm
	setenv tst_remote_host_$x $tst_remote_host_gtcm

	if ("$argv_new" =~ *PORTNO_DEFINED_GTCM*) then
		setenv portno_gtcm `cat gtcm_portno_$x.txt`
		set argv_new = `echo "$argv_new" | sed "s,PORTNO_DEFINED_GTCM,$portno_gtcm,g"  `
	endif
	if ("$argv_new" =~ *PORTNO_GTCM*) then
		setenv portno_gtcm `$sec_shell_gtcm "$sec_getenv_gtcm;cd $sec_dir_gtcm; source $gtm_tst/com/portno_acquire.csh"`
		if ("" == "$portno_gtcm") echo "TEST-E-PORTNO_GTCM"
		echo "gtcm port : $portno_gtcm" >>& $scriptlog
		$sec_shell_gtcm "$sec_getenv_gtcm; cd $sec_dir_gtcm; if (-e gtcm_portno.txt) mv gtcm_portno.txt gtcm_portno.txt_$datefmt ; echo $portno_gtcm >! gtcm_portno.txt" >>& $scriptlog
		if ($status != 0) echo "$sec_shell_gtcm did not succeed" >>& $scriptlog

		if (-e gtcm_portno_$x.txt) mv gtcm_portno_$x.txt  gtcm_portno_$x.txt_$datefmt
		echo $portno_gtcm >>& gtcm_portno_$x.txt
		set rmthost = ${tst_remote_host_gtcm:ar}
		# ###########################################################################################
		# Test [YDBTest#559] [GTM-9425] $GTCM_<node-name> accepts "host-name:port-number"
		# This is done by randomly setting GTCM_nodename env var to hostname:port or [hostname]:port
		set rand = `$gtm_tst/com/genrandnumbers.csh 1 0 1`	# choose 1 random number between 0 and 1 (both included)
		set hostname = "${tst_remote_host_gtcm}"
		if ($rand == 1) then
			set hostname = "[$hostname]"
		endif
		# ###########################################################################################
		source $gtm_tst/com/set_ydb_env_var_random.csh ydb_cm_${rmthost} GTCM_${rmthost} "${hostname}:${portno_gtcm}"
		set argv_new = `echo "$argv_new" | sed "s,PORTNO_GTCM,$portno_gtcm,g"  `
	endif
	# , is used instead of / since there are /'s in the environment variables (but not commas, I hope`)
	set argv_new = `echo "$argv_new" | sed "s,TST_REMOTE_DIR_GTCM,$tst_remote_dir_gtcm,g" | sed "s,SEC_SHELL_GTCM,$sec_shell_gtcm,g"  | sed "s,TST_REMOTE_HOST_GTCM,$tst_remote_host_gtcm,g" `
	# save the GTCM command to a log file for failure processing
	echo "The resulting command is - '$argv_new'" >>& $scriptlog
	$argv_new |& tee -a $scriptlog
	set tmpstatus = $status
	if ( 0 != $tmpstatus ) then
		echo "GTCMCOMMAND-E-FAIL $gtcm_server : $tmpstatus" | tee -a $scriptlog
	else
		echo "GTCMCOMMAND-I-PASS $gtcm_server" >>& $scriptlog
	endif
	echo "" >>& $scriptlog
	@ x = $x + 1
end
