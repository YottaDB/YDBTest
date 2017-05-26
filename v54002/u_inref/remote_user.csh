#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_com/gtm_cshrc.csh
setenv gtm_tst $4
source $gtm_tst/com/remote_getenv.csh $3

version $1 $2
echo $gtm_exe
setenv GTM "$gtm_exe/mumps -direct"
cd $3
setenv gtmgbldir "mumps.gld"

# Generate script (encr_env_remote_user.csh) to be sourced so as to setup encryption environment for
# remote user (gtmtest1)
$gtm_tst/com/set_gtmtest1_encr_settings.csh	\
	encr_env_remote_user.csh		\
	$tst_working_dir/mumps.dat		\
	$tst_working_dir/mumps_remote_dat_key	\
	$tst_working_dir/remote_gtmcrypt.cfg	\
	$tst_working_dir/db_remote_mapping_file

source $tst_working_dir/encr_env_remote_user.csh

echo "Starting the second MUMPS process"
($gtm_exe/mumps -run %XCMD 'set ^b=1  view "JNLWAIT"' >&! simplewrite21.out & ; echo $! >! mumps21_pid.log) >&! bg_process21.out
$gtm_tst/com/wait_for_log.csh -log mumps21_pid.log
set pid_2 = `cat mumps21_pid.log`
$gtm_tst/com/wait_for_proc_to_die.csh $pid_2 240
echo "Done testing"
