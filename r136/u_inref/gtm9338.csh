#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This test checks that trigger compilation responds to location"
echo "# specified by the gtm_tmp environment variable."
echo ""
echo "# Creating a temporary directory to be used as gtm_tmp"
mkdir gtm9338_tmp
setenv gtm_tmp "$PWD/gtm9338_tmp"
echo ""

echo "# Creating the database"
$gtm_tst/com/dbcreate.csh mumps
echo ""

echo "# Creating the first trigger definition file"
cat<<EOF >>trigger9338_1.trg
+^Acct("ID") -name=ValidateAccount1 -commands=S -xecute="Write ""Hello Earth!"""

EOF
echo ""

echo "# Add new trigger. This trigger will be successfully added"
$gtm_dist/mupip trigger -triggerfile=trigger9338_1.trg
echo ""

echo "# Remove write permissions to gtm_tmp directory"
chmod -w "$PWD/gtm9338_tmp"
echo ""

echo "# Creating the second trigger definition file"
cat<<EOF >>trigger9338_2.trg
+^Acct("ID") -name=ValidateAccount2 -commands=S -xecute="Write ""Hello Mars!"""

EOF
echo ""

echo "# Add new trigger. This trigger will be unsuccessful"
$gtm_dist/mupip trigger -triggerfile=trigger9338_2.trg
echo ""

echo "# Verify database"
$gtm_tst/com/dbcheck.csh
