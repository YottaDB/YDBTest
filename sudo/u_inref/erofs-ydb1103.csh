#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

echo "#############################################################################################"
echo "# Test that database file open does not issue DBFILERR error (EROFS) in read-only file system"
echo "#############################################################################################"

echo "# Create database file mumps.dat with read-write permissions in test output directory"
$gtm_tst/com/dbcreate.csh mumps

echo "# Populate mumps.dat with 3 global nodes ^x(1), ^x(2) and ^x(3)"
$gtm_dist/mumps -run %XCMD 'for i=1:1:3 set ^x(i)=$j(i,3)'

echo "# Create an ext4 fileystem on the file [device_file]"
mkfs -t ext4 device_file 10000 >& mkfs.out

echo "# Mount [device_file] as a loopback file system in [./loopfs] as a read-write filesystem"
mkdir ./loopfs
sudo mount -t ext4 -o loop device_file ./loopfs

echo "# Run [zwrite ^x] with mumps.dat in read-write filesystem and expect to see 3 lines of output"
$gtm_dist/mumps -run %XCMD 'zwrite ^x'

echo "# Copy ./mumps.dat to [./loopfs/mumps.dat]"
sudo cp mumps.dat ./loopfs

echo "# Change mumps.gld to point DEFAULT region to [./loopfs/mumps.dat]"
$gtm_dist/mumps -run GDE "change -seg DEFAULT -file=./loopfs/mumps.dat"

echo "# Unmount ./loopfs and remount it as a read-only filesystem"
sudo umount ./loopfs
sudo mount -t ext4 -o loop,ro device_file ./loopfs

echo "# Run [zwrite ^x] with mumps.dat in read-only filesystem and expect to still see 3 lines of output"
$gtm_dist/mumps -run %XCMD 'zwrite ^x'

echo "# Unmount ./loopfs"
sudo umount ./loopfs

echo "# Change mumps.gld back to point DEFAULT region to [./mumps.dat]"
$gtm_dist/mumps -run GDE "change -seg DEFAULT -file=mumps.dat"

$gtm_tst/com/dbcheck.csh

