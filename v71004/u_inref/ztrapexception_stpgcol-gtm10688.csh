#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-10688 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410688)

SET \$ZTRAP appropriately validates the code string provided as a new value. GTM-9480/GTM-DE304273 in V7.0-004, which addressed an issue with \$ZTRAP maintenance, introduced a possibility that the compilation of a \$ZTRAP during a "SET \$ZTRAP=x" operation could result in assigning a garbage value to \$ZTRAP. A similar issue, dating to V6.3-001A, also affects certain I/O exception handlers specified as exception device parameters. If your application always uses code vectors rather than labels, a workaround for both issues is to set the gtm_ztrap_form environment variable to "adaptive", which prevents the assignment operation from validating the code. (GTM-10688)

CAT_EOF
echo

echo '# The garbage value is possible only if a garbage collection of the stringpool happens while SET $ZTRAP or the'
echo '# EXCEPTION device parameter validates (compiles) the new value. White-box test case 188 (WBTEST_ZTTEST), which'
echo '# V7.1-004 added, forces a garbage collection at exactly that point. So this subtest enables that white-box test'
echo '# case, and for each of SET $ZTRAP, OPEN with EXCEPTION and USE with EXCEPTION checks that'
echo '#   1. a garbage collection did happen inside the command (the stringpool has fewer bytes in use afterwards),'
echo '#   2. $ZTRAP or the EXCEPTION of the device (from ZSHOW "D") has the value that was set, and'
echo '#   3. an error then invokes that $ZTRAP or EXCEPTION.'
echo '# YottaDB already protected SET $ZTRAP and EXCEPTION against such a garbage collection before the V7.1-004 merge, so'
echo '# this subtest guards against a regression.'
echo

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 188	# WBTEST_ZTTEST
echo '# Run [mumps -run gtm10688]'
$gtm_dist/mumps -run gtm10688
