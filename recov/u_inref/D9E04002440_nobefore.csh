#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv test_debug 1
unsetenv test_replic
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
# Cannot use triggers while turning journaling on and off
setenv gtm_test_trigger 0
\mkdir ./bak1
$gtm_tst/com/dbcreate.csh mumps 8 125 1000 1024 2048 64 2048
echo "$MUPIP set -journal=enable,on,nobefore,auto=16384,epoch=40 -reg * |& sort -f"
$MUPIP set -journal=enable,on,nobefore,auto=16384,epoch=40 -reg "*" |& sort -f
echo "Multi-Process GTM Process starts in background..."
#
$gtm_tst/com/imptp.csh "5" >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
#
sleep 40
echo "$MUPIP backup * ./bak1"
$MUPIP backup "*" ./bak1 >>& backup.out
sleep 80
#
$gtm_tst/com/gtm_crash.csh
#
$gtm_tst/com/corrupt_jnlrec.csh mumps b c >>& corrupt_jnlrec.out
#
if ($?test_debug == 1) then
	\mkdir ./save; \cp {*.gld,*.dat,*.mj*} ./save
endif
#
# Now copy back backed up database
\cp ./bak1/* .
##
echo "$MUPIP journal -recover -verbose -forward *"
echo "$MUPIP journal -recover -verbose -forward *" >>&  forward.out
$MUPIP journal -recover -verbose -forward "*" >>& forward.out
set recstat1 = $status
$grep "JNLSUCCESS" forward.out
set recstat2 = $status
if ($recstat1 != 0 || $recstat2 != 0) then
	echo "TEST-E-RECOVFAIL Mupip recover failed with status recstat1: $recstat1, recstat2: $recstat2 "
	exit
endif
$gtm_tst/com/checkdb.csh
$gtm_tst/com/dbcheck.csh
