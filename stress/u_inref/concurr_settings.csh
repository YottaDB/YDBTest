#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script contains environment settings for concurr.csh and concurr_small.csh
# Since both the subtests are almost the same, any change to settings will always happen to both subtests
# Any setting specific to one of the subtests should be handled either in the subtest or in the correponding section in this script

setenv gtm_gvundef_fatal 1	# want assert failures in case of GVUNDEF errors
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn 1

if ($tst_buffsize < 4194304 ) then
	setenv tst_buffsize 4194304
endif

# When run in encrypt mode, stress test mupip reorg -encrypt using 3 keys
if ("ENCRYPT" == $test_encryption) then
	setenv gtm_test_eotf_keys 3
endif

if (! $?gtm_test_replay) then
	# Randomly choose
	# mupip reorg upgrade/downgrade
	#          (or)
	# mupip reorg encrypt (and/or) online integ [downgrade is not compatible with reorg encrypt or online integ (because of V4 blocks)]
	@ rand = `$gtm_exe/mumps -run rand 5`
	# If rand = 0,1 -> do upgrade/downgrade
	# If rand = 2,3 -> do eotf
	# if rand = 3,4 -> do oli
	# Note that if rand is 3 -> both eotf and oli is done.
	if ( (1 >= $rand) && ("BG" == "$acc_meth") ) then
		set choose_updown = 1
		# If MUPIP REORG UPGRADE/DOWNGRADE is running, it might leave the database with V4 format blocks towards the end of the test
		# and the dbcheck will error out with SSV4NOALLOW. So, set gtm_test_online_integ to "-noonline"
		setenv gtm_test_online_integ "-noonline"
		echo "setenv choose_updown $choose_updown"			>> settings.csh
		echo "setenv gtm_test_online_integ $gtm_test_online_integ"	>> settings.csh
	else
		if ( ( 3 >= $rand) && ("ENCRYPT" == "$test_encryption") ) then
			set choose_eotf = 1
			echo "setenv choose_eotf $choose_eotf"			>> settings.csh
		endif
		if ( 3 <= $rand) then
			set choose_oli = 1
			echo "setenv choose_oli $choose_oli"			>> settings.csh
		endif
	endif
	if ($?choose_eotf) then
		# Each reorg encrypt causes 2 switches of journal files. Since it is done continuously in a loop,
		# it results in a lot of journal files for the source server to read. Until GTM-4928 is fixed, limit alignsize to 32768 (16MB)
		# 16MB because, at least one test failed with 32MB align size. (Few with 128MB and almost all failures analyzed were with 256MB)
		if (32768 < $test_align) then
			setenv test_align 32768
			set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
			setenv tst_jnl_str $tstjnlstr
			echo '# tst_jnl_str modified by subtest'	>> settings.csh
			echo "setenv tst_jnl_str $tstjnlstr"		>> settings.csh
		endif
	endif
	set blksz = `$tst_awk -F = '/block_size=/ {if (max < $NF) max=$NF} END{print max}' $gtm_tst/$tst/u_inref/*stress_*.gde`
	@ align_bytes = `expr $test_align \* 512`
	if ($blksz >= $align_bytes) then
		while ($blksz >= $align_bytes && $test_align < 4194304)
			@ test_align = `expr $test_align \* 2`
			@ align_bytes = `expr $test_align \* 512`
		end
		set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
		setenv tst_jnl_str $tstjnlstr
	endif
	# is_syncio has been randomly set by instream.csh to either "" or ",sync_io"
	setenv tst_jnl_str "${tst_jnl_str}${is_syncio}"
	echo "setenv tst_jnl_str $tst_jnl_str"					>> settings.csh
	# Do the below only for concurr subtest
	if ("concurr" == "$test_subtest_name") then
		set concurr_randdbg = `$gtm_exe/mumps -run rand 2`
		echo "# Randomly switch to dbg image of mupip when running with pro"	>>&! settings.csh
		echo "setenv concurr_randdbg $concurr_randdbg"				>>&! settings.csh
	endif
endif
