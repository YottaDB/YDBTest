#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

setenv gtm_test_spanreg 0   # because this test output is sensitive to block layout and random .sprgde can change that

# Disable this env var as the test output is sensitive to block layout and the allocation clue can change it
unsetenv gtm_tp_allocation_clue

$gtm_tst/com/dbcreate.csh mumps 3 -key=255 -rec=1000 -block_size=1024

$gtm_exe/mumps -run gtm8084

$DSE << DSE_EOF
	find -reg=AREG
	find -key=^a
	find -reg=BREG
	find -key=^b(500)
	find -reg=DEFAULT
	find -key=^c(1001)
DSE_EOF
echo ""

# The expected output from above is
# AREG:       4:10,   5:10,
# BREG:       4:1F,   B6:39B, AD:149,
# DEFAULT:    4:2A4,  322:2A3,        CB:1C9, 35:EE,  F:3AD,  3:10,

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in GVT at each level in AREG"
echo "# Get regular MUPIP INTEG output for AREG"
$MUPIP integ -reg AREG

echo "$MUPIP integ -block=5 -reg AREG"
$MUPIP integ -block=5 -reg AREG
echo "$MUPIP integ -block=4 -reg AREG"
$MUPIP integ -block=4 -reg AREG

echo "# Induce DBINVGBL error at BLOCK=5 in AREG"
$DSE << DSE_EOF
	find -reg=AREG
	overwrite -block=5 -offset=14 -data="b"
DSE_EOF
echo ""

echo "$MUPIP integ -block=5 -reg AREG : Should NOT give a DBINVGBL error since 5 is the only block that is integed"
$MUPIP integ -block=5 -reg AREG
echo "$MUPIP integ -block=4 -reg AREG : Should give a DBINVGBL error since 4 and 5 have different global names in same tree"
$MUPIP integ -block=4 -reg AREG

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in GVT at each level in BREG"
echo "# Get regular MUPIP INTEG output for BREG"
$MUPIP integ -reg BREG

echo "$MUPIP integ -block=AD -reg BREG"
$MUPIP integ -block=AD -reg BREG
echo "$MUPIP integ -block=B6 -reg BREG"
$MUPIP integ -block=B6 -reg BREG
echo "$MUPIP integ -block=4 -reg BREG"
$MUPIP integ -block=4 -reg BREG
echo "# Induce DBINVGBL error at BLOCK=B6 in BREG"
$DSE << DSE_EOF
	find -reg=BREG
	overwrite -block=B6 -offset=14 -data="c"
DSE_EOF
echo ""

echo "$MUPIP integ -block=AD -reg BREG"
$MUPIP integ -block=AD -reg BREG
echo "$MUPIP integ -block=B6 -reg BREG"
$MUPIP integ -block=B6 -reg BREG
echo "$MUPIP integ -block=4 -reg BREG"
$MUPIP integ -block=4 -reg BREG

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in GVT at each level in DEFAULT"
echo "# Get regular MUPIP INTEG output for DEFAULT"
$MUPIP integ -reg DEFAULT

echo "$MUPIP integ -block=3 -reg DEFAULT"
$MUPIP integ -block=3 -reg DEFAULT
echo "$MUPIP integ -block=F -reg DEFAULT"
$MUPIP integ -block=F -reg DEFAULT
echo "$MUPIP integ -block=35 -reg DEFAULT"
$MUPIP integ -block=35 -reg DEFAULT
echo "$MUPIP integ -block=CB -reg DEFAULT"
$MUPIP integ -block=CB -reg DEFAULT
echo "$MUPIP integ -block=322 -reg DEFAULT"
$MUPIP integ -block=322 -reg DEFAULT
echo "$MUPIP integ -block=4 -reg DEFAULT"
$MUPIP integ -block=4 -reg DEFAULT
echo "# Induce DBINVGBL error at BLOCK=CB in DEFAULT"
$DSE << DSE_EOF
	find -reg=DEFAULT
	overwrite -block=CB -offset=14 -data="a"
DSE_EOF
echo ""

echo "$MUPIP integ -block=3 -reg DEFAULT"
$MUPIP integ -block=3 -reg DEFAULT
echo "$MUPIP integ -block=F -reg DEFAULT"
$MUPIP integ -block=F -reg DEFAULT
echo "$MUPIP integ -block=35 -reg DEFAULT"
$MUPIP integ -block=35 -reg DEFAULT
echo "$MUPIP integ -block=CB -reg DEFAULT"
$MUPIP integ -block=CB -reg DEFAULT
echo "$MUPIP integ -block=322 -reg DEFAULT"
$MUPIP integ -block=322 -reg DEFAULT
echo "$MUPIP integ -block=4 -reg DEFAULT"
$MUPIP integ -block=4 -reg DEFAULT
echo "# Fix DBINVGBL error at BLOCK=CB in DEFAULT"
$DSE << DSE_EOF
	find -reg=DEFAULT
	overwrite -block=CB -offset=14 -data="c"
DSE_EOF
echo ""

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in GVT in ALL regions. sort needed for deterministic region order"
echo '$MUPIP integ -block=5 -reg "*" |& sort'
# Redirect integ output to file to facilitate debugging test failures.
# Use .logx (not .log) to avoid test framework from looking at the DBINVGBL errors in these files.
$MUPIP integ -block=5 -reg "*" >& integ_5.logx
sort integ_5.logx
echo '$MUPIP integ -block=B6 -reg "*" |& sort'
$MUPIP integ -block=B6 -reg "*" >& integ_b6.logx
sort integ_b6.logx

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in DT at each level in ALL regions. sort needed for deterministic region order"
echo '$MUPIP integ -block=2 -reg "*" |& sort'
$MUPIP integ -block=2 -reg "*" >& integ_2.logx
sort integ_2.logx
echo '$MUPIP integ -block=1 -reg "*" |& sort'
$MUPIP integ -block=1 -reg "*" >& integ_1.logx
sort integ_1.logx

echo ""
echo "# Fix DBINVGBL error at BLOCK=5 in AREG"
$DSE << DSE_EOF
	find -reg=AREG
	overwrite -block=5 -offset=14 -data="a"
DSE_EOF
echo ""

echo "# Fix DBINVGBL error at BLOCK=B6 in BREG"
$DSE << DSE_EOF
	find -reg=BREG
	overwrite -block=B6 -offset=14 -data="b"
DSE_EOF
echo ""

$gtm_tst/com/dbcheck.csh
