#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
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
# mupipstop_readlineterm-ydb1128	[jon]		Test MUPIP STOP terminates DSE/LKE/MUPIP even if they hold a critical section when ydb_readline=1
# mureorgupgrade-ydb1027		[jon]		Test 2 MUPIP REORG -UPGRADE test cases for YDB#1027
# remove_stpmove-ydb1673		[jon]		Test remove unnecessary stp_move() call when linking multiple copies of same routine
# stp_gcol_nosort-ydb1145		[nars]		Test VIEW "STP_GCOL_NOSORT", $VIEW("STP_GCOL_NOSORT"), $VIEW("SPSIZESORT") and ydb_stp_gcol_nosort
# encode_decode_simpleapi-ydb474	[bdw,david]	Test ydb_encode_s(), ydb_decode_s(), and their threaded variants
# ztrigger_t_tries-ydbMR1702		[nars]		Test $ztrigger("item") clears t_tries in case of errors
# gvcst_expand_any_key-ydb1027		[nars]		Test MUPIP REORG -MIN_LEVEL=1 does not assert fail in gvcst_expand_any_key.c
# ydbcitab_norestore-ydb1161		[jon]		Test %YDB-E-CITABENV error is not issued when calling an M function via a function handle returned by a previous call to ydb_cip_t
# boolean_envvars-ydb1150		[jon]		Test Boolean environment variables only accept substrings of yes, no, true, and false, but not superstrings
# GDE_CTRLc-ydb883		        [ben]		Test that <Ctrl+c> in GDE interface exits environment
# gvdbnakedmismatch_mergelock-ydb665	[jon]		Test of GVDBGNAKEDMISMATCH errors from MERGE and LOCK command
# ydbcliops-ydb1102			[jon]		Test enhancements to yottadb CLI options
# mupipload_zwrlgbin-ydb1172		[jon]		Test of MUPIP LOAD accepts ZWR format extracts that contain large binary data
# mupgrade_jnlmissing-ydb1018		[jon]		Test of MUPIP UPGRADE for 3 scenarios when journal file is missing
# valtoobig-ydb1130			[ben]		Test that allocation=7340026 autoswitchlimit=7340025 gives VALTOOBIG error
# jobcmdslow_gtm9058-ydb1181		[nars]		Test JOB command is not slow and other JOB command tests
# rtnlaboff-ydbMR1762			[jon]		Test RTNLABOFF error message replacement for JOBLABOFF
# zgetjpi_cmdline-ydb876		[ben]		Test that $ZGETJPI(PID,keyword) with keyword CMDLINE gives the command line of the indicated process
# large_block_backup-ydb1169		[ben]		This is a test to ensure that you  can create a backup of a database with a large block size. The size 50176 is used.
# empty_routine-ydb1184			[ben]		Test mumps -run with empty routine name produces the correct error
# mutex_type-ydb1178			[nars]		Various tests of MUTEX_TYPE being YDB, PTHREAD or ADAPTIVE
# rundown_file_not_found-ydb1154	[ben]		Test that mupip rundown runs successfully even if the file pointed to by gtm_repl_instance/ydb_repl_instance does not exist.
# fallintoflst-ydb1142			[ben]		Test that that FALLINTOFLST compile time warning occurs and that compiler finishes compilation without issue.
# socketspinloop-ydb1195		[jon]		Test that WRITE /WAIT on socket device with multiple listening sockets return even with a timeout
# mcomm_deserialize-ydb1152		[jon]		Test M commands to serialize/deserialize local or global variable subtree
# duplicatenew_warning-ydb1111		[ben]		Test that mumps compiler correctly gives a DUPLICATENEW warning when attempting to new a variable twice on the same line.
# nakedref_varsubs-ydb1177		[jon]		Test naked reference optimization if GVN subscripts are unsubscripted local variables'
# mupipbackup_brokenfile-ydb1202	[jon]		Test MUPIP BACKUP -ONLINE does not produce broken backup file
# c_clear_err_buff-ydb1180		[ben]		Test that $ECODE properly reset after ydb_ci[p]_t or (ydb|gtm)_ci[p] is called.
# job_cmdline_dash-ydb933		[ben]		Test that JOB command can have a command line where an input starts with a dash without issue.
# mupip_terminal_prompts-ydb917		[ben]		Test that various mupip commands will no longer say that they accept a file or region when invoked without arguments.
# unblock_signals_during_init-ydb1205	[david]		Test that signal initialization unblocks signals in a parent process signal mask
# generated_from_msg-ydb858		[ben]		Test that send_msg_va now includes the <entrypoint>+<offset> format or the symbolic name of the calling function in error msg.
#----------------------------------------------------------------------------------------------------------------------------------

