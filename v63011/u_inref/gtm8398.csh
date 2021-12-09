#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This tests that GDE and MUPIP EXTEND work with an extension_count larger than 65355"
echo "# Prior to V6.3-011, the limit for the extension_count was 65535 blocks. In V6.3-011,"
echo "# the limit is increased to 1,048,575 blocks."

$echoline
echo "# Create a global directory with an extension_count of 1048575 on the DEFAULT segment."
echo "# This will produce an error on versions prior to V6.3-011."
$GDE change -segment DEFAULT -extension_count=1048575
$echoline
echo "# Create the database from the global directory"
$MUPIP CREATE

$echoline
echo "# Now we execute a MUPIP EXTEND DEFAULT to extend the database by the segment's extension_count of 1048575 blocks"
$MUPIP EXTEND DEFAULT

$echoline
echo "# Attempt to change the extension count to 1048576. This should fail with an error as this value is over the limit."
$GDE change -segment DEFAULT -extension_count=1048576

$echoline
echo "# Run dbcheck"
$gtm_tst/com/dbcheck.csh
