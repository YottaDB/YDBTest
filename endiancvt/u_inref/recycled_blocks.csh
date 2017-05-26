#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
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

# Basic preparation for the test
source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh
cat << EOF

## Create a V4 database
## Populate it with data
## Kill some globals to create RECYCLED blocks
## Using DSE check if a few blocks are marked as REUSABLE (':')
##  - \$DSE dump -block=0

EOF

$sv4
echo "GT.M switched to $v4ver version"
# priorver.txt is to filter the old version names in the reference file
echo $v4ver >& priorver.txt
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh mumps $coll_arg
source $gtm_tst/com/bakrestore_test_replic.csh
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source coll_env.csh 1; source $gtm_tst/com/bakrestore_test_replic.csh ; $gtm_tst/com/dbcreate_base.csh mumps $coll_arg ; source $gtm_tst/com/bakrestore_test_replic.csh"

$gtm_exe/mumps -run populate
$GTM << EOF
kill ^bglobal
EOF

$DSE dump -block=0

cat << EOF

## Upgrade the database to V5 using the standard upgrade procedure
## Test that BOTH endian convert AND reorg upgrade mark REUSABLE blocks as FREE
## Endian convert the database
##  - \$MUPIP endiancvt mumps.dat
## Move the database to the opposite endian platform
## Using DSE check if the REUSABLE blocks are now changed into FREE blocks ('.')
##  - \$DSE dump -block=0

EOF

$sv5
$gtm_tst/$tst/u_inref/dbcertify.csh
echo ""
# The database at this point contains REUSABLE blocks but all of them will be marked FREE by mupip reorg upgrade
# since this is the FIRST reorg upgrade. But endiancvt requires a reorg upgrade to have been done. So do the
# reorg upgrade once, and then recreate REUSABLE blocks before presenting to endiancvt.
echo "# mupip reorg upgrade..."
$MUPIP reorg -upgrade -region DEFAULT >>&! reorg_upgrade.out
$grep UPGRADE reorg_upgrade.out
echo "# DSE dump after FIRST MUPIP REORG UPGRADE ; Make sure no REUSABLE blocks (:) show up"
$DSE dump -block=0
echo "# Repopulate the data and redo the M-kill to create REUSABLE blocks"
$gtm_exe/mumps -run populate
$GTM << EOF
kill ^bglobal
EOF
echo "# Rerun MUPIP REORG UPGRADE; This SECOND reorg should NOT mark REUSABLE blocks as FREE"
$MUPIP reorg -upgrade -region DEFAULT >>&! reorg_upgrade_1.out
$grep UPGRADE reorg_upgrade_1.out
echo "# DSE dump after SECOND MUPIP REORG UPGRADE ; Make sure REUSABLE blocks (:) do show up"
$DSE dump -block=0
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/bakrestore_test_replic.csh

$MUPIP endiancvt mumps.dat < yes.txt
# Now copy the database to the remote machine to do a dse dump
# Note - Even if the primary side has encryption disabled, it is possible that the test chose encryption randomly and hence the
# settings was NOT carried over to the secondary resulting in encrypted gld and databases on the secondary. Below copy will
# overwrite the encrypted database on the secondary with the unencrypted database on the primary causing mismatching encryption
# flag values between the global directory and database file header. We expect GT.M to gracefully handle this situation by
# honoring the encryption setting on the file header and ignore the global directory. Since the test automatically creates such
# a situation, later changes to this test should "keep" this situation as-is and should not attempt to fix it by copying the
# global directory as well from the primary to secondary OR force encryption to be turned OFF on the secondary as well.
$rcp mumps.dat "$tst_remote_host":$SEC_SIDE/
echo "# DSE dump after endian cvt; Make sure REUSABLE blocks (:) do NOT show up"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $DSE dump -block=0"
