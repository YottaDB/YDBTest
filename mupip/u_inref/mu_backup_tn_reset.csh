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
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

$gtm_tst/com/dbcreate.csh mumps 1

echo "# Update some globals to database"
$GTM << EOF
s ^valueA=10
s ^valueB=20
EOF

echo "# DSE dump -file"
$DSE dump -file >& dse_dmp1.out
$grep "Backup" dse_dmp1.out
$grep "Current transaction" dse_dmp1.out

echo "# Reset transaction mumber"
$MUPIP integ -file mumps.dat -tn_reset

$DSE dump -file >& dse_dmp2.out
$grep "Backup" dse_dmp2.out
$grep "Current transaction" dse_dmp2.out

echo "# Try incremental backup after tn_reset, it should take backup"
$MUPIP backup "*" -incr -since=i -record inc1.dat

echo "# Try incremental backup after immediate backup, it should fail"
$MUPIP backup "*" -incr -since=i -record inc2.dat

echo "# Integrity check"
$MUPIP integ -file mumps.dat

$GTM << EOF
s ^valueC=30
EOF

$DSE dump -file >& dse_dmp3.out
$grep "Backup" dse_dmp3.out
$grep "Current transaction" dse_dmp3.out

echo "# Try incremental backup after one more update, it should work"
$MUPIP backup "*" -incr -since=i -record inc3.dat

echo "# Restore from inc1.dat and inc2.dat"

\rm mumps.dat
$MUPIP create
$MUPIP restore mumps.dat inc1.dat,inc3.dat
$GTM << EOF
w "valueA = ",^valueA," valueB =  ",^valueB," valueC = ",^valueC
EOF
$gtm_tst/com/dbcheck.csh
echo "# End of subtest"
