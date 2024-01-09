#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9409 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9409)

GT.M appropriately reports the underlying cause of a JOBFAIL error due to an issue setting up a socketpair
to transfer context to the new JOB process. Previously, it did not supply this information. (GTM-9409)

CAT_EOF

echo "# Enable WBTEST_JOBFAIL_FILE_LIM (174) white-box testing"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 174

echo "# Run [JOB] command. Expect to see JOBFAIL error with error detail of [Job error in socketpair] AND [%SYSTEM-E-ENO24]"
$gtm_dist/mumps -run gtm9409

echo "# Disable WBTEST_JOBFAIL_FILE_LIM (174) white-box testing"
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

