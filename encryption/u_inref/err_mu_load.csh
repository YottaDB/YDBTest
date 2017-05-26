#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This subtest tests mupip load behavior without gtm_passwd

setenv save_gtm_passwd $gtm_passwd
setenv gtmgbldir mumps
$gtm_tst/com/dbcreate.csh mumps 2

$GTM << EOF
d fill1^myfill("set")
d fill1^myfill("ver")
h
EOF

$MUPIP extract -fo=bin ext1.bin

\rm *.dat
\rm *.gld

$gtm_tst/com/dbcreate.csh mumps 1

echo "---------------------------------------"
echo "Mupip load without gtm_passwd"
echo "---------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd

$MUPIP load -fo=bin ext1.bin

echo "---------------------------------------"
echo "Mupip load with bad gtm_passwd"
echo "---------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh

$MUPIP load -fo=bin ext1.bin

setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/dbcheck.csh
