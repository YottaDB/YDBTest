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
GTM-DE525624 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE525624):

Because it is a byte-oriented function, \$ZTRANSLATE() does not issue a BADCHAR when operating on UTF-8 strings. Due to a regression in V6.3-013, this function incorrectly issued a BADCHAR error when the input string contained non-UTF-8 characters. There are two possible workarounds for this issue: 1) A targeted approach requiring code changes to enclose each use of \$ZTRANSLATE() with VIEW "NOBADCHAR" and VIEW "BADCHAR"; ensures all UTF-8 data is handled appropriately. 2) A broad approach of defining gtm_badchar as zero or FALSE to disable BADCHAR checking through-out the application which disables detection of any improperly formatted UTF-8 strings. (GTM-DE525624)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"

echo '# Test 1: $ZTRANSLATE does not issue a BADCHAR error for a non-UTF-8 character in the input string'
echo '# Run a routine [nobadchar^gtmde525624] that passes a string containing a non-UTF-8 character to $ZTRANSLATE.'
echo '# Expect "PASS" message. Previously this issued a BADCHAR error when gtm_chset=UTF-8 with GT.M versions V6.3-013 to V7.1-000.'
$gtm_dist/mumps -r nobadchar^gtmde525624
