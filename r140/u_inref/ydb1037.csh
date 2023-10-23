#!/usr/local/bin/tcsh -f
#################################################################
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

echo '--------------------------------------------------------------------------------------'
echo '# Test that %YDB-E-STACKCRIT secondary error does not happen with ZTRAP in direct mode'
echo '--------------------------------------------------------------------------------------'
echo '# We run a few thousand iterations and make sure the M stack usage has not changed across those iterations.'
echo '# Previously, the M stack usage would increase across iterations and eventually result in a %YDB-E-STACKCRIT error.'

setenv gtm_mstack_crit_threshold 15	# set env var to minimum threshold percentage so as to get STACKCRIT error the fastest

echo
echo '# Running [do ^ydb1037] using [mumps -direct]. Expecting PASS message below'
$GTM << GTM_EOF
	do ^ydb1037
GTM_EOF

echo
echo '# Running [do ^ydb1037] using [mumps -run]. Expecting PASS message below'
$gtm_dist/mumps -run ydb1037
@ exit_status = $status
echo "[mumps -run] exited with status = [$exit_status]"