echo "r204 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	""
setenv subtest_list_non_replic	"$subtest_list_non_replic view_statshare-ydb254"
setenv subtest_list_non_replic	"$subtest_list_non_replic zshow_v-ydb873"
setenv subtest_list_non_replic	"$subtest_list_non_replic get_src_line"
setenv subtest_list_non_replic	"$subtest_list_non_replic naked_refs-ydb665"
setenv subtest_list_non_replic	"$subtest_list_non_replic gtm-v71001"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollar_translate-ydb1129"
setenv subtest_list_non_replic	"$subtest_list_non_replic machine-ydb1133"
setenv subtest_list_non_replic	"$subtest_list_non_replic dollar_zycompile-ydb1138"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupipstop_readlineterm-ydb1128"
setenv subtest_list_non_replic	"$subtest_list_non_replic mureorgupgrade-ydb1027"
setenv subtest_list_non_replic	"$subtest_list_non_replic remove_stpmove-ydb1673"
setenv subtest_list_non_replic	"$subtest_list_non_replic stp_gcol_nosort-ydb1145"
setenv subtest_list_non_replic	"$subtest_list_non_replic encode_decode_simpleapi-ydb474"
setenv subtest_list_non_replic	"$subtest_list_non_replic ztrigger_t_tries-ydbMR1702"
setenv subtest_list_non_replic	"$subtest_list_non_replic gvcst_expand_any_key-ydb1027"
setenv subtest_list_non_replic	"$subtest_list_non_replic ydbcitab_norestore-ydb1161"
setenv subtest_list_non_replic	"$subtest_list_non_replic boolean_envvars-ydb1150"
setenv subtest_list_non_replic	"$subtest_list_non_replic GDE_CTRLc-ydb883"
setenv subtest_list_non_replic	"$subtest_list_non_replic gvdbnakedmismatch_mergelock-ydb665"
setenv subtest_list_non_replic	"$subtest_list_non_replic ydbcliops-ydb1102"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupipload_zwrlgbin-ydb1172"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupgrade_jnlmissing-ydb1018"
setenv subtest_list_non_replic	"$subtest_list_non_replic valtoobig-ydb1130"
setenv subtest_list_non_replic	"$subtest_list_non_replic jobcmdslow_gtm9058-ydb1181"
setenv subtest_list_non_replic	"$subtest_list_non_replic rtnlaboff-ydbMR1762"
setenv subtest_list_non_replic	"$subtest_list_non_replic zgetjpi_cmdline-ydb876"
setenv subtest_list_non_replic	"$subtest_list_non_replic large_block_backup-ydb1169"
setenv subtest_list_non_replic	"$subtest_list_non_replic empty_routine-ydb1184"
setenv subtest_list_non_replic	"$subtest_list_non_replic rundown_file_not_found-ydb1154"
setenv subtest_list_non_replic	"$subtest_list_non_replic fallintoflst-ydb1142"
setenv subtest_list_non_replic	"$subtest_list_non_replic socketspinloop-ydb1195"
setenv subtest_list_non_replic	"$subtest_list_non_replic mcomm_deserialize-ydb1152"
setenv subtest_list_non_replic	"$subtest_list_non_replic duplicatenew_warning-ydb1111"
setenv subtest_list_non_replic	"$subtest_list_non_replic nakedref_varsubs-ydb1177"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupipbackup_brokenfile-ydb1202"
setenv subtest_list_non_replic	"$subtest_list_non_replic c_clear_err_buff-ydb1180"
setenv subtest_list_non_replic	"$subtest_list_non_replic job_cmdline_dash-ydb933"
setenv subtest_list_non_replic	"$subtest_list_non_replic mupip_terminal_prompts-ydb917"
setenv subtest_list_non_replic	"$subtest_list_non_replic unblock_signals_during_init-ydb1205"
setenv subtest_list_non_replic	"$subtest_list_non_replic generated_from_msg-ydb858"

setenv subtest_list_replic	""
setenv subtest_list_replic	"$subtest_list_replic mutex_type-ydb1178"
# setenv subtest_list_replic	"$subtest_list_replic mupipbackup_brokenfile-ydb1202"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
if ("$gtm_test_dynamic_literals" == "DYNAMIC_LITERALS") then
	# Disable this test if dynamic literals are enabled, since the optimization under test will not be performed,
	# causing spurious test failures.
	setenv subtest_exclude_list "$subtest_exclude_list nakedref_varsubs-ydb1177"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r204 test DONE."
