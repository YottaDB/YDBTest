#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test tries to do a database upgrade from V4 to V5. Since a V4 version will not be supporting encryption, unconditionally turn off
# encryption
setenv test_encryption NON_ENCRYPT

cat << EOF

## In machine_host
##  Create a V4 database and populate it with data
##  mupip endiancvt -outdb mumps_cvt.dat mumps.dat
##  mupip endiancvt mumps.dat
## copy mumps.dat to other endian machine
##  mupip endiancvt -outdb mumps_cvt.dat mumps.dat
##  mupip endiancvt mumps.dat
##      --> All of the above endiancvt attempts should err out with "Database file mumps.dat has an unrecognizable format" error

EOF

source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh
$sv4
echo "GT.M switched to $v4ver version"
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh mumps $coll_arg
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_exe/mumps -run populate
# switch back to V5
$sv5
cp mumps.dat bak.dat
$MUPIP endiancvt mumps.dat -outdb=mumps_cvt.dat < yes.txt >>&! endiancvt_try1.out
$gtm_tst/com/check_error_exist.csh endiancvt_try1.out unrecognizable MUNOACTION
$MUPIP endiancvt mumps.dat < yes.txt >>&! endiancvt_try2.out
$gtm_tst/com/check_error_exist.csh endiancvt_try2.out unrecognizable MUNOACTION
cp bak.dat mumps.dat

$rcp mumps.dat "$tst_remote_host":$SEC_SIDE
$sec_shell "$sec_getenv; cd $SEC_SIDE; source coll_env.csh 1 ; $MUPIP endiancvt mumps.dat -outdb=mumps_cvt.dat < yes.txt >>&! endiancvt_try3.out ; $gtm_tst/com/check_error_exist.csh endiancvt_try3.out unrecognizable MUNOACTION"
$sec_shell "$sec_getenv; cd $SEC_SIDE; source coll_env.csh 1 ; $MUPIP endiancvt mumps.dat < yes.txt >>&! endiancvt_try4.out ; $gtm_tst/com/check_error_exist.csh endiancvt_try4.out unrecognizable MUNOACTION"

cat << EOF

##  Create a V4 database and populate it with data
##  Upgrade and stop at mupip upgrade mumps.dat  /* blocks to upgrade is non zero now */
##  mupip endiancvt -outdb mumps_cvt.dat mumps.dat
##      -> The attempt should fail issuing YDB-E-NOENDIANCVT, Unable to convert the endian format of file mumps.dat due to some blocks are not upgraded to the current version
##  Run mupip reorg -upgrade -region DEFAULT /* blocks to upgrade is zero now */
##  mupip endiancvt -outdb mumps_cvt.dat mumps.dat
##      --> Should be successful

EOF
$gtm_tst/$tst/u_inref/dbcertify.csh

$MUPIP endiancvt mumps.dat -outdb=mumps_cvt.dat < yes.txt >>&! endiancvt_try5.out
$gtm_tst/com/check_error_exist.csh endiancvt_try5.out NOENDIANCVT MUNOACTION

echo ""
echo "# mupip reorg upgrade..."
$MUPIP reorg -upgrade -region DEFAULT >>&! reorg_upgrade.out
$grep UPGRADE reorg_upgrade.out

$MUPIP endiancvt mumps.dat -outdb=mumps_cvt.dat < yes.txt

echo "# Now copy the database to the remote machine and do an integ check"
$rcp mumps_cvt.dat "$tst_remote_host":$SEC_SIDE/
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source coll_env.csh 1; $gtm_tst/$tst/u_inref/integ_check.csh mumps_cvt.dat"
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/bakrestore_test_replic.csh
