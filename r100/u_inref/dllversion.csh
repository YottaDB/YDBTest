#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2001-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Pick up list of versions to test
#
set gtm_test_shlib_versions = `$gtm_tst/com/random_ver.csh -type shlib_mismatch`
if ("$gtm_test_shlib_versions" =~ "*-E-*") then
    echo "No prior versions available: $gtm_test_shlib_versions"
    exit -1
endif
echo "$gtm_test_shlib_versions" > version_list.txt
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_shlib_versions
#
# Test building shared library with each version that isn't us
#
set errcnt = 0
foreach ver ($gtm_test_shlib_versions)
    $gtm_tst/$tst/u_inref/dllversion_oneversion.csh $ver >&! $ver.log
    set stat = $status
    if ($stat) then
	echo "-------------------------------------------------------------"
	echo "TEST-E-DLLVERSION version $ver returned $stat status."
	echo "Please check the output at $ver.log"
	@ errcnt = $errcnt + 1
	echo "-------------------------------------------------------------"
    endif
    # check output
    $gtm_tst/com/check_reference_file.csh $gtm_tst/$tst/outref/dllversion_oneversion.txt $ver.log
    set stat = $status
    if ($stat) then
	echo "-------------------------------------------------------------"
	echo "TEST-E-DLLVERSION FAIL from dllversion for version $ver"
	echo "Please check $ver.diff"
	@ errcnt = $errcnt + 1
	echo "-------------------------------------------------------------"
    endif
end
if (0 == $errcnt) then
    echo "PASS"
    $tst_gzip V*.log
else
    echo "FAIL"
endif
