#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1

echo "# Test case 1 : Treat deletion of a non-existent trigger as a success"
echo "-abcdt1" > t1.trg

cat << cat_EOF >> t2.trg
-abcdt2
+^abcdt2 -commands=S -name=abcdt2 -xecute=<<
        do ^twork
>>
cat_EOF

$gtm_exe/mumps -run delete^gtm8019

echo "# Test case 2 :"
echo "# Trigger names with a number part (after the #) starting with a 0 should not be considered valid"
echo "# Trigger name length 22 before the # should not be considered a valid name"
$gtm_exe/mumps -run gtm8019

$gtm_tst/com/dbcheck.csh -extract
