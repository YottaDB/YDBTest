#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test manually switches between MM and BG mode. However, if the test framework
# randomly set acc_meth=BG, then it is possible that encryption also was enabled.
# In that case, this test will fail with due to %YDB-E-CRYPTNOMM errors. So,
# disable encryption for this test if it is enabled.
if ("ENCRYPT" == "$test_encryption" ) then
	setenv test_encryption NON_ENCRYPT
endif
$gtm_tst/$tst/u_inref/basic_base.csh >>&! basic_base.log
$tst_awk -f $gtm_tst/$tst/inref/filter_64bittn.awk basic_base.log
