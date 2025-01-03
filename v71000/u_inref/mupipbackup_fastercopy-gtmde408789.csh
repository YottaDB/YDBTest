#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE408789 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE408789)

MUPIP BACKUP -DATABASE attempts to use a faster copy mechanism depending on the support by the kernel,
and by source and destination filesystems. If the source and destination filesystems are different
or the faster copy mechanisms are not available in the kernel, MUPIP BACKUP -DATABASE uses the default
copy mechanism (/bin/cp). Previously, GT.M used faster copy mechanisms only on Linux Kernel 5.3 or above,
and changes due to backporting in Linux kernels could cause MUPIP BACKUP to report an EXDEV error on filesystems
where backups had earlier been supported.

MUPIP BACKUP -ONLINE does not retry backup when it detects a concurrent rollback or on certain errors
during the copy phase of BACKUP. Previously, MUPIP BACKUP -ONLINE incorrectly retried backup when it encountered
a concurrent rollback or an error in the first backup attempt; the workaround was to specify -RETRY=0.
CAT_EOF

echo "##########################################################################################"
echo "Test 1st paragraph of release note"
echo "See https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2213#note_2310214085 for how"
echo "various parts of the above release note are tested in other existing tests and why only"
echo "the below use case is tested here."
echo "##########################################################################################"

setenv ydb_msgprefix "GTM"   # So can run the test under GTM or YDB
setenv gtm_test_disable_randomdbtn # the BACKUPTN messages in this test output rely on transaction numbers, so disable random db tn
echo
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

cat << CAT_EOF | sed 's/^/# /;'
Now we try a backup and we expect to see it complete successfully in two different cases:"
1. Kernel version >= 5.3: ydb_test_copy_file_range_avail is set to 0: Backups are done using the 'faster copy mechanism'"
2. Kernel version < 5.3: ydb_test_copy_file_range_avail is set to 1: Backups are done using 'cp'"

Prior to GT.M V7.1-000, the ydb_test_copy_file_range_avail=1 case would have issued an
EXDEV error on unsupported filesystems. Now, no EXDEV is error is issued in this case.
CAT_EOF

set targetfile = "/tmp/mumps_${user}_$$.dat"	# pick unique name that will not collide with other users/tests
$gtm_dist/mupip backup "*" $targetfile >& mupip.out
rm -f $targetfile
$gtm_dist/mupip backup -dbg "*" $targetfile >>& mupip.out
rm -f $targetfile
echo "# Also filter out %YDB-I-FILERENAME and %YDB-I-JNLCREATE and %YDB-I-FILERENAME lines"
echo "# which appear only occasionally, depending on random settings."
cat mupip.out | grep -vE "FILERENAME|JNLCREATE"
echo

echo "##########################################################################################"
echo "2nd paragraph of release note is not tested, per discussion at:"
echo "https://gitlab.com/YottaDB/DB/YDBTest/-/issues/647#note_2285043070"
echo "##########################################################################################"

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif
