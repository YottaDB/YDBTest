#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Autorelink is disabled for this test for now because it seems to be causing SIG-11s for the
# write 2*2 command due to some kind of issue that may be a valgrind issue and not a ydb issue.
# This appears to be related to valgrind's -q option which is necessary to keep the reference
# file simple.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

echo "# Test invoking YottaDB via valgrind does not produce a %YDB-E-YDBDISTUNVERIF"

# valgrind on the following systems has been seen to give an extra warning when the test runs with huge pages randomly enabled.
#	SUSE Enterprise Linux Desktop (version "valgrind-3.18.1")
#	OpenSUSE Tumbleweed (version "valgrind-3.19.0")
# The warning shows up as follows
#	==63815== WARNING: valgrind ignores shmget(shmflg) SHM_HUGETLB
# Interestingly, some systems with the above distribution and valgrind version do not issue the warning.
# In any case, we filter this out to avoid false test failures.
set filter="WARNING: valgrind ignores shmget(shmflg) SHM_HUGETLB"

$echoline
echo "# First test valgrind -q $ydb_dist/yottadb -version"
valgrind -q $ydb_dist/yottadb -version >& valgrind1.out
if ($status) then
	echo "valgrind invocation failed : See valgrind1.out for details"
	exit 1
endif
grep -v "$filter" valgrind1.out

$echoline
echo '# Create a database and test valgrind -q $ydb_dist/mupip integ -reg "*"'
$gtm_tst/com/dbcreate.csh mumps

# When running "mupip integ -reg *" on an encrypted database through valgrind, a few warnings show up
# during the dlopen() of the encryption plugin .so file. Those warnings are outside YDB or YDBEncrypt
# code base so we suppress those warnings by using the below suppression file. Having this suppression
# file even with "-noencrypt" does not hurt so we use this file in all cases below.
set supp_file = ydb704_mupip_integ.supp
cat > $supp_file << CAT_EOF
{
	ydb704_1
	Memcheck:Addr8
	fun:strncmp
	fun:is_dst
	fun:_dl_dst_count
}
{
	ydb704_2
	Memcheck:Addr8
	fun:strncmp
	fun:is_dst
	fun:_dl_dst_substitute
}
CAT_EOF

valgrind --suppressions=$supp_file -q $ydb_dist/mupip integ -reg "*" >& valgrind2.out
if ($status) then
	echo "valgrind invocation failed : See valgrind2.out for details"
	exit 1
endif
grep -v "$filter" valgrind2.out

$echoline
echo "# Finally, test invoking a YottaDB command to write the result of 2*2 with valgrind."
valgrind -q $ydb_dist/yottadb -run ^%XCMD 'write "2*2 = ",2*2,!' >& valgrind3.out
if ($status) then
	echo "valgrind invocation failed : See valgrind3.out for details"
	exit 1
endif
grep -v "$filter" valgrind3.out

