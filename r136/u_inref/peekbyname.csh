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

echo "# Create databases and start replication"
$gtm_tst/com/dbcreate.csh mumps

echo "# Wait for the initial connection to be established"
setenv start_time `cat start_time`
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message "New History Content"

echo "# Check PEEKBYNAME for all fields listed by LIST^%PEEKBYNAME on source side."
echo "# Check there are only a few known errors (maintained in the subtest reference file)."
echo "# The expected errors are supposed to go away when YDB#952 is fixed"
echo "# And having a reference file ensures no new errors get added inadvertently"

echo "# Generate and run srcpeek.m which has all PEEKBYNAME commands for the source side"
$ydb_dist/yottadb -run peekbyname source > srcpeek.m
$ydb_dist/yottadb -direct < srcpeek.m >& srcpeek.out

echo "# Check PEEKBYNAME for all fields listed by LIST^%PEEKBYNAME on receiver side"
echo "# Check there are only a few known errors (maintained in the subtest reference file)."

echo "# Generate and run rcvrpeek.m which has all PEEKBYNAME commands for the receiver side"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $ydb_dist/yottadb -run peekbyname receiver > rcvrpeek.m; $ydb_dist/yottadb -direct < rcvrpeek.m" >& rcvrpeek.out

echo "# Check errors on source side PEEKBYNAME calls"
grep -B 1 'YDB-' srcpeek.out

echo "# Check errors on receiver side PEEKBYNAME calls"
grep -B 1 'YDB-' rcvrpeek.out

# Now that any YDB- messages (YDB-E- or YDB-F- etc.) have been identified by the "grep" above,
# move these files out of the way so the test framework does not identify the same messages again.
mv srcpeek.out srcpeek.outx
mv rcvrpeek.out rcvrpeek.outx

echo "# Shutdown replication servers"
$gtm_tst/com/dbcheck.csh

