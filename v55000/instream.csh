#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#-------------------------------------------------------------------------------------
#
# gtm7082		[base]		Verify that -extract=-stdout prints to standard output doesn't truncate output
# C9H04002848		[smw]		interrupted HANGs
# C9I08003014   	[estess]        Verify no stack frame corruption with fix
# GTM7072       	[estess]        Fix for assert failures with debug build
# GTM6940       	[estess]        Failing direct mode commands test
# D9K06002778   	[estess]        White box test to test survival of stack mpc corruption
# C9K10003334   	[estess]        Error thrown during $ZINTrupt should not be rethrown when jobinterrupt returns
# C9L03003376   	[estess]        ZMessage 1 should not result in a "success" return code
# C9L04003403   	[estess]        Test overflow of indirect array in zshow_stack
# gtm7016		[base]		Verify that load -stdin read from standard input GTM-7016
# gtm7077 		[rog] 		MUPIP EXTRACT of large block
# gtm7020		[shaha]		verify that trigger operations restart instead of assert failing
# nullindr		[estess]	Test ZPRINT/$TEXT/ZBREAK with null indirect value can fail on trigger-enabled platform
# gtm7185		[rog]		Test FOR increment and termination with subscripted local variable
# gtm7073		[base]		LKE should write to SYSLOG if lock space is full. LKE SHOW should print LOCKSPACEFULL
#				        to screen. LKE SHOW should work properly on multiple regions.
# GTM6813		[sopini]	Various DO functionality
# C9H04002849		[smw]		interrupted LOCKs
# gtm7234		[rog]		check that a UNIX JOB command doesn't attempt to pass parameter if there isn't one
# multiple_jnlpools	[kishore]	Various test cases of multiple jnlpool issues
# gtm7205		[base]		Lock memory works right. No processes left hung when queue is full
# validate_table	[bahirs]	Check the calculated tables entries and hard-coded table entries jnl_get_checksum.c
#					module are consistent.
# C9J02003091		[kishoreh]	Turning on journal by pointing to an existing file should throw an error
#-------------------------------------------------------------------------------------

echo "v55000 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "gtm7082 C9H04002848 C9I08003014 GTM6940 GTM7072 D9K06002778 C9K10003334 C9L03003376 C9L04003403"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7016 gtm7077 gtm7020 nullindr gtm7185 gtm7073 C9H04002849 GTM6813"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm7234 gtm7205 validate_table C9J02003091"
setenv subtest_list_replic     "multiple_jnlpools"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
#
# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
#
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
        setenv subtest_exclude_list "$subtest_exclude_list D9K06002778"
endif
#
if (("OSF1" == $HOSTOS) || ("OS/390" ==  $HOSTOS)) then
        # The following subtests use "expect" which is absent in Tru64 and z/OS therefore do not include them.
        setenv subtest_exclude_list "$subtest_exclude_list C9I08003014 GTM6940"
endif
# If the platform/host does not have GG structured build directory, disable tests that require them
if ($?gtm_test_noggbuilddir) then
	setenv subtest_exclude_list "$subtest_exclude_list validate_table"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v55000 test DONE."
