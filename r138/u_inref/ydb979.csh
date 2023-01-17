#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo '# YDB979 - Verify that running MUPIP FTOK -jnlpool and/or -recvpool with a replication file specified that'
echo '# is exactly 255 chars (size of MAX_FN_LEN) to verify that it is handled correctly. Previously, a MUPIP'
echo '# FTOK that specified -jnlpool but no repl instance file used to fail with garbage added to the end of'
echo '# the filename (see https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1308#note_1244775945).'
echo
echo '# Create repl inst filename such that $gtm_repl_instance name will be exactly 255 chars.'
set new_gtm_repl_instance = `$gtm_dist/mumps -run longfilename 255 mumps.repl`
if $status != 0 then
    echo $new_gtm_repl_instance # This envvar contains an error message when $status != 0
    exit 1
endif
echo "$new_gtm_repl_instance" >& new_gtm_repl_instance.txt # Added for debugging
echo
echo '# Create databases and start up and sync replication'
$MULTISITE_REPLIC_PREPARE 2
# create the database
$gtm_tst/com/dbcreate.csh mumps > dbcreate.out
# start both instances
$MSR START INST1 INST2 RP
echo
echo '# Change replication instance file to use alternate long name and try MUPIP FTOK on it both with and without'
echo '# replication instance file name given.'
ln -s `pwd`/mumps.repl $new_gtm_repl_instance
set save_gtm_repl_instance = $gtm_repl_instance
setenv gtm_repl_instance $new_gtm_repl_instance
$gtm_dist/mumps -run showEnvVarLen^ydb979 gtm_repl_instance # Show length of $gtm_repl_instance (validate against 255 length in reference file)
#
echo
echo '# $MUPIP FTOK -jnlpool'
$MUPIP FTOK -jnlpool
echo
echo '# $MUPIP FTOK -jnlpool '$gtm_repl_instance
$MUPIP FTOK -jnlpool $gtm_repl_instance
echo
echo '# $MUPIP FTOK -recvpool'
$MUPIP FTOK -recvpool
echo
echo '# $MUPIP FTOK -recvpool '$gtm_repl_instance
$MUPIP FTOK -recvpool $gtm_repl_instance
echo
echo '# $MUPIP FTOK -jnlpool -recvpool'
$MUPIP FTOK -jnlpool -recvpool
echo
echo '# $MUPIP FTOK -jnlpool -recvpool '$gtm_repl_instance
$MUPIP FTOK -jnlpool -recvpool $gtm_repl_instance
echo
echo '# Create sub-directory in it and try to reference our repl instance file from there - causes failure here if ftok is -1 meaning'
echo '# that it could not find the file when generating ftok info and printing it and the fileid info.'
mkdir asubdir
cd asubdir
echo
echo '# $MUPIP FTOK -jnlpool -recvpool '$gtm_repl_instance
$MUPIP FTOK -jnlpool -recvpool $gtm_repl_instance
cd ..
echo
echo '# Create ultra-long replication instance file name'
set new_gtm_repl_instance2 = `$gtm_dist/mumps -run longfilename 300 mumps.repl`
if $status != 0 then
    echo $new_gtm_repl_instance2 # This envvar contains an error message when $status != 0
    exit 1
endif
ln -s `pwd`/mumps.repl $new_gtm_repl_instance2
setenv gtm_repl_instance $new_gtm_repl_instance2
$gtm_dist/mumps -run showEnvVarLen^ydb979 gtm_repl_instance # Show length of $gtm_repl_instance (validate against 255 length in reference file)
echo
echo '# $MUPIP FTOK -jnlpool -recvpool '$gtm_repl_instance
$MUPIP FTOK -jnlpool -recvpool $gtm_repl_instance
#
# Restore gtm_repl_instance to its original version so replication shutdown works correctly
#
setenv gtm_repl_instance $save_gtm_repl_instance
echo
echo 'Create max-length DB name'
setenv maxdblenname `$gtm_dist/mumps -run longfilename 255 mumps.dat`
$gtm_dist/mumps -run showEnvVarLen^ydb979 "maxdblenname"
ln -s `pwd`/mumps.dat $maxdblenname
echo
echo '# $MUPIP FTOK '$maxdblenname
$MUPIP FTOK $maxdblenname
echo
echo '# Create ultra-long DB name (300 chars)'
setenv ultralongdbname `$gtm_dist/mumps -run longfilename 300 mumps.dat`
if $status != 0 then
    echo $ultralongdbname # This envvar contains an error message when $status != 0
    exit 1
endif
$gtm_dist/mumps -run showEnvVarLen^ydb979 "ultralongdbname"
ln -s `pwd`/mumps.dat $ultralongdbname
echo
echo '# $MUPIP FTOK '$ultralongdbname
$MUPIP FTOK $ultralongdbname
echo
echo '# Validate database'
$gtm_tst/com/dbcheck.csh
