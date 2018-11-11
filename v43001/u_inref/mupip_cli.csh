#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# related to C001923

# journaling is specifically done in this test. So let's not randomly enable journaling in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL
$gtm_tst/com/dbcreate.csh . 3

set echo
echo "This should error out, since effectively, ENABLE is not specified in the second (and overriding) -journal= specification"
$MUPIP set -journal="on,before,enable" -file mumps.dat -journal="on"


echo ""
echo "This should start journalling with BEFORE images"
$MUPIP set -journal="on,nobefore" -file mumps.dat -journal="on,before,enable"

echo ""
echo  "This should not error out"
$MUPIP set -journal="on,off" -file mumps.dat -journal="on,before,enable"

echo ""
echo  "This should not error out"
$MUPIP set -journal="alloc=a" -file mumps.dat
echo ""
echo "This should error out"
$gtm_exe/mumps  -bad

echo ""
$MUPIP set -journal="on,enable,before" -file mumps.dat
$GTM << FIN
s ^Y=3
s ^Z=4
h
FIN
rm *.dat
$MUPIP create
$MUPIP journal -recover -noapply_after_image -forward mumps.mjl
$GTM <<FIN
w ^Y
w ^Z
h
FIN

unset echo
$gtm_tst/com/dbcheck.csh
