#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "## -------------------------------------"
echo "## Test %ZMVALID M utility routine"
echo "## -------------------------------------"

echo "# Test %ZMVALID on valid single-line M code. Expecting an empty line of output."
$ydb_dist/yottadb -run %XCMD 'set x=$$^%ZMVALID("write 0") zwrite x'

echo "# Test %ZMVALID on valid multi-line M code. Expecting an empty line of output."
$ydb_dist/yottadb -run %XCMD 'set x=$$^%ZMVALID("write 0"_$char(10)_" write 1") zwrite x'

echo "# Test %ZMVALID on invalid single-line M code. Expecting compile error output."
$ydb_dist/yottadb -run %XCMD 'set x=$$^%ZMVALID("writ 0") use $principal:(width=65535) write x'

echo "# Test %ZMVALID on invalid multi-line M code. Expecting compile error output."
$ydb_dist/yottadb -run %XCMD 'set x=$$^%ZMVALID("write 0"_$char(10)_" write 2abc") use $principal:(width=65535) write x'

echo "# Test %ZMVALID works even if pwd does not have write access (i.e. .o file is not created as part of compilation)"
chmod -w .
$ydb_dist/yottadb -run %XCMD 'set x=$$^%ZMVALID("write 0") zwrite x'
chmod +w .

