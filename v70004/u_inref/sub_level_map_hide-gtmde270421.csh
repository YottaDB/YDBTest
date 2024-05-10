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
GTM-DE270421 - Test the following release note
*****************************************************************

Release note (http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-DE270421) says:

> GT.M handles \$ORDER(), \$ZPREVIOUS(), \$QUERY(), \$NEXT(),
> and MERGE operations which traverse subscript-level mappings
> correctly. Previously, these operations could return gvns
> which should have been excluded by the global directory. In
> the case of MERGE, the target could contain data from excluded
> subtrees. (GTM-DE270421)

The tests create 2 glds, one with one region, anther one with
two regions and subscript-level mapping. The M program generates
some data for mixed glds, then iterates over all nodes, using
different iterator instructions, listed in Release Notes. This
test prints the test database, and some meta values:
- enumerated: number of nodes enumerated by the tested command
  (under certain circumstances, some nodes may be skipped),
- has_value: enumerated nodes with valid values (under some
  circustances, some enumerated nodes report UNDEF error
  with V70003 and earlier versions),
- total_count: the number of data items set (constant value).

The second part of the test runs the MERGE command, it copies
the values from the test global to a target one, which has no
mappings set.

Both part of the tests executed two times. The first round is
using 1reg.gld for generating data and 2reg.gld for walk tests.
This is the scenario, which previous versions failed, so it
needs testing.

The second round is using 2reg.gld for both data generation and
walk tests. This setup has never failed, so it's unnecessary to
test it, but it's a good explanation of how mapping tests works.
CAT_EOF
echo ""

echo "# ---- Create databases ----"

echo "# Run dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps 2 -stdnull >& dbcreate.log

echo "# Set up 1reg.gld"
setenv gtmgbldir "1reg.gld"
$ydb_dist/mumps -run GDE >& gde1.out << EOF
change -segment DEFAULT -file=mumps.dat
change -segment DEFAULT -access_method=$acc_meth
exit
EOF

echo "# Set up 2reg.gld with subscript level mapping"
setenv gtmgbldir "2reg.gld"
$ydb_dist/mumps -run GDE >& gde2.out << EOF
change -segment DEFAULT -file=mumps.dat
change -segment DEFAULT -access_method=$acc_meth
add -name t1(2) -region=AREG
add -name t1(4) -region=AREG
add -name t2(2) -region=AREG
add -name t2(4) -region=AREG
add -name t3(2) -region=AREG
add -name t3(4) -region=AREG
add -name t4(2) -region=AREG
add -name t4(4) -region=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a.dat
change -region DEFAULT -stdnullcoll
change -region AREG -stdnullcoll
change -segment ASEG -access_method=$acc_meth
exit
EOF
echo ""

echo "# ==== Round 1: create data: 1reg.gld, walk: 2reg.gld ===="
echo ""

echo "# ---- Execute walk tests (round 1) ----"
$gtm_dist/mumps -run main^SubLevelMapHide 1 t1
echo ""

echo "# ---- Execute MERGE test (round 1) ----"
$gtm_dist/mumps -run merge^SubLevelMapHide 1 t2
echo ""

echo "# ==== Round 2: create data: 2reg.gld, walk: 2reg.gld (1reg.gld is not used) ===="
echo ""

echo "# ---- Execute walk tests (round 2) ----"
$gtm_dist/mumps -run main^SubLevelMapHide 2 t3
echo ""

echo "# ---- Execute MERGE test (round 2) ----"
$gtm_dist/mumps -run merge^SubLevelMapHide 2 t4

$gtm_tst/com/dbcheck.csh >& dbcheck.log
