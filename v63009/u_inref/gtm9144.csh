#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "# Initialize database 1 with GT.M null subscript collation"
$gtm_tst/com/dbcreate.csh mumps 1 -nostdnull -null_subscripts=TRUE

echo "# Null collation set to GT.M in database 1"
$GTM << EOF
set ^X(1)=2
set ^X("")=3
set ^X("a")=4
EOF

echo "# Extract database 1 in Binary format"
$MUPIP extract -format=binary extr.bin >&! mupip_extract_bin.out
if ($status) then
        echo "# mupip binary extract failed. Check mupip_extract_bin.out. Will exit now"
        exit 1
endif

$gtm_tst/com/dbcheck.csh

echo "# Initialize database 2 with Standard null subscript collation"
$gtm_tst/com/dbcreate.csh mumps2 1 -stdnull -null_subscripts=TRUE
setenv gtmgbldir mumps2.gld

echo "# Null collation set to Standard in database 2"
$GTM << EOF
set ^X(1)=2
set ^X("")=3
set ^X("a")=4
EOF

echo "# Loading binary extract from database 1 into database 2"
$MUPIP load -format=binary extr.bin

echo "# Extract database 2 in Binary Format"
$MUPIP extract -format=binary extr2.bin >&! mupip_extract_bin.out
if ($status) then
        echo "# mupip binary extract failed. Check mupip_extract_bin.out. Will exit now"
        exit 1
endif

$gtm_tst/com/dbcheck.csh

echo "Creating database 3 exactly like database 1"
$gtm_tst/com/dbcreate.csh mumps3 1 -nostdnull -null_subscripts=TRUE
setenv gtmgbldir mumps3.gld

echo "# Null collation set to GT.M in database 3"
$GTM << EOF
set ^X(1)=2
set ^X("")=3
set ^X("a")=4
EOF

echo "# Loading binary extract from database 2 into database 3"
$MUPIP load -format=binary extr2.bin

$gtm_tst/com/dbcheck.csh

