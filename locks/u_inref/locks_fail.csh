#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# If we make such changes that 10 processes occupy 10 pages of the lock queue, then this script needs to be updated. Otherwise,
# this test will hang.

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and affects the calculations of this very sensitive test. So disable counter overflows.
unsetenv gtm_db_counter_sem_incr

echo "# Create mumps.dat with lock space of 10 pages."
# use M mode on zos to avoid tagging issue in lockspacefull.m
if ( "os390" == $gtm_test_osname ) then
	$switch_chset M >& switch_ch_m.log
endif
setenv gtmgbldir mumps.gld
$gtm_exe/mumps -run GDE << GDE_EOF >& gde.out
change -segment DEFAULT -lock_space=10
exit
GDE_EOF
$MUPIP create >& dbcreate.out

# This test is included in the replic run as well even though it doesn't start replication servers (via dbcreate.csh). So,
# mumps.repl is never created even thought $gtm_repl_instance is defined. If $gtm_custom_errors is set, global references (updates/
# reads) will try top open Journal Pool and will end up with FTOKERR/ENO2 errors. So, unsetenv gtm_repl_instance
unsetenv gtm_repl_instance


#Fire off 10 processes to see what percantage of memory is used. Based on that, caluclate maximum queue capacity. E.g. 10 locks use 50% of the lock queue. Then we know that the queue capacity is 20.
#10 is an arbitrary number of processes. Could be changed.
echo "# Calculate maximum queue capacity"
$gtm_exe/mumps -run %XCMD "do ^lockspacefull(10,1)" >&! lke_show.txtx
set per=`sed -n 's/.*Estimated free lock space: \([0-9]*\).*/\1/p' lke_show.txtx`
set per=`expr 100 - $per`
echo $per > per.txtx
set lockparm=`echo  \(1000 + $per - 1\) / $per | bc`
echo "# Calculated maximum lock queue capacitys is $lockparm"

#Increase by one to overload lock queue
@ lockparm++

echo "# Fire off $lockparm + 1 processes and expect LOCKSPACEINFO and LOCKSPACEFULL messages"
setenv syslog_before1 `date +"%b %e %H:%M:%S"`
$gtm_exe/mumps -run %XCMD "do ^lockspacefull($lockparm,0)"

echo "# Lock space overloaded and quit. Now checking syslog."
# Put in timing info for getoper
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window.txt
$gtm_tst/com/getoper.csh "$syslog_before1" "" syslog1.txt "" "YDB-I-LOCKSPACEINFO"

echo "# Verify that messages are not generated from another process"
set pids=`$tst_awk '{if ($1 ~ "PID:") {var=var "|" $2}} END{print substr(var,2)}' justlock.mjo*`
$grep -q -E "$pids" syslog1.txt
if ($? != 0) then
    echo "LOCKSPACE related messages do not come from this test!"
endif
