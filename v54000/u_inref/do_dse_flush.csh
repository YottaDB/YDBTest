#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This script is invoked only by the v54000/C9D08002390 subtest, once per test case. The first argument
# is the number of the test case doing the invoking, so "$test_number" of 4 below is the section that
# subtest announces as "# Test case 4: WRITERSTUCK repeats once per stuck writer (GTM-DE568333)".
set test_number = $1
# Optional second argument is the white box test case number to drive. It defaults to 25, which fakes a
# single stuck writer, and is what test cases 1 through 3 use. Test case 4 passes 409 instead, which fakes
# two stuck writers so that "wcs_flu" issues one WRITERSTUCK message per writer.
if (2 <= $#argv) then
	set wbox_number = $2
else
	set wbox_number = 25
endif

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number $wbox_number	# 25 = WBTEST_BUFOWNERSTUCK_STACK, 409 = WBTEST_MULTI_WRITERSTUCK
setenv gtm_white_box_test_case_count 1

echo $$ >& dse_parent.pid_$test_number
$DSE << DSE_EOF
	spawn "date > do_dse_flush.started_$test_number"
	spawn "$gtm_tst/com/wait_for_log.csh -log dse.pid_$test_number"
	all -buffer_flush
DSE_EOF
date > do_dse_flush.done_$test_number
