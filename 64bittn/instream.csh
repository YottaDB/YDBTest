#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#####################################################
# D9E03-002438 - 64 Bit Transaction Number
#####################################################
# read_only         	[Mohammad]
# rolling_upgrade   	[Mohammad]
# mupip_upgrd_dwngrd 	[Balaji]
# mu_reorg_upgrd_dwngrd [Balaji]
# dbcertify 		[Balaji]
# mupip_journal 	[Balaji]
# vermismatch 		[Balaji]
# mupip_integ 		[Balaji]
# mupip_create 		[Balaji]
# mupip_backup_restore 	[Balaji]
# basic			[kishore]
# mupip_set_version	[kishore]
# blks_to_upgrade	[kishore]
# extract_upg_downg	[kishore]
# dse_commands		[kishore]
# D9F07002556		[narayanan]
echo "64 Bit Transaction Number tests starts ..."
# Encryption needs to disabled for this test as it deals with v4 db format most of the places
setenv test_encryption_orig $test_encryption
if ("ENCRYPT" == "$test_encryption" ) then
	setenv test_encryption NON_ENCRYPT
endif
# MM access method works well only from versions V5.3-002. Since most of the subtests need V4 version, force BG
source $gtm_tst/com/gtm_test_setbgaccess.csh
# set the following env. var as this test handles the desired db block format itself
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn 1
###################################################################################
# For 64 bit tests we have to pick & random V4 version & use them for all sub-tests
# the script has to be sourced to carry the random value to the test
# output of the script will be in variable v4ver
#
if ($?gtm_test_replay) then
	source $gtm_test_replay
else
	# Over time, we have seen certain random setting values expose GTM-5873 so want to test those
	# more frequently than they would normally be exercised (if we let them be chosen by the default
	# randomization, it might take years for this to be exercised). We know of two settings that triggered
	# GTM-5873 so include those here. And run them each 10% of the time. And run randomized for 80% of the rest
	# (i.e. dirtrand/gvtrand will be chosen randomly inside setdirt^upgrdtst and setgvt^upgrdtst).
	set randno = `$gtm_exe/mumps -run rand 10`
	if ($randno == 1) then
		# Settings that exposed GTM-5873 (C9G04-002790) : Apr 2006
		setenv rand_collation 1
		setenv dirtrand 5225
		setenv gvtrand 31711
		setenv v5cert_randno 1
		setenv jnl_rand 71
		setenv dirtrand1 2885
		setenv gvtrand1 21097
	else if ($randno == 2) then
		# Settings that exposed regression in GTM-5873 (C9G04-002790) : Mar 2015
		setenv rand_collation 0
		setenv dirtrand 9541
		setenv gvtrand 20722
		setenv v5cert_randno 1
		setenv jnl_rand 48
		setenv dirtrand1 405
		setenv gvtrand1 30609
	endif
	if !( $?gtm_platform_no_V4 ) then
	        setenv v4ver `$gtm_tst/com/random_ver.csh -type V4`
		if ( "$v4ver" =~ "*-E-*") then
			# This will cause the test to fail, but the subtests should all pass
			echo "There are no V4 versions. Dynamically setting gtm_platform_no_V4"
			setenv gtm_platform_no_V4 1
			echo "setenv gtm_platform_no_V4 1" >> settings.csh
		else
			echo "setenv v4ver $v4ver" >> settings.csh
		endif
	endif
endif

####################################################################################
## set env. vars to switch version in the tests ( to be used in all sub-tests)
setenv sv5 "source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image"
#
setenv DBCERTIFY "$gtm_exe/dbcertify"
setenv MUPIPV5 "env gtm_dist=$gtm_exe $gtm_exe/mupip"
####################################################################################
# setup the env var to switch to the target V4 version
# Prepare too-full blocks database using v4dbprepare.csh
# save and use it for all the sub-tests below
# Not required for 64bit machines and replic test
if ( !($?test_replic) && !($?gtm_platform_no_V4) ) then
	setenv sv4 "source $gtm_tst/com/switch_gtm_version.csh $v4ver $tst_image"
	$sv4
	mkdir ../dbprepare
	cd ../dbprepare
	echo "# chosen V4 VERSION FOR this 64bittn test run is "$v4ver >>&! v4dbprepare.log
	source $gtm_tst/$tst/u_inref/v4dbprepare.csh >>&! v4dbprepare.log
	cd -
	$sv5
endif
####################################################################################
##
setenv subtest_list_common ""
if ( $?gtm_platform_no_V4 ) then
	setenv subtest_list_non_replic "basic mupip_journal mupip_integ dse_commands "
else
	setenv subtest_list_non_replic "basic dbcertify mupip_upgrd_dwngrd vermismatch read_only blks_to_upgrade extract_upg_downg D9F07002556 "
	setenv subtest_list_non_replic "$subtest_list_non_replic mupip_journal mupip_integ dse_commands mu_reorg_upgrd_dwngrd mupip_create mupip_backup_restore mupip_set_version "
endif
setenv subtest_list_replic     "rolling_upgrade"
#
######################################################
if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
######################################################
setenv subtest_exclude_list ""
# filter out some subtests for some servers
set hostn = $HOST:r:r:r
#
$gtm_tst/com/submit_subtest.csh
unsetenv v4ver
echo "64 Bit Transaction Number tests ends"
