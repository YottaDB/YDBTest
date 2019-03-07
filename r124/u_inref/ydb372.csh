#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo "# Tests using indirection in a setleft works correctly even if it is preceeded by a setleft which has an invalid ISV usage."
echo "# Previously such a usage would fail with a fatal GTMASSERT2 error during compilation."
echo ""
echo "# Generate and compile each m file. Then run the m file in -run mode and -direct mode. An error is expected, but not a GTMASSERT2 error."
echo ""

# Create a DB for global variables
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
        echo "DB Create Failed, Output Below"
        cat dbcreate_log.txt
endif

echo "# Generate true.m for specific test cases."
echo "test()" >> true.m
echo '	write "true",!' >> true.m
echo "	quit 1" >> true.m
cat true.m
echo "-----------------------------------------------"
$ydb_dist/mumps -run gentestfiles $gtm_tst/$tst/inref/ydb372
foreach subt ( tst*.m )
	echo "Subtest $subt"
	cat $subt
	echo "# Compile the m file"
	$ydb_dist/mumps $subt
	echo ""
	echo "# Run the m file using mumps -run"
	$ydb_dist/mumps -run $subt:r
	echo ""
	echo "# Compile/Run the m file using mumps -direct"
	$ydb_dist/mumps -direct < $subt
	echo "-----------------------------------------------"
end

$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
        echo "DB Check Failed, Output Below"
        cat dbcheck_log.txt
endif
