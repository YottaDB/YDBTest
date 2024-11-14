#!/usr/local/bin/tcsh -f

#################################################################
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# C9H09-002905 Source server should log only AFTER sending at least 10000 transactions on the pipe

if (! $?test_replic) then
	echo "This subtest is applicable only with -replic. Exiting."
	exit
endif

$gtm_tst/com/dbcreate.csh mumps		# create database and start replication servers
$gtm_exe/mumps -run c002905		# generate updates
$gtm_tst/com/dbcheck.csh -extract	# shut down replication servers and do data check between primary and secondary

# Check that REPL INFO messages show up only after at least 10000 transactions.
$tst_awk -f $gtm_tst/$tst/inref/c002905.awk SRC_*.log
