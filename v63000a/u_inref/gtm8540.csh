#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script test cases that may result in incorrect literals values in the compiler

# We need a database for a few commands
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000                                                          >& dbcreate.log

# concat operation
echo "Concat"
$gtm_exe/mumps -direct <<GTM_EOF
if "-"_1 write \$ORDER(x,-1)
GTM_EOF

# $ASCII -- this test didn't require any modifications, as $ASCII forces to int
echo '$ASCII'
$gtm_exe/mumps -direct <<GTM_EOF
if \$ASCII("Hi",0) write \$ORDER(x,-1)
GTM_EOF

# $EXTRACT
echo '$EXTRACT'
$gtm_exe/mumps -direct <<GTM_EOF
if \$EXTRACT("P-1P",2,3) write \$ORDER(x,-1)
GTM_EOF

# $TRANSLATE
echo '$TRANSLATE'
$gtm_exe/mumps -direct <<GTM_EOF
if \$TRANSLATE("+1","+","-") write \$ORDER(x,-1)
GTM_EOF

# $ZCHAR -- this had the s2n force, which was removed to verify test works
echo '$ZCHAR'
$gtm_exe/mumps -direct <<GTM_EOF
if \$ZCHAR(45,49) write \$ORDER(x,-1)
GTM_EOF

# $ZDATE, $ZTRIGGER skipped; can't make a test case

# $ZWRITE -- fn_zwrite does something odd if we pass it a number as a string; can we remove that?
echo '$ZWRITE'
$gtm_exe/mumps -direct <<GTM_EOF
if \$ZWRITE("-1") write \$ORDER(x,-1)
GTM_EOF

# indirection -- this *almost* triggers the bug, but misses becase it leaves a trailing character on the string
#  If that is ever fixed, and this bug persists, this will trigger
echo "Indirection"
$gtm_exe/mumps -direct <<GTM_EOF
SET from="B",to="^A(15)",x="-1",^A(15,-1)="hello"
set ^A(15,-1,-2)=1
if @to@(-1)=5 write \$ORDER(x,+"-1)")
GTM_EOF

# $CHAR -- this had the s2n force, which was removed to verify test works
echo '$CHAR'
$gtm_exe/mumps -direct <<GTM_EOF
if \$CHAR(45,49) write \$ORDER(x,-1)
GTM_EOF

# $PIECE
echo '$PIECE'
$gtm_exe/mumps -direct <<GTM_EOF
if \$PIECE("P-1P","P",2) write \$ORDER(x,-1)
GTM_EOF

$gtm_tst/com/dbcheck.csh                                                          >& dbcheck.log
