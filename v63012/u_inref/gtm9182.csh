#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Most of this test was based on the v63003/gtm4212 test which checks for"
echo "# a FILENAMETOOLONG error for temp file paths that are >= 255 characters."
echo "# The gtm9182 issue was similar to this one but subtly different as the"
echo "# bug here was that the error wasn't returned immediately if the temp"
echo "# file's path was < 255 characters but the backup file's path was"
echo "# > 255 characters. The gtm9182 changes only fixed this for backups"
echo "# where a backup filename not a directory was specified. The YDB#864"
echo "# changes address issues with backups incorrectly succeeding where a"
echo "# directory is specified. This test covers both of these cases."

cat >> gtm9182.m << xx
	write \$ZDIRECTORY
nozdir
	write \$translate(\$justify(" ",\$zcmdline-\$length(\$zdirectory))," ","a")
	quit
longfilename
	for i=1:1:\$zcmdline write \$extract("habcdefg",i#8+1)
xx

$echoline
echo "# As the length of the temp file, including the trailing / is 24 (an example"
echo "# is DEFAULT_0000c4be_XXXXXX where the 0000c4be part is randomly generated)"
echo "# and the length of a database called 'mumps', including '.dat' and the"
echo "# trailing / is 10, we create a database called 'mumpsmumpsmumpsmumpsm' so that"
echo "# it will be 26 characters long, 2 character longer than the temp file path."
echo "# This is 2 characters longer than the temp file path because a directory"
echo "# path + temp file of exactly 255 characters produces an error but a backup"
echo "# file path of exactly 255 characters works fine. An attempt to modify the"
echo "# GTM-4212 changes to allow a path + temp file of exactly 255 resulted in"
echo "# a %SYSTEM-E-ENO22 error when the MKSTEMP() macro attempted to create the"
echo "# temp file. Hence the database file name must be at least 2 characters"
echo "# longer than the temp file to produce an error that we wouldn't see with"
echo "# just the GTM-4212 changes. We also disable journaling on this database."
echo "# This is necessary because the journals would sometimes fill up, producing"
echo "# test failures due to YDB-I-JNLCREATE and YDB-I-FILERENAME messages"

$gtm_tst/com/dbcreate.csh mumpsmumpsmumpsmumpsm 1
setenv ydb_gbldir mumpsmumpsmumpsmumpsm.gld
$MUPIP set -file -nojournal mumpsmumpsmumpsmumpsm.dat

if ("dbg" == "$tst_image") then
	setenv gtm_white_box_test_case_enable   1
	setenv gtm_white_box_test_case_number   203	# WBTEST_YDB_STATICPID so FILEPARSE error due to temporary file name length
							# (which includes pid) occurs at deterministic target backup directory
							# path length.

	$echoline
	echo "# Run MUPIP BACKUP with backup directory path lengths of 209, 210 and 211."
	echo "# We expect the first one to succeed and the other 2 to fail with FILENAMETOOLONG error."
	foreach i (209 210 211)
		$ydb_dist/mumps -run gtm9182 $i >>& a$i.out
		set dir = `cat a$i.out`
		mkdir -p $dir
		$echoline
		echo "# Backing up DEFAULT Region to path length $i"
		$MUPIP BACKUP "DEFAULT" $dir >& bck$i.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck$i.outx
	end

	unsetenv gtm_white_box_test_case_number
	unsetenv gtm_white_box_test_case_enable
endif

$echoline
echo "# Backing up DEFAULT region to full file path of 250 characters"
echo '# with $ydb_baktmpdir set to a shorter path. This backup will'
echo "# incorrectly succeed without the YDB#864 changes but fail with"
echo "# a FILENAMETOOLONG error with YDB#864."
$ydb_dist/mumps -run gtm9182 250 >>& a250.out
set dir = `cat a250.out`
mkdir -p $dir
mkdir -p backup
setenv ydb_baktmpdir `pwd`/backup
$MUPIP BACKUP "DEFAULT" $dir >& bck_tmpdir.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck_tmpdir.outx

$echoline
echo "# Backing up DEFAULT region to relative file path of 255 characters."
echo "# This should produce a FILENAMETOOLONG error since the absolute file path is more than 255 characters long."
$ydb_dist/mumps -run nozdir^gtm9182 255 >>& a255.out
set dir = `cat a255.out`
mkdir -p $dir
$MUPIP BACKUP "DEFAULT" $dir >& bck_tmpdir.outx; $grep -Ev 'FILERENAME|JNLCREATE' bck_tmpdir.outx
unsetenv ydb_baktmpdir

$echoline
echo "# Testing a 255 character backup file name with no file path."
echo "# This should produce a FILENAMETOOLONG error since the absolute file path is more than 255 characters long."
$ydb_dist/mumps -run longfilename^gtm9182 255 >> longfilename255.out
set file = `cat longfilename255.out`
$MUPIP BACKUP DEFAULT $file

$echoline
echo "# Testing a 256 character backup file name with no file path."
echo "# This should produce a SYSTEM-E-ENO36 error on both YottaDB"
echo "# and upstream versions."
$ydb_dist/mumps -run longfilename^gtm9182 256 >> longfilename256.out
set file = `cat longfilename256.out`
$MUPIP BACKUP DEFAULT $file

$echoline
$gtm_tst/com/dbcheck.csh
