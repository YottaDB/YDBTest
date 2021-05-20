#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Tests processes properly detach from a database when a FREEZE -ON -ONLINE is in effect
#
source $gtm_tst/com/gtm_test_setbgaccess.csh
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
echo "# Start background script that does MUPIP FREEZE -ONLINE -ON -NOAUTORELEASE or -AUTORELEASE"
($SHELL $gtm_tst/$tst/u_inref/gtm8850freeze.csh & ; echo $!>>& bg.pid) >& f.out
if ($status) then
	echo "# Error returned from MUPIP Freeze command"
	cat f.out
endif
# Filter out potential OFRZAUTOREL warning messages from being caught by the test framework
# Note that we need to redirect output to a .logx (not .log) file to avoid
# test framework from catching a potential TEST-E-ERRORNOTSEEN message from the check_error_exist.csh script
# in case the OFRZAUTOREL message is not seen (which is possible in some cases).
$gtm_tst/com/check_error_exist.csh f.out "%YDB-W-OFRZAUTOREL" >& ofrzautorel.logx

echo "# Start 8 background scripts that starts MUMPS processes which do two updates and terminate in a loop"
@ num = 0
while ($num < 8)
        ($SHELL $gtm_tst/$tst/u_inref/gtm8850xcmd.csh & ; echo $!>>& bg.pid) >& x$num.out
        @ num = $num + 1
end
echo "# Run background scripts for 15 seconds to see if there is a hang"
sleep 15
echo "# Signal background scripts to stop"
touch test.STOP
# Wait for background processes to stop
foreach bgpid(`cat bg.pid`)
	# We have seen default 60 seconds not enough in rare cases hence a wait time of 300 seconds below
	$gtm_tst/com/wait_for_proc_to_die.csh $bgpid 300
end
echo "# All processes exited correctly"
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
