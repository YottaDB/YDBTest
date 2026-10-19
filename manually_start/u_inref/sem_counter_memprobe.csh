#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Called by instream.csh to decide whether this host has the memory for the sem_counter subtest.
# Starts 500 processes the way sem_counter does, measures the memory they take, and writes "RUN" or "SKIP" to stdout.
# The details are in tmp/sem_counter_memprobe/memprobe.txt.
#
# Most of this script repeats the settings and the database, journaling and passive source server setup at the top of
# sem_counter.csh. That is deliberate, as the memory each process takes depends on them (M mode, no encryption, and
# the journal pool each process attaches to), so the probe has to set up the same way to measure the same thing. It
# cannot simply run sem_counter.csh, as instream.csh has to decide before submit_subtest.csh runs any subtest, and
# sem_counter.csh goes on to start all 32800 processes. It runs as a separate script, so that these settings do not
# leak into the other subtests. A change to that part of sem_counter.csh that affects the memory per process needs the
# same change here.

setenv gtm_test_qdbrundown 1
setenv gtm_test_qdbrundown_parms "-qdbrundown"
unsetenv gtm_db_counter_sem_incr
setenv gtm_test_jnl SETJNL
setenv test_encryption NON_ENCRYPT
$switch_chset M >&! switch_chset_memprobe.out
mkdir sem_counter_memprobe
cd sem_counter_memprobe
# Set up the database, journaling and passive source server as sem_counter does, as each process attaching to the
# journal pool adds to the memory it needs
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
$MUPIP set -region "*" -journal=on,before -replic=on >&! replic_on.out
source $gtm_tst/com/passive_start_upd_enable.csh >&! passive_start.out
$gtm_exe/mumps -run probe^semcounter
$MUPIP replicate -source -shutdown -timeout=0 >&! passive_stop.out
$MUPIP rundown -region "*" >&! rundown.out
