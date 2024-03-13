
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
cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTMDE-222430 - Test the following release note
*****************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637998)

GT.M handles SIGHUP appropriately when \$PRINCIPAL has HUPENABLE set; in V7.0-001 due to changes in deferred event handling,
error handing could encounter a GTMASSERT2. In addition, a TERMHANGUP error implicitly sets the device to NOHUPENABLE,
so should a process anticipate multiple disconnects/hangups, it should explicitly issue a USE \$PRINCIPAL:HUPENABLE. Also,
ZSHOW "D" displays the HUPENABLE state for \$PRINCIPAL. (GTM-DE222430)

CAT_EOF
setenv ydb_msgprefix "GTM"
echo ""
echo '# Test #1 : ZSHOW "D"'
echo '# ZSHOW should "D" displays the HUPENABLE state for $PRINCIPAL'
echo ''
(expect -d $gtm_tst/$tst/u_inref/gtmde222430A.exp > expectA.outx) >& expect.dbg
if ($status) then
	echo "TEST-E-FAIL Expect error"
else
  tr -d '\01' < expectA.outx > expect_sanitizedA1.outx
	perl $gtm_tst/com/expectsanitize.pl expect_sanitizedA1.outx > expect_sanitizedA2.outx
	cat expect_sanitizedA2.outx
endif
echo ''
echo '# Test #2 : E-TERMHANGUP'
echo '# in V7.0-001 due to changes in deferred event handling, error handing could encounter a GTMASSERT2.'
echo '# But in V7.0-002 it should be E-TERMHANGUP'
echo ''
(expect -d $gtm_tst/$tst/u_inref/gtmde222430B.exp > expectB.outx) >& expectB.dbg
if ($status) then
	echo "TEST-E-FAIL Expect error"
else
  tr -d '\01' < expectB.outx > expect_sanitizedB1.outx
	perl $gtm_tst/com/expectsanitize.pl expect_sanitizedB1.outx > expect_sanitizedB2.outx
	cat expect_sanitizedB2.outx
endif

cat gtmde222430b_exception.log
