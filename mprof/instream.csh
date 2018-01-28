#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# general		[miazim]	Survey of core mprof functionality.
# error_messages	[miazim]	Validates mprof behavior in face of various errors.
# C001951		[miazim]	Ensures that syntax errors in mprof VIEW commands are handled appropriately.
# D9L03002804		[sopini]	Tests for correctness of FOR and same-line command reporting, time aggregation, etc.
# D9L06002815		[sopini]	Tests implicit mprof initialization, absolute time fields, and cumulative process times.
# GTM7196		[sopini]	Verifies that there are no memory leaks with mprof.
#-------------------------------------------------------------------------------------

echo "mprof test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "general error_messages C001951 D9L03002804 D9L06002815 GTM7196"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Unset the implicit MPROF mode that might interfere with this test.
unsetenv gtm_trace_gbl_name

# The tst_ld_sidedeck change is required for external call in nested_malloc.
if ( "os390" == $gtm_test_osname ) then
        # Save the normal LIBPATH and append the desired paths for call ins to work.
        set old_libpath=${LIBPATH}
        setenv LIBPATH ${tst_working_dir}:${gtm_exe}:.:${LIBPATH}
        # Apparently on z/OS the the sidedeck must be specified for the call out DLL
        setenv tst_ld_sidedeck "-L$gtm_dist $tst_ld_yottadb"
else
        setenv tst_ld_sidedeck ""
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "mprof test DONE."
