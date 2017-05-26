#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that native size related integrity checks are passed even when access method is switched from MM to BG

# Total blocks, in terms of DISK_BLOCK_SIZE  are calculated as below:
# start_vbn is 513. So 512 blocks are used by DB header and master bit map.
# 	512
#  +	 20	(10 GTM blocks of 1024 size)
#  +	  2	(1 Bitmap blocks for 10 GTM.M blocks)
#  +	  1 	(EOF block)
#  =	535
# (535 * 512) is the DB size which is not in the multiple of the OS_PAGE_SIZE  which is 4096 (currently) on all
# the test servers. shmat() usage for memory mapping on AIX increases the DB size to 536 DISK blocks to make it
# the multiple of OS_PAGE_SIZE. Irrespective of INTEG check should pass on all the test servers.

setenv gtm_test_jnl NON_SETJNL
setenv test_encryption NON_ENCRYPT	# Since -acc_meth=MM is passed to dbcreate
unsetenv acc_meth
$gtm_tst/com/dbcreate.csh mumps 1 . 998 1024 10 -acc_meth=MM
$gtm_exe/mumps -run %XCMD 'for i=1:1:7 set ^x(i)=$j(i,998)'
echo
$gtm_exe/mumps -run %XCMD 'do accmeth^gtm7756'
$MUPIP integ -reg "*" >&! integ1.out
$MUPIP set -acc=BG -reg "*"
echo
$gtm_exe/mumps -run %XCMD 'do accmeth^gtm7756'
$MUPIP integ -reg "*" >&! integ2.out

$gtm_tst/com/dbcheck.csh
