#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# C9I09003032 : Prevent malformed string literals from over-scanning EOL
#
echo "# This subtest generates a lot of GTM-W-LITNONGRAPH, YDB-E-SPOREOL and YDB-E-EQUAL errors"
$gtm_tst/com/dbcreate.csh mumps 1
echo "# Compile the mumps routine containing malformed string literals"
cp $gtm_tst/$tst/inref/c003032.m .
$gtm_exe/mumps c003032.m
cp c003032.o c003032.o_compiled

echo "# Run the compiled version"
$gtm_exe/mumps -run c003032

echo "# Remove the object file and run the routine"
rm c003032.o
$gtm_exe/mumps -run c003032

echo "# Run the routine in direct mode"
mv c003032.o c003032.o_executed
$GTM << EOF
do ^c003032
EOF

echo "# Execute the write command with malformed string literal in direct mode"
$GTM << EOF
write !,"this is a bad string literal with a tab        in it,!
set a="unclosed string
set ^b="this is 	tab
EOF

$gtm_tst/com/dbcheck.csh
echo "End of C9I09003032 test..."
