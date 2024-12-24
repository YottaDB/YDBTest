#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-F135383 - Test the following release note
*****************************************************************

Release note http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE422089 says:

GT.M reports the LINETOOLONG error when input to a DSE, MUPIP, or LKE utility prompt exceeds the allowed maximum of 33022 bytes. Additionally, GT.M reports the ARGTRUNC warning when a shell argument of a GDE, MUPIP, or LKE utility executable exceeds the allowed maximum of 33022 bytes. Previously, GT.M silently truncated shell arguments that exceeded these limits and did not produce an error when input to a utility prompt exceeded the allowed 33022 bytes. (GTM-DE422089)
CAT_EOF
echo
echo "# Note that this test also passes with r2.02, despite the fact that v71000 was merged only with r2.04."
echo "# This occurs due to the changes noted at: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/651#note_2310269539."
echo "# Note also that the outref file for this test uses SUSPEND_OUTPUT UNICODE_MODE per https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2228#note_2323971949"
echo
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
foreach len (33021 33022 33023)
	$gtm_dist/mumps -run %XCMD 'use $p:(width=65535:nowrap) write $$^%RANDSTR('$len')' >& longline$len.in
	endif
	echo "# -------------------------------------------------------------------------------------------------------------"
	echo "# Check for utility output when the prompt input is $len bytes long."
	echo "# Expect ARGSLONGLINE from MUPIP when input is > 33022 bytes long,"
	echo "# otherwise expect CLIERR for an unrecognized command."
	echo
	echo "# Check MUPIP output"
	cat longline$len.in | $gtm_dist/mupip
	echo
	echo "# Check LKE output"
	cat longline$len.in | $gtm_dist/lke
	echo
	echo "# Check DSE output"
	cat longline$len.in | $gtm_dist/dse
	echo
	echo "# Check for CLIERR 'Command line too long' errors when a utility is given"
	echo "# an argument that is $len bytes long."
	echo "# Expect CLIERR from MUPIP"
	$gtm_dist/mupip set -`cat longline$len.in`
	echo "# Expect CLIERR from LKE"
	$gtm_dist/lke -`cat longline$len.in`
	echo "# Expect CLIERR from GDE"
	$gtm_dist/mumps -run GDE add -`cat longline$len.in`
	echo
end
$gtm_tst/com/dbcheck.csh
