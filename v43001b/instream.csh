# for stuff fixed for V43001B
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# D9C05002113 [Malli]     - SET $EXTRACT/$PIECE reports YDB-E-UNIMPLOP when last argument is an integer literal
# D9C05002121 [Nergis]    - mupip backup should work with relative path names if the (concurrent)
#				mumps and mupip processes are in different directories
# D9C06002149 [Prasad]    - Source Server Issue at EPro
# C9C07002079 [Narayanan] - MUPIP INTEG /REG "*" causes switch of journal files due to wcs_recover()
# D9C07002164 [Narayanan] - "
echo "v43001b test starts..."
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
#
setenv subtest_list_common "D9C05002121"
setenv subtest_list_replic "D9C06002149"
setenv subtest_list_non_replic "D9C05002113 C9C07002079 D9C07002164"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
$gtm_tst/com/submit_subtest.csh
echo "v43001b test DONE."
