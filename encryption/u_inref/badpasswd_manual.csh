#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# To validate prompting of password by mumps when gtm_passwd is set to null
# Using expect script badpasswd_manual.exp to feed the password to GTM
#
echo "#########TEST CONDITION:MUMPS TEST WHEN gtm_passwd SET TO NULL STRING###########"

setenv gtmgbldir ./create.gld
#

cp $gtm_tst/encryption/inref/temp.gde .
$gtm_tst/com/dbcreate.csh create 1
$GDE << EOF
@temp.gde
exit
EOF
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
setenv save_gtm_passwd $gtm_passwd
setenv gtm_passwd
setenv process $gtm_dist
#The output of the expect script is redirected to expect.out file
echo "Refer expect.out for the expect script output"
expect -f $gtm_test/$tst_src/encryption/u_inref/badpasswd_manual.exp $gtm_test_gpghome_passwd $process>&expect.out
setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/dbcheck.csh
