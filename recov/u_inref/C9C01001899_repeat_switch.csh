#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2003, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
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
setenv test_reorg "NON_REORG"
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
# Cannot use triggers while turning journaling on and off
setenv gtm_test_trigger 0
$gtm_tst/com/dbcreate.csh mumps 8 125 1000 1024 4096 1024 4096
$MUPIP set -journal=enable,off,before -reg "*" |& sort -f
echo "Multi-Process GTM Process starts in background..."
$gtm_tst/com/imptp.csh "4" >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 30
@ cnt = 0
while ($cnt < 20)
	set epoch = `date | $tst_awk '{srand(); print (1 + int(rand() * 900))}'`
	$MUPIP set -journal=enable,on,before,epoch=$epoch -reg "*" |& sort -f
	$MUPIP set -journal=enable,off,before,epoch=$epoch -reg "*" |& sort -f
	@ cnt = $cnt + 1
end
@ cnt = 0
while ($cnt < 20)
	$MUPIP set -journal=enable,on,before -reg DEFAULT
	$MUPIP set -journal=enable,off,before -reg DEFAULT
	@ cnt = $cnt + 1
end
$MUPIP set -journal=enable,off,before -reg "*" |& sort -f
$MUPIP set -journal=enable,on,before -reg "*" |& sort -f
#$MUPIP set -journal=enable,on,before -reg "*" |& sort -f
#sleep 60
#$MUPIP set -journal=enable,off,before -reg "*" |& sort -f
#sleep 10
#$MUPIP set -journal=enable,on,before -reg "*" |& sort -f
sleep 10
#
$gtm_tst/com/gtm_crash.csh
#
#
if ($?test_debug == 1) then
	\mkdir ./save; \cp {*.dat,*.mj*} ./save
endif
#
echo "$MUPIP journal -recover -backward *"
echo "$MUPIP journal -recover -backward *" >>&  recover.out
$MUPIP journal -recover -backward "*" >>& recover.out
set recstat = $status
$grep "successful" recover.out
if ($recstat != 0) then
	echo "TEST-E-RECOVFAIL Mupip recover failed with status $recstat. Test FAILED"
	exit
endif
$gtm_tst/com/dbcheck_filter.csh
$gtm_tst/com/checkdb.csh
if ($status) exit
#
\rm *.dat
$MUPIP create |& sort -f
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
sleep 10
echo "$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl -nocheck -nochain"
$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,d.mjl,e.mjl,f.mjl,g.mjl,mumps.mjl -nocheck -nochain >& forw_recover.out
set recstat = $status
$grep "successful" forw_recover.out
if ($recstat != 0) then
	echo "TEST-E-RECOVFAIL Mupip forward recover failed with status $recstat. Test FAILED"
	exit
endif
$gtm_tst/com/dbcheck.csh -nosprgde
if ($status) exit
#
egrep "YDB-E|YDB-F" *.out
cat *.mje*
