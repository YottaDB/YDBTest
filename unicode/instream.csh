#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# gtm7886			[shaha] Failure to load ICU libraries on AIX should report the true error
# gtm6858			[shaha] Use AIX's system ICU libraries and test GTM-7375 which allows more version numbers
# gtm8352                       [SEstes] Test UTF8 scan-cache logic for $FIND() and $EXTRACT() on strings in UTF8 mode
#
#all subtests will be run under UTF-8 (or can override explicitly)
echo "unicode test starts ..."
#
unsetenv gtm_locale             # This interferes with several subtests so remove it for this test
set shorthost = $HOST:r:r:r
if ( "TRUE" == "$gtm_test_unicode_support" ) then
	setenv gtm_test_unicode "TRUE"
	$switch_chset "UTF-8" >&! switch_utf8.log
	if (0 == $?test_replic) then
		setenv unicode_testlist "badchar chset errors filenames gde gtmroutines limits recompile functions dse "
		setenv unicode_testlist "$unicode_testlist unicode_comments_literals  unicode_job  unicode_prompt  unicode_simple_updates unicode_do"
		setenv unicode_testlist "$unicode_testlist unicode_misc unicode_dir unicode_piece"
		setenv unicode_testlist "$unicode_testlist unicodePatternTest  unicodeZwritePattern d002577 c001953 ugc2mpatcmap gtm6858 gtm8352"
		# Test this only on AIX
		if ("HOST_AIX_RS6000" == "$gtm_test_os_machtype") then
			setenv unicode_testlist "$unicode_testlist gtm7886"
		endif
	else
		setenv unicode_testlist "repl_log unicode_tptype"
	endif
else
	setenv unicode_testlist "no_ICU"
endif
# filter out some subtests for some servers
# Disable dse and functions subtests on platforms that don't support unicode 5.0 (4 byte unicode chars)
setenv subtest_list "$unicode_testlist"
setenv subtest_exclude_list ""
if ("1" == "$gtm_platform_no_4byte_utf8") then
	setenv subtest_exclude_list "$subtest_exclude_list dse functions"
endif

# libconfig and CONVDBKEYS do not like file names in UTF-8.
if (("AIX" == $HOSTOS) && ("ENCRYPT" == "$test_encryption")) then
	setenv subtest_exclude_list "$subtest_exclude_list filenames repl_log"
endif

# tcsh (6.18.01) issue with unicode characters on AIX
if ("AIX" == $HOSTOS) then
	setenv subtest_exclude_list "$subtest_exclude_list filenames"
endif

# Disable repl_log on shrug <shrug_unicodedir_CRYPTKEYFETCHFAILED>
if ($shorthost =~ "shrug") then
	setenv subtest_exclude_list "$subtest_exclude_list repl_log"
endif

$gtm_tst/com/submit_subtest.csh
echo "unicode test done."
