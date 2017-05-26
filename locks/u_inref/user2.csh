#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set ver = `basename $gtm_ver`
set img = `basename $gtm_dist`
source $gtm_tst/com/set_specific.csh
$gtm_tst/com/send_env.csh

# user2.csh is called more than once. Remove mumps_remote_dat_key if already exists
if (-e mumps_remote_dat_key) \rm -f mumps_remote_dat_key
if ( "ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/encrypt_for_gtmtest1.csh mumps_dat_key mumps_remote_dat_key
endif

if ( "gtm8157" == "$1" ) then
	$rsh $tst_org_host -l $gtmtest1 $gtm_tst/$tst/u_inref/gtm8157.csh $ver $img $tst_working_dir $gtm_tst >&! remote_user_gtm8157.log &
else
	$rsh $tst_org_host -l $gtmtest1 $gtm_tst/$tst/u_inref/remote_user.csh $ver $img $tst_working_dir $gtm_tst >& remote_user.log &
endif
