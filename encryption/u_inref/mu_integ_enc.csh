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
echo "Test that encryption plugin issues appropriate errors when MUPIP INTEG is run with a bad configuration."
#
# Set white box testing environment to avoid assert failures due to bad configuration.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
#

$gtm_tst/com/dbcreate.csh mumps 3

echo
echo "##############################################################"
echo "Test Scenario 1: Environment variable gtmcrypt_config not set."
echo "##############################################################"
setenv save_gtmcrypt_config $gtmcrypt_config
unsetenv gtmcrypt_config
$MUPIP integ -reg "*" |& sort

echo
echo "#####################################################################"
echo "Test Scenario 2: Environment variable gtm_passwd set to bad password."
echo "#####################################################################"
setenv gtmcrypt_config $save_gtmcrypt_config
setenv restore_passwd $gtm_passwd
setenv gtm_passwd `echo 'badvalue' | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
$gtm_tst/com/reset_gpg_agent.csh
$MUPIP integ -reg "*" |& sort
setenv gtm_passwd $restore_passwd
$gtm_tst/com/reset_gpg_agent.csh

echo
echo "##################################################################################"
echo "Test Scenario 3: Environment variable gtmcrypt_config points to non-existent file."
echo "##################################################################################"
setenv gtmcrypt_config ./foobar.cfg
$MUPIP integ -reg "*" |& sort

setenv gtmcrypt_config $save_gtmcrypt_config
$gtm_tst/com/dbcheck.csh
