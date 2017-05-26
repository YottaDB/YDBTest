#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Basic preparation for the test
# randomly chose collation, copy yes.txt, find the endian, disable setversion and randomdbtn
if ( !( $?gtm_test_replay || $?endiancvt_col_rand ) ) then
	setenv endiancvt_col_rand `$gtm_exe/mumps -run rand 2`
	echo "setenv endiancvt_col_rand $endiancvt_col_rand"	>> settings.csh
endif
if ($endiancvt_col_rand) then
	source $gtm_tst/com/cre_coll_sl_reverse.csh 1
	$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cat $gtm_tst/com/cre_coll_sl_reverse.csh >&! coll_env.csh"
	setenv coll_arg '-coll=1'
	setenv test_collation_no 1
	# If it is a 64 bit gtm, libreverse library should be recompiled.
	# $tst_general_dir/run_cre_coll_sl_reverse.txt signals switch_gtm_version.csh to call cre_coll_sl_reverse.csh again
	if ("64" == "$gtm_platform_size") echo "1" >&! $tst_general_dir/run_cre_coll_sl_reverse.txt
else
	$sec_shell "$sec_getenv ; cd $SEC_SIDE ; echo '/usr/local/bin/tcsh -f' >&! coll_env.csh"
	setenv coll_arg ''
endif
echo "coll_arg value: $coll_arg" > coll_option.log
cp $gtm_tst/$tst/inref/yes.txt .
$rcp yes.txt "$tst_remote_host":$SEC_SIDE
# If the local and remote endian is not already determined.
if !($?endian_local) then
	if ("BIG_ENDIAN" == "$gtm_endian") then
		# Big Endian
		setenv endian_local BIG
		setenv endian_remote LITTLE
	else
		# Little Endian
		setenv endian_local LITTLE
		setenv endian_remote BIG
	endif
endif
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
