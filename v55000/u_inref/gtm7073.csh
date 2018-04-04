#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

echo "Begin gtm7073"
$gtm_tst/com/dbcreate.csh mumps 4

echo "#No locks. All lock space should be free"
$LKE show

echo "#All but DEFAULT region should have free space"
$GTM <<EOF
lock +a
zsy "$LKE show"
EOF

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# do rundown if needed as otherwise LKE SHOW output in test
								# reference file gets affected due to leftover shm

echo "#All but AREG region should have free space"
$GTM <<EOF
s ^avar=1
lock +^avar
zsy "$LKE show"
EOF

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# do rundown if needed like previous call

echo "#All but BREG region should have free space"
$GTM <<EOF
s ^bvar=1
lock +^bvar
zsy "$LKE show"
EOF

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# do rundown if needed like previous call

echo "#CREG and DEFAULT region should have free space"
$GTM <<EOF
s ^avar=1
lock +^avar
s ^bvar=1
lock +^bvar
zsy "$LKE show"
EOF

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# do rundown if needed like previous call

echo "#No locks should be here"
$LKE show

echo "#Trying to grab 1000 locks from DEFAULT (should hang before reaching 1000)"
set syslog_before1 = `date +"%b %e %H:%M:%S"`
#show1.txtx should have maximum # of locks here
$gtm_exe/mumps -run %XCMD 'for i=1:1:1000 s cmd="lock +myl("""_$J("mylocksub"_i,255)_"""):0" x cmd zsy:i=1000 "$LKE show" write:i=1000 "PID: ",$J' >& show1.txtx
$head -n 6 show1.txtx
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window1.txt

$grep -q "%YDB-I-LOCKSPACEUSE, Estimated free lock space: [0-9]% of 40 pages" show1.txtx
if ($? != 0) then
    echo "Error: Free lock space is outside of expected range. Check show1.txtx."
endif
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "YDB-E-LOCKSPACEFULL|YDB-I-LOCKSPACEINFO"
$grep -q "YDB-E-LOCKSPACEFULL" syslog1.txt
if ($? == 0) then
    echo "TEST-I-PASS YDB-E-LOCKSPACEFULL found in operator log as expected."
else
    echo "TEST-E-FAIL YDB-E-LOCKSPACEFULL not found in operator log. Check syslog1.txt."
endif
#LOCKSPACEFULL and LOCKSPACEINFO Must be issued together.
$grep -q "YDB-I-LOCKSPACEINFO" syslog1.txt
if ($? != 0) then
    echo "TEST-E-FAIL YDB-I-LOCKSPACEINFO not found in operator log. Check syslog1.txt."
endif


#Get PID
set pid=`sed -n 's/PID: \([0-9]*\)/\1/p' show1.txtx`
#Verify PID
$grep -q "GTM.*\[$pid\]" syslog1.txt
if ($? != 0) then
    echo "Syslog PID does not match with the actual process PID check show1.txt and syslog1.txt"
endif

set msgpat="LOCKSPACEFULL, No more room for LOCK slots on database file "
set msgpat="$msgpat"`pwd`
set msgpat="$msgpat/mumps.dat"
$grep -q "$msgpat" syslog1.txt
if ($? != 0) then
    echo "Message format or extra information (waiting proc count etc.) are incorrect check syslog1.txt"
endif

$grep -q "processes on queue: 0/[1-9][0-9]*; LOCK slots in use: [1-9][0-9]*/[1-9][0-9]*;" syslog1.txt
if ($? != 0) then
    echo "LOCK or queue values are incorrect check syslog1.txt"
endif

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0	# do rundown if needed before "mumps -run XCMD" invocation
								# as this stage of the test relies on a clean start of db shm
echo "#Grabbing as many locks possible, releasing 2 of them, waiting on the bg"
$gtm_exe/mumps -run %XCMD 'set ^die=0,^grabbed=0'
set syslog_before1 = `date +"%b %e %H:%M:%S"`
($gtm_exe/mumps -run %XCMD 'do lockandwait^gtm7073(1000)' >&! procstat1.txt &)
$gtm_exe/mumps -run waitlocks^gtm7073
# Wait for the message to trigger
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1000locks.txt "" "YDB-I-LOCKSPACEINFO"
sleep 1 # Advance timestamp because some fast boxes capture this message again in the following getoper.csh

