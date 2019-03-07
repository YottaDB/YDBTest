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
echo '# Tests that Error inside indirection usage in direct mode using $ETRAP (not $ZTRAP) does not terminate process'
#
$ydb_dist/mumps -direct << YDB_EOF
	set \$etrap="write \$zstatus,!"
	write "# Trigger DIVZERO error without using indirection in direct mode using \$ETRAP",!
	set z=1/0
	write "# Trigger DIVZERO error using indirection in direct mode using \$ETRAP (this used to terminate process before #324 fixes)",!
	set @"z=1/0"
	write "# Process is still alive",!
	write "# Test that XECUTE ""ZMESSAGE 2"" issues an ENO2 error in direct mode (this used to assert fail in an interim state of #324 code)",!
	xecute "zmessage 2"
	halt
YDB_EOF
