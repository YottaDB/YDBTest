#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test to make sure that you can backup a file with a blocksize of >32768,'
echo '# in V6 databases this should create a MUNOSTRMBKUP error, in V7 databases'
echo '# this no longer produces an error. This discrepancy is checked in the outref file.'
echo
echo "# Creating database."
$gtm_tst/com/dbcreate.csh -block_size=50176
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif
$gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP
mkdir bkup
echo "# add transaction to database so that bytestream backup can work"
$gtm_dist/mumps -run %XCMD "SET ^X=0"
echo "# creating backup with mupip"
$gtm_dist/mupip backup -bytestream "*" bkup/mumps.dat >& bck_tmpdir.out ; $grep -Ev 'FILERENAME|JNLCREATE' bck_tmpdir.out
