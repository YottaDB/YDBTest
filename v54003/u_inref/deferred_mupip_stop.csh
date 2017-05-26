#!/usr/local/bin/tcsh

# This subtest verifies that the first two MUPIP STOP signals delivered while a process is in the
# interrupt-deferred zone will be ignored. The third MUPIP STOP is supposed to terminate the process
# regardless of its state.

$gtm_tst/com/dbcreate.csh mumps

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 52

cat << EOF > sample.m
sample
 set ^a=1
EOF

($gtm_exe/mumps -run sample >&! sample.outx & ; echo $! >! pid.outx) >&! sample.out

$gtm_tst/com/wait_for_log.csh -log pid.outx
set pid = `cat pid.outx`

$gtm_tst/com/wait_for_log.csh -log sample.outx -message "will sleep indefinitely now"

$gtm_exe/mupip stop $pid >& mupip_stop_1.outx
sleep 5
$gtm_tst/com/is_proc_alive.csh $pid

if (0 == $status) then
	echo "Process $pid is alive after one MUPIP STOP"
else
	echo "Process $pid is dead after one MUPIP STOP"
	exit 1
endif

$gtm_exe/mupip stop $pid >& mupip_stop_2.outx
sleep 5
$gtm_tst/com/is_proc_alive.csh $pid

if (0 == $status) then
	echo "Process $pid is alive after two MUPIP STOPs"
else
	echo "Process $pid is dead after two MUPIP STOPs"
	exit 1
endif

$gtm_exe/mupip stop $pid >& mupip_stop_3.outx
sleep 5
$gtm_tst/com/wait_for_proc_to_die.csh $pid 120

if (0 != $status) then
	echo "Process $pid is alive after three MUPIP STOPs"
	exit 1
else
	echo "Process $pid is dead after three MUPIP STOPs"
endif

unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number

$gtm_tst/com/dbcheck.csh