#save half of the lock count somewhere
set locks=`$LKE show | & $grep -c "Owned by PID"`
set locks=`expr $locks / 2 + 1`

echo "#Adding 2 of the locks again. The lock space should be full but syslog should not have LOCKSPACEFULL"
set syslog_before1 = `date +"%b %e %H:%M:%S"`
#show2.txtx should have 2 locks from one process and the rest should be from another process
$gtm_exe/mumps -run %XCMD 'lock +(a1,a2) zsy "$LKE show"' >& show2.txtx
$head -n 6 show2.txtx
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window2.txt

$grep -q "%YDB-I-LOCKSPACEUSE, Estimated free lock space: [0-9]% of 40 pages" show2.txtx
if ($? != 0) then
    echo "Error: Free lock space is not in expected range. Check show2.txtx."
endif
if (`$grep "PID= [0-9]*" show2.txtx | cut -d\  -f 2- | sort | uniq | grep -c "PID"` != 2) then
    echo "Error: Locks should be held by 2 processes. Check show2.txt"
endif
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog2.txt ""
$grep "YDB-E-LOCKSPACEFULL" syslog2.txt
if ($? == 0) then
    echo "TEST-E-FAIL YDB-E-LOCKSPACEFULL found in operator log. Check syslog2.txt."
else
    echo "TEST-I-PASS YDB-E-LOCKSPACEFULL not found in operator log as expected."
endif

$LKE show >& show3.txtx
#Now that 2 locks are released, show3.txtx should have locks from a single process
if(`$grep "PID= [0-9]*" show3.txtx | cut -d\  -f 2- | uniq | grep -c "PID"` != 1) then
    echo "Error: Locks should be held by a single process. Check show3.txt"
endif

echo "#Stop the process"
$gtm_exe/mumps -run %XCMD 'set ^die=1'
$gtm_tst/com/wait_for_proc_to_die.csh `cat procstat1.txt` 300

echo "#Trying with 2 diffrent processes..."
echo "#Grab 3 locks with shorter names and wait in the background"
$gtm_exe/mumps -run %XCMD 'set ^die=0,^grabbed=0'
($gtm_exe/mumps -run %XCMD 'do lockandwait^gtm7073(5)' >&! procstat2.txt &)
$gtm_exe/mumps -run waitlocks^gtm7073

echo "#Grab 1000 locks with shorter names and wait in the background"
set syslog_before1 = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run %XCMD 'set ^grabbed=0'
($gtm_exe/mumps -run %XCMD 'do lockandwait^gtm7073(1000)' >&! procstat3.txt &)
$gtm_exe/mumps -run waitlocks^gtm7073
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window3.txt
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog3.txt "" "YDB-I-LOCKSPACEINFO"
if ($status) then
    echo "TEST-E-FAIL YDB-I-LOCKSPACEINFO not found in operator log. Check syslog3.txt."
else
    echo "TEST-I-PASS YDB-I-LOCKSPACEINFO found in operator log as expected."
endif

$LKE show >& show4.txtx
#Get PID
set pid=`sed -n 's/.*PID= \([0-9]*\).*/\1/p' show4.txtx | sort | uniq`
#Verify PID
$grep -E -q "GTM.*\[($pid[1]|$pid[2])\]" syslog3.txt
if ($? != 0) then
    echo "Syslog PID does not match with the actual process PID check and syslog3.txt"
endif

set msgpat="LOCKSPACEFULL, No more room for LOCK slots on database file "
set msgpat="$msgpat"`pwd`
set msgpat="$msgpat/mumps.dat"

$grep -q "$msgpat" syslog3.txt
if ($? != 0) then
    echo "Message format or extra information (waiting proc count etc.) are incorrect check syslog3.txt"
endif

