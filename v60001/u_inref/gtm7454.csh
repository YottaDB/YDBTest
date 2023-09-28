#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test online fast integrity check during the reorg operations, which can set the cs->mode as gds_t_busy2free
setenv gtm_test_mupip_set_version "V5"
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to differences in MUPIP REORG output
# The white-box setting is to delay the integ process to 30 seconds
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 26
setenv gtm_white_box_test_case_count 1
#the following offset is necessary tu run the waitforOLIstart.csh
$gtm_tools/offset.csh node_local gtm_main.c >&! offset.out
setenv hexoffset `$grep -w wbox_test_seq_num offset.out | sed 's/\].*//g;s/.*\[0x//g'`
echo $hexoffset >! hexoffset.out

# mupip reorg -truncate feature is supported only with the BG access method.
source $gtm_tst/com/gtm_test_setbgaccess.csh
#key size:64, record size:1000, block size:2048
$gtm_tst/com/dbcreate.csh mumps 1 64 1000 2048

# Test update of level-0 directory tree
echo "# Create a level-0 block in directory tree"
$GTM <<EOF
set ^a(1)=1
h
EOF

echo "# Now start integ"
($MUPIP integ -online -fast -preserve -r DEFAULT  & ; echo $! >! fast_oli.pid ) >& fast_oli.outx
set fast_pid=`cat fast_oli.pid`
$gtm_tst/com/waitforOLIstart.csh

echo "# Update level-0 block in directory tree by reorg"
$MUPIP reorg -truncate
$GTM <<EOF
set ^b(1)=1
h
EOF

echo "# Wait for background online integ to complete"
$gtm_tst/com/wait_for_proc_to_die.csh $fast_pid 120
#rm ydb_snapshot*

# Test 2: mixed updates with kill and reorg
$GTM <<EOF
for i=1:1:50001 set ^x(i)=\$j(i,20)
EOF

echo "# Now start integ"
($MUPIP integ -online -fast -preserve -r DEFAULT  & ; echo $! >! fast_oli2.pid ) >& fast_oli2.outx
set fast_pid2=`cat fast_oli2.pid`
$gtm_tst/com/waitforOLIstart.csh

echo "# Start database update"
foreach updateX  (1 10001 20001 30001 40001)
	$GTM <<EOF
		set start=$updateX
		set end=$updateX+9999
		for i=start:1:end kill ^x(i)
EOF

	$MUPIP reorg -truncate

	@ updateY = 50000 - $updateX
	$GTM <<EOF
		set start=$updateY-9999
		set end=$updateY
		for i=start:1:end set ^y(i)=\$j(i,20)
EOF

end

echo "# Wait for background online integ to complete"
$gtm_tst/com/wait_for_proc_to_die.csh $fast_pid2 120
if ($status) then
	echo "# `date` TEST-E-TIMEOUT waited 120 seconds for online integ $fast_pid2 to complete."
	echo "# Exiting the test."
	exit
endif

setenv gtm_white_box_test_case_enable 0

$gtm_tst/com/dbcheck.csh
