#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################


# Make output the same under GT.M and YDB
setenv ydb_prompt 'GTM>'
setenv ydb_msgprefix "GTM"

echo "Access a variable on condition of a false postconditional,"
echo "then access that variable again later in the same line."
echo "Ensure that it causes an error rather than a segfault"
echo "as it did in v70002"

echo "set:0 x=3 write x" | $GTM
