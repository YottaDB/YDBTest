#!/usr/local/bin/tcsh -f
#################################################################
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
#
echo '# Testing '

echo "# Create a 1 region DB region DEFAULT"
echo ''
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "# Create a file, alias.csh, to be sourced by child shells : "
#echo "#			!/usr/local/bin/tcsh -f"
#echo '#			alias cp "jakewashere"'
echo '#			echo "hello world"'

#echo '!/usr/local/bin/tcsh -f'> "alias.csh"
echo 'alias cp "jakewashere"' >> ".cshrc" #"alias.csh"

echo '# Set $SHELL env var to have child shells source alias.csh'
#setenv SHELL "$SHELL -x ./alias.csh"
echo ''

echo '------------------'
echo '$SHELL'": $SHELL"
echo "alias.csh:"
cat alias.csh
echo '------------------'
echo ''

echo "# Running Mupip with "'$SHELL'" set to $SHELL"
$MUPIP BACKUP "*" tstBackup

echo '# Shut down the DB '
$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
if ($status) then
	echo "DB Check Failed, Output Below"
	cat dbcheck_log.txt
endif

