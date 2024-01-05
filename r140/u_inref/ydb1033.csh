#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test of YDB#1033 - Verifies $ZCMDLINE is can be both SET and NEWed'

$ydb_dist/yottadb -run ydb1033

echo "# Run [mupip -]. This should issue a %YDB-E-CLIERR error."
echo '# After YDB@5666d3a6, this used to SIG-11 and was fixed by YDB\!1458 (YDB@c995a2c6).'
$ydb_dist/mupip -

