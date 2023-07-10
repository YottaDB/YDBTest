#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#

#
# Usage :
#	compare_backup_db_sz.csh <path_to_database> <path_to_backup>
#
if ($#argv != 2) then
	echo Usage : compare_backup_db_sz.csh <path_to_database> <path_to_backup>
	exit 0
endif
#The backup size has been reduced only on AIX and Linux. so exit the test if not these platforms.
if ($gtm_test_osname !~ {linux,aix}) then
	exit 0
endif

if (0 != $ydb_test_4g_db_blks) then
	# If > 4g db blocks testing scheme is enabled, we will have a big HOLE in the db file and that disturbs
	# the allocated portion of the file (output by "ls -s" below) and will in turn cause a test failure.
	# Therefore do not do this check if that scheme is enabled.
	exit 0
endif

set db_file=$argv[1]
set bkup_file=$argv[2]
set db_sz=`ls -s $db_file | $tst_awk '{print $1}'`
set backup_sz=`ls -s $bkup_file | $tst_awk '{print $1}'`
if ($backup_sz > $db_sz) then
	set outdir="dat_files.bak_`date +%s`_$$"
	mkdir $outdir
        echo "BACKUP-E-SIZE : size of backup is more than size of DB!"
	echo "DB Size : $db_sz , File : $db_file ... "
	echo "Backup Size : $backup_sz , File : $bkup_file ... "
	echo "DB File copied to $outdir"
	# Not copying the backup dir, as it should not have been tampered.
	if ("linux" == $gtm_test_osname) then
		cp --sparse=always $db_file $outdir/$db_file
	else # AIX
		pax -r -w $db_file $outdir/$db_file
	endif
endif

