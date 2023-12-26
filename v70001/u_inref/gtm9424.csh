#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
GTM-9424 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9424)

1) MUPIP BACKUP -DATABASE uses what seems to be the best copy mechanism available on the kernel to create
   a backup copy of the database. If the copy mechanism supports monitoring, MUPIP BACKUP -SHOWPROGRESS
   periodically displays the transfer progress, estimated time left, speed, and the number of transaction
   applied to the database during backup. Pressing CTRL_C performs the appropriate cleanup and exits the
   BACKUP command. Previously, MUPIP BACKUP used cp or pax for copy phase and did not have a progress
   monitoring mechanism. On kernels where the copy mechanism supports robust error handling, MUPIP BACKUP
   handles error conditions such as ENOMEM, ENOSPC, EIO, and so on with a more descriptive action message.

2) MUPIP BACKUP displays the BKUPFILPERM message when it finds that there is no write permission for the
   backup file. MUPIP BACKUP performs this check before starting BACKUP. Previously, MUPIP BACKUP reported
   this condition after performing the copy.

3) The -RETRY=n qualifier of MUPIP BACKUP -DATABASE makes n number of attempts to retry performing BACKUP
   if the backup fails. If -RETRY is not specified, GT.M defaults -RETRY to zero (0). In case of an error,
   retry attempts are always based on cp or pax. Previously, the -RETRY qualifier was not available.(GTM-9424)

##########################################################################################
Test 1 : Test 1st paragraph of release note
##########################################################################################
a) The [best copy mechanism] mentioned in the 1st paragraph of the release note is one that invokes the
copy_file_range() system call in the YDB code. I did verify manually that on a 2Gb sized database
(filled by running the M command [for i=1:1:10000000 set ^x(i)=\$j(i,200)]), GT.M V7.0-001 takes 23%
less elapsed time than GT.M V7.0-000 when measured using the shell builtin [time] command. The same
time improvement is seen even between YottaDB master (which has V7.0-001 merged) and r1.38 (which only
has GT.M V6.3-014 merged). It is not easy to automate this test of performance improvement so that is
not tested here.

b) The [MUPIP BACKUP -SHOWPROGRESS] command and its output is tested (though in a primitive form) in the
v70001/gtm4272 subtest (in Test # 2) as part of commit 81a7f6d8. That is as good of an automated test
case we can easily come up with.

c) The [ENOMEM, ENOSPC, EIO] error handling part is tested by trying to backup to a target file system that
is a different mount point than the current file system. We use /tmp for that purpose. We expect an
error message corresponding to the EXDEV error code (Error code: 18, Invalid cross-device link) in the
mupip backup output. That is considered enough of a test of other error return values from copy_file_range()
like ENOMEM, ENOSPC, EIO etc.

d) The [CTRL_C] part of the release note is tested by issuing a Ctrl-C to a backup command while it is
running and expecting to see a %YDB-I-BACKUPCTRL message in the output followed by a %YDB-E-MUNOFINISH.
In addition, we also check that the target directory has no files created (i.e. appropriate cleanup was done).
CAT_EOF

setenv gtm_test_disable_randomdbtn # the BACKUPTN messages in this test output rely on transaction numbers, so disable random db tn

echo
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

# Skip below stage of the test if copy_file_range() is not available as the EXDEV error is not issued in that case.
# Also skip the below stage if Ubuntu 20.04. Although copy_file_range() is available there, the EXDEV error does not
# show up for reasons not clear. Since that is an old version of Ubuntu, we just skip this stage of the test there.
if (($ydb_test_copy_file_range_avail) && (("ubuntu" != $gtm_test_linux_distrib) || ("20.04" != $gtm_test_linux_version))) then
	# copy_file_range() is guaranteed to issue EXDEV error only if source and target file systems are different.
	# If they are the same, it can issue an error in the following case (pasted from https://lwn.net/Articles/846403/)
	#     When called from user space, copy_file_range() will only try to copy a file across filesystems
	#     if the two are of the same type, and if that filesystem has explicit support for the system call
	# Hence attempting the backup only if the file systems are of different type.
	# But for reasons not clear, even if the file systems are different, on AARCH64 and ARMV6L, the EXDEV error code
	# does not show up. It is not considered worth it to further investigate that and so this part of the subtest
	# is disabled on those platforms.
	if (($tst_dir_fstype != $tmp_dir_fstype) && ("armv6l" != `uname -m`) && ("aarch64" != `uname -m`)) then
		echo "# ------------------------------"
		echo "# Test (1c) : EXDEV error code from MUPIP BACKUP"
		echo "# ------------------------------"
		echo "# Try running mupip backup with target directory of /tmp (which is different mount point)"
		echo "# Expect to see [Error code: 18, Invalid cross-device link] error."
		set targetfile = "/tmp/mumps_${user}_$$.dat"	# pick unique name that will not collide with other users/tests
		$MUPIP backup "*" $targetfile
		echo "# ------------------------------"
		echo "# Test the following line of the 3rd paragraph of the GT.M release note"
		echo "#     In case of an error, retry attempts are always based on cp or pax."
		echo "# Try running mupip backup with target directory of /tmp but with [-retry=2]"
		echo "# We expect to see [Error code: 18, Invalid cross-device link] error in the first attempt."
		echo "# But we expect the second attempt to succeed because it will happen with cp (not copy_file_range())"
		echo "# Expect to see 1 BKUPRETRY message for the second attempt."
		echo "#"
		echo "# Note that Test (1c) did not run backup with [-retry] and therefore also tested the following line"
		echo "# of the 3rd paragraph of the GT.M release note. The output there would not have had any BKUPRETRY messages."
		echo "#     If -RETRY is not specified, GT.M defaults -RETRY to zero (0)"
		echo "# ------------------------------"
		$MUPIP backup -retry=2 "*" $targetfile
		rm -f $targetfile
	endif
