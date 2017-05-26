#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that turning journaling on a backed up database does not end up with JNLRDONLY error if there's
# no reason to do modifications on the former journal file.

# Before image journaling only works with BG
setenv acc_meth "BG"
# Turn on journaling
setenv jnl_forced 1
setenv gtm_test_jnl_nobefore 0
setenv tst_jnl_str "-journal=enable,on,before"
setenv gtm_test_jnl NON_SETJNL

$gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set $tst_jnl_str -reg "*" >& jnl_on.txt

$gtm_exe/mumps -run %XCMD 'set ^a=1'

chmod a-w mumps.mjl

#This should be legal becauase we do no alteration on mumps.mjl
echo "Case #1"
$MUPIP set -journal="before,on,filename=$PWD/newj1.mjl" -region 'DEFAULT' >& test1.txt
$gtm_tst/com/check_error_exist.csh test1.txt "JNLCREATE"

# Take away write permissions from the current journal file
chmod u-w newj1.mjl

# Backup the database under backupdir, mumps.dat still points to newj1.mjl
$gtm_tst/com/backup_dbjnl.csh backupdir "*.dat *.gld" cp nozip

cd backupdir

# This should be illegal because we did not specify the full path, it attempt to rename newj1.mjl
# which has no write permissions
echo "Case #2"
$MUPIP set -noprevjnlfile -journal="before,on" -region 'DEFAULT' >& test2.txt
$gtm_tst/com/check_error_exist.csh test2.txt "JNLRDONLY"

# This should be legal because we now create this in a new directory with no renaming requirement
echo "Case #3"
$MUPIP set -noprevjnlfile -journal="before,on,filename=$PWD/newj2.mjl" -region 'DEFAULT' >& test3.txt
$gtm_tst/com/check_error_exist.csh test3.txt "JNLCREATE" "PREVJNLLINKCUT"

cd ..

# This should be illegal because the journal file is open by another process with write permissions
# The mjl files need to be properly terminated
echo "Case #4"

# Give the write permissions back so that mumps process can open the journal file in the shared memory
# with write permissions
chmod a+w newj1.mjl

$gtm_tst/com/simplebgupdate.csh 10 >& bgup.txt
$gtm_exe/mumps -run %XCMD 'for i=1:1:120 write:i=120 "TEST-E-FAIL No update by the bg process",! quit:$data(^GBL)!(i=120)  hang 0.5'

chmod a-w newj1.mjl

$MUPIP set -journal="before,on,filename=$PWD/new3.mjl" -region 'DEFAULT' >& test4.txt
$gtm_tst/com/check_error_exist.csh test4.txt "JNLRDONLY"

touch endbgupdate.txt

# wait for bg process to end
$gtm_tst/com/wait_for_proc_to_die.csh `sed 's/^\[.*\] //' bgup.txt`

echo "Case #5"

# In case ipcs are expected to be leftover (possible if qdbrundown is in effect and $gtm_db_counter_sem_incr != 1)
# give back write permissions to the journal file and then do the MUPIP RUNDOWN as it otherwise cannot do a "wcs_flu".
# And then restore permissions like it was.
source $gtm_tst/com/can_ipcs_be_leftover.csh
if ($status) then
	chmod a+w newj1.mjl
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
	chmod a-w newj1.mjl
endif

# Make sure this does not core due to cs_addrs->nl being NULL
$MUPIP set -replication=on -reg "*" >& test5.txt
$gtm_tst/com/check_error_exist.csh test5.txt "JNLRDONLY"

echo "Case #6"

# Make sure specified file name succesfully turns on replication
$MUPIP set -replication=on -journal="before,on,filename=$PWD/new4.mjl" -reg "*" >& test6.txt
$gtm_tst/com/check_error_exist.csh test6.txt "REPLSTATE.*is now ON"

$gtm_tst/com/dbcheck.csh
