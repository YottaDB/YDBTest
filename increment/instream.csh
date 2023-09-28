#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2004, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#####################################################
# [Mohammad] C9D03-002249 - $increment(glvn[,expr])
#####################################################
echo "increment test starts ..."
if ("GT.CM" == $test_gtm_gtcm) then
	setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to difficulties with remote systems having same V6 version to create DBs
endif
if ($LFE == "L") then
	setenv subtest_list "incrbas incrgv1 incrgv2"
else
	if ($test_gtm_gtcm ==  "GT.CM") then
		setenv subtest_list "incrbas incrgv5"
	else
		setenv subtest_list "incrbas incrgv1 incrgv2 incrgv4"
	endif
endif

$gtm_tst/com/submit_subtest.csh
#
echo "increment test DONE."
