#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

# Since the reference file for this test has "SUSPEND_OUTPUT 4G_ABOVE_DB_BLKS" usage, it needs to fixate
# the value of the "ydb_test_4g_db_blks" env var in case it is randomly set by the test framework to a non-zero value.
if (0 != $ydb_test_4g_db_blks) then
	echo "# Setting ydb_test_4g_db_blks env var to a fixed value as reference file has 4G_ABOVE_DB_BLKS usages" >> settings.csh
	setenv ydb_test_4g_db_blks 8388608
endif

echo "# The Release note for this issue follows:"
echo "# MUPIP SIZE recognizes the -SU[BSCRIPT]= qualifier to specify a global or a range of keys to estimate. The global key may"
echo "# be enclosed in quotation marks (" "). Identify a range by separating two subscripts with a colon (:). The -SE[LECT]= and"
echo "# -SU[BSCRIPT]= qualifiers are incompatible. Scan heuristic for MUPIP SIZE shows information of all levels down to the"
echo "# target level. Previously, it showed details only for the target level. For all heuristics, the adjacency shown is of"
echo "# current level. Previously, the adjacency shown was for the next lower level. In addition, MUPIP INTEG correctly handles"
echo "# the case of NULL subscripts, when no end key is specified; previously, it failed with a segmentation violation (SIG-11)."
echo "# (GTM-8322)."

$echoline
echo "# This tests MUPIP SIZE -SUBSCRIPT with no heuristic, arsampe heuristic and impsample heuristic. The scan heuristic is not"
echo "# tested because it is already covered by the r132/ydb717 test. The MUPIP INTEG SIG-11 is not tested because it is already"
echo "# tested by r132/ydb739. That issue was not actually fixed in V6.3-010 but is was fixed in r1.32 by YDB#739."

$echoline
echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps

$echoline
echo "# Populating the database with globals"
$ydb_dist/yottadb -run ^gtm8322

foreach heuristic ( "" -heuristic=arsample,samples=100 -heuristic=impsample,samples=100 )

echo "# Heuristic is now $heuristic"
echo "# Testing with enclosed quotes then without. Both outputs should be identical."

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^a(42) to ^a(9000) (same global; numeric subscript to numeric subscript)'
	$ydb_dist/mupip size -subscript='"^a(42)":"^a(9000)"' $heuristic
	$ydb_dist/mupip size -subscript='^a(42):^a(9000)' $heuristic

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^q("n") to ^q("y") (same global; string subscript to string subscript)'
	$ydb_dist/mupip size -subscript='"^q(""n"")":"^q(""y"")"' $heuristic

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^f(60) to ^f("c") (same global; numeric subscript to string subscript)'
	$ydb_dist/mupip size -subscript='"^f(60)":"^f(""c"")"' $heuristic

	$echoline
	echo "# Testing MUPIP SIZE -SUBSCRIPT from ^c(21) to ^e(5000) (different globals; numeric subscript to numeric subscript)"
	$ydb_dist/mupip size -subscript='"^c(21)":"^e(5000)"' $heuristic
	$ydb_dist/mupip size -subscript='^c(21):"^e(5000)"' $heuristic

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^g("a") to ^p("c") (different globals; string subscript to string subscript)'
	$ydb_dist/mupip size -subscript='"^g(""a"")":"^p(""c"")"' $heuristic

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^r(6174) to ^x("q") (different globals; numeric subscript to string subscript)'
	$ydb_dist/mupip size -subscript='"^r(6174)":"^x(""q"")"' $heuristic

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^k("k") to ^o(3375) (different globals; string subscript to numeric subscript)'
	$ydb_dist/mupip size -subscript='"^k(""k"")":"^o(3375)"' $heuristic

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^e(250) (numeric subscript to no end range specified)'
	$ydb_dist/mupip size -subscript='"^e(250)":""' $heuristic
	$ydb_dist/mupip size -subscript='^e(250):' $heuristic

	$echoline
	echo '# Testing MUPIP SIZE -SUBSCRIPT from ^l("p") (string subscript to no end range specified)'
	$ydb_dist/mupip size -subscript='"^l(""p"")":""' $heuristic
end

$echoline
echo "# Testing MUPIP SIZE -SUBSCRIPT -SELECT. This should produce an error."
$ydb_dist/mupip size -subscript='"^d":"^k"' -select='"^d":"^k"'

$echoline
echo "# Create a new database with null subscripts enabled"
$gtm_tst/com/dbcreate.csh mumps2 1 -stdnull -null_subscripts=TRUE
setenv gtmgbldir mumps2.gld

$echoline
echo "# Populate the new database"
$ydb_dist/yottadb -dir << EOF
set ^X(1)=2
set ^X("")=3
set ^X("a")=4
EOF

$echoline
echo "# Run a MUPIP SIZE -SUBSCRIPT with null subscripts, no end key and region *"
$ydb_dist/mupip size -subscript='"^X("""")":""' -reg "*"

$echoline
echo "# Run a MUPIP SIZE -SUBSCRIPT with null subscripts, no end key and region default"
$ydb_dist/mupip size -subscript='"^X("""")":""' -reg "default"

$echoline
echo "# Run a MUPIP SIZE -SUBSCRIPT with null subscripts, no end key and region DEFAULT"
$ydb_dist/mupip size -subscript='"^X("""")":""' -reg "DEFAULT"
