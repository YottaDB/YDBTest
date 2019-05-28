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
echo '# No GDB output will be printed if the test passes'
echo '# If it fails the bad lines will end up in the log file'
echo '# The full gdb output is in the gdb*.out files'

# SETUP of the driver M file
cp $gtm_tst/$tst/inref/ydb449.m .

# the output changes based on gdb version (anything older than 8)
# so we need to get the gdb major version and copy the correct reference file for it
if (`gdb -v | sed -n 1p | awk '{split($NF,a,"."); print a[1]}'` < 8) then
	cp $gtm_tst/$tst/inref/ydb449gdb7.txt toGrep.txt
else
	cp $gtm_tst/$tst/inref/ydb449gdb.txt toGrep.txt
endif

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
head -n 4 toGrep.txt > temp # upper 4 lines are the $incr case

# run the driver under gdb
echo '\nisNoIso = 0, isOrder = 0'
gdb $gtm_dist/mumps -x gdbcmds1 -quiet >& gdb1.out
grep -i "breakpoint\|Segmentation fault" gdb1.out > toCmp1.out
grep -vn -f temp toCmp1.out
if ($status == 1) then
	echo "PASS"
else
	echo "FAIL"
endif

sed -i '3c run -run ydb449 0 1' gdbcmds1
echo '\nisNoIso = 0, isOrder = 1'
gdb $gtm_dist/mumps -x gdbcmds1 -quiet >& gdb2.out
grep -i "breakpoint\|Segmentation fault" gdb2.out > toCmp2.out
grep -vn -f temp toCmp2.out
if ($status == 1) then
	echo "PASS"
else
	echo "FAIL"
endif

cat > gdbcmds2 << xx
set breakpoint pending on
break op_tcommit
run -run ydb449 1 0
break tp_tend
shell $gtm_dist/mumps -run concur^ydb449
continue
continue
xx
tail -n 4 toGrep.txt > temp # lower 4 lines are the VIEW "NOISOLATION" case

echo '\nisNoIso = 1, isOrder = 0'
gdb $gtm_dist/mumps -x gdbcmds2 -quiet >& gdb3.out
grep -i "breakpoint\|Segmentation fault" gdb3.out > toCmp3.out
grep -vn -f temp toCmp3.out
if ($status == 1) then
	echo "PASS"
else
	echo "FAIL"
endif

sed -i '3c run -run ydb449 1 1' gdbcmds2
echo '\nisNoIso = 1, isOrder = 1'
gdb $gtm_dist/mumps -x gdbcmds2 -quiet >& gdb4.out
grep -i "breakpoint\|Segmentation fault" gdb4.out > toCmp4.out
grep -vn -f temp toCmp4.out
if ($status == 1) then
	echo "PASS"
else
	echo "FAIL"
endif

$gtm_tst/com/dbcheck.csh
