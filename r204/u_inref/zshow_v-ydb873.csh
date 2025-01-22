#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo '# Test that ZSHOW "V" accepts a STACK level parameter'

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo '# --- Test $IO output at various levels ---'
echo '# Test default level'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V"'
echo '# Test explicit level'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V"::1'
echo '# Test non-default level'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V"::0'
echo '# Test -1 as alias for current $STACK level'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V"::-1'
echo '# Test arbitrary expressions'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V"::5-6'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V"::$STACK'
$gtm_dist/mumps -run zshowfuncydb873
echo '# Test non-integer stack levels'
$gtm_dist/mumps -run %XCMD 'NEW  ZSHOW "V"::0.85'
$gtm_dist/mumps -run %XCMD 'NEW  ZSHOW "V"::-0.85'
$gtm_dist/mumps -run %XCMD 'NEW  ZSHOW "V"::1E-1'

echo '\n# --- Test local variable output ---'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V":b:0   ZWRITE b'

echo '\n# --- Test global variable output ---'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a"  ZSHOW "V":^b:0   ZWRITE ^b'

echo '\n# --- Test indirection ---'
echo '# Test indirection to local'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a",y="b"  ZSHOW "V":@y:0   ZWRITE b'
echo '# Test indirection to global'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a",y="^c"  ZSHOW "V":@y:0   ZWRITE ^c'
echo '# Test double indirection to local'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a",y="@z",z="b"  ZSHOW "V":@y:0   ZWRITE b'
echo '# Test double indirection to global'
$gtm_dist/mumps -run %XCMD 'NEW  SET x="a",y="@z",z="^d"  ZSHOW "V":@y:0   ZWRITE ^d'
echo '# Test stack level specified through indirection'
$gtm_dist/mumps -run %XCMD 'SET x="y",y=-1 ZSHOW "v"::@x'

echo '\n# --- Test that local variables defined before trigger entry are visible using ZSHOW "V"::0 inside the trigger ---'
$gtm_dist/mumps -run trigydb873

echo '\n# --- Test that multiple triggers on the same variable all see the same parent stack frames ---'
$gtm_dist/mumps -run multitrigydb873
echo '# Each trigger in this M file is executed in a random order. Redirect the output to a log and output it in a deterministic order.'
cat "x2set1#out.log" "x2set2#out.log"

echo '\n# --- Test ZSHOWSTACKRANGE errors ---'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V"::-2'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V"::4'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V":-2'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V":::4'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V"::'
$gtm_dist/mumps -run %XCMD 'SET x="y",y=5  ZSHOW "V"::@x'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V"::0.85'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V"::-0.85'
$gtm_dist/mumps -run %XCMD 'ZSHOW "V"::1E-1'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S"::-2'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S"::4'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S":-2'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S":::4'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S"::'
$gtm_dist/mumps -run %XCMD 'SET x="y",y=5  ZSHOW "V"::@x'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S"::0.85'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S"::-0.85'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S"::1E-1'

echo '\n# --- Test that stack level is ignored for non-V codes ---'
$gtm_dist/mumps -run %XCMD 'ZSHOW "S"::4'
$gtm_dist/mumps -run %XCMD 'NEW  ZSHOW "SV"::0'

echo '\n# --- Test that V is still deduplicated when stack level is present ---'
$gtm_dist/mumps -run %XCMD 'NEW  ZSHOW "VV"::0'

echo "# Run [dbcheck.csh]"
$gtm_tst/com/dbcheck.csh >>& dbcreate.out
