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

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-DE308470 - Test the following release note
*****************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-DE308470)

> Expratoms in a boolean expression are evaluated in
> left-to-right order in FULL_BOOLEAN compilation mode.
> Previously, side effects in a \$SELECT() could affect earlier
> expratoms in a boolean expression. (GTM-DE308470)

See similar tests:
 - r134/ydb546
 - v63009/gtm9155

SelectBooleanAssertRand results:
  expected result (V70004 and later):
    > error: %GTM-E-LVUNDEF, Undefined local variable: false
  wrong result (before V70004), dbg mode:
    > %GTM-F-ASSERT, Assert failed in /Distrib/YottaDB/V70003/sr_port/bx_boolop.c line 195 for expression (OCT_JUMP & oc_tab[t1->opcode].octype)
  wrong result (before V70004), pro mode:
    > %GTM-F-GTMASSERT2, GT.M V7.0-003 Linux x86_64 - Assert failed /Distrib/YottaDB/V70003/sr_port/bx_tail.c line 117 for expression (FALSE && t)
  see also:
    https://gitlab.com/YottaDB/DB/YDB/-/issues/698#description

SelectBooleanAssertSubr results:
  expected result (V70004 and later):
    > write ((\$\$RetSame(\$select(false:1,1:0),4)!\$random(((\$select(false:1,1:\$zysqlnull)!('\$select(true:1)))'&(((('@inull)'?1""0"")'&(((^false&(\$test&'null))'!((@^itrue'=('@ifalse))'[(@itrue]]@^ifalse)))?1""1""))=((0='\$test)'[((('@itrue)&@inull)?1""0""))))))'&(((\$\$Always0)'!^false)'=(@^ifalse'!(null'&\$test))))
    > 		                                                                                                                                                                                                                                                          ^-----
    > At column 73, line 27, source module v70004/inref/SelectBooleanAssertSubr.m
    > %GTM-E-INVSVN, Invalid special variable name
    > %GTM-E-FMLLSTMISSING, The formal list is absent from a label called with an actual list: Always0
    > %GTM-I-SRCNAM, in source module v70004/inref/SelectBooleanAssertSubr.m
  wrong result (before V70004), dbg mode:
    > At column 73, line 27, source module v70004/inref/SelectBooleanAssertSubr.m
    > %GTM-E-INVSVN, Invalid special variable name
    > %GTM-F-ASSERT, Assert failed in /Distrib/YottaDB/V70003/sr_port/bx_boolop.c line 195 for expression (OCT_JUMP & oc_tab[t1->opcode].octype)
  wrong result (before V70004), pro mode:
    > write ((\$\$RetSame(\$select(false:1,1:0),4)!\$random(((\$select(false:1,1:\$zysqlnull)!('\$select(true:1)))'&(((('@inull)'?1""0"")'&(((^false&(\$test&'null))'!((@^itrue'=('@ifalse))'[(@itrue]]@^ifalse)))?1""1""))=((0='\$test)'[((('@itrue)&@inull)?1""0""))))))'&(((\$\$Always0)'!^false)'=(@^ifalse'!(null'&\$test))))
    > 		                                                                                                                                                                                                                                                          ^-----
    > At column 73, line 27, source module v70004/inref/SelectBooleanAssertSubr.m
    > %GTM-E-INVSVN, Invalid special variable name
    > %GTM-F-GTMASSERT2, GT.M V7.0-003 Linux x86_64 - Assert failed /Distrib/YottaDB/V70003/sr_port/bx_tail.c line 117 for expression (FALSE && t)
  see also:
    https://gitlab.com/YottaDB/DB/YDB/-/issues/698#note_544075462
CAT_EOF
echo ""

setenv ydb_msgprefix "GTM"
setenv gtm_side_effects 1

echo "# ---- Execute expression with RANDOM, expecting LVUNDEF error  ----"
$gtm_dist/mumps -run test^SelectBooleanAssertRand
echo ''

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log
echo "# ---- Execute expression with subroutine, expecting 8+1 errors  ----"
$gtm_dist/mumps -run test^SelectBooleanAssertSubr

$gtm_tst/com/dbcheck.csh >& dbcheck.log
