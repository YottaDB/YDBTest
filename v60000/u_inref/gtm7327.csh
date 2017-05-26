#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Begin gtm7327"
$gtm_tst/com/dbcreate.csh mumps
setenv gtm_tpnotacidtime 31	# out of range (0-30) value (>30) will cause it to default to 2 (seconds)
setenv gtm_zmaxtptime 15
set syslog_before1 = `date +"%b %e %H:%M:%S"`
$GTM << GTM_EOF
do ^gtm7327
zcontinue
GTM_EOF
set waitpids = `$gtm_exe/mumps -run %XCMD 'write ^jobid(1)," ",^jobid(2),!'`
$gtm_tst/com/wait_for_proc_to_die.csh $waitpids[1]
$gtm_tst/com/wait_for_proc_to_die.csh $waitpids[2]
set syslog_after1 = `date +"%b %e %H:%M:%S"`
echo $syslog_before1 $syslog_after1 > time_window1.txt
$gtm_tst/com/getoper.csh "$syslog_before1" "$syslog_after1" syslog1.txt
set pid = `cat pid.txt`
$grep "${pid}.*trans.6.gtm7327" syslog1.txt
# with tpnotacid time at 2, the log should be full of complaints
setenv gtm_tpnotacidtime 4
setenv gtm_zmaxtptime 61
sleep 1		# to ensure getoper has a working window
set syslog_before2 = `date +"%b %e %H:%M:%S"`
$GTM << GTM_EOF
do ^gtm7327
zcontinue
GTM_EOF
set waitpids = `$gtm_exe/mumps -run %XCMD 'write ^jobid(1)," ",^jobid(2),!'`
$gtm_tst/com/wait_for_proc_to_die.csh $waitpids[1]
$gtm_tst/com/wait_for_proc_to_die.csh $waitpids[2]
set syslog_after2 = `date +"%b %e %H:%M:%S"`
echo $syslog_before2 $syslog_after2 > time_window2.txt
$gtm_tst/com/getoper.csh "$syslog_before2" "$syslog_after2" syslog2.txt
set pid = `cat pid.txt`
$grep "${pid}.*trans.6.gtm7327" syslog2.txt
# with tpnotacid time at 4, the log should only complain about things that are not time(out) related
unsetenv gtm_tpnotacidtime
unsetenv gtm_zmaxtptime
$gtm_tst/com/dbcheck.csh
echo "End gtm7327"
