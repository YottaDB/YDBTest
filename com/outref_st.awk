#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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

# This awk script is invoked when "gtmtest.csh" is invoked with the "-st" option to run just a comma-separated list of subtests.
# It creates "outstream.cmp" based on the reference file and the actual test output.
# If the test run excluded one or more of the specified subtests then do not include them in the "outstream.cmp" file.
# This is taken care of by checking the "PASS from <subtest>" lines in the output and seeing if "<subtest>" (i.e. $3)
# is one of the specified subtests in the "-st" option (env var "gtm_test_st_list") and if so include that "PASS from <subtest>"
# line and otherwise exclude it. Any line that does not have a "PASS from ..." will be automatically included.
# The below logic implements this.

BEGIN	{
		num=split(gtm_test_st_list, st, ",");
		for (i = 1; i <= num; i++)
			subtests[st[i]];
	}
{
	if (("PASS" != $1) || ("from" != $2) || ($3 in subtests))
		print
}
