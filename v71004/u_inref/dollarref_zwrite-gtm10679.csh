#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
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
GTM-10679 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410679)

ZWRITE of a gvn maintains \$REFERENCE to the last node it successfully processed. If you use ZWRITE as a debugging tool, or unlikely, in application code, in a circumstance where preserving \$REFERENCE has importance, note \$REFERENCE and restore it, as you would for any other command or function that references a global. Previously, ZWRITE restored the \$REFERENCE to the value it had prior to the ZWRITE. (GTM-10679)

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo '### Test that ZWRITE updates $REFERENCE after a variety of other operations update $REFERENCE'
$gtm_dist/mumps -run gtm10679

$gtm_tst/com/dbcheck.csh >& dbcheck.out
