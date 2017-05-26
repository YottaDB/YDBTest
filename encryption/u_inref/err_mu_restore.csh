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

# This subtest test mupip restore behavior without gtm_passwd.

setenv save_gtm_passwd $gtm_passwd
$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
d fill1^myfill("set")
d fill1^myfill("ver")
h
EOF

mkdir back1

echo "mupip backup -bytestream DEFAULT ./back1"
$MUPIP backup -bytestream DEFAULT ./back1

\rm *.dat

$gtm_tst/com/dbcreate.csh mumps 1
echo "---------------------------------------------------------------"
echo "Restore database with out gtm_passwd and expect to error out"
echo "---------------------------------------------------------------"
echo "unsetenv gtm_passwd"
unsetenv gtm_passwd
echo "mupip restore mumps.dat ./back1/mumps.dat"
$MUPIP restore mumps.dat ./back1/mumps.dat

echo "---------------------------------------------------------------"
echo "Restore database with bad gtm_passwd and expect to error out"
echo "---------------------------------------------------------------"
setenv gtm_passwd `echo "badvalue" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -d " " -f3`
$gtm_tst/com/reset_gpg_agent.csh
echo "mupip restore mumps.dat ./back1/mumps.dat"
$MUPIP restore mumps.dat ./back1/mumps.dat

setenv gtm_passwd $save_gtm_passwd
$gtm_tst/com/reset_gpg_agent.csh
$gtm_tst/com/dbcheck.csh
