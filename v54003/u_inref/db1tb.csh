#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test integ/recover functional with db > 1TB (GTM-6958)
# This test is allocating 1 TB disk space so do not preallocate it otherwise it will fail due to lack of space
setenv gtm_test_defer_allocate 1
#
# This test can only run with BG access method, so let's make sure that's what we have
#
source $gtm_tst/com/gtm_test_setbgaccess.csh
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
#
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
# Database created should exceed 1TB
#
setenv gtm_test_db_format "NO_CHANGE"  # Don't mess with other flavors - db is too big for that
setenv gtmdbglvl 0x100000              # Enable creation of large sparce file where normally would not be allowed
$gtm_tst/com/dbcreate.csh mumps 1 255 2048 32768 33560000
unsetenv gtmdbglvl
#
# If trying to generate errors in V990, uncomment the below line
#
#source $gtm_tst/com/switch_gtm_version.csh V990 $tst_image
#
# First try an integ on the database
#
$gtm_tst/com/dbcheck.csh
#
# Start up a passive source server to be able to do repl rollback to test those functions work with a large db.
#
source $gtm_tst/com/passive_start_upd_enable.csh >& START_PASSIVE_SRC.log
#
# Now set gtm_tp_allocation_clue so we can create a couple updates near the end of the database
# to verify recovery works properly. First make a single update, wait a couple seconds, then do more so we
# can have a good solid time to rollback to.
#
setenv gtm_tp_allocation_clue 33625600
$GTM <<EOF
TStart ():Transactionid="BATCH" Set ^A(1)=42 TCommit
Hang 1.1
Set file="RECOVER_TIME.txt"
Open file:New
Use file
Write \$ZDate(\$Horolog,"DD-MON-YEAR 24:60:SS")
Close file
Hang 1.1
For i=1:1:100 TStart ():Transactionid="BATCH" Set ^a(i)=\$Justify(\$Job,900) TCommit
EOF
#
# Shutdown the source server and try to rollback almost to the beginning
#
set since_time = `cat RECOVER_TIME.txt`
$MUPIP replic -source -shutdown -timeout=0 >>& passive_stop.out
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
$MUPIP journal -recover -back -since=\"$since_time\" -verify "*"
#
$gtm_tst/com/dbcheck.csh
