#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9D05002325 [Malli]	  mupip online backup/restore  on tcp port for different hosts does not work
#
#
# Note that small value gtm_test_sleep_sec_short will not reduce code coverage
# but it will reduce running time
#
if ("ENCRYPT" == $test_encryption) then
	# The test ships database from primary to secondary. Hence disable encryption if necessary
	source $gtm_tst/com/encryption_disable_multihost.csh $tst_remote_host $tst_ver
endif

# Since this test creates a database on primary host, ships it across to secondary hosts, and performs MUPIP INTEG on it there, we
# need to ensure that the same symmetric key used on all machines.
if ("ENCRYPT" == $test_encryption) then
	source $gtm_tst/com/create_sym_key_for_multihost_use.csh
endif

# Make sure we can talk IPv6, and scrub the v6 suffix if we can't.
eval 'if (\! $?host_ipv6_support_'${tst_org_host:r:r:r:r}') set host_ipv6_support_'${tst_org_host:r:r:r:r}'=0'
eval 'if (\! $?host_ipv6_support_'${tst_remote_host:r:r:r:r}') set host_ipv6_support_'${tst_remote_host:r:r:r:r}'=0'
if (! `eval echo '$host_ipv6_support_'$tst_org_host:r:r:r:r` || ! `eval echo '$host_ipv6_support_'$tst_remote_host:r:r:r:r`) then
	echo "# disabling IPv6 due to lack of host support"			>>& settings.csh
	if ($tst_org_host != $tst_org_host:r:r:r:r) then
	       setenv tst_org_host $tst_org_host:r:r:r:r
	       echo "setenv tst_org_host $tst_org_host"				>>& settings.csh
	endif
	if ($tst_remote_host != $tst_remote_host:r:r:r:r) then
		setenv tst_remote_host $tst_remote_host:r:r:r:r
		echo "setenv tst_remote_host $tst_remote_host"			>>& settings.csh
	endif
endif
# Large align size will have issues with 32 bit OS and the maximum align sizes vary across the GG servers
# So force the align_size to the testsystem default value i.e 4096.
setenv test_align 4096
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/align=[1-9][0-9]*/align='$test_align'/'`

echo "MUPIP BACKUP/RESTORE over TCP: test Starts..."
if ($LFE == "E") then
	setenv test_sleep_sec 45
        setenv gtm_test_jobcnt 3
else
	setenv test_sleep_sec 20
        setenv gtm_test_jobcnt 2
endif

# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

# Note that the test starts out using -replic in order to create remote directories needed to run the mupip restore.
# It does not need replication from then on. Hence the RF_SHUT call right after the dbcreate.
# Since we do updates on the database after that, we need to also turn replication off on the database (something RF_SHUT
# does not do by default) hence the "off" parameter.
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 4096 2000 4096 2000
$tst_tcsh $gtm_tst/com/RF_SHUT.csh "off"
source $gtm_tst/com/bakrestore_test_replic.csh

# GTM Process starts
echo "GTM starts..."
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep $test_sleep_sec

echo "Stop GTM..."
$gtm_tst/com/endtp.csh >>& endtp.out

####
set portno=`$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_acquire.csh"`
$sec_shell "$sec_getenv; echo $portno >&! $SEC_SIDE/portno"

echo "Backup begins at primary..."
# Always remove host suffix from output to simplify outref
if ($?tst_remote_host) then
	set bckup_to="tcp://${tst_remote_host}:$portno"
	set bckup_to_out="tcp://${tst_remote_host:r:r:r:r}:$portno"
	if ("$tst_remote_host" == "scylla2" || "$tst_remote_host" == "charybdis2") then
		set restore_from="tcp://${tst_org_host}2:$portno"
		set restore_from_out="tcp://${tst_org_host:r:r:r:r}2:$portno"
	else
		set restore_from="tcp://${tst_org_host}:$portno"
		set restore_from_out="tcp://${tst_org_host:r:r:r:r}:$portno"
	endif
else
	set bckup_to="tcp://${tst_org_host}:$portno"
	set bckup_to_out="tcp://${tst_org_host:r:r:r:r}:$portno"
	set restore_from="$bckup_to"
	set restore_from="$bckup_to_out"
endif
echo '$MUPIP backup -online -incremental -transaction=1 -nettimeout=420 DEFAULT "'$bckup_to_out'"'
($MUPIP backup -online -incremental -transaction=1 -nettimeout=420 DEFAULT "$bckup_to"  &) >&backup.log

echo "Restore begins at secondary..."
echo '$MUPIP restore -nettimeout=420 mumps.dat "'$restore_from_out'"'
$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP restore -nettimeout=420 mumps.dat "'$restore_from'" >&! restore_sec.log'
$cprcp _REMOTEINFO_$SEC_SIDE/restore_sec.log .
cat restore_sec.log

source $gtm_tst/com/bakrestore_test_replic.csh
$tst_tcsh $gtm_tst/com/RF_EXTR.csh
unsetenv test_replic
$gtm_tst/com/dbcheck.csh
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/portno_release.csh"
echo "MUPIP BACKUP/RESTORE over TCP: test DONE."
