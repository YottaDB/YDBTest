#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Test to ensure that the new format of the"
echo '# "generated from" syslog messages works correctly.'
echo "# In the new format, the syslog message ends by giving the address"
echo "# of the place in the code that generated the syslog message in"
echo "# library_base+offset format."
echo "# We will first test this by generating some syslog messages"
echo "# by freezing and unfreezing a database and confirming that the format"
echo "# of the syslog messages is consistent with library_base+offset."
echo "# Then, we will invoke a Mumps script that will start a new"
echo "# gdb debugging session and check that adding each offset value to the new base value"
echo "# of the library gives the correct code segment, confirming that the offset values are correct."
echo

echo "# Creating database."
$gtm_tst/com/dbcreate.csh mumps
set start_time=`date "+%Y-%m-%d %H:%M:%S"`
echo "# freezing database."
$gtm_dist/mupip freeze -on DEFAULT
echo "# Unfreezing database."
$gtm_dist/mupip freeze -off DEFAULT
echo "# saving syslog"
$gtm_tst/com/getoper.csh "$start_time" "" syslog1.txt ""
echo "# Checking syslog for DBFREEZEON."
grep DBFREEZEON syslog1.txt | grep $tst_working_dir | tail -n 1
echo "# Checking syslog for DBFREEZEOFF."
grep DBFREEZEOFF syslog1.txt | grep $tst_working_dir
set line = `grep DBFREEZEOFF syslog1.txt | grep $tst_working_dir`
echo "# extracting offset from line"
set offset = `echo "$line" | sed -n -E 's/.*[+](0x[0-9A-F]{16})[^+]*/\1/p'`
set baseAddrSyslog = `echo "$line" | sed -n -E 's/.*([0-9A-F]{16})[+]0x[0-9A-F]{16}[^+]*/\1/p'`
echo "# resulting DBFREEZEOFF offset is $offset"

echo
echo "# The next step is to invoke a mumps script that will use a gdb debugging session to"
echo "# print out the place in the code pointed to by the offset value retrieved from"
echo "# the syslog."
echo "# So, the previously calculated value of offset $offset is used."
$gtm_dist/mumps -run ydb858 $offset

echo "# Next, the same test is performed with the DBFREEZEON syslog message."
set line = `grep DBFREEZEON syslog1.txt | grep $tst_working_dir`
echo "# extracting DBFREEZEON offset from line"
set offset = `echo "$line" | sed -n -E 's/.*[+](0x[0-9A-F]{16})[^+]*/\1/p'`
set baseAddrSyslog = `echo "$line" | sed -n -E 's/.*([0-9A-F]{16})[+]0x[0-9A-F]{16}[^+]*/\1/p'`
echo "# resulting DBFREEZEON offset is $offset"

echo
echo "# And again, call the mumps script to test that"
echo "# the offset value is correct this time with the DBFREEZEON offset value."
$gtm_dist/mumps -run ydb858 $offset
