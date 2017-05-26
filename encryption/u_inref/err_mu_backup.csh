#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# This subtest test the backup functionality while doing parallel GTM updates
# without gtm_passwd

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
setenv save_gtm_passwd $gtm_passwd
$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
d fill1^myfill("set")
d fill1^myfill("ver")
h
EOF

echo "-------------------------------------------------------------------------------"
echo "Backup without gtm_passwd and expect to work"
echo "-------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "#####################################################"
mkdir back1
echo "mupip backup -bytestream DEFAULT ./back1"
$MUPIP backup -bytestream DEFAULT ./back1
echo "#####################################################"
mkdir back2
echo "mupip backup -comprehensive DEFAULT ./back2"
$MUPIP backup -comprehensive DEFAULT ./back2

echo "-------------------------------------------------------------------------------"
echo "Backup with bad gtm_passwd and expect to work"
echo "-------------------------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "#####################################################"
mkdir back3
echo "mupip backup -bytestream DEFAULT ./back3"
$MUPIP backup -bytestream DEFAULT ./back3
echo "#####################################################"
mkdir back4
echo "mupip backup -comprehensive DEFAULT ./back4"
$MUPIP backup -comprehensive DEFAULT ./back4

mv mumps.dat mumps.dat_1
setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$MUPIP create
setenv gtm_test_dbfill "SLOWFILL"
setenv gtm_test_jobcnt 1
$gtm_tst/com/imptp.csh >>&! imptp.out
sleep 5

echo "-------------------------------------------------------------------------------"
echo "Backup while parallel GTM updates without gtm_passwd and expect to error out"
echo "-------------------------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "#####################################################"
mkdir back5
echo "mupip backup -bytestream -online DEFAULT ./back5"
$MUPIP backup -bytestream -online DEFAULT ./back5
echo "#####################################################"
mkdir back6
echo "mupip backup -comprehensive DEFAULT ./back6"
$MUPIP backup -comprehensive DEFAULT ./back6

setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/endtp.csh >>&! imptp.out
$gtm_tst/com/dbcheck.csh
