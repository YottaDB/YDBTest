#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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
# This test is AIX only
if ("HOST_AIX_RS6000" != "$gtm_test_os_machtype") then
	echo "Host is not AIX, this test does not apply"
	exit -1
endif

# Switch to UTF-8 mode
$switch_chset UTF-8 >&! uchset.out

# Use the highest discovered ICU library for the test case
foreach lib ( {,/usr,/usr/local}/lib*/libicuio* )
	set icuver = ${lib:t:r:s/libicuio//}
	if ("" == "${icuver}")
		continue
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_icu_version gtm_icu_version "${icuver}"
end

# Use PWD as the location of the ICU libraries
setenv LD_LIBRARY_PATH $PWD
setenv LIBPATH $PWD

# Copy over just the starting libicuio<ver>.a files. The load will fail with a dependency error. Use -h to copy the symlinks
foreach lib ( {,/usr,/usr/local}/lib*/libicuio${gtm_icu_version:s/.//}* )
	cp -h $lib ./
end

# Executing GT.M without all the libraries will fail, so redirect the output to a non-error checked log file
$gtm_dist/mumps -run %XCMD 'write $zversion,!' >&! icu_fail.logx

# Previously the above command generated only three lines. The last line contained an ambiguous reference.
#
#%YDB-E-DLLNOOPEN, Failed to load external dynamic library ##TEST_PATH##/libicuio42.1.a(libicuio.so)
#%YDB-I-TEXT, Could not load module ##TEST_PATH##/libicuio42.1.a(libicuio.so).
#        Member libicuio.so is not found in archive
#
# Now the error prints out more detailed information.
#
#%YDB-E-DLLNOOPEN, Failed to load external dynamic library ##TEST_PATH##/libicuio42.1.a(libicuio42.1.so)
#%YDB-I-TEXT, Could not load module ##TEST_PATH##/libicuio42.1.a(libicuio42.1.so).
#        Dependent module libicuuc42.a(libicuuc42.1.so) could not be loaded.
#Could not load module libicuuc42.a(libicuuc42.1.so).
#System error: No such file or directory
#Could not load module ##TEST_PATH##/libicuio42.1.a(libicuio42.1.so).
#        Dependent module ##TEST_PATH##/libicuio42.1.a(libicuio42.1.so) could not be loaded.
#

# Switch back to M mode and verify that the unversioned SO name is not present
$switch_chset M >&! mchset.out
$grep libicuio.so icu_fail.logx
if ( 0 != $status ) then
	echo "PASS"
else
	echo "FAIL"
endif
