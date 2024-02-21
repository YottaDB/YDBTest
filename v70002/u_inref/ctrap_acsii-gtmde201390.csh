#!/usr/local/bin/tcsh -f
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
cat << 'CAT_EOF' | sed 's/^/# /;'
********************************************************************************************
GTM-F201390 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637470)

CTRAP characters other than CTRL-x, where x corresponds to the non-graphic characters represented by $CHAR(n) with n 0 to 31
inclusive, have no effect, and do not show up in ZSHOW "D" output. On the keyboard those characters correspond to <CTRL-@> to
<CTRL-_> with the bulk of the range being <CTRL-A> to <CTRL-Z>. Note that CTRAP=$CHAR(3) has a different semantic than the other
CTRAP characters, in that, when enabled and $PRINCIPAL is a terminal device type, <CTRL-C> can interrupt at any time, including
when $PRINCIPAL'=$IO. GT.M only recognizes the other CTRAP characters when they appear in input to a READ command. Previously,
characters outside the range with codes 0-31 showed up in ZSHOW "D" output with a modulo 32 $CHAR() representation and caused
corresponding CTRAP recognition. (GTM-DE201390)

'CAT_EOF'

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"
echo ""
echo '# Test #1 : ZSHOW "D" test'
echo "# Running expect (output: expect_sanitized.outx)"
(expect -d $gtm_tst/$tst/u_inref/gtmde201390.exp > expect.outx) >& expect.dbg
if ($status) then
	echo "TEST-E-FAIL Expect error"
else
  tr -d '\01' < expect.outx > expect_sanitized1.outx
	perl $gtm_tst/com/expectsanitize.pl expect_sanitized1.outx > expect_sanitized2.outx
	cat expect_sanitized2.outx
endif