endif

echo "# ------------------------------"
echo "# Test (1d) : Ctrl-C results in BACKUPCTRL error message"
echo "# ------------------------------"
echo "# Fill the .dat file with enough updates to make sure the mupip backup command runs for a while so we can Ctrl-C it."
$gtm_dist/mumps -run %XCMD 'for i=1:1:100000 set ^x(i)=$j(i,200)'
mkdir bak1
(expect -d $gtm_tst/$tst/u_inref/gtm9424.exp > expect.out) >& expect.dbg
if ($status) then
        echo "EXPECT-E-FAIL : expect returned non-zero exit status"
endif
mv expect.out expect.outx       # move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect.outx > expect_sanitized.outx
echo "# Filter out lines containing %YDB from mupip backup output. Expect to see BACKUPCTRL and MUNOFINISH messages."
echo "# Remove the [^C] character from the output as it can show up in an arbitrary position making the output non-deterministic."
echo "# Also filter out %YDB-I-FILERENAME and %YDB-I-JNLCREATE lines as the journal file switch may or may not happen depending"
echo "# on where in the mupip backup process flow the Ctrl-C interrupts."
echo "# Additionally, the %YDB-I-BACKUPCTRL could show up sometimes without being in a new line depending on when the"
echo "# Ctrl-C happens. Therefore ensure it always starts at a new line using a [sed] command below."
sed 's/\^C//;s/%YDB-I-BACKUPCTRL/\n&/;' expect_sanitized.outx | $grep YDB | grep -vE "FILERENAME|JNLCREATE"
echo
echo "# Check that [bak1] directory has NO files in it (i.e. appropriate cleanup happened in [mupip backup] command)."
echo "# Running [ls -l bak1]. Expecting no output."
ls -l bak1

echo "############################################################################################"
echo "# Test 2 : Test 2nd paragraph of release note"
echo "############################################################################################"

echo "# Test that BKUPFILPERM message is issued in case of no write permission to target backup file"
echo "# Also test that this message is issued BEFORE any starting the BACKUP. This is done by issuing"
echo "# a mupip backup command using the [-dbg] qualifier and expecting to not see any [MUPIP INFO] messages"
echo "# as seeing those would mean backup did some work BEFORE issuing the error."
echo "# Create target file [bak1/mumps.dat] and remove write permissions on it"
touch bak1/mumps.dat
chmod -w bak1/mumps.dat
echo "# Run [mupip backup -replace -noonline -dbg * bak1/mumps.dat]"
echo "# Need to use [-replace] to be able to overwrite an existing target file"
echo "# Need to use [-noonline] to avoid a FILEEXISTS error that shows up before the BKUPFILPERM code path in the -online case"
echo "# Expect to see BKUPFILEPERM and MUNOFINISH errors below"
$MUPIP backup -replace -noonline -dbg "*" bak1/mumps.dat

echo "# ------------------------------"
echo "# Test the following line of the 3rd paragraph of the GT.M release note"
echo "#     The -RETRY=n qualifier of MUPIP BACKUP -DATABASE makes n number of attempts to retry"
echo "#     performing BACKUP if the backup fails."
echo "# Rerun the same mupip backup command as the previous stage but with [-retry=3]"
echo "# We expect to see BKUPFILPERM message 3 times along with 2 BKUPRETRY messages for the 2nd and 3rd attempts."
echo "# Run [mupip backup -replace -noonline -retry=3 * bak1/mumps.dat]"
echo "# ------------------------------"
$MUPIP backup -replace -noonline -retry=3 "*" bak1/mumps.dat

echo "# Do dbcheck on database"
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif

