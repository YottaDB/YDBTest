#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
#
# TEST : UPDATERESYNC
#
# create database on A side (secondary)
#set verbose
#echo "remove verbose"
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 1 255 1000
setenv portno `$sec_shell 'cat $SEC_DIR/portno'`
setenv start_time `cat start_time`

$GTM << GTM_EOF
f i=1:1:100 s ^a(i)=i
w "finished"
h
GTM_EOF
$gtm_tst/com/RF_sync.csh
$gtm_tst/com/rfstatus.csh "BEFORE SHUTDOWN:"

echo "Shut down receiver (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"

# Continue GTM in A (does not replicate into B) 100 updates on primary.
$GTM << GTM_EOF
for i=1:1:100 s ^b(i)=i
GTM_EOF
mkdir bak1
$MUPIP backup -bkupdbjnl=disable -online -replinstance=bak1 "*" bak1
cd $SEC_SIDE
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *.mjl* *.repl" mv
echo $PRI_SIDE
cp $PRI_SIDE/bak1/* .
echo "backup completed"

# Since database file is being copied from primary side to secondary side, we have to refer to $gtmcrypt_config containing keys
# for primary side database files.
if ("ENCRYPT" == $test_encryption) then
	cd $PRI_SIDE
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed 's|dat: "'$cwd'/|dat: "|' ${gtmcrypt_config}.orig > $gtmcrypt_config
	setenv gtmcrypt_config $PRI_SIDE/gtmcrypt.cfg
	cd $SEC_SIDE
endif

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown of recvpool ipcs before moving mumps.repl to pri_mumps.repl
mv mumps.repl pri_mumps.repl
# At this point, mumps.repl is renamed under a different name and so the below "MUPIP SET" command will error out with FTOKERR/ENO2
# error if $gtm_custom_errors is defined. Unsetenv $gtm_repl_instance temporarily to avoid the false errors
source $gtm_tst/com/unset_ydb_env_var.csh ydb_repl_instance gtm_repl_instance
$MUPIP set -replication=on -reg "*" >&! repl_on.out
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_repl_instance gtm_repl_instance mumps.repl
# replication instance file be created with -supplementary option for A->P and P->Q situations i.e if test_replic_suppl_type is 1 or 2
set supplarg = ""
if ((1 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
	set supplarg = "-supplementary"
endif
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replicate -instance_create -name=$gtm_test_cur_sec_name'" $gtm_test_qdbrundown_parms $supplarg"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh ""."" $portno $start_time ""updateresync=pri_mumps.repl -initialize"" < /dev/null >>&! $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/RF_sync.csh
$gtm_tst/com/rfstatus.csh "AFTER UPDATE RESYNC START:"
cd $PRI_SIDE
$GTM << GTM_EOF
for i=1:1:100 s ^c(i)=i
GTM_EOF
$gtm_tst/com/RF_sync.csh
echo "Shut down receiver (B)..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"

# Do more updates just to make sure receiver starts up fine even after a -updateresync startup/shutdown sequence
$GTM << GTM_EOF
for i=1:1:100 s ^d(i)=i
GTM_EOF

setenv start_time `date +%H_%M_%S`
echo "Restarting Secondary..."
cd $SEC_SIDE
$gtm_tst/com/RCVR.csh "." $portno $start_time >&! START_${start_time}.out
$gtm_tst/com/rfstatus.csh "AFTER_RCVR_RESTART:"
$gtm_tst/com/dbcheck.csh -extract
