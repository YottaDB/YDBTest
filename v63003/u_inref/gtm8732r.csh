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
# Testing valid inputs for LOG_INTERVAL and HELPERS for
# MUPIP REPLICATE -RECEIVER
#

set x = `$ydb_dist/mumps -run ^%XCMD "write 2**31-1"`
set y = `$ydb_dist/mumps -run ^%XCMD "write 2**31"`
set rand = `$gtm_tst/com/genrandnumbers.csh 1 0 $x`
set rand128 = `$gtm_tst/com/genrandnumbers.csh 1 1 128`
echo '# Creating data base'
$gtm_tst/com/dbcreate.csh mumps 1>>db.out

echo '# Running changelog with LOG_INTERVAL 0'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -CHANGELOG -LOG=a.log -LOG_INTERVAL=0"

echo '# Running changelog with LOG_INTERVAL 2^31-1'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -CHANGELOG -LOG=s.log -LOG_INTERVAL=$x"

echo '# Running changelog with LOG_INTERVAL a random number <=2^31-1'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -CHANGELOG -LOG=a.log -LOG_INTERVAL=$rand"

echo '# Running changelog with LOG_INTERVAL 2^31(expecting an error)'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -CHANGELOG -LOG=s.log -LOG_INTERVAL=$y"

echo '# Running changelog with LOG_INTERVAL -1 (expecting an error)'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -CHANGELOG -LOG=a.log -LOG_INTERVAL=-1"

echo '# Setting Helpers to 1'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -START -HELPERS=1"

echo '# Resetting Helpers and Setting to 128'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -SHUTDOWN -HELPERS -TIMEOUT=0">>&mute.out
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -START -HELPERS=128"

echo '# Resetting Helpers and Setting to a Random Number [1,128]'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -SHUTDOWN -HELPERS -TIMEOUT=0">>&mute.out
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -START -HELPERS=$rand128"

echo '# Resetting Helpers and Setting to 129 (error expected)'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -SHUTDOWN -HELPERS -TIMEOUT=0">>&mute.out
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -START -HELPERS=129"

echo '# Resetting Helpers and Setting to 0 (error expected)'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -SHUTDOWN -HELPERS -TIMEOUT=0">>&mute.out
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replicate -RECEIVER -START -HELPERS=0"

echo '# Shutting down database'
$gtm_tst/com/dbcheck.csh>>&db.out
