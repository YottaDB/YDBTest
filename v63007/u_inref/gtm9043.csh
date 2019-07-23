#!/usr/local/bin/tcsh
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

echo '# GT.M detects the case of more concatenation operands in a row than it can handle when parsing the source code; previously it detected this at code generation, which meant it always failed to create an object file in this case'

echo '# Attemping to run M code with 254 concatinations in a row'
echo '# Should give a MAXARGCNT error'
$gtm_dist/mumps -r gtm9043
echo '# Checking that object file gtm9043.o was still created'
ls gtm9043.o
if (0 == $status) then
	echo 'PASS'
else
	echo 'FAIL: Could not find gtm9043.o'
endif
