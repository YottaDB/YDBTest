#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# use  with same_user.csh (same user) or other_user.csh (gtmtest1) to run an arbitrary M routine (specified in $4)
# call with: second_process.csh ver image directory m_routine

echo $*
echo "User Name          : " `whoami`
echo "Version            : " $1
echo "Image              : " $2
if ("" == "$4") then
	echo "TEST-E-NOARG don't know what to run, exiting..."
	exit
endif
set dom = $4
echo "Will run           : $dom"

cd $3
# since $gtm_tst is not defined at this moment, use V990:
source $gtm_test/T990/com/remote_getenv.csh $3
# Below "version" alias use would error out in a non-GG (i.e. YDB) setup.
# But we don't need to worry about it for now because the mupjnl subtests that call this script
# are currently disabled due to $?gtm_test_noggusers being non-zero (in mupjnl/instream.csh).
version $1 $2
echo $gtm_exe
setenv GTM "$gtm_exe/mumps -direct"
pwd
setenv gtmgbldir "mumps.gld"
# Since this script will be called for both the current user as well as the gtmtest1 user, we would do the encryption settings for
# the remote user (gtmtest1) only if the below condition is satisfied.
if ( $USER == "$gtmtest1" ) then
	$gtm_tst/com/set_gtmtest1_encr_settings.csh	\
		encr_env_remote_user.csh		\
		$tst_working_dir/mumps.dat		\
		$tst_working_dir/mumps_remote_dat_key	\
		$tst_working_dir/remote_gtmcrypt.cfg	\
		$tst_working_dir/db_remote_mapping_file
	source $tst_working_dir/encr_env_remote_user.csh
endif
cp $gtm_tst/$tst/inref/${dom}.m  dom.m
$GTM << \USER2 >&! gtm_output.out
s f="USER2PID"_+$ztrnlnm("gtm_test_jobid")_".mjo"
o f u f
w "PID ",$J,!
c f
u $P
w "$ZV = ",$ZV,!
w "start...",!
w "$H = ",$H,!
d ^dom
ZTS
s (^aact,^bact,^cact,^dact)="ACTIVE ZTP"
w "in active ztp...",!
w "$H = ",$H,!
s ^sema1="done"
view "JNLFLUSH"
for i=1:1:240 quit:$data(^done)  h 3 view "JNLFLUSH"
if i=80 w "TEST-E-TIMEOUT: Timed out: user1 has not set ^done ",$H,!
w "end..."
w "$H = ",$H,!
ZTC
s ^sema2=1
view "JNLFLUSH"
h
\USER2
cat gtm_output.out
echo "The date is: "`date`
echo "End of second_process job!"
chmod g+w dom.*
