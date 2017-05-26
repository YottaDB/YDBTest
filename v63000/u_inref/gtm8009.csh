#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Journal enable is done in this test. So let's not randomly enable journaling in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL

# Create the database
$gtm_tst/com/dbcreate.csh mumps

# Enable journaling
$MUPIP set -journal="enable,on,nobefore" -reg "*" >& mupip_set_jnl.log

# Compile our program that determines file descriptors with open files attached
cp $gtm_tst/com/showopenfiles.c .
cc -o showopenfiles showopenfiles.c

# Let's use sh since tcsh is nice enough to close the open file descriptors for us
setenv SHELL sh

echo "Verify open database and journal fds does not get passed via zsystem"
$gtm_dist/mumps -r zsystemset^gtm8009

echo "Verify open read-only database and journal fds does not get passed via zsystem"
chmod u-w mumps.dat
$gtm_dist/mumps -r zsystemwrite^gtm8009
chmod u+w mumps.dat

echo "Verify an open file's fd does not get passed via zsystem"
$gtm_dist/mumps -r mdevfile^gtm8009

echo "Verify an open fifo's fd does not get passed via zsystem"
$gtm_dist/mumps -r fifo^gtm8009

echo "Verify an open socket's fd does not get passed via zsystem"
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF
open "socket":(LISTEN=${portno}_":TCP":attach="server"):10:"SOCKET"
zsystem "showopenfiles"
halt
EOF
$gtm_tst/com/portno_release.csh

$gtm_tst/com/dbcheck.csh
