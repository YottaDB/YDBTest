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
echo "-----------------------------------------------------------"
echo "Test case for journal recover with encryption"
echo "-----------------------------------------------------------"

setenv save_gtm_passwd $gtm_passwd
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
$gtm_tst/com/dbcreate.csh mumps 1
echo "# Enable journaling"
$MUPIP set -journal="enable,on,before" -reg DEFAULT

cp mumps.dat back.dat

echo "# Update some data"
$GTM << EOF
d fill1^myfill("set")
d fill1^myfill("ver")
h
EOF

echo "# Remove dat file"
\rm mumps.dat

mv back.dat mumps.dat

echo "-----------------------------------------------------------"
echo "journal recover without gtm_passwd and expect to error out"
echo "-----------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
$MUPIP journal -recover -forw mumps.mjl

echo "-----------------------------------------------------------"
echo "journal recover with bad gtm_passwd and expect to error out"
echo "-----------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
$MUPIP journal -recover -forw mumps.mjl

echo "-----------------------------------------------------------"
echo "journal recover with correct gtm_passwd and expect to work"
echo "-----------------------------------------------------------"
setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$MUPIP journal -recover -forw mumps.mjl

$gtm_tst/com/dbcheck.csh
