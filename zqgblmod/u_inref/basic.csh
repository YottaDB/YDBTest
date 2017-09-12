#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : ZQGBLMOD
#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
# The test does a failover so A->P is not possible
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
#
# LOG files makes it slower
# create database on A side (secondary)
$gtm_tst/com/dbcreate.csh mumps 4 255 1000 -block_size=1024

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`

$GTM << EOF
w "do ^sptp1(1,1000)",!
do ^sptp1(1,1000)
h
EOF
$gtm_tst/com/RF_sync.csh
$gtm_tst/com/rfstatus.csh

echo '# Switch journals right before shutting down to ensure $ZQGBLMOD returns the "best" values since $ZQGBLMOD returns the most pessimistic values (i.e. beginning of the journal file).'
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/jnl_on.csh"
echo "# Shut down receiver (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"

# Continue GTM in A (does not replicate into B)
$GTM << EOF
w "do ^sptp2(1001,10000)",!
do ^sptp2(1001,10000)
h
EOF

echo "Shutdown Primary in (A)..."
$gtm_tst/com/SRC_SHUT.csh "." >>&! SHUT_${start_time}.out

# FAILOVER
$DO_FAIL_OVER
setenv start_time `date +%H_%M_%S`
echo "Restarting (B) as primary..."
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/SRC.csh ""."" $portno $start_time < /dev/null "">& !"" $PRI_SIDE/SRC_${start_time}.out"

cd $SEC_SIDE
$gtm_tst/com/mupip_rollback.csh -BACKWARD -fetchresync=$portno -losttrans=fetch.glo "*" >>&! rollback.log
$gtm_tst/com/RCVR.csh "." $portno $start_time >&! START_${start_time}.log
$pri_shell '$pri_getenv; cd $PRI_SIDE; $MUPIP replicate -source -needrestart -instsecondary=$gtm_test_cur_sec_name'
$gtm_tst/com/rfstatus.csh "AFTER_RCVR_RESTART:"

# Primary in B
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/sptp3.csh < /dev/null"
$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/$tst/u_inref/zqlapp.csh < /dev/null"
$gtm_tst/com/dbcheck.csh -extract
