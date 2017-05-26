#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "errors test Starts..."
setenv subtest_list "err_messages test_fao comperr"
$gtm_tst/com/submit_subtest.csh
echo "errors test DONE."
