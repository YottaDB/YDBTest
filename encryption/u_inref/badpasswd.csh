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
#
# Test all possible values for gtm_passwd environment variable ie; null value, bad passphrase, unset gtm_passwd env variable
#
echo "Testing plugin Error messages with  Mupip create functionality"
#
#Set white box testing environment.
echo "# Enable WHITE BOX TESTING"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
#
echo "#########TEST CONDITION:ALL TRUE###########"

setenv gtmgbldir ./create.gld
$gtm_tst/com/dbcreate.csh create 3

cp $gtm_tst/encryption/inref/temp.gde .
$GDE << EOF
@temp.gde
EOF

$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat" mv
$MUPIP create -reg=areg
$MUPIP create -reg=yreg
$MUPIP create -reg=default
$MUPIP create -reg=zreg
$MUPIP create -reg=breg

echo "#########TEST CONDITION:BAD PASSPHRASE###########"
setenv gtm_passwd `echo 'badvalue' | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat" mv
$MUPIP create -reg=areg
$MUPIP create -reg=yreg
$MUPIP create -reg=default
$MUPIP create -reg=zreg
$MUPIP create -reg=breg

echo "#########TEST CONDITION:gtm_passwd unset#########"
unsetenv gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/backup_dbjnl.csh bak3 "*.dat" mv
$MUPIP create -reg=areg
$MUPIP create -reg=breg
$MUPIP create -reg=default
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg

echo "#########TEST CONDITION:gtm_passwd restored to the true value########"
setenv gtm_passwd `echo $gtm_test_gpghome_passwd |$gtm_dist/plugin/gtmcrypt/maskpass|cut -f 3 -d ' '`
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/backup_dbjnl.csh bak4 "*.dat" mv
$MUPIP CREATE
$DSE <<EOF >&dsedumpencrypt.out
find -reg=DEFAULT
dump -fileheader -all
exit
EOF

echo "HASH DUMP ON ENCRYPTED DATABASE"
$grep hash dsedumpencrypt.out

$DSE <<EOF >&dsedumpunencrypt.out
find -reg=YREG
dump -fileheader -all
exit
EOF

echo "HASH DUMP ON NONENCRYPTED DATABASE"
$grep hash dsedumpunencrypt.out

$gtm_tst/com/dbcheck.csh
