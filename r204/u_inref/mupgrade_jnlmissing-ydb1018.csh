#!/usr/local/bin/tcsh -f
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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
YDB#1018 - Test of MUPIP UPGRADE for 3 scenarios when journal file is missing
********************************************************************************************

Test the following scenarios from:
1. https://gitlab.com/YottaDB/DB/YDB/-/issues/1018#note_2695983616
2. https://gitlab.com/YottaDB/DB/YDB/-/issues/1018#note_2702018996 (basically previous bullet but with -replic=on also)
3. https://gitlab.com/YottaDB/DB/YDB/-/issues/1018#note_2696001560

CAT_EOF
echo

# Disable MM access method to prevent failures due to %GTM-W-MMBEFOREJNL and %GTM-E-BADDBVER messages appearing in output,
# and the expected %GTM-E-DBUPGRDREQ and %GTM-W-MUNOTALLINTEG messages not appearing.
setenv acc_meth "BG"
setenv ydb_msgprefix "GTM"
# Disable SEMINCR to prevent shared memory segments from being left over due
# to the test system simulating many processes simultaneously accessing a single
# database file. See the following thread for details:
# https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2281
unsetenv gtm_db_counter_sem_incr
setenv gtm_test_use_V6_DBs 0	# Disable V6 mode DBs as this test already switches versions for its various test cases
setenv ydb_test_4g_db_blks 0	# Disable this random hugedb env var as it makes statsdb file integ output non-deterministic
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver

echo "### Test 1: No DBUPGRDREQ error when running MUPIP UPGRADE after an earlier failed MUPIP UPGRADE due to a missing journal file path"
set test_num = T1
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir $test_num.gld
echo "# Create V6 database files"
$gtm_tst/com/dbcreate.csh $test_num >&! dbcreate$test_num.out
$gtm_dist/mumps -run GDE exit >&! gde$test_num.out
echo "# Create V6 journal file in journal file path"
mkdir default
$gtm_dist/mupip set -journal=enable,on,before,file="default/$test_num.mjl" -reg DEFAULT
cp $test_num.gld ${test_num}v6.gld

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Remove journal file path"
rm -rf default
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gde$test_num.out
cp $test_num.gld ${test_num}v7.gld
echo

echo "# Run MUPIP UPGRADE"
yes | $gtm_dist/mupip upgrade -reg "*"
echo "# Run MUPIP INTEG"
$gtm_dist/mupip integ -reg "*"
echo

echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Restore the original V6 .gld to prevent %GTM-E-GDINVALID errors with V63010 and V63011"
cp ${test_num}v6.gld $test_num.gld
echo "# Disable journaling"
$gtm_dist/mupip set -nojournal -reg "*"

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory $gtmgbldir to prevent GDINVALID errors due to restored v6 .gld file above: GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gde$test_num.out
echo "# Run MUPIP UPGRADE"
yes | $gtm_dist/mupip upgrade -reg "*"
echo

echo "### Test 2: No DBUPGRDREQ error when running MUPIP UPGRADE after an earlier failed MUPIP UPGRADE due to a missing journal file path and REPLJNLCNFLCT error when replication is enabled"
set test_num = T2
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir $test_num.gld
echo "# Create V6 database files"
$gtm_tst/com/dbcreate.csh $test_num >&! dbcreate$test_num.out
$gtm_dist/mumps -run GDE exit >&! gde$test_num.out
echo "# Create V6 journal file in journal file path"
mkdir default
$gtm_dist/mupip set -journal=enable,on,before,file="default/$test_num.mjl" -replic=on -reg DEFAULT
cp $test_num.gld ${test_num}v6.gld

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Remove journal file path"
rm -rf default
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gde$test_num.out
cp $test_num.gld ${test_num}v7.gld
echo

echo "# Run MUPIP UPGRADE"
yes | $gtm_dist/mupip upgrade -reg "*"
echo "# Run MUPIP INTEG"
$gtm_dist/mupip integ -reg "*"
echo

echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Restore the original V6 .gld to prevent %GTM-E-GDINVALID errors with V63010 and V63011"
cp ${test_num}v6.gld $test_num.gld
echo "# Disable journaling"
$gtm_dist/mupip set -nojournal -reg "*"

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory $gtmgbldir to prevent GDINVALID errors due to restored v6 .gld file above: GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gde$test_num.out
echo "# Run MUPIP UPGRADE"
yes | $gtm_dist/mupip upgrade -reg "*"
echo

echo "### Test 3: No assert failure or SIG-11 when running MUPIP UPGRADE after an earlier failed MUPIP UPGRADE due to a missing journal file path"
set test_num = T3
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
setenv gtmgbldir $test_num.gld
cat <<CAT_EOF >& expected_order.txt
a.dat
b.dat
T3.dat
CAT_EOF
echo "# Create V6 database files"
touch actual_order.txt
while ("" != `diff expected_order.txt actual_order.txt`)
	# Continually recreate the database files until their inodes result in the desired ordering (in expected_order.txt)
	# This is done to prevent outref irregularities due to regions being processed in different orders depending on inode values.
	rm -f $test_num.dat a.dat b.dat
	$gtm_tst/com/dbcreate.csh $test_num 3 >&! dbcreate$test_num.out
	ls -li *.dat | awk '{print $1, $NF}' | sort -n | sed 's/^[0-9]* \([abT3]*.dat\)/\1/g' >& actual_order.txt
end
$gtm_dist/mumps -run GDE exit >&! gde$test_num.out
$gtm_dist/mupip integ -reg "*" >&! mupipinteg$test_num.out
echo "# Create V6 journal file in journal file path"
mkdir breg
$gtm_dist/mupip set -journal=enable,on,before,file="breg/b.mjl" -reg BREG
$gtm_dist/mumps -run %XCMD 'set ^a=1,^b=2,^c=3'
cp $test_num.gld ${test_num}v6.gld

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Remove journal file path"
rm -f *.o
rm -rf breg
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gde$test_num.out
cp $test_num.gld ${test_num}v7.gld
echo

echo "# Run MUPIP UPGRADE"
yes | $gtm_dist/mupip upgrade -reg "*"
echo

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
