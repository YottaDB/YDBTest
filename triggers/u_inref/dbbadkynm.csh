#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2010, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

# dbbadkynm.csh - test to show that a global of the form ^#xxx, ^#txx, ^%x%x, and ^#a
# will give a DBBADKYNM integrity error.
# Use DSE to change ^avar to ^#var and then use mupip integ to show the error.
# The ^%x is shown as a valid form in the test.
# The ^#t is the only valid form after the # and it is also tested below.

$gtm_tst/com/dbcreate.csh mumps 1

$GTM <<GTM_EOF
set ^avar=1
write "^avar = ",^avar,!
GTM_EOF

$DSE >& dse1.out << DSE_EOF
dump -b=2
dump -b=3
overwrite -block=2 -data="#var" -offset=14
overwrite -block=3 -data="#var" -offset=14
dump -b=2
dump -b=3
quit
DSE_EOF

echo "Test for ^#var"
echo
$grep "Key \^#" dse1.out
echo

$GTM <<GTM_EOF
write "^avar = ",^avar,!
GTM_EOF

$MUPIP integ mumps.dat
echo

$DSE >& dse2.out << DSE_EOF
overwrite -block=2 -data="#tar" -offset=14
overwrite -block=3 -data="#tar" -offset=14
dump -b=2
dump -b=3
quit
DSE_EOF

echo "Test for ^#tar"
echo
$grep "Key \^#" dse2.out
echo

$MUPIP integ mumps.dat
echo

$DSE >& dse3.out << DSE_EOF
overwrite -block=2 -data="%t%r" -offset=14
overwrite -block=3 -data="%t%r" -offset=14
dump -b=2
dump -b=3
quit
DSE_EOF

echo "Test for ^%t%r"
echo
$grep "Key \^%" dse3.out
echo

$MUPIP integ mumps.dat
echo

#start with a fresh database for the new pattern ^%t
mv mumps.dat mumps1.dat.sav
$MUPIP create

$GTM <<GTM_EOF
set ^%t=1
write "^%t = ",^%t,!
GTM_EOF

$DSE >& dse4.out << DSE_EOF
dump -b=2
dump -b=3
quit
DSE_EOF

echo "Test for ^%t"
echo
$grep "Key \^" dse4.out
echo

$MUPIP integ mumps.dat
echo

$DSE >& dse5.out << DSE_EOF
dump -b=2
dump -b=3
overwrite -block=2 -data="#a" -offset=14
overwrite -block=3 -data="#a" -offset=14
dump -b=2
dump -b=3
quit
DSE_EOF

echo "Test for ^#a"
echo
$grep "Key \^#" dse5.out
echo

$MUPIP integ mumps.dat
echo

$DSE >& dse6.out << DSE_EOF
overwrite -block=2 -data="#t" -offset=14
overwrite -block=3 -data="#t" -offset=14
dump -b=2
dump -b=3
quit
DSE_EOF

echo "Test for ^#t"
echo
$grep "Key \^#" dse6.out
echo

$MUPIP integ mumps.dat
$gtm_tst/com/dbcheck.csh
