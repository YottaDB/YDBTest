#!/usr/local/bin/tcsh
#################################################################
#                                                               #
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "# This tests that a MUPIP INTEG -SUBSCRIPT does not SIG-11 if the"
echo "# database contains NULL subscripts and the end key is not specified."
echo "# Due to a bug that was only partially fixed in the upstream version"
echo "# V6.3-010, this would produce a SIG-11 in YottaDB versions prior to"
echo "# r1.32 and upstream versions up to at least V6.3-014."

# Disallow use of V6 mode DBs using a random V6 version as it changes the output from MUPIP INTEG
setenv gtm_test_use_V6_DBs 0
#
$echoline
echo "# Creating database"
$gtm_tst/com/dbcreate.csh mumps 1 -stdnull -null_subscripts=TRUE

$echoline
echo "# Setting some globals"
$ydb_dist/yottadb -dir << EOF
set ^X(1)=2
set ^X("")=3
set ^X("a")=4
EOF

$echoline
echo "# Run a MUPIP INTEG -SUBSCRIPT with a null subscript and no end key"
$ydb_dist/mupip integ -subscript='"^X("""")":""' -reg "*"
