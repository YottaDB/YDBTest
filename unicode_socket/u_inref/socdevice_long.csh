#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$switch_chset UTF-8
echo ENTERING SOCKET SOCDEVICE_LONG
setenv gtmgbldir mumps.gld
# test long strings
$gtm_tst/com/dbcreate.csh mumps 1 225 7800 8192
source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM << setupconfiguration
s ^config("hostname")="$tst_org_host"
s ^config("portno")=$portno
d ^socset
h
setupconfiguration
#
mkdir save ; cp *.dat save #BYPASSOK no need to use backup_dbjnl.csh
$GTM << GTM_EOF
d ^socdev("")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_def ; cp -f save/* .
$GTM << GTM_EOF
d ^socdev("UTF-8")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_UTF-8 ; cp -f save/* .
$GTM << GTM_EOF
d ^socdev("UTF-16LE")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_UTF-16LE ; cp -f save/* .
$GTM << GTM_EOF
d ^socdev("UTF-16BE")
h
GTM_EOF
#
$gtm_tst/com/backup_dbjnl.csh save_UTF-16BE ; cp -f save/* .
$GTM << GTM_EOF
d ^socdev("UTF-16")
h
GTM_EOF
#
sleep 10
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET SOCDEVICE_LONG
