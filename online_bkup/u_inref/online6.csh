#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
#
if ( "TRUE" == $gtm_test_unicode_support ) $switch_chset UTF-8
#
echo ENTERING ONLINE6
#
# save replic/reorg info
if ($?test_replic) then
	setenv test_replic_save_in_online6 Y
else
	setenv test_replic_save_in_online6 N
endif
unsetenv test_replic
setenv test_reorg_save_in_online6 NON_REORG
if ($?test_reorg) then
	setenv test_reorg_save_in_online6 $test_reorg
endif
setenv test_reorg NON_REORG
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

# Create keys for online6.dat and online66.dat before the MUPIP RESTORE operation starts.
# In an encryption scenario MUPIP RESTORE expects the hash of the backup database to be
# present and hence the dbcreate for online6.gld and online66.gld needs to be done well before
# MUPIP RESTORE happens.
setenv gtmgbldir online66.gld
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	set alloc = 15000
else
	set alloc = 100
endif
setenv gtm_test_sprgde_id "ID1"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh online66 1 255 700 1536 $alloc 256

if ($test_replic_save_in_online6 == "Y") then
	setenv test_replic
endif
setenv test_reorg $test_reorg_save_in_online6
#
setenv gtmgbldir online6.gld
if (("MM" == $acc_meth) && (0 == $gtm_platform_mmfile_ext)) then
	set alloc = 15000
else
	set alloc = 100
endif
# Since the dbcreate.csh below will rename exising db and gld, move it away temporarily
$gtm_tst/com/backup_dbjnl.csh bak "*.dat *.gld" mv nozip
setenv gtm_test_sprgde_id "ID2"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh online6 1 255 700 1536 $alloc 256
mv bak/* .
#
# Do the updates first.
setenv gtmgbldir online6.gld
if ( "TRUE" == $gtm_test_unicode_support ) then
	$GTM << tcpset
	d in2^udbfill("set")
	h
tcpset

else
	$GTM << tcpset
	d fill3^myfill("set")
	h
tcpset

endif
#
if ($test_replic_save_in_online6 == "Y") then
	set portno=`$sec_shell "$sec_getenv; cd $SEC_SIDE; source $gtm_tst/com/portno_acquire.csh"`
	$sec_shell "$sec_getenv; mv $SEC_SIDE/portno $SEC_SIDE/portno_first ; echo $portno >>&! $SEC_SIDE/portno"
else
	source $gtm_tst/com/portno_acquire.csh >>& portno.out
endif
#
# Start restore in the background
setenv gtmgbldir online66.gld
# On HPUX Itanium use tusc to help analyze socket connect issues
if ("HOST_HP-UX_IA64" == "$gtm_test_os_machtype") then
    setenv res_tusc "tusc -o restore_tusc"
    setenv back_tusc "tusc -o backup_tusc"
else
    setenv res_tusc ""
    setenv back_tusc ""
endif

($res_tusc $MUPIP restore -nettimeout=600 online66.dat "tcp://${tst_org_host}:$portno" &) >&! online66restore.log
#
# Start backup in the foreground
setenv gtmgbldir online6.gld
$back_tusc $MUPIP backup -online -incremental -transaction=1 -nettimeout=60 DEFAULT "tcp://${tst_org_host}:$portno"
if ($status != 0) then
	echo ERROR from backup/restore from tcp.
	$gtm_tst/com/dbcheck.csh # To shutdown the replication servers in case of replic
	$gtm_tst/com/portno_release.csh
	if ($test_replic_save_in_online6 == "Y") then
		$sec_shell "$sec_getenv; mv $SEC_SIDE/portno_first $SEC_SIDE/portno"
	endif
	exit 96
endif
$gtm_tst/com/portno_release.csh
if ($test_replic_save_in_online6 == "Y") then
	$sec_shell "$sec_getenv; mv $SEC_SIDE/portno_first $SEC_SIDE/portno"
endif
#
$gtm_tst/com/dbcheck.csh
#
setenv gtmgbldir online66.gld
# We expect the MUPIP RESTORE to be completed by now. But, in some rare cases, under load it is possible that the RESTORE is still
# running and that means it holds the standalone access. For GT.M startup below to wait for the MUPIP RESTORE to complete and
# release the standalone access, set gtm_db_startup_max_wait to -1.
setenv gtm_db_startup_max_wait -1
if ( "TRUE" == $gtm_test_unicode_support ) then
	$GTM << tcpverify
	d in2^udbfill("ver")
	h
tcpverify
else
	$GTM << tcpverify
	d fill3^myfill("ver")
	h
tcpverify
endif
#
$MUPIP restore online66.dat "tcp://${tst_org_host}/" >&! badtcp1.outx
$gtm_tst/com/check_string_exist.csh badtcp1.outx any 'GTM-E-GETADDRINFO, Error in getting address info'
$MUPIP restore online66.dat "tcp://bogus@host:7777" >&! badtcp2.outx
$gtm_tst/com/check_string_exist.csh badtcp2.outx any 'GTM-E-GETADDRINFO, Error in getting address info'
$MUPIP restore online66.dat "tcp://${tst_org_host}:77D77" >&! badtcp3.outx
$gtm_tst/com/check_string_exist.csh badtcp3.outx any 'GTM-E-SYSCALL, Error received from system call bind'
echo LEAVING ONLINE6
