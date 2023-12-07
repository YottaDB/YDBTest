#################################################################
#								#
# Copyright (c) 2003-2014 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#######################################
### UNIX Call-ins mechanism tests   ###
#######################################
# maxstrlen		[mohammad] 	Supporing local variable up to 1MB (D9D06-002345).
# multi_gtm_init	[s7mj] 		Subtest for testing more than one set of gtm_init/gtm_exit per process.
# gtm_percent		[laurent]	support call in with M label starting with % (C9E12-002681).
# gtm_cip		[rajendrk]	Performance improved version of gtm_ci.
# timers		[sopini]	Verify the operation of gtm_start_timer and gtm_cancel_timer operations.
# empty_table		[sopini]	Ensure that providing an empty table file does not cause SIG-11s.
# stack_leak		[sopini]	Ensure that call-ins do not leak M stack when gtmci_init() is called repeatedly.
# environment		[estess]	Test $VIEW("ENVIRONMENT") for MUPIP/CALLIN/TRIGGER values
# test_rtn_replace	[estess]	Verify no explosions when routine hiding behind call-in frame is replaced
# test_mprof_hidden_rtn [estess]	Verify M-Profiling functions correctly when routine is hidden behind a call-in frame
# test_ci_z_halt	[estess]	Verify [Z]HALT in a call-in returns to caller instead of actually halting
# test_ci_goto0		[estess]	Verify ZGOTO 0 in a call-in returns to caller after algorithmic change
# test_ci_z_halt_rc     [estess]        Verify return values when frames exited by HALT/ZHALT/ZGOTO 0/QUIT work correctly.
# ydbaccess_ci          [sam]           Run ProgrammersGuide/extrout.html ydbaccess_ci example
# ydbaccess_cip         [sam]           Run ProgrammersGuide/extrout.html ydbaccess_cip example
# ydbreturn_ci          [sam]           Run ProgrammersGuide/extrout.html ydbreturn_ci example
#
# Options to record Load Path in executables. Similar options needed for OS390 platform
setenv subtest_exclude_list ""
setenv unicode_testlist "unic2m2c2m unimaxstrlen"
#
setenv subtest_list_common ""
setenv subtest_list_non_replic "32args argcnt c_args ctomctom ctomtom gtm_args gtm_errors gtm_exit_err lngargs maxnstlvl nest_err nest_err_et"
setenv subtest_list_non_replic "$subtest_list_non_replic nest_err_et2 nest_err_et3 nest_err_zt nest_err_zt2 nest_err_zt3 maxstrlen gtmxc_test_types"
setenv subtest_list_non_replic "$subtest_list_non_replic xc_test_types multi_gtm_init gtm_percent gtm_cip timers empty_table stack_leak"
setenv subtest_list_non_replic "$subtest_list_non_replic test_rtn_replace test_mprof_hidden_rtn test_ci_z_halt test_ci_zgoto0 test_ci_z_halt_rc"
setenv subtest_list_non_replic "$subtest_list_non_replic ydbaccess_ci ydbaccess_cip ydbreturn_ci ydbxc_test_types"
setenv subtest_list_replic "environment"

if ("TRUE" == $gtm_test_unicode_support) then
	## Unicode supported machine
	setenv subtest_list_non_replic "$subtest_list_non_replic $unicode_testlist"
endif

if (1 == $gtm_test_trigger) then
	setenv test_specific_trig_file "$gtm_tst/$tst/inref/callins.trg"
endif

# filter out some subtests for some servers
set hostn = $HOST:r:r:r
# Disable unic2m2c2m subtest on platforms that do not support 4 byte unicode characters
if ("1" == "$gtm_platform_no_4byte_utf8") then
	setenv subtest_exclude_list "unic2m2c2m"
endif

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
	setenv subtest_exclude_list "$subtest_exclude_list environment"		# Don't run this without replic or it fails
endif

if ( "os390" == $gtm_test_osname ) then
	# Save the normal LIBPATH and append the desired paths for call ins to work
	set old_libpath=${LIBPATH}
	setenv LIBPATH ${tst_working_dir}:${gtm_exe}:.:${LIBPATH}
	# Apparently on z/OS the the sidedeck must be specified for the call out DLL
	setenv tst_ld_sidedeck "-L$gtm_dist $tst_ld_yottadb"
else
	setenv tst_ld_sidedeck ""
endif

$gtm_tst/com/submit_subtest.csh

if ( "os390" == $gtm_test_osname ) then
	# Restore the normal LIBPATH
	setenv LIBPATH $old_libpath
	unsetenv tst_ld_sidedeck
endif

echo "CALL IN tests DONE"
