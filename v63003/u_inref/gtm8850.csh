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
source $gtm_tst/com/mm_nobefore.csh
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo "# Start background script that does MUPIP FREEZE -ONLINE -ON -NOAUTORELEASE"
($SHELL $gtm_tst/$tst/u_inref/gtm8850freeze.csh & ; echo $!>>& bg.pid) >& f.outx
echo "# Start 8 background scripts that starts MUMPS processes which do two updates and terminate in a loop"
@ num = 0
while ($num < 8)
        ($SHELL $gtm_tst/$tst/u_inref/gtm8850xcmd.csh & ; echo $!>>& bg.pid) >& x$num.outx
        @ num = $num + 1
end
echo "# Run background scripts for 15 seconds to see if there is a hang"
sleep 15
echo "# Signal background scripts to stop"
touch test.STOP
# Wait for background processes to stop
foreach bgpid(`cat bg.pid`)
	$gtm_tst/com/wait_for_proc_to_die.csh $bgpid
end
echo "# Confirm all background processes finished properly"
echo ""
echo "# Status for freeze process"
cat f.outx |& $grep finished
foreach i (`seq 0 1 7`)
	echo ""
	echo "# Status for process $i"
	cat x$i.outx
end
$gtm_tst/com/dbcheck.csh >>& dbcheck.out


