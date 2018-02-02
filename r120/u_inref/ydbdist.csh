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
set saveydbdist = $ydb_dist
unsetenv ydb_dist
unsetenv gtm_dist

echo "# Allocate a portno to be used for gtcm_gnp_server/gtcm_server"
source $gtm_tst/com/portno_acquire.csh >>& portno.out

# "gtcm_play" is not included in the below list because it produces some timing issues in the test runs
# Not sure what that is and since this is a helper executable for a mostly unused functionality (GTCM OMI),
# it is not considered as essential to test that out here.
set executables = "mumps mupip dbcertify dse ftok geteuid gtcm_gnp_server gtcm_pkdisp gtcm_server gtcm_shmclean gtmsecshr lke semstat2"

$echoline
echo "# Test of <ydb_dist/gtm_dist> env vars and how they affect how executables in $saveydbdist are invoked"
$echoline
#

foreach testcnt (1 2 3 4)
	echo ""
	switch ($testcnt)
	case 1:
		echo "# Test 1 : mumps/mupip/dse/lke etc. invoked through a soft link of a different name should work"
		breaksw
	case 2:
		echo '# Test 2 : Copy of mumps/mupip/dse/lke etc. invoked from a directory that also contains a copy of libyottadb.so should work'
		echo '#          Previously this would issue an IMAGENAME error for the "mumps" case. That is no longer the case'
		cp $saveydbdist/libyottadb.so .	# needed by those executables that dlopen libyottadb.so (mumps, dse, mupip etc.)
		breaksw
	case 3:
		echo '# Test 3 : Copy of mumps/mupip/dse/lke etc. invoked from a directory that does not also contain a copy of libyottadb.so should issue DLLNOOPEN error'
		echo '#          Previously this would issue a GTMDISTUNVERIF error.'
		breaksw
	case 4:
		echo '# Test 4 : mumps/mupip/dse/lke etc. invoked from a current directory where they do not exist, but are found in $PATH, should work'
		set origpath = ($path)
		set path = ($saveydbdist $origpath)
		breaksw
	endsw
	foreach exe ($executables)
		echo "#  Invoking executable : $exe"
		switch ($testcnt)
		case 1:
			set newexe = "`pwd`/my$exe"
			ln -s $saveydbdist/$exe $newexe
			breaksw
		case 2:
			set newexe = "`pwd`/my$exe"
			cp $saveydbdist/$exe $newexe
			breaksw
		case 3:
			set newexe = "`pwd`/my$exe"
			cp $saveydbdist/$exe $newexe
			breaksw
		case 4:
			set newexe = "$exe"
			breaksw
		endsw
		# gtcm_gnp_server needs log files to be specified otherwise they would go to $gtm_dist and
		# depending on whether or not a previous log file existed, they could cause a FILERENAME message to show up or not
		# and in turn cause test failures.
		# gtcm_server too needs log files but more so to find out the pid of the backgrounded server
		# and wait for it to be done before displaying the log file in the test output.
		if (("gtcm_gnp_server" == $exe) || ("gtcm_server" == $exe)) then
			set logfile = log_${exe}_${testcnt}.logx
			set pidfile = ${exe}_${testcnt}.pid
			if ("gtcm_gnp_server" == $exe) then
				set cmd = "$newexe -log=$logfile -service=$portno"
			else
				set cmd = "$newexe -log $logfile -service $portno"
			endif
		else
			set logfile = ""
			set cmd = "$newexe"
		endif
		# Although we redirect the below to a file and immediately cat the file, not redirecting the output
		# results in some test output reordering issues. Not exactly sure what the cause is. But since redirection
		# addresses that issue, it is not further investigated. Use logx (not log) to avoid test error framework
		# from signaling errors in these files at the end of the test.
		$cmd >& ${exe}_${testcnt}.logx
		@ exitstatus = $status
		cat ${exe}_${testcnt}.logx
		if (("$logfile" != "") && (0 == $exitstatus)) then
			# Stop the backgrounded server before moving on.
			# server was started. shut it down. pid can be found in log file.
			$gtm_tst/com/wait_for_log.csh -log $logfile -message "pid :" -waitcreation
			# Since ydb_dist is unset at this point, use system "head" utility rather than $head (aka head.m)
			head -n 1 $logfile | sed 's/].*//g' | $tst_awk '{print $NF}' >! $pidfile
			@ pid = `cat $pidfile`
			if (0 == $pid) then
				echo "Could not find pid from log file $logfile"
			else
				$kill -15 $pid
				$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
			endif
		endif
		if ($newexe != $exe) then
			rm -f $newexe
		endif
	end
	switch ($testcnt)
	case 1:
		breaksw
	case 2:
		rm -f libyottadb.so
		breaksw
	case 3:
		breaksw
	case 4:
		set path = ($origpath)
		breaksw
	endsw
end

echo ""
echo '# Test 5 : gtmsecshr issues a SECSHRNOYDBDIST error if ydb_dist env var is not set'
sleep 1	# sleep to ensure syslog_start is a different time than the time previous tests ran (as they also produce SECSHRNOYDBDIST message)
set syslog_start = `date +"%b %e %H:%M:%S"`
$saveydbdist/gtmsecshr
$gtm_tst/com/getoper.csh "$syslog_start" "" "syslog1.txt" "" "SECSHRNOYDBDIST"
$gtm_tst/com/check_error_exist.csh syslog1.txt SECSHRNOYDBDIST

echo "# Remove portno allocation file"
$gtm_tst/com/portno_release.csh

# Restore ydb_dist/gtm_dist
setenv ydb_dist $saveydbdist
setenv gtm_dist $saveydbdist

