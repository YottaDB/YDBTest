#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/dbcreate.csh . 4
setenv > setenv.out

echo "Lock ^b at client..."
($gtm_exe/mumps -run lbcl </dev/null  >& lbcl.out &) >&! lbcl_bkground.out
sleep 5
# wait upto 100*1 secs for the previous command to get the lock
$GTM << GTM_EOF
l ^b:1
f i=1:1:100 q:\$T=0  l ^b:1 l  h 1
i i=100 w "Waited too long, but the client process did not lock ^b. Please check  lbcl.out",!
h
GTM_EOF

$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; "'$gtm_exe/mumps'" -run lbsvr </dev/null >>&! lbsvr.out; cat lbsvr.out"

#
# check if LKE on server side does indicate client node for the lock of ^b held at client [D9D10-002375]
#
echo ""
echo "------------------------------"
echo "LKE SHOW -ALL on remote_host_2"
echo "------------------------------"
$rsh $tst_remote_host_2  "source $gtm_tst/com/remote_getenv.csh $SEC_DIR_GTCM_2 ; cd $SEC_DIR_GTCM_2; "'$gtm_exe/lke'" show -all </dev/null >& lock_all.out"
$rcp "$tst_remote_host_2":"$SEC_DIR_GTCM_2/lock_all.out" "lock_all.out"
cat lock_all.out
$GTM << GTM_EOF
s ^bexitnow=1
h
GTM_EOF
sleep 10
$gtm_tst/com/dbcheck.csh
