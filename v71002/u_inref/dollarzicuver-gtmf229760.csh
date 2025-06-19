#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
GTM-F229760 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-F229760)

The \$ZICUVER Intrinsic Special Variable provides the current International Character Utilities (ICU) version or an empty string if ICU is not available. GT.M requires ICU to support UTF-8 operation. Previously, GT.M did not make this information available to the application code. (GTM-F229760)

CAT_EOF
echo

echo '### Test 1: $ICUVER returns correct ICU version when $ZCHSET=UTF-8'
$switch_chset UTF-8
set zicuver = `$gtm_dist/mumps -run %XCMD 'write $zicuver,!'`
set libicuver = `$gtm_dist/mumps -run %XCMD 'zsystem "grep libicudata.so /proc/"_$j_"/maps | head -1"' | sed 's/.*libicudata.so.\(suse\)\?\([0-9\.]*\)$/\2/g'`
echo $zicuver >&! zicuverUTF8.out
echo $libicuver >&! libicuverUTF8.out
if ($zicuver != $libicuver) then
	echo 'FAIL: $ZICUVER ('"$zicuver"'does not match the version of libicudata.so ('"$libicuver"')'
else
	echo 'PASS: $ZICUVER ('"$zicuver"') matches the version of libicudata.so ('"$libicuver"')'
endif
echo

echo '### Test 2: $ICUVER returns the empty string when $ZCHSET=M'
$switch_chset M
set zicuver = `$gtm_dist/mumps -run %XCMD 'write $zicuver,!'`
if ("$zicuver" != "") then
	echo 'FAIL: $ZICUVER is '"$zicuver"', not the empty string, but $ZCHSET=M'
else
	echo 'PASS: $ZICUVER is the empty string when $ZCHSET=M'
endif
