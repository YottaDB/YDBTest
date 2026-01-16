#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Some explanation on what this awk program does.
#
# Below is the content of the file D9G12002636.txt.
#
#     31 YDB>zshow "S"
#     32 d002636+99^d002636    (Direct mode)
#     33
#     34 YDB>zshow "D"
#     35 ##TEST_AWK[a-zA-Z0-9/]* OPEN TERMINAL NOPAST NOESCA NOREADONLY TYPE WIDTH=[1-9][0-9]* LENG=[1-9][0-9]* TTSYNC NOHOSTSYNC
#     36
#     37 YDB>zcontinue
#     38
#     39 PASS direct mode was interrupted
#
# When the subtest is run with "ydb_readline=1", it is possible to see empty lines between lines 31 and 32,
# 34 and 35 AND 37 and 38 if a "mupip intrpt" that the test sends interrupts the process in direct mode
# while in the middle of keying in the commands in lines 31, 34 and 37 respectively.
# See https://gitlab.com/YottaDB/DB/YDB/-/issues/1039#note_3013362828 for more details.
#
# Because a "mupip intrpt" need not always happen in the middle of the direct mode keyboard entry, these empty
# lines are not guaranteed to be there always and hence cannot be part of the reference file either.
#
# Therefore, until YDB#1039 is fixed to not print that empty line, this awk script removes those random empty lines.
#
# For zshow "S" and zshow "D", we check if there is an empty line immediately afterwards.
#	Hence the "check_for_empty_line1" variable usage for this case.
# For zcontinue, there is already an empty line (line 38 above) in the reference file.
#	So we check if there is an empty line AFTER that. Hence the "check_for_empty_line2" variable for this case.
#

BEGIN				{ check_for_empty_line1 = 0; check_for_empty_line2 = 0; }
$0 == "YDB>zshow \"S\""		{ check_for_empty_line1 = 1; print $0; next; }
$0 == "YDB>zshow \"D\""		{ check_for_empty_line1 = 1; print $0; next; }
$0 == "YDB>zcontinue"		{ check_for_empty_line2 = 2; print $0; next; }
1 == check_for_empty_line1	{ check_for_empty_line1 = 0; if ($0 == "") next; }
2 == check_for_empty_line2	{ check_for_empty_line2 = 1; print $0; next; }
1 == check_for_empty_line2	{ check_for_empty_line2 = 0; if ($0 == "") next; }
				{ print $0; }
END				{ }

