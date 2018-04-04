#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2006, 2013 Fidelity Information Services, Inc	#
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

# Basic preparation for the test
source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh

## Create a 4 region V5 database (DEFAULT,AREG,BREG,CREG)
## populate them with data
## Concurrently run multiple endiancvt processes.
## Using DSE dump check if all the databases are converted to non native endian format (with respect to this machine)

echo "# Create a 4 region V5 database and populate them with data"
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh mumps 4 255 1000 $coll_arg
source $gtm_tst/com/bakrestore_test_replic.csh
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source coll_env.csh 1; source $gtm_tst/com/bakrestore_test_replic.csh ; $gtm_tst/com/dbcreate_base.csh mumps 4 255 1000 $coll_arg ; source $gtm_tst/com/bakrestore_test_replic.csh"

# This directory will be used later to test endianness of a database
mkdir check_endian ; cp mumps.gld check_endian
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; mkdir check_endian ; cp mumps.gld check_endian"

$gtm_tst/com/imptp.csh >>&! imptp.out
sleep 30
$gtm_tst/com/endtp.csh >>&! imptp.out

source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcheck.csh
source $gtm_tst/com/bakrestore_test_replic.csh

echo "# Now endian convert the databases concurrently"
$gtm_tst/$tst/u_inref/endiancvt_db.csh mumps.dat a.dat b.dat c.dat >&! endiancvt_db.out ; $grep YDB-I-ENDIANCVT endiancvt_db.out

$rcp mumps.dat "$tst_remote_host":$SEC_SIDE
$rcp a.dat "$tst_remote_host":$SEC_SIDE
$rcp b.dat "$tst_remote_host":$SEC_SIDE
$rcp c.dat "$tst_remote_host":$SEC_SIDE

## After successful conversion of database copy them over to the other endian machine
## In the remote machine
##  mupip endiancvt mumps.dat
##  mupip endiancvt b.dat
##  Check the endian format using DSE
##      -> mumps.dat and b.dat should be chaged to non native endian format (with respect to the remote machine)
##      -> a.dat and c.dat shouldn't be changed i.e remain in the native endian format (with respect to the remote machine)
##  Run endiancvt on all the databases simultaneously
##  Check the endian format using DSE
##      -> mumps.dat and b.dat should be changed to native endian format (with respect to the remote machine)
##      -> a.dat and c.dat should be changed to non native endian format (with respect to the remote machine)

echo "# In the remote machine, find the endian format of all the databases using dse dump"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ;$gtm_tst/$tst/u_inref/check_endian.csh $endian_remote DEFAULT AREG BREG CREG"
echo ""
echo "# In the remote machine, endian convert mumps.dat and b.dat only"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; $MUPIP endiancvt mumps.dat < yes.txt; $MUPIP endiancvt b.dat < yes.txt"

echo "# Now test the endianness of each database using DSE"
echo "# DEFAULT: mumps.dat"
$rcp "$tst_remote_host":$SEC_SIDE/mumps.dat check_endian/mumps.dat
cd check_endian ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_local DEFAULT ; cd ..
echo "# AREG: a.dat"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cp a.dat check_endian/ ; cd check_endian/ ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_remote AREG ; cd .. "
echo "# BREG: b.dat"
$rcp "$tst_remote_host":$SEC_SIDE/b.dat check_endian/b.dat
cd check_endian ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_local BREG ; cd ..
echo "# CREG: c.dat"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cp c.dat check_endian/ ; cd check_endian/ ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_remote CREG ; cd .. "


echo "#  In the remote machine, run endiancvt on all the databases simultaneously"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ;"'$gtm_tst/$tst/u_inref/endiancvt_db.csh mumps.dat a.dat b.dat c.dat >&! endiancvt_db.out ; $grep YDB-I-ENDIANCVT endiancvt_db.out'

echo "# Now test the endianness of each database using DSE"
echo "# DEFAULT: mumps.dat"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cp mumps.dat check_endian/ ; cd check_endian/ ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_remote DEFAULT ; cd .. "
echo "# AREG: a.dat"
$rcp "$tst_remote_host":$SEC_SIDE/a.dat check_endian/mumps.dat
cd check_endian ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_local AREG ; cd ..
echo "# BREG: b.dat"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cp b.dat check_endian/ ; cd check_endian/ ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_remote BREG ; cd .. "
echo "# CREG: c.dat"
$rcp "$tst_remote_host":$SEC_SIDE/c.dat check_endian/c.dat
cd check_endian ; $gtm_tst/$tst/u_inref/check_endian.csh $endian_local CREG ; cd ..
echo "End of test"
