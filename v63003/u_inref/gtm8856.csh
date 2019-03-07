#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Running pattern matching with a PATCODE not included in
# the patern table, if statement is produced, it will show
# that the program produced an error at compile time instead of
# run time
#

cat <<EOF > patcode.txt
PATSTART
  PATTABLE NEWLANGUAGE
PATEND
EOF
$ydb_dist/mumps -run gtm8856
