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
#
#
#

echo '# Test of SIG-11 from ZWRITE of global after a name-level $ORDER if some database files do not exist'

echo '# Creating a 3 region database DEFAULT, AREG, BREG'
$gtm_tst/com/dbcreate.csh mumps 3
setenv ydb_gbldir mumps.gld

echo '# Moving b.dat so it cannot be found'
mv b.dat notb.dat

echo '# do ^%GD zwrite ^b'
# echo three line breaks to run ^%GD and then exit it
echo "do ^%GD\n\n\nzwrite ^b" | $ydb_dist/mumps -direct

echo '# Moving b.dat back and doing dbcheck'
mv notb.dat b.dat
$gtm_tst/com/dbcheck.csh
