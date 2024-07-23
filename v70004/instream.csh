#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------
# sub_level_map_hide-gtmde270421       [ern0]   Correct navigation when subscript-level mapping "hides" data
# select_boolean_assert-gtmde308470    [ern0]   GTMASSERT2 fatal error when ydb_side_effects/gtm_side_effects env var is 1 and $SELECT is used in a boolean expression
# select_op_order-gtmde308470          [berwyn] Preserve left-to-right evaluation within $SELECT() when using FULL_BOOLEAN compilation
# restrict_lke_clear-gtmf135380        [ern0]   Verify LKE restrictions file behaviour for LKE CLEAR command
# socket_open_mupip_stop-gtmde297205   [nars]   MUPIP STOP in the midst of SOCKET OPEN does not produce GTMASSERT2 fatal error
# dollar_ztslate_stp_gcol-gtmde305529  [nars]   $ZTSLATE value is protected amidst garbage collection
# socket_use_ioerror_sig11-gtmde307442 [nars]   SOCKET USE command with CONNECT/LISTEN and IOERROR="T" does not SIG-11
# retry_norm-gtmf166755                [pooh]   MUPIP BACKUP retry normalization
#----------------------------------------------------------------------------------------------------------------------------------

echo "v70004 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""

setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic sub_level_map_hide-gtmde270421"
setenv subtest_list_non_replic	"$subtest_list_non_replic select_boolean_assert-gtmde308470"
setenv subtest_list_non_replic	"$subtest_list_non_replic select_op_order-gtmde308470"
setenv subtest_list_non_replic	"$subtest_list_non_replic restrict_lke_clear-gtmf135380"
setenv subtest_list_non_replic	"$subtest_list_non_replic socket_open_mupip_stop-gtmde297205"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollar_ztslate_stp_gcol-gtmde305529"
setenv subtest_list_non_replic	"$subtest_list_non_replic socket_use_ioerror_sig11-gtmde307442"
setenv subtest_list_non_replic	"$subtest_list_non_replic retry_norm-gtmf166755"

setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v70004 test DONE."
