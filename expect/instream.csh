#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
# rx0 			[shaha] 	The READ x:0 test
# gtm4661 		[bahirs] 	GT.M process does not stuck if terminated with SIGTERM signal.
#					GT.M process sends only one SUSPENDING messages after receiving SIGTSTP signal.
# contjnlbufwriter 	[bahirs] 	Verify that process sends CONT signal to JNLBUF writer.
# dlrkey 		[bahirs] 	Test that on completion of a READ from a terminal device,
#					$KEY has the same value as $ZB.
# D9F05002548		[shaha]		Verify that terminal editing key presses do not terminate a READ.
# zshowempterm		[bahirs] 	Verify EMPTERM deviceparameter is properly shown in the zshow "d" output
# tterase  		[bahirs]	Verify the effect ERASE, BACKSAPCE and DELETE key on empty and noempty terminal with various
# 					combinations of [NO]EMPTERM, [NO]ESCAP and [NO]EDIT deviceparameters.
# erasebs 		[bahirs] 	Verify that special terminal input character ERASE and BACKSPACE key behave correctly, when
# 					they have different values, in presence of EMPTERM device parameter
# gtm6449               [base]          Verify that the delete key deletes the character on the cursor and it works when not defined in the terminfo database
# gtm7994		[base]		Verify that the application terminators do not affect direct mode if DMTERM is specified
# gtm7993		[base]		Verify that the arrow keys work with vt220 emulator
# gtm8232		[base]		Verify piping MUPIP output into "more" does not break the terminal characteristics if CTRL-C'ed
# terminal		[shaha]		Test of various terminal capabilities: GT.M processes respond to control-C, $Y management, printing 36K of bytes
# terminal5		[shaha]		Verify terminal screen redraws using screen
# ctrlc			[shaha]		Verify that MUMPS and LKE handle control-C as expected
# gtm7658		[partridger]	Test of $principal state after running ^%RI
# gtm8223		[partridger]	Test of $principal state after running ^%GI
# maskpass_term		[sopini]	Ensure that maskpass does not mess up the terminal settings.
# C9K05003274		[shaha]		Verify that we can mix MUPIP INTRPT and Control-C
#-------------------------------------------------------------------------------------

echo "expect test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "rx0 gtm4661 contjnlbufwriter dlrkey D9F05002548 zshowempterm tterase erasebs gtm6449 gtm7994"
setenv subtest_list_non_replic "${subtest_list_non_replic} gtm7993 gtm8232 terminal terminal5 ctrlc gtm7658 gtm8223 maskpass_term"
setenv subtest_list_non_replic "${subtest_list_non_replic} C9K05003274"
setenv subtest_list_replic     ""
setenv subtest_exclude_list     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled) then
	# We see cores when ASAN is used with tests that send signals (gtm4661 sends SIGTERM etc.)
	# This happens whether YottaDB is compiled with gcc or clang.
	# And the stack traces are inside ASAN code where a SIG-11 occurs as well.
	# Not yet sure if it is an ASAN issue or a YottaDB issue inside the signal handler.
	# Exclude this subtest until we can find time to investigate this further.
	# The same test runs fine without ASAN and so is enabled in that case.
	setenv subtest_exclude_list "$subtest_exclude_list gtm4661"
endif

# filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
        setenv subtest_exclude_list "$subtest_exclude_list contjnlbufwriter"
endif

if ($?ydb_readline) then
	# Right now, the readline implementation does not support stopping reads at terminators
	# Disable this test until we switch to use the Readline callback interface, which will
	# allow us to read character by character and handle terminators
	# This is tracked at https://gitlab.com/YottaDB/DB/YDB/-/issues/1039
	if ( "0" != $ydb_readline ) then
		setenv subtest_exclude_list "$subtest_exclude_list gtm7994"
	endif
endif

# Use sed filters to remove subtests that are to be disabled on a particular host or OS
if ("HOST_OSF1_ALPHA" != "$gtm_test_os_machtype") then
	# Submit the list of subtests
	$gtm_tst/com/submit_subtest.csh
endif

echo "expect test DONE."
