#! /usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
source $gtm_tst/com/dbcreate.csh . 3
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set filterit = '%YDB-I-BACKUPTN, Transactions from'
else
	set filterit = 'NOTHINGTOFILTEROUT'
endif
alias trcount '$tst_awk '"'"'/%YDB-I-BACKUPTN, Transactions from/ {tot=tot+strtonum($6)} END{ print "# Total number of transactions backed up: ",tot}'"'"' '
echo "Journal State state is DISABLED"
echo "Case 1a"
$MUPIP set -journal=on,before -reg "*" |& sort -f
echo "Case 1b"
$MUPIP set -journal=off,before -reg "*" |& sort -f
echo "Case 1c"
$MUPIP set -journal=disable -reg "*" |& sort -f
echo "Case 1d"
$MUPIP set -journal=disable,nobefore -reg "*" |& sort -f
echo "Case 1e"
$MUPIP set -journal=enable,on -reg "*" |& sort -f
$gtm_tst/$tst/u_inref/testdb.csh
echo "Case 2 : Test replic=on works with -journal=nobefore"
$MUPIP set -replic=on -journal=enable,on,nobefore -reg "*"  |& sort -f
echo "Case 3a : Test replic=on without explicit -journal= preserves nobefore_image characteristics"
$MUPIP set -replic=on -reg "*" |& sort -f
echo "Case 3b : Test -journal=nobefore switches journals even though -replic was not specified"
$MUPIP set -journal=enable,on,nobefore -reg "*" |& sort -f
echo "Case 3c"
$MUPIP set -replic=off -reg "*" |& sort -f
echo "Case 3d : Test replic=on right after a replic=off creates db with before_images (and not nobefore as it was previously)"
$MUPIP set -replic=on -reg "*" |& sort -f
echo "Case 3e : Turn replication off so db updates in next step can run fine"
$MUPIP set -replic=off -reg "*" |& sort -f
$gtm_tst/$tst/u_inref/testdb.csh
echo "Case 4"
$MUPIP set -journal=enable,off,nobefore -reg "*" |& sort -f
$gtm_tst/$tst/u_inref/testdb.csh
mkdir ./back
$MUPIP back "*" ./back -newj >&! mupip_backup_newj.out
sort mupip_backup_newj.out |& $grep -v "$filterit"
trcount mupip_backup_newj.out
\rm *.mjl
echo "Case 5"
$MUPIP set -journal=enable,on,before -reg "*" |& sort -f
$MUPIP set -journal=enable,on,before,filename=dummy.mjl -reg "*"
$gtm_tst/$tst/u_inref/testdb.csh
echo "Case 6"
$MUPIP set -journal=enable,on,before,filename=mumps.mjl -reg AREG
$MUPIP set -journal=enable,on,before,filename=a.mjl -reg DEFAULT
$gtm_tst/$tst/u_inref/testdb.csh
echo "Case 7"
chmod 444 mumps.mjl
$MUPIP set -journal=enable,on,before -reg "*" |& sort -f
echo "Case 8"
chmod 666 mumps.mjl
$MUPIP set -journal=enable,on,before,buff=1 -reg "*" |& sort -f
$gtm_tst/com/dbcheck.csh
