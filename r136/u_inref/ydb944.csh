#################################################################
#								#
# Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Turn off statshare related env var as this test relies on a specific flow (breakpoint in t_end.c in the debugger
# is hit for the non-stats region) and enabling stats regions affects that flow by breaking in the stats region.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

# Turn off V6 DB randomization in dbcreate.csh as this test relies on the current version creating the database.
# If an older version creates the database, it might not fail reliably (in builds without the fix) like it otherwise would.
setenv gtm_test_use_V6_DBs 0   # Disable V6 DB mode in dbcreate.csh

echo "# Run dbcreate.csh"
$gtm_tst/com/dbcreate.csh mumps -blk=1024 -recsize=1000

echo "# Test that no %YDB-E-TPFAIL error (eeee) when cnl->tp_hint is almost 2**31 (for V6) or 2**63 (V7)"
echo "# This test is based on https://gitlab.com/YottaDB/DB/YDB/-/issues/944#note_1152977733"

# Check if database has 4-byte (V6 format) or 8-byte (V7 format) block numbers
# We figure this out by dumping the first record in block 1 in the database.
# If the record size is C then we know it is V7. If not, it must be 8 and V6 format.
set recsize = `$gtm_dist/dse dump -block=1 |& $grep Rec | $tst_awk '{print $7}'`
if ("C" == $recsize) then
	# V7 == 8-byte block numbers
	set hint = 0x7ffffffffffffffe
else
	# V6 == 4-byte block numbers
	set hint = 0x7ffffffe
endif

echo "# Start gdb so we can set cnl->tp_hint = 0x7ffffffe (for V6) or 0x7ffffffffffffffe (for V7) and then run ydb944.m"
gdb -q $gtm_dist/mumps >& gdb.out << GDB_EOF
set breakpoint pending on
b t_end
run -run ydb944
set cs_addrs->nl->tp_hint = $hint
print/x cs_addrs->nl->tp_hint
delete 1
cont
quit
GDB_EOF

# Only extract lines that we care about from the gdb output as it can contain linux-distribution-specific output
$grep -Ew '$hint|^#' gdb.out

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh

