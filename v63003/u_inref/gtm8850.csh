#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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

$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
# Start background script that does MUPIP FREEZE -ONLINE -ON -NOAUTORELEASE
$SHELL $gtm_tst/$tst/u_inref/gtm8850a.csh >& f.outx &
# Start 8 background scripts that starts MUMPS processes which do two updates and terminate in a loop
@ num = 0
while ($num < 8)
        $SHELL $gtm_tst/$tst/u_inref/gtm8850b.csh >& x$num.outx &
        @ num = $num + 1
end
# Run background scripts for 15 seconds to see if there is a hang
sleep 15
# Signal background scripts to stop
touch test.STOP
# Wait for background processes to stop
wait
$gtm_tst/com/dbcheck.csh >>& dbcheck.out


