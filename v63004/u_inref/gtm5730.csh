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

$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.outx

echo "# Get start time (used in .updproc file name)"
setenv start_time `cat start_time` # start_time is used in naming conventions

echo "# Run gtm5730.m to update DB 2000 times"
$gtm_dist/mumps -run gtm5730 > gtm5730.m.log

echo "# RF_sync to allow reciever to catch up"
$gtm_tst/com/RF_sync.csh

echo "# Dump .updproc file from recieving side to rcvr.updproc"
$sec_shell 'cat $SEC_DIR/RCVR_'${start_time}.log.updproc'' >& rcvr.updproc

echo "# Search rcvr.updproc for non-numerical type descriptor"
$ydb_dist/mumps -run LOOP^%XCMD --xec=';write:$zfind(%l,"Rectype") $zpiece(%l,":",5)," ",$zpiece(%l,":",6),!;' < rcvr.updproc

$gtm_tst/com/dbcheck.csh >& dbcheck.outx

