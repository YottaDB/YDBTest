#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
###########################################################################
# D9E03-002438 - C9911-001317 Unicode, ISO/IEC-10646 Character Set Support
###########################################################################
# badchar			[Balaji]
# chset				[Balaji]
# errors			[Balaji]
# filenames			[Balaji]
# functions			[Balaji]
# gde				[Balaji]
# gtmroutines			[Balaji]
# limits			[Balaji]
# recompile			[Balaji]
# unicode_comments_literals	[Layek]
# unicode_job			[Layek]
# unicode_prompt		[Layek]
# unicode_simple_updates	[Layek]
# unicode_do			[Layek]
# unicode_misc			[Layek]
# unicode_dir			[Layek]
# unicode_piece			[Layek]
# unicodePatternTest		[Layek]
# unicodeZwritePattern		[Layek]
# d002577			[Layek]
# c001953			[Layek]
# repl_log			[Layek]
# unicode_tptype		[Layek]
# ugc2mpatcmap			[Bill] D9I05-002686
# gtm6858			[shaha] Use AIX's system ICU libraries and test GTM-7375 which allows more version numbers
# gtm8352                       [SEstes] Test UTF8 scan-cache logic for $FIND() and $EXTRACT() on strings in UTF8 mode
#
#all subtests will be run under UTF-8 (or can override explicitly)
echo "unicode test starts ..."
setenv subtest_list_common ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic badchar"
setenv subtest_list_non_replic "$subtest_list_non_replic chset"
setenv subtest_list_non_replic "$subtest_list_non_replic errors"
setenv subtest_list_non_replic "$subtest_list_non_replic filenames"
setenv subtest_list_non_replic "$subtest_list_non_replic gde"
setenv subtest_list_non_replic "$subtest_list_non_replic gtmroutines"
setenv subtest_list_non_replic "$subtest_list_non_replic limits"
setenv subtest_list_non_replic "$subtest_list_non_replic recompile"
setenv subtest_list_non_replic "$subtest_list_non_replic functions"
setenv subtest_list_non_replic "$subtest_list_non_replic dse"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_comments_literals"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_job"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_prompt"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_simple_updates"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_do"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_misc"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_dir"
setenv subtest_list_non_replic "$subtest_list_non_replic unicode_piece"
setenv subtest_list_non_replic "$subtest_list_non_replic unicodePatternTest"
setenv subtest_list_non_replic "$subtest_list_non_replic unicodeZwritePattern"
setenv subtest_list_non_replic "$subtest_list_non_replic d002577"
setenv subtest_list_non_replic "$subtest_list_non_replic c001953"
setenv subtest_list_non_replic "$subtest_list_non_replic ugc2mpatcmap"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm6858"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8352"
setenv subtest_list_replic " "
setenv subtest_list_replic "$subtest_list_replic repl_log"
setenv subtest_list_replic "$subtest_list_replic unicode_tptype"
#
unsetenv gtm_locale             # This interferes with several subtests so remove it for this test
set shorthost = $HOST:r:r:r
if ( "TRUE" == "$gtm_test_unicode_support" ) then
	setenv gtm_test_unicode "TRUE"
	$switch_chset "UTF-8" >&! switch_utf8.log
	if (0 == $?test_replic) then
		setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
	else
		setenv subtest_list "$subtest_list_common $subtest_list_replic"
	endif
else
	setenv subtest_list "no_ICU"
endif
# filter out some subtests for some servers
# Disable dse and functions subtests on platforms that don't support unicode 5.0 (4 byte unicode chars)
setenv subtest_list "$subtest_list"
setenv subtest_exclude_list ""
if ("1" == "$gtm_platform_no_4byte_utf8") then
	setenv subtest_exclude_list "$subtest_exclude_list dse functions"
endif

# Disable repl_log on shrug <shrug_unicodedir_CRYPTKEYFETCHFAILED>
if ($shorthost =~ "shrug") then
	setenv subtest_exclude_list "$subtest_exclude_list repl_log"
endif

$gtm_tst/com/submit_subtest.csh
echo "unicode test done."
