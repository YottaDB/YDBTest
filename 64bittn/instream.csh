#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
# basic			[kishore]
# dse_commands		[kishore]
# mupip_journal 	[Balaji]
# mupip_integ 		[Balaji]
echo "64 Bit Transaction Number tests starts ..."
# set the following env. var as this test handles the desired db block format itself
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn 1
###################################################################################
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
endif

####################################################################################
## set env. vars to switch version in the tests ( to be used in all sub-tests)
setenv sv5 "source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image"
#
setenv DBCERTIFY "$gtm_exe/dbcertify"
setenv MUPIPV5 "env gtm_dist=$gtm_exe $gtm_exe/mupip"
####################################################################################
##
setenv subtest_list_common ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic basic"
setenv subtest_list_non_replic "$subtest_list_non_replic mupip_journal"
setenv subtest_list_non_replic "$subtest_list_non_replic mupip_integ"
setenv subtest_list_non_replic "$subtest_list_non_replic dse_commands "
setenv subtest_list_replic ""
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

# The below subtest uses DSE CHANGE -FILE -BLKS_TO_UPGRADE= and MUPIP SET -VERSION= both of which are not supported
# in GT.M V7.0-000 (YottaDB r2.00). Therefore disable it for now.
setenv subtest_exclude_list "$subtest_exclude_list mupip_integ"	# [UPGRADE_DOWNGRADE_UNSUPPORTED]

$gtm_tst/com/submit_subtest.csh
echo "64 Bit Transaction Number tests ends"