$grep -q "processes on queue: 0/[1-9][0-9]*; LOCK slots in use: [1-9][0-9]*/[1-9][0-9]*;" syslog3.txt
if ($? != 0) then
    echo "LOCK or queue values are incorrect check syslog3.txt"
endif

$LKE show >& show5.txtx
echo "#Stop the processes"
$gtm_exe/mumps -run %XCMD 'set ^die=1'
$gtm_tst/com/wait_for_proc_to_die.csh `cat procstat2.txt` 300
$gtm_tst/com/wait_for_proc_to_die.csh `cat procstat3.txt` 300

echo "#using half of the total lock space"
set syslog_before1 = `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run %XCMD 'set ^die=0,^grabbed=0'
($gtm_exe/mumps -run %XCMD "do lockandwait^gtm7073($locks+2)" >&! procstat4.txt &)
$gtm_exe/mumps -run waitlocks^gtm7073
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window4.txt
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog4.txt ""
$grep "YDB-E-LOCKSPACEFULL" syslog4.txt
if ($? == 0) then
    echo "TEST-E-FAIL YDB-E-LOCKSPACEFULL found in operator log. Check syslog4.txt."
else
    echo "TEST-I-PASS YDB-E-LOCKSPACEFULL not found in operator log as expected."
endif

$LKE show >& show6.txt

echo "#Stop the processes"
$gtm_exe/mumps -run %XCMD 'set ^die=1'
$gtm_tst/com/wait_for_proc_to_die.csh `cat procstat4.txt` 300

echo "#Fill up entire space with short named locks and check if LOCKSPACEFULL message exists in LKE SHOW command"
$gtm_exe/mumps -run %XCMD 'set ^die=0,^grabbed=0'
($gtm_exe/mumps -run %XCMD 'do lockandwait^gtm7073(1000)' >&! procstat5.txt &)
$gtm_exe/mumps -run waitlocks^gtm7073
$gtm_exe/mumps -run %XCMD 'lock +(a,b) zsy "$LKE show"' >& show7.txt
$grep -q LOCKSPACEFULL show7.txt
if ($? == 0) then
    echo "LOCKSPACEFULL message found in LKE SHOW output as expected."
else
    echo "LOCKSPACEFULL message could not be found in LKE SHOW output. Check show7.txt."
endif

set msgpat="LOCKSPACEFULL, No more room for LOCK slots on database file "
set msgpat="$msgpat"`pwd`
set msgpat="$msgpat/mumps.dat"

$grep -q "$msgpat" show7.txt
if ($? != 0) then
    echo "Message format or extra information (waiting proc count etc.) are incorrect check show7.txt"
endif

$grep -q "processes on queue: 0/[1-9][0-9]*; LOCK slots in use: [1-9][0-9]*/[1-9][0-9]*;" show7.txt
if ($? != 0) then
    echo "LOCK or queue values are incorrect check show7.txt.txt"
endif

($gtm_exe/mumps -run %XCMD 'write $job for i=1:1:3 lock @("+a"_i)' >&! procstat6.txt &)

#Wait for command above to hang for 10 seconds
set pass=0
foreach i (1 2 3 4 5)
    sleep 2
    $LKE show -a -w >& show8.txt
    $grep -q  "$msgpat" show8.txt
    if ($? == 0) then
	set pass=1 #If found, stop waiting
	break
    endif
end
if ($pass != 1) then
       	echo "Message format or extra information (waiting proc count etc.) are incorrect check show8.txt"
endif

echo "#Stop the processes"
$gtm_exe/mumps -run %XCMD 'set ^die=1'
$gtm_tst/com/wait_for_proc_to_die.csh `cat procstat5.txt` 300
$gtm_tst/com/wait_for_proc_to_die.csh `cat procstat6.txt` 300

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do leftover ipc rundown if needed before doing rundown in test

$MUPIP rundown -region "*" >& rundown_stat.txtx
if ($? != 0) then
    echo "Error in mupip rundown. Check rundown_stat.txtx"
endif
$gtm_tst/com/dbcheck.csh
echo "End gtm7073"
