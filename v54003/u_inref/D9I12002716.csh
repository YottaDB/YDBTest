#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2011, 2013 Fidelity Information Services, Inc	#
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

# This is a timing sensitive test that does a lot of frees.
unsetenv gtmdbglvl
echo '# This is a timing sensitive test that does a lot of frees.' >>&! settings.csh
echo 'unsetenv gtmdbglvl' >>&! settings.csh

# To have an acceptable test duration and coverage, we will limit gtm_jnl_release_timeout to be either undefined, or its value
# between 30 and 330 seconds.  This will allow us to take a peek at open journal files 30 sec. before the idle timer fires.
set peek_time = 30
if ($?gtm_jnl_release_timeout) then
	set timeout = `$gtm_exe/mumps -run %XCMD "write $gtm_jnl_release_timeout#301+30"`
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_jnl_release_timeout gtm_jnl_release_timeout $timeout
	@ wait_time = $timeout - $peek_time
else
	# If gtm_jnl_release_timeout is not defined, the default value of 5 min. (300 sec.) will be used, so set wait_time accordingly.
	@ wait_time = 300 - $peek_time
endif

# Setup database
setenv gtmgbldir "mumps.gld"
setenv tst_buffsize 1048576	# Use the smallest possible jnl pool size so we go to journal files sooner.
# Use a low autoswitch limit so we have multi-generation of journal files.
# Use minimum align size value to reduce the memory requirement to open all the journal files
# Note : New align value is just appended to the end, instead of modifying the already set value. It works.
setenv tst_jnl_str "$tst_jnl_str,autoswitchlimit=16384,align=4096"
$gtm_tst/com/dbcreate.csh mumps 1 . 1024 2048

# Do some db activities and sync, to ensure replication running correctly.
$GTM << EOF
set ^a=1,^b=1,^c=1,^d=1
EOF
$gtm_tst/com/RF_sync.csh

# Get pid of source server, required to check its open files later.
set pidsrc=`$MUPIP replicate -source -checkhealth |& $tst_awk  '($1 == "PID") && ($2 ~ /[0-9]*/) { print $2 }'`

# Shut down receiver, and do a bunch of updates, so the journal pool & files get filled.
setenv start_time `cat start_time`
setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
if ( "os390" == "$gtm_test_osname" ) then
	# On z/OS the backlog get cleared much faster, so create a much bigger one
	set backlog = "1350000"
	set retry = "1"
else
	set backlog = "150000"
	set retry = "2"
endif
retry:
$GTM >>! backlog_filling.txt << EOF
for i=1:1:$backlog set (^a,^b,^c,^d)=\$justify(i,1000)
EOF

# Restart the receiver, and check that the source server uses more than one journal file.
# We will wait for a maximum of 5 minutes, peeking at every 5 seconds, to get more than one journal files open.
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno < /dev/null >>&! $SEC_SIDE/START_${start_time}.out"
set max=300
set inc=5
date >>& lsof1.txt
$lsof -p $pidsrc >>& lsof1.txt
set nbfiles=`$grep '.mjl' lsof1.txt | wc -l`
while (($max > 0) && (2 > $nbfiles))
	sleep $inc
	date >& _lsof1.txt
	$lsof -p $pidsrc >>& _lsof1.txt
	set nbfiles=`$grep '.mjl' _lsof1.txt | wc -l`
	@ max = $max - $inc
	cat _lsof1.txt >>& lsof1.txt
end
if (2 > $nbfiles) then
	if (0 < $retry) then
		# We will retry with a bigger backlog.  So, we need to shut down the receiver (will be restarted once the backlog
		# is created) and double the backlog size.
		$gtm_tst/com/RF_sync.csh
		$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
		mv lsof1.txt lsof1_retry_$retry.txt
		@ retry = $retry - 1
		@ backlog = $backlog * 2
		goto retry
	else
		echo "Less than 2 open journal files, no more retry.  Check lsof1.txt"
		goto check
	endif
else
	echo "Got some journal files open."
endif

# Shut down receiver, and wait a little bit less than $gtm_jnl_release_timeout.  Source should still have journal files open.
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"
( $gtm_tst/$tst/u_inref/D9I12002716_lsof_loop.csh $wait_time $pidsrc &) >>&! lsof_loop.out
sleep $wait_time
echo "After wait_time GTM_TEST_DEBUGINFO : $wait_time"
date >>& lsof2.txt
$lsof -p $pidsrc >>& lsof2.txt
wait
if (2 > `$grep '.mjl' lsof2.txt | wc -l`) then
	echo "Less than 2 open journal files.  Check lsof2.txt"
	goto check
else
	echo "Still got some journal files open."
endif

# Then wait for a maximum of 5 minutes until no more journal files are open.
# Since the first $wait_time is ($gtm_source_idle_timout - $peek_time), we will wait for approximately 5 sec. after
# $gtm_jnl_release_timeout, and then re-check at the same ($peek_time + 5) interval.
echo "Now waiting for journal files to be closed..."
@ inc = $peek_time + 5
@ max = 300 - $inc
sleep $inc
date >>& lsof3.txt
$lsof -p $pidsrc >>& lsof3.txt
set nbfiles=`$grep '.mjl' lsof3.txt | wc -l`
while (($max > 0) && (0 != $nbfiles))
	sleep $inc
	date >& _lsof3.txt
	$lsof -p $pidsrc >>& _lsof3.txt
	set nbfiles=`$grep '.mjl' _lsof3.txt | wc -l`
	@ max = $max - $inc
	cat _lsof3.txt >>& lsof3.txt
end
if (0 != $nbfiles) then
	echo "Still have opened journal files after 5 minutes.  Check lsof3.txt"
else
	echo "No more open journal files."
endif

# Restart receiver and finish replication
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno < /dev/null >>&! $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/RF_sync.csh

check:
# Check that the database is correct
$gtm_tst/com/dbcheck.csh
