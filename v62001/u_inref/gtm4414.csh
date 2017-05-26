#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that specifying passcurlvn lets the parent process to pass its locals to the child
$gtm_tst/com/dbcreate.csh mumps > newdbcreate.out # Create just to allow TP
$gtm_exe/mumps -run gtm4414a

echo "# Comparing the locals of the parent and child"
# First eliminate the '; *' grabage that is left behind for new'ing the original local name
sed 's/inscopealias="foo" ;\*/inscopealias="foo"/' parentlocals.out > parentlocals.outtmp
mv parentlocals.out{tmp,}
sed 's/restartvar="after" ;\*/restartvar="after"/' localsintp.out > localsintp.outtmp
mv localsintp.out{tmp,}

diff childlocals.mjo parentlocals.out
diff tstartjob.mjo localsintp.out
diff passbyrefjobjob.mjo localsinpassbyref.out

# Set a regular pattern of locals and verify they are correctly passed
$gtm_exe/mumps -run gtm4414b
if ("" != `$grep TEST\-I\-PASS gtm4414b.mjo`) then
    echo "# Verified that the locals have passed in gtm4414b"
endif

echo "# Triggering the JOBLVN2LONG error"
# Make trace extension outx because truss produces other strings that the test framework incorrectly captures
# as errors in the outref: e.g EACCES
$truss -o trace.outx -f $gtm_exe/mumps -run joblvn2longmsg >& joblvnerror.outx
$gtm_tst/com/grepfile.csh JOBLVN2LONG joblvnerror.outx 1
echo "# Wait for grandchild to quit"
# The second execve() call is made by the grandchild so take its PID
if ("AIX" == "$HOSTOS") then
	# Two execve() calls do not reliably show up in the truss output on AIX so use another message
	$gtm_tst/com/wait_for_log.csh -log trace.outx -message '[^0-9]*\([0-9]*\).*returning as child' -count 2
	set procs = `sed -n 's/[^0-9]*\([0-9]*\).*returning as child.*/\1/p' trace.outx`
else
	$gtm_tst/com/wait_for_log.csh -log trace.outx -message '[^0-9]*\([0-9]*\).*execve' -count 2
	set procs = `sed -n 's/[^0-9]*\([0-9]*\).*execve.*/\1/p' trace.outx`
endif
set proctowait = $procs[1]
if ("" == $proctowait) then
	echo "TEST-E-FAIL could not capture PID to wait"
	exit 1
endif
echo $proctowait > proctowait.pid
$gtm_tst/com/wait_for_proc_to_die.csh $proctowait
$gtm_tst/com/wait_for_log.csh -log joblvn2longmsg.mje -message JOBLVN2LONG
mv joblvn2longmsg.{mje,out} # Rename it because any error inside *mje* is picked up by the outref
$gtm_tst/com/check_error_exist.csh joblvn2longmsg.out JOBLVN2LONG
if ($?gtm_test_autorelink_support) then
	echo "Check that relinkctl ipcs are not left over in case of JOBLVN2LONG error (GTM-8224)."
	echo "Running mupip rctldump . and verifying # of routines is 0 and # of attached processes is 1"
	$gtm_exe/mupip rctldump . |& $grep -E "# of|joblvn2longmsg"
endif
$gtm_tst/com/dbcheck.csh	# even though db was not updated, dbcheck is necessary just to balance dbcreate
