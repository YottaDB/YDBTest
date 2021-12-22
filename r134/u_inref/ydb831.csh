#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '-----------------------------------------------------------------------------------------'
echo '######## Test that $FNUMBER issues LVUNDEF error if input argument is undefined #########'
echo '-----------------------------------------------------------------------------------------'

$ydb_dist/yottadb -direct << YDB_EOF
write "# Expect LVUNDEF error for x variable",!
write \$fnumber(x,"P"),!
write "# Expect LVUNDEF error for x variable",!
write \$fnumber(x,"P","1"),!
write "# Expect LVUNDEF error for y variable",!
write \$fnumber(1,y),!
write "# Expect LVUNDEF error for z variable",!
write \$fnumber(1,"P",z),!
YDB_EOF

