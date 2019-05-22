#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that reverse $order/$query functions work correctly when $increment/VIEW "NOISOLATION" is in use
#
#

echo '# Test that reverse $order/$query functions work correctly when $increment/VIEW "NOISOLATION" is in use'

# SETUP of the driver M file
cp $gtm_tst/$tst/inref/ydb449.m .

$gtm_tst/com/dbcreate.csh mumps

# the gdbcmds to be run
cat >> gdbcmds1 << xx
set breakpoint pending on
break gvcst_incr
run -run ydb449 0 0
break t_end
continue
shell $gtm_dist/mumps -run concur^ydb449
delete 1 2
continue
xx
# run the driver under gdb
echo '\nisNoIso = 0, isOrder = 0'
gdb $gtm_dist/mumps -x gdbcmds1 -quiet | grep -i "breakpoint\|Segmentation fault"

sed -i '3c run -run ydb449 0 1' gdbcmds1
echo '\nisNoIso = 0, isOrder = 1'
gdb $gtm_dist/mumps -x gdbcmds1 -quiet | grep -i "breakpoint\|Segmentation fault"

cat > gdbcmds2 << xx
set breakpoint pending on
break op_tcommit
run -run ydb449 1 0
break tp_tend
shell $gtm_dist/mumps -run concur^ydb449
continue
continue
xx
echo '\nisNoIso = 1, isOrder = 0'
gdb $gtm_dist/mumps -x gdbcmds2 -quiet | grep -i "breakpoint\|Segmentation fault"

sed -i '3c run -run ydb449 1 1' gdbcmds2
echo '\nisNoIso = 1, isOrder = 1'
gdb $gtm_dist/mumps -x gdbcmds2 -quiet | grep -i "breakpoint\|Segmentation fault"

$gtm_tst/com/dbcheck.csh
