#!/bin/sh
#################################################################
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Tests that $ydb_dist/yottadb, tmp/yottadb, and /tmp/yottadb/<rel> have correct permissions under the following conditions:'
echo '# 1. YottaDB is installed with --group-restriction'
echo '# 2. YottaDB is installed without --group-restriction'
echo '# 3. After install, ydb_env_set is sourced as the root user'
echo '# 4. After install, ydb_env_set is sourced as a non-root user'
echo '# 5. /tmp/yottadb exists before this test is run'
echo '# 6. /tmp/yottadb does not exist before this test is run'
echo

# setup of the image environment
set curr_dir=`pwd`
mkdir install # the install destination
cd install
# we have to make this folder beforehand otherwise the installer will throw out errors
# this happens only when this script is invoked by the test system
# it works fine without permission issues when run as root in an interactive terminal
mkdir gtmsecshrdir
chmod -R 755 .
cp $gtm_tst/$tst/u_inref/tmpyottadbperms-ydb1125.sh  .
foreach i (`seq 1 12`)
	mkdir test$i
end

echo "# Get the group id of the current process"
getent group `ps -o gid -p "$$"` | cut -f 1 -d ":" >& gid.txt
cp gid.txt .. # Save gid.txt file for later
set group = `cat gid.txt`
echo "# Get the YottaDB release number"
set ver_num=`$ydb_dist/mumps -run ^%XCMD 'write $ZYRELEASE' | cut -d" " -f2`
setenv tmp_relname "$ver_num"'_'"$gtm_test_machtype"
set tmp_reldir="/tmp/yottadb/$tmp_relname"
echo "# Get the group of $tmp_reldir, if it already exists"
if ( -d $tmp_reldir ) then
	set relinit_ls=`$gtm_tst/com/lsminusl.csh -L /tmp/yottadb | grep $tmp_relname`
	setenv relinit_group `echo $relinit_ls | cut -d" " -f 4`
endif
source $gtm_tst/$tst/u_inref/setinstalloptions.csh      # sets the variable "installoptions" (e.g. "--force-install" if needed)
setenv sudostr "$sudostr"
echo

echo '### Test 1: Install YottaDB under the following conditions:'
echo '# 1. WITH --group-restriction'
echo '# 2. Run ydb_env_set as non-root user'
echo '# 3. $ydb_tmp is undefined'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-x---].'
echo '# 2. Permissions of [/tmp/yottadb/] are [drwxrwxrwt], or unchanged.'
echo '# 3. Permissions of [/tmp/yottadb/<rel>] are [drwxrwx---], or unchanged.'
sh ./tmpyottadbperms-ydb1125.sh 1 $group "undef"
echo

echo '### Test 2: Install YottaDB under the following conditions:'
echo '# 1. WITHOUT --group-restriction'
echo '# 2. Run ydb_env_set as non-root user'
echo '# 3. $ydb_tmp is undefined'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-xr-x].'
echo '# 2. Permissions of [/tmp/yottadb/] are [drwxrwxrwt], or unchanged.'
echo '# 3. Permissions of [/tmp/yottadb/<rel>] are [drwxrwxrwx], or unchanged.'
sh ./tmpyottadbperms-ydb1125.sh 2 "nogroup" "undef"
echo

echo '### Test 3: Install YottaDB under the following conditions:'
echo '# 1. WITH --group-restriction'
echo '# 2. Run ydb_env_set as non-root user'
echo '# 3. $ydb_tmp is a directory path, WITHOUT <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-x---].'
echo '# 2. Permissions of [$ydb_tmp/..] are unchanged.'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwx---], or unchanged.'
sh ./tmpyottadbperms-ydb1125.sh 3 $group "norel"
echo

echo '### Test 4: Install YottaDB under the following conditions:'
echo '# 1. WITHOUT --group-restriction'
echo '# 2. Run ydb_env_set as non-root user'
echo '# 3. $ydb_tmp is a directory path, WITHOUT <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-xr-x].'
echo '# 2. Permissions of [$ydb_tmp/..] are unchanged.'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwxrwx], or unchanged.'
sh ./tmpyottadbperms-ydb1125.sh 4 "nogroup" "norel"
echo

