#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies the population of relink-control file entries and overflow behavior with ZRUPDATEs.
# It invokes a script to do 1M + 1 ZRUPDATEs on actual files and validate the resultant RCTLDUMP.

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_autorelink_ctlmax gtm_autorelink_ctlmax 1000000

# First, create a temporary file system to avoid having to remove 1M files at the end.
set tmpFS = tmpfs
mkdir $tmpFS
$gtm_com/IGS MOUNT $tmpFS 100000 2048
if ($status) then
	echo "TEST-E-FAIL, Mounting tmpfs failed. Exiting test now."
	exit 1
endif
echo "$gtm_com/IGS UMOUNT `pwd`/$tmpFS" >>& ../cleanup.csh

# Extract the files.
cd $tmpFS
$tst_gunzip -d < $gtm_test/big_files/autorelink/1M_dot_Os.tar.gz | tar -xf -
(ls -1 files | wc -l > ../file-count.txt &)
(df -khTa >&! ../tmpfs-usage.txt &)
cd ..

# Do the ZRUPDATEs and validate the RCTLDUMP.
$gtm_dist/mumps -run bigrctl $tmpFS/files

# Unmount the file system.
$gtm_com/IGS UMOUNT $tmpFS
$grep -v "UMOUNT" ../cleanup.csh >&! ../cleanup.csh.bak
mv ../cleanup.csh.bak ../cleanup.csh
