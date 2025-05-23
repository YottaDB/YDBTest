#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test case is for TR C9A06-001499
# this test also takes care of C9A08-001570
# 08/01/2003 - zhouc - change for TR C9D07-002335
setenv tst_buffsize 33554432
# setting random dbtn and version no will not give a consistant output for the first backup done below
setenv gtm_test_disable_randomdbtn
setenv gtm_test_mupip_set_version "disable"
# Since the test explicitly uses before image journaling, force BG access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
# chosing a higher value of align size will result in a fewer align records in the journal file
# The test relies on "just" crossing the 4G jnl limit and a switch.
# In cases of very high align size, the 4G limit might not be reached. So do not inherit the random align_size from do_test
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`
$gtm_tst/com/dbcreate.csh mumps 1 64 8092 8192 4096 2048 4096
echo "Start time: " >>& tracktime.log
date >>& tracktime.log

$MUPIP set -journal="enable,on,before,auto=8388607,alloc=655477,exten=65535" -reg "*"

if ($?test_replic) then
	setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
	setenv start_time `cat start_time`
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP set -journal="enable,on,before,auto=8388607,alloc=655477,exten=65535" -reg "*"'
	# Stop the receiver server. But before that, ensure the receiver server has connected with the source and recorded the
	# source instance information in the receiver instance file. In the case where "test_replic_suppl_type" env var is randomly
	# chosen to be 1 by the test framework i.e. it is an A->P replication setup (where A is non-supplementary and P is a
	# supplementary instance), P needs to record A's instance information in P's instance file at the first connection (the
	# test framework starts the receiver for the first time with the special flag -updateresync (see "needupdateresyncarg"
	# variable usage in "com/RCVR.csh"). Or else the receiver on P would get an INSUNKNOWN error when it is restarted later in
	# the test (framework does not use -updateresync for restarts). Hence the wait for the history record to be processed on
	# the receiver side before it is shut down (instance information of source is recorded by receiver BEFORE the history
	# record is processed by the update process).
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log.updproc -message 'New History Content' -duration 120"
	echo "Receiver shut down ..."
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>& $SEC_SIDE/SHUT_${start_time}.out"
endif

$MUPIP backup  "*" -nonewjnlfiles before.dat
$GTM << gtm_eof
	d ^jnl4G
gtm_eof
# Determine number of journal files to expect
if ($?test_replic) then
	# Since a) dbcreate would have created journal files b) we do an explict journal on and c) there should be a 4G switch
	set exp_count = 3
else
	# Expect a journal switch at 4G limit
	set exp_count = 2
endif

# Try to make sure we get that many
@ num_try = 10

set filecount = `ls -1 |& $grep "mumps.mjl" |& wc -l`
while ($filecount < $exp_count && $num_try > 0)
# add approx 20M to journal file
echo "$filecount is less than $exp_count with num_try = $num_try so add another 20M" >>&! goover4GB.txt
$GTM << GTM_EOF >>&! goover4GB.txt
	tstart ():(serial:transaction="BA")
	for l=1:1:2500 set ^l=\$j(" ",8000)
	tcommit
GTM_EOF
	set filecount = `ls -1 |& $grep "mumps.mjl" |& wc -l`
	@ num_try = $num_try - 1
end
#
echo "Done filling database at :" >>& tracktime.log
date >>& tracktime.log
#
if ($?test_replic) then
#	start the receiver server
	setenv start2_time `date +%H_%M_%S`
	echo "Starting receiver server ..."
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno $start2_time < /dev/null "">&!"" $SEC_SIDE/RCVR_${start2_time}.out"
	sleep 10
# shut down source/receive servers
	$tst_tcsh $gtm_tst/com/RF_SHUT.csh  "on"
	$tst_tcsh $gtm_tst/com/RF_EXTR.csh
	$pri_shell "$pri_getenv; cd $PRI_SIDE; $gtm_tst/com/dbcheck_base.csh"
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/dbcheck_base.csh"
else
	$gtm_tst/com/dbcheck.csh
endif
#
echo "check the journal files"

if ("$exp_count" != "$filecount") then
	echo "TEST-E-FILECOUNT. $exp_count of journal files expected at this stage. But only $filecount seen"
	ls |& $grep "^mumps.mjl"
endif
#
#	test case for TR C9A0080-001570
	echo "check -show=header time"
#	get the 4G journal file
	$MUPIP journal -show=header -for -noverify mumps.mjl >& show.out
	$grep "Prev journal" show.out >& prev.out
	set jnlname=`$tst_awk -F/ '{print $NF}' prev.out`
	set format="%Y %m %d %H %M %S %Z"
	set time2=`date +"$format"`
	$MUPIP journal -show=header -back -noverify $jnlname >& show_back.log
	set time3=`date +"$format"`
	$MUPIP journal -show=header -for -noverify $jnlname >& show_for.log
	set time4=`date +"$format"`
	echo $time2 " " $time3 >& time_diff.txt
	@ diff1=`$tst_awk -f $gtm_tst/com/diff_time.awk time_diff.txt`
	rm time_diff.txt
	echo $time3 " " $time4 >& time_diff.txt
	@ diff2=`$tst_awk -f $gtm_tst/com/diff_time.awk time_diff.txt`
	@ diff3 = $diff2 - $diff1
	# Since $diff3 is the time taken by the "-show=header -for" minus the time taken
	# by the "-show=header -back", it can be positive or negative. Therefore, we check
	# both positive and negative. Specifically, time3-time2 and time4-time3 should be
	# less than 60 seconds. This was increased from 5 seconds in November 2020 due to a
	# failure on an ARMv7L machine where it took 17 seconds for one show=header.
	if (($diff3 > 60) || ($diff3 < -60)) then
		echo "Show=header should not take that long"
		echo $time2 "," $time3 "," $time4
		exit 1
	endif
if ($?test_replic == 0) then
#
# 	save the original database and journal files
	mkdir ./save
#	cp mumps.* ./save
#	The below is needed until * expands properly for >4GB files on Solaris in tcsh
	foreach filetocopy (`ls -1 |& $grep "mumps"`)
		cp $filetocopy ./save
	end
#
	echo "Backward recovery ..."
	set time0=`cat time0.txt`
	set time1=`cat time1.txt`
	echo "Starting backward recovery at:" >>& tracktime.log
	date >>& tracktime.log
	$MUPIP journal -recov -back -since=\"$time1\" mumps.mjl >>& rec_bak.log
	set stat1=$status
	$grep "Recover successful" rec_bak.log
	set stat2=$status
#
	if ($stat1 != 0 || $stat2 != 0)  then
		echo "4g_journal TEST FAILED"
		cat rec_bak.log
		$gtm_tst/com/dbcheck.csh
		exit 1
	endif
	echo "Done backward recovery at :" >>& tracktime.log
	date >>& tracktime.log
#
	echo "Verifying data ..."
$GTM << gtm_eof
	  d dverify^jnl4G(0)
gtm_eof
#
else
#	save the journal file
	mkdir ./save
#	cp mumps.* ./save
#	The below is needed until * expands properly for >4GB files on Solaris in tcsh
	foreach filetocopy (`ls -1 |& $grep "mumps"`)
		cp $filetocopy ./save
	end
	echo "Rollback on side A ..."
	echo "Starting rollback at:" >>& tracktime.log
	date >>& tracktime.log
	echo "$gtm_tst/com/mupip_rollback.csh -resync=130 -losttrans=fetch.glo " >>&! rollback1.log
	$gtm_tst/com/mupip_rollback.csh -resync=130 -losttrans=fetch.glo "*" >>&! rollback1.log
	$grep "successful" rollback1.log
#
#
	echo "Rollback on side B ..."
	$sec_shell "$sec_getenv; cd $SEC_SIDE; "'echo $gtm_tst/com/mupip_rollback.csh -resync=130 -losttrans=lost2.glo >>&! rollback2.log'
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$gtm_tst/com/mupip_rollback.csh -resync=130 -losttrans=lost2.glo "*" >>&! rollback2.log; grep "successful" rollback2.log' # BYPASSOK grep
#
	echo "Verifying data ..."
$GTM << gtm_eof
	d dverify^jnl4G(1)
gtm_eof
#
endif
#
# according to Layek, the forward recovery should work for both replic and non-replic - 08/14/2003 - zhouc
echo "Forward recovery ..."
#	rm mumps.*
#	The below is needed until * expands properly for >4GB files on Solaris in tcsh
	foreach filetorm (`ls -1 |& $grep "mumps"`)
		rm $filetorm
	end
#	cp ./save/*.* .
#	The below is needed until * expands properly for >4GB files on Solaris in tcsh
	foreach filetocopy (`ls -1 ./save`)
		cp ./save/$filetocopy .
	end
	cp before.dat mumps.dat
	echo "Start forward recovery at:" >>& tracktime.log
	date >>& tracktime.log
	$MUPIP journal -recov -for mumps.mjl >>& rec_for.log
	set stat3=$status
	$grep "Recover successful" rec_for.log
	set stat4=$status
#
	if ($stat3 != 0 || $stat4 != 0) then
		echo "4g_journal TEST FAILED"
		cat rec_for.log
		exit 1
	endif
#
echo "Done forward recovery at :" >>& tracktime.log
date >>& tracktime.log
echo "Verifying data ..."
$GTM << gtm_eof
	d dverify^jnl4G(0)
gtm_eof
#
#move the tracktime.log  to upper level directory; otherwise it will get removed on success
mv tracktime.log ./..
#
if ($gtm_test_use_V6_DBs) then
	# Since $gtm_test_use_V6_DBs is TRUE, the dbcheck.csh call below is going to do a "mupip upgrade" test
	# in dbcheck_base.csh to test V6 to V7 upgrade logic on this database file. The first thing that test
	# does is a "$MUPIP backup -journal=disable -nonewjnlfiles". We have seen this create a database with
	# a DBBSIZMN integrity error in rare cases when the database has "Async IO" turned ON. The integrity
	# error occurs because GDS block 1 (the root block of the directory tree) is all zeroed out and empty
	# in the backed up database file. This is because "mubfilcpy()" (invoked by "mupip backup") does a separate
	# open of the source database file without O_DIRECT and identifies alternate holes/data portions using
	# lseek(SEEK_HOLE) and lseek(SEEK_DATA) calls and uses # copy_file_range() to do the copies to the sparse target
	# backup file. And for reasons not yet clear, when the database block size is 8Kb (which is the case in this test),
	# a multiple of the filesystem block size of 4Kb, the lseek(SEEK_DATA) call when done from an offset that is in
	# the middle of the local bitmap block GDS block 0 returns the offset of GDS block 2. It misses out GDS block 1
	# in some cases. It is not clear what conditions cause this. But it seems like some weird interaction of O_DIRECT
	# usage (which is the case for Async IO enabled files) and maybe the filesystem (XFS was the only one where we saw
	# this during in-house testing) and maybe even the Linux kernel (Debian 12, 6.1.0-31-amd64). This GDS block 1
	# is initialized at database create time and never touched again in this test. So whether we open the file
	# using O_DIRECT (and bypass the file cache) or without O_DIRECT (and use the file cache), this block cannot
	# suddenly disappear and seem like a zeroed out block to the filesystem cache. Until there is more evidence of
	# this being a potential YottaDB issue (if at all, it has to be an Async IO == O_DIRECT issue only), we assume
	# this is some external issue and work around it by invoking hexdump to dump the bytes corresponding to
	# GDS block 0 (offset 0x40000 to 0x42000) and block 1 (offset 0x42000 to 0x44000). With this change, the
	# test passes reliably whereas it fails 25% of the time otherwise. Somehow the act of dumping those blocks
	# using hexdump makes the filesystem cache see GDS block 1 as data in the later lseek(SEEK_DATA) call.
	if ($gtm_test_asyncio) then
		hexdump -C -s 0x40000 -n 0x4000 mumps.dat > mumps.dat.hd
	endif
endif

$gtm_tst/com/dbcheck.csh -noshut
