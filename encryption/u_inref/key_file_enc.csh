#! /usr/local/bin/tcsh -f
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
# Set white box testing environment to avoid assert failures due to bad configuration.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
#

$gtm_tst/com/dbcreate.csh mumps 3

echo
echo "##############################################################"
echo "Test Scenario 1: Bad perms for one of the key files."
echo "##############################################################"
\rm -rf *.dat
chmod 100 mumps_dat_key
$MUPIP create

echo
echo "##############################################################"
echo "Test Scenario 2: One of the keys doesn't exist."
echo "##############################################################"
\rm -rf *.dat
chmod 700 mumps_dat_key		# restore perms.
mv mumps_dat_key mumps_dat_key.bak
$MUPIP create

echo
echo "##############################################################"
echo "Test Scenario 3: One of the keys is empty."
echo "##############################################################"
touch no_data.txt
cat no_data.txt | $gpg --homedir=$GNUPGHOME -e -o mumps_dat_key -r $user_emailid |& $grep -v "$gpg_ignore_str"
\rm -rf *.dat
$MUPIP create

echo
echo "##############################################################"
echo "Restore everything and do an INTEG"
echo "##############################################################"
mv mumps_dat_key.bak mumps_dat_key
\rm -rf *.dat
$MUPIP create

$gtm_tst/com/dbcheck.csh
