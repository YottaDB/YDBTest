#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#;;;Test saving the exit status of the final process in a pipeline for the PIPE device in $ZCLOSE
#;;;

# Build the ntestin.c routine used in pipetest for this test.  Use delay_filer for the executable name so no
# conflict with the pipetest.  Both look at the process name via ps while it is running in the background.
$gt_cc_compiler -o delay_filter -I$gtm_tst/$tst/inref -I$gtm_dist $gtm_tst/$tst/inref/ntestin.c
# we need another copy with a different name
cp delay_filter delay_filter2
# we need another copy with a different name for timeout test
cp delay_filter delay_filter3

rm -f ntestin.o

$echoline
echo "**************************** pipe close status ***********************"
$echoline
$gtm_dist/mumps -run closestatus

$echoline
echo "**************************** pipe close timeout error message ***********************"
$echoline

# clean up ntestin3 pids in pids_test8

setenv pids `cat pids_test8`
foreach pid ($pids)
	# allow up to 30 sec for pid to be removed
	set cnt=0
	while ( 30 > $cnt )
		(kill -HUP $pid >& /dev/null)
		$gtm_tst/com/is_proc_alive.csh $pid
		if (1 == $status) then
			break
		endif
		sleep 1
		@ cnt++
	end
	if (30 == $cnt) then
		echo "pid\: $pid is still alive - error"
	endif
end


$gtm_dist/mumps -dir >& timeout_errors <<here
set p="pp"
open p:(comm="cat")::"pipe"
zshow "d"
write "Try close p:timeout=-1",!
close p:timeout=-1
zshow "d"
write "Try close p:timeout=.5",!
close p:timeout=.5
zshow "d"
write "Try close p:timeout=1",!
close p:timeout=1
zshow "d"
halt
here

# expect 2 failures
set failures=`$grep -c "DEVPARMTOOSMALL" timeout_errors`
if (2 == $failures) then
	echo "Two DEVPARMTOOSMALL errors seen - as expected"
else
	echo "Check timeout_errors for timeout error messages"
endif
