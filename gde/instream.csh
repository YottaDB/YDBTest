#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
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
# basic		[HK] 	The original gde test in instream.csh - just moved to a subtest
# gdeput	[]	verify that gde will write to the appropriate .gld file in various cases
# longname 	[zhouc] Test longnames with GDE
# gtm7681	[nars]	GDE ADD -NAME with * in name-space creates incorrect mappings of globals.
# gtm7700	[nars]	GDE SHOW COMMANDS displays incorrect commands if * maps to non-DEFAULT region.
# gtm7184	[zouc]	Test the abbreviated values for null subscripts qualifier in gde
# errors	[kishoreh]	Test case for various error scenarios
# nameerrors	[kishoreh]	Various error scenarios specific to add -name
# gblname	[kishoreh]	subtest to test various usages of the new -gblname qualifier
# name		[kishoreh]	Various -name test cases
# showregion	[kishoreh]	Test various region qualifiers
# name_subscripts	[kishoreh] example from spanning regions functional spec - i.e DIVISION("Europe","a":"m")
#-------------------------------------------------------------------------------------

# setenv gtm_lvnullsubs 0 or 1 or 2 and then invoking GDE should all work the same.
if !($?gtm_test_replay) then
	@ rand = `$gtm_exe/mumps -run rand 4`
	# Do nothing if rand is 3
	if (3 != "$rand") then
		setenv gtm_lvnullsubs $rand
		echo "setenv gtm_lvnullsubs $gtm_lvnullsubs # set by instream.csh" >>&! settings.csh
	endif
endif

setenv maxlen 31
echo "gde test starts..."
# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "basic gdeput longname gtm7681 gtm7700 gtm7184 errors nameerrors gblname name showregion misc longsubscripts name_subscripts"
setenv subtest_list_replic     ""

if ( "TRUE" == "$gtm_test_unicode_support" ) then
	setenv subtest_list_non_replic "$subtest_list_non_replic unicode"
endif

if ($?test_replic) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh
echo "gde test DONE."
