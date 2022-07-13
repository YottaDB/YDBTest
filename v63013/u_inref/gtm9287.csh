#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

echo "# This test checks that the correct line numbers are reported"
echo "# for syntax errors in M files longer than 64K-1 lines."
echo "# Prior to V6.3-013 the error messages with line numbers in"
echo "# excess of that size were reported incorrectly, as modulo 64Ki."

set filename = "ydb451largemfile"
set i = 1
while ($i < 65536)
 echo ' set i=$get(i)+1' >> $filename.m
 @ i++
end
echo " xyoffend" >> $filename.m

echo ""
echo "# Compiling the routine"
$ydb_dist/yottadb $filename.m

echo ""
echo "# Running the routine"
$ydb_dist/yottadb -run $filename

