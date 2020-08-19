#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that $FNUMBER(NUM,"",N)=NUM returns 0 when N is non-zero and NUM is an integer'
echo '# This might seem counter-intuitive but is how M has defined $FNUMBER behavior'
echo '# And this test ensures it continues to stay that way and alert us if any inadvertent change to this happens'
echo ""

echo -n 'Running : write $FNUMBER(3,"",1)=3 : Expecting to see 0 (and not 1) : Actual output = '
$ydb_dist/yottadb -run %XCMD 'write $FNUMBER(3,"",1)=3'

echo -n 'Running : write "3.0"=3            : Expecting to see 0 (and not 1) : Actual output = '
$ydb_dist/yottadb -run %XCMD 'write "3.0"=3'

echo -n 'Running : write 3.0=3              : Expecting to see 1 (and not 0) : Actual output = '
$ydb_dist/yottadb -run %XCMD 'write 3.0=3'

