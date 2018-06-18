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
echo "# Triggering an IO Permissions Error, expecting a message in $device (would be zero in previous versions)"
$ydb_dist/mumps -run dollardevice^gtm8587
echo ""
echo "# RUNNING TEST FOR $key\rIF YOU SEE THIS THE TEST FAILED">>&temp1.txt
echo "# Ending a read with a new line control character, expecting $key to reflect this (would be null in previous versions)"
$ydb_dist/mumps -run dollarkey^gtm8587 temp1.txt
echo ""
echo "# Ending a read with an EOF, expecting $key to be null"
$ydb_dist/mumps -run dollarkey^gtm8587
