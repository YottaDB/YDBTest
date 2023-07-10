#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
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
setenv ydb_test_4g_db_blks 0	# Disable debug-only huge db scheme as this test is sensitive to DT/GVT block layout
				# and the huge HOLE in bitmap block 512 onwards disturbs the assumptions in this test.
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
# AREG:       4:10,   3:10,
# BREG:       4:33,   C8:268, AD:149,
# DEFAULT:    4:2B0,  322:2AF,        CB:1D1, 35:F2,  F:3CD,  3:10,

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in GVT at each level in AREG"
echo "# Get regular MUPIP INTEG output for AREG"
$MUPIP integ -reg AREG

echo "$MUPIP integ -block=3 -reg AREG"
$MUPIP integ -block=3 -reg AREG
echo "$MUPIP integ -block=4 -reg AREG"
$MUPIP integ -block=4 -reg AREG

echo "# Induce DBINVGBL error at BLOCK=3 in AREG"
$DSE << DSE_EOF
	find -reg=AREG
	overwrite -block=3 -offset=14 -data="b"
DSE_EOF
echo ""

echo "$MUPIP integ -block=3 -reg AREG : Should NOT give a DBINVGBL error since 3 is the only block that is integed"
$MUPIP integ -block=3 -reg AREG
echo "$MUPIP integ -block=4 -reg AREG : Should give a DBINVGBL error since 4 and 3 have different global names in same tree"
$MUPIP integ -block=4 -reg AREG

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in GVT at each level in BREG"
echo "# Get regular MUPIP INTEG output for BREG"
$MUPIP integ -reg BREG

echo "$MUPIP integ -block=AD -reg BREG"
$MUPIP integ -block=AD -reg BREG
echo "$MUPIP integ -block=C8 -reg BREG"
$MUPIP integ -block=C8 -reg BREG
echo "$MUPIP integ -block=4 -reg BREG"
$MUPIP integ -block=4 -reg BREG
echo "# Induce DBINVGBL error at BLOCK=C8 in BREG"
$DSE << DSE_EOF
	find -reg=BREG
	overwrite -block=C8 -offset=14 -data="c"
DSE_EOF
echo ""

echo "$MUPIP integ -block=AD -reg BREG"
$MUPIP integ -block=AD -reg BREG
echo "$MUPIP integ -block=C8 -reg BREG"
$MUPIP integ -block=C8 -reg BREG
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
echo '$MUPIP integ -block=3 -reg "*" |& sort'
# Redirect integ output to file to facilitate debugging test failures.
# Use .logx (not .log) to avoid test framework from looking at the DBINVGBL errors in these files.
$MUPIP integ -block=3 -reg "*" >& integ_3.logx
sort integ_3.logx
echo '$MUPIP integ -block=B6 -reg "*" |& sort'
$MUPIP integ -block=C8 -reg "*" >& integ_c8.logx
sort integ_c8.logx

$echoline
echo "# Test MUPIP INTEG -BLOCK= for block in DT at each level in ALL regions. sort needed for deterministic region order"
echo '$MUPIP integ -block=2 -reg "*" |& sort'
$MUPIP integ -block=2 -reg "*" >& integ_2.logx
sort integ_2.logx
echo '$MUPIP integ -block=1 -reg "*" |& sort'
$MUPIP integ -block=1 -reg "*" >& integ_1.logx
sort integ_1.logx

echo ""
echo "# Fix DBINVGBL error at BLOCK=3 in AREG"
$DSE << DSE_EOF
	find -reg=AREG
	overwrite -block=3 -offset=14 -data="a"
DSE_EOF
echo ""

echo "# Fix DBINVGBL error at BLOCK=C8 in BREG"
$DSE << DSE_EOF
	find -reg=BREG
	overwrite -block=C8 -offset=14 -data="b"
DSE_EOF
echo ""

$gtm_tst/com/dbcheck.csh