echo '### Test 5: Install YottaDB under the following conditions:'
echo '# 1. WITH --group-restriction'
echo '# 2. Run ydb_env_set as non-root user'
echo '# 3. $ydb_tmp is a directory path, WITH <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-x---].'
echo '# 2. Permissions of [$ydb_tmp/..] are [drwxrwxrwt], or unchanged.'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwx---], or unchanged.'
sh ./tmpyottadbperms-ydb1125.sh 5 $group "rel"
echo

echo '### Test 6: Install YottaDB under the following conditions:'
echo '# 1. WITHOUT --group-restriction'
echo '# 2. Run ydb_env_set as non-root user'
echo '# 3. $ydb_tmp is a directory path, WITH <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-xr-x].'
echo '# 2. Permissions of [$ydb_tmp/..] are [drwxrwxrwt], or unchanged.'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwxrwx], or unchanged.'
sh ./tmpyottadbperms-ydb1125.sh 6 "nogroup" "rel"
echo

echo '### Test 7: Install YottaDB under the following conditions:'
echo '# 1. WITH --group-restriction'
echo '# 2. Run ydb_env_set as root user'
echo '# 3. $ydb_tmp is undefined'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-x---].'
echo '# 2. Permissions of [/tmp/yottadb/] are [drwxrwxrwt].'
echo '# 3. Permissions of [/tmp/yottadb/<rel>] are [drwxrwx---].'
$sudostr -E sh ./tmpyottadbperms-ydb1125.sh 7 $group "undef"
echo

echo '### Test 8: Install YottaDB under the following conditions:'
echo '# 1. WITHOUT --group-restriction'
echo '# 2. Run ydb_env_set as root user'
echo '# 3. $ydb_tmp is undefined'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-xr-x].'
echo '# 2. Permissions of [/tmp/yottadb/] are [drwxrwxrwt].'
echo '# 3. Permissions of [/tmp/yottadb/<rel>] are [drwxrwxrwx].'
$sudostr -E sh ./tmpyottadbperms-ydb1125.sh 8 "nogroup" "undef"
echo

echo '### Test 9: Install YottaDB under the following conditions:'
echo '# 1. WITH --group-restriction'
echo '# 2. Run ydb_env_set as root user'
echo '# 3. $ydb_tmp is a directory path, WITHOUT <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-x---].'
echo '# 2. Permissions of [$ydb_tmp/..] are unchanged.'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwx---].'
$sudostr -E sh ./tmpyottadbperms-ydb1125.sh 9 $group "norel"
echo

echo '### Test 10: Install YottaDB under the following conditions:'
echo '# 1. WITHOUT --group-restriction'
echo '# 2. Run ydb_env_set as root user'
echo '# 3. $ydb_tmp is a directory path, WITHOUT <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-xr-x].'
echo '# 2. Permissions of [$ydb_tmp/..] are unchanged.'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwxrwx].'
$sudostr -E sh ./tmpyottadbperms-ydb1125.sh 10 "nogroup" "norel"
echo

echo '### Test 11: Install YottaDB under the following conditions:'
echo '# 1. WITH --group-restriction'
echo '# 2. Run ydb_env_set as root user'
echo '# 3. $ydb_tmp is a directory path, WITH <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-x---].'
echo '# 2. Permissions of [$ydb_tmp/..] are [drwxrwxrwt].'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwx---].'
$sudostr -E sh ./tmpyottadbperms-ydb1125.sh 11 $group "rel"
echo

echo '### Test 12: Install YottaDB under the following conditions:'
echo '# 1. WITHOUT --group-restriction'
echo '# 2. Run ydb_env_set as root user'
echo '# 3. $ydb_tmp is a directory path, WITH <rel>'
echo '# Expect the following results:'
echo '# 1. Permissions of [$ydb_dist/yottadb] are [-r-xr-xr-x].'
echo '# 2. Permissions of [$ydb_tmp/..] are [drwxrwxrwt].'
echo '# 3. Permissions of [$ydb_tmp] are [drwxrwxrwx].'
$sudostr -E sh ./tmpyottadbperms-ydb1125.sh 12 "nogroup" "rel"

# Remove test files that will create permission errors during test cleanup
$sudostr rm -rf test*/gtmsecshrdir
$sudostr rm -rf test*/utf8/gtmsecshrdir
$sudostr chmod u+rwx,g+rwx,o+rwx -R test*
$sudostr chown -R $USER\:$group ./*
