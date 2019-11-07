#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test ensures that the max subscripts for naked references is correct.
# It was created because previously existing tests did not ensure that the
# limit for subscripts in a naked reference was exactly 31.

# A naked reference replaces the last subscript with 1 or more subscripts.
# Below, this starts with 2 subscripts, then replaces the last subscript with
# 30 subscripts to max it out at 31 subscripts. Then, it attempts to add an
# extra subscript twice.
echo "==================="
echo "Test in Direct Mode"
echo "==================="
$gtm_tst/com/dbcreate.csh "mumps" 1 255 500
$GTM << aaa
view "gdscert":1
SET ^val("A",2)="DATA"
SET ^(0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9)="DATA2"
SET ^(0,1)="DATA3"
SET ^(2,3)="DATA4"
aaa
# This runs a loop of naked references starting with an initial reference of 3
# subscripts and adding a subscript via naked reference each time through the loop
# up to a total of 100 iterations until the subscript overruns the array. The last
# number printed out is the maximum number of subscripts in an array built using
# naked references. Currently, it should be 31. If the maximum number of subscripts
# is changed in the future, this test will fail until the reference files are updated
# to reflect the new maximum.
echo "====================================="
echo "Test by running a loop from a .m file"
echo "====================================="
$gtm_dist/mumps -r ydb174
$gtm_tst/com/dbcheck.csh
