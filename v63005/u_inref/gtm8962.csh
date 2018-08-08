#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests ZSHOW "I" shows $ZPIN and $ZPOUT even if they are the same as $PRINCIPAL and no longer displays $ZPROCESS
# and $ZTNAME is in alphabetical order

# Using an expect script because $ZPIN and $ZPOUT are the same as $PRINCIPAL when using direct mode
(expect -d $gtm_tst/$tst/u_inref/gtm8962.exp > expect.outx) >& xpect.dbg
if ($status) then
	echo "EXPECT FAILED"
endif
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx

echo '# Confirming $ZPIN=$PRINCIPAL, searching for $ZPIN in the output of ZSHOW "I"'
$grep '^$ZPIN' expect_sanitized.outx
echo ""
echo '# Confirming $ZPOUT=$PRINCIPAL, searching for $ZPOUT in the output of ZSHOW "I"'
$grep '^$ZPOUT' expect_sanitized.outx
echo ""
echo '# Searching for $PRINCIPAL in the output of ZSHOW "I"'
$grep '^$PRINCIPAL' expect_sanitized.outx
echo ""
echo '# Searching for $ZPROCESS in the output of ZSHOW "I"'
$grep ZPROCESS expect_sanitized.outx
echo ""
echo '# Showing $ZTNAME the lines surrounding it in the output of ZSHOW "I" to confirm $ZTNAME occurs in alphabetical order'
$grep -A1 -B1 ZTNAME expect_sanitized.outx
