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
#
#
set key='$KEY'
set device='$DEVICE'
setenv gtm_chset "UTF-8"
echo "RUNNING TEST FOR $key"
echo "RUNNING TEST FOR $key\rIF YOU SEE THIS THE TEST FAILED">>&temp1.txt
$ydb_dist/mumps -run gtm8587 temp1.txt
echo "RUNNING TEST FOR $device"
$ydb_dist/mumps -run gtm8587
