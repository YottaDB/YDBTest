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
# Test that sr_port/code_gen.c does not check triple chain validity in case of compile error
#

$gtm_tst/com/dbcreate.csh mumps

echo '# Test that sr_port/code_gen does not check triple chain validity in case of compile error'

echo '+^e -command=S -xecute="TPRestart:(2>$TRestart) quit" -name=postconditionalbad' > x.trg
echo "# Testing with tigger file:"
cat x.trg

echo "# Running file, should exit with errors"
$gtm_dist/mumps -run %XCMD 'write $ztrigger("file","x.trg")'

$gtm_tst/com/dbcheck.csh
