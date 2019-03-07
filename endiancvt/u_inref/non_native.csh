#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Basic preparation for the test
source $gtm_tst/$tst/u_inref/endiancvt_prepare.csh
source $gtm_tst/com/bakrestore_test_replic.csh
$gtm_tst/com/dbcreate.csh mumps $coll_arg
source $gtm_tst/com/bakrestore_test_replic.csh
echo "# now in the remote directory"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; source coll_env.csh 1; unsetenv test_replic ; $gtm_tst/com/dbcreate_base.csh mumps $coll_arg ; setenv test_replic"
mv mumps.dat bak.dat
echo "# Copy the database from the remote machine."
$rcp "$tst_remote_host":"$SEC_SIDE/mumps.dat" .

cat << EOF

## Now the database is opposite endian. So none of the below command shoud work
## The commands should issue YDB-E-DBENDIAN error

EOF

echo "# DSE dump"
$DSE dump -fileheader >&! dse_dump.out
$gtm_tst/com/check_error_exist.csh dse_dump.out YDB-E-DBENDIAN YDB-E-DBNOREGION

echo "# GTM -> write"
$GTM << EOF >>&! gtm.out
write ^a=10
halt
EOF

$gtm_tst/com/check_error_exist.csh gtm.out YDB-E-DBENDIAN

echo "# LKE show"
$LKE show -all >&! lke.out
$gtm_tst/com/check_error_exist.csh lke.out YDB-E-DBENDIAN YDB-E-DBNOREGION

echo "# MUPIP integ"
$MUPIP integ -region "*" >&! mupip_integ.out
$gtm_tst/com/check_error_exist.csh mupip_integ.out YDB-E-DBENDIAN MUNOTALLINTEG

echo "# MUPIP freeze"
$MUPIP freeze -on "*" >&! mupip_freeze.out
$gtm_tst/com/check_error_exist.csh mupip_freeze.out YDB-E-DBENDIAN

echo "# MUPIP backup"
mkdir bak_dir
$MUPIP backup -database "*" bak_dir >&! mupip_backup.out
$gtm_tst/com/check_error_exist.csh mupip_backup.out YDB-E-DBENDIAN

echo "# MUPIP extract"
$MUPIP extract extract.glo >&! mupip_extract.out
$gtm_tst/com/check_error_exist.csh mupip_extract.out YDB-E-DBENDIAN

# Clean up ftok semaphore which will be left around from the DBENDIAN errors above
$MUPIP rundown -file mumps.dat >& mupip_rundown.out

# None of the mupip commands will work. No point in doing a dbcheck
#$gtm_tst/com/dbcheck.csh
echo "End of test"
