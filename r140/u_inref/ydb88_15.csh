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

(ydb88_exec_test.csh $0 grep '^\#\|tabs' >! expect.out) >&! expect.dbg
sed -i 's/\(WRITE.*with\)\(.*\)\(macs.*\)/\1\ e[SPACES_OR_TAB\]\3/g' expect.out
sed -i 's/\(WRITE.*with\)\(.*\)\(sual.*\)/\1\ vi[SPACES_OR_TAB\]\3/g' expect.out
sed -i 's/\t/\[TAB\]/g' expect.out
sed -i 's/  \+/[SPACES]/g' expect.out
cat expect.out
