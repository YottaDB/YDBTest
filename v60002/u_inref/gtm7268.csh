#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
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

# We want to run out of space and disable journaling so turn off custom errors
unsetenv gtm_custom_errors
# We deliberately run out of space, so allow it.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 16
# This particular case is triggered with TP, so force it in imptp.
setenv gtm_test_tp "TP"
setenv gtm_test_tptype "ONLINE"

$gtm_tst/com/dbcreate.csh mumps 1 512

set jnldir = "../testfiles/gtm_jnlextlowspace_multi"
mkdir $jnldir

$gtm_com/IGS MOUNT $jnldir 15360
if ($status) then
	echo "Mounting tmpfs failed. Exiting test now"
	exit 1
endif
echo "$gtm_com/IGS UMOUNT testfiles/gtm_jnlextlowspace_multi" >>& ../cleanup.csh

$MUPIP set ${tst_jnl_str},file=$jnldir/a.mjl,epoch_interval=900,buffer_size=32768,allocation=30000 -flush_time=15:0:0 -reg DEFAULT >&! DEFAULT_jnl_on.out
if ($status) then
	echo "enabling journaling for region DEFAULT failed. Check DEFAULT_jnl_on.out. Exiting test now"
	exit 1
endif

# Add some data to partially fill the disk and throw off the extension checks
dd if=/dev/zero of=$jnldir/JUNK bs=4096 count=512 >& dd.out

set syslog_before1 = `date +"%b %e %H:%M:%S"`

$gtm_tst/com/imptp.csh 12 >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "JNLCLOSED"

$gtm_tst/com/endtp.csh

$gtm_tst/com/dbcheck.csh >& dbcheck.out

# unmount and remove the unmount command from cleanup.csh
$gtm_com/IGS UMOUNT $jnldir
$grep -v "UMOUNT" ../cleanup.csh >&! ../cleanup.csh.bak
mv ../cleanup.csh.bak ../cleanup.csh
