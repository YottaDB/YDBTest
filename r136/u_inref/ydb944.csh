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

echo "# Run dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps -blk=1024 -recsize=1000

echo "# Test that no %YDB-E-TPFAIL error (eeee) when cnl->tp_hint is almost 2GiB"
echo "# This test is based on https://gitlab.com/YottaDB/DB/YDB/-/issues/944#note_1152977733"

echo "# Start gdb so we can set cnl->tp_hint = 0x7ffffffe and then run ydb944.m"
gdb -q $ydb_dist/yottadb >& gdb.out << GDB_EOF
set breakpoint pending on
b t_end
run -run ydb944
set cs_addrs->nl->tp_hint = 0x7ffffffe
print/x cs_addrs->nl->tp_hint
delete 1
cont
quit
GDB_EOF

# Only extract lines that we care about from the gdb output as it can contain linux-distribution-specific output
$grep -E '0x7ffffffe|^# ' gdb.out

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh

