#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Testing '

echo "# Create a 1 region DB region DEFAULT"
echo ''
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Create a file, shell.csh, to be sourced by child shells : "

echo '#\!/usr/local/bin/tcsh -f' 				> "shell.csh"
echo 'set echo ; set verbose'					>> "shell.csh"
echo 'alias cp "jakewashere"' 					>> "shell.csh"
echo '# ^MUPIP BACKUP uses the cp command internally' 		>> "shell.csh"
echo '# and used to fail in environments with cp aliases'	>> "shell.csh"
echo ''								>> "shell.csh"
echo 'if ( "$1" == "-c") then' 					>> "shell.csh"
echo '	shift ' 						>> "shell.csh"
echo 'endif' 							>> "shell.csh"
echo 'echo "$*" > script.csh'					>> "shell.csh"
echo 'source script.csh'					>> "shell.csh"
echo ''

chmod +x ./shell.csh
chmod +rw ./

echo 'cat shell.csh'
cat ./shell.csh
echo ''

echo '# Set $SHELL env var to have child shell shell.csh '
setenv SHELL "$PWD/shell.csh"
echo ''

echo "# Running Mupip with "'$SHELL'" ./shell.csh"
$MUPIP BACKUP "*" tstBackup >>& backup_log.txt
if ($status) then
	echo "MUPIP BACKUP RETURNED AN ERROR"
	cat backup_log.txt
endif

grep -e "%YDB-I-BACKUPSUCCESS" backup_log.txt


echo '# Shut down the DB '
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif

