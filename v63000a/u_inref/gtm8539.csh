#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

$gtm_tst/com/dbcreate.csh mumps

$MUPIP set -journal="enable,on,before,auto=208896,epoch_interval=300" -reg "*" >& mupip_set_jnl.log

$DSE d -f -a | & $grep DFS
$gtm_dist/mumps -run gtm8539 >& gtm8539.out
$DSE d -f -a | & $grep DFS

$gtm_tst/com/dbcheck.csh
