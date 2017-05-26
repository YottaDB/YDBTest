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

$gtm_tst/com/dbcreate.csh mumps 1

set start_time = `cat start_time`
# Wait for the Source Server to have written/read all information to/from the instance file before we obtain shared memory and
# semaphore IDs.
$gtm_tst/com/wait_for_log.csh -message "New History Content" -log SRC_$start_time.log -duration 30

$MUPIP replic -edit -show $gtm_repl_instance >&! pri_replinst.out
$sec_shell "$sec_getenv ; cd $SEC_SIDE; $MUPIP replic -edit -show $gtm_repl_instance" >&! sec_replinst.out
$MUPIP ftok mumps.dat >&! pri_db_ipcs.out
$sec_shell "$sec_getenv ; cd $SEC_SIDE; $MUPIP ftok mumps.dat" >&! sec_db_ipcs.out

# Get the journal and receive pool shared memory and semaphore IDs on both primary and secondary.
set srcjpshmid = `cat pri_replinst.out | $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("HDR","Journal Pool Shm Id"),!'`
set srcjpsemid = `cat pri_replinst.out | $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("HDR","Journal Pool Sem Id"),!'`
set rcvjpshmid = `cat sec_replinst.out | $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("HDR","Journal Pool Shm Id"),!'`
set rcvjpsemid = `cat sec_replinst.out | $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("HDR","Journal Pool Sem Id"),!'`
set rcvshmid = `cat sec_replinst.out | $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("HDR","Receive Pool Shm Id"),!'`
set rcvsemid = `cat sec_replinst.out | $gtm_exe/mumps -run %XCMD 'do ^replinst write fields("HDR","Receive Pool Sem Id"),!'`
set srcdbshmid = `$tst_awk '/mumps.dat/ {print $6}' pri_db_ipcs.out`
set srcdbsemid = `$tst_awk '/mumps.dat/ {print $3}' pri_db_ipcs.out`
set rcvdbshmid = `$tst_awk '/mumps.dat/ {print $6}' sec_db_ipcs.out`
set rcvdbsemid = `$tst_awk '/mumps.dat/ {print $3}' sec_db_ipcs.out`
set ipcids = ($srcjpshmid $srcjpsemid $rcvjpshmid $rcvjpsemid $rcvshmid $rcvsemid $srcdbshmid $srcdbsemid $rcvdbshmid $rcvdbsemid)
echo $ipcids >&! ipcs-to-be-removed.out

# Crash the primary and secondary leaving IPCs lying around
$gtm_tst/com/primary_crash.csh NO_IPCRM
$sec_shell "$sec_getenv; cd $SEC_SIDE ; $gtm_tst/com/receiver_crash.csh NO_IPCRM"

# If encryption is turned on, rundown needs to know the secondary database's encryption key. So, add that to the configuration file.
if ("ENCRYPT" == $test_encryption) then
	$gtm_tst/com/modconfig.csh $gtmcrypt_config append-keypair $SEC_SIDE/mumps.dat $SEC_SIDE/mumps_dat_key
endif

# Do an argument-less rundown.
$MUPIP rundown -override >&! rundown.outx

# Verify that the IPCs corresponding to the source and receiver server are gone.
echo "==IPCS check begins=="
$gtm_tst/com/ipcs -a | $grep $USER >&! ipcs.out
foreach ipc ($ipcids)
	$tst_awk -v ipc=$ipc '$2==ipc {print}' ipcs.out
end
echo "==IPCS check ends=="

# Since the replication servers are all gone, pass -noshut to dbcheck and manually release the reserved ports
$sec_shell "$sec_getenv ; cd $SEC_SIDE; source $gtm_tst/com/portno_release.csh"
$gtm_tst/com/dbcheck.csh -noshut
