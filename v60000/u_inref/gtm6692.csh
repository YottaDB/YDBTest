#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This test demonstrates that MUMPS can bypass semaphores in rundown if the number of processes are greater than two times
# the number of processors.

# With 16K counter semaphore bump per process, the 32K counter overflow happens with just 2 processes
# and prevents exercising white-box code which this test relies upon so disable counter overflow
# in this test by setting the increment value to default value of 1 (aka unset).
unsetenv gtm_db_counter_sem_incr

# Verify that GDE is able to set QDBRUNDOWN in the fileheader
$GDE change -region DEFAULT -qdbrundown >>& gde_qbr.out
$gtm_exe/mupip create >>& gde_qbr.out
$gtm_exe/dse dump -f -a >&! dse_qbr.out
$grep -q "Quick database rundown is active.*TRUE" dse_qbr.out
if(0 != $?) then
    echo "$status : GDE could not set fileheader properly. Check mumps.gld, mumps.dat, dse_qbr.out and gde_qbr.out. Now exiting."
    exit -1
else
    rm mumps.{dat,gld} gde_qbr.out
endif
$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -region DEFAULT -qdbrundown -lock_space=500 >&! mupip_set_qdbr_and_lockspace.out
$DSE change -f -flush_time='01:00:00:00' >&! flush_time.out
setenv cur_dir `pwd`
\cp $gtm_tst/com/numproc.c $cur_dir
$gt_cc_compiler $cur_dir/numproc.c  -o $cur_dir/numproc >>& compile.out
# numproc saves the number of processors (cores) on the test host
set numproc=`$cur_dir/numproc`
# Send twice the number of processes to activate bypass
set numproc=`expr $numproc \* 2`
echo "#launching $numproc processes to do an update and hang"
# The second parameter "1" means do an update before hanging
$gtm_exe/mumps -run %XCMD "do run^launchjobs($numproc,1)"
# Wait for jobs to launch
$gtm_exe/mumps -run %XCMD "do wait^launchjobs($numproc)"
set pidlist=`sed -n 's/PID=\([0-9]*\)/\1/p' singleproc_launchjobs.mjo*`
# This whitebox test case makes DSE hold access and ftok semaphore until mumps process reaches to gds_rundown()
# When mumps reaches gds_rundown, it lets DSE go by changing flag
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 60
setenv gtm_white_box_test_case_count 1
echo "#Launching 1 processes to hang"
$gtm_exe/mumps -run %XCMD "do run^launchjobs(1,0)"
echo "#Wait for 1 process to hang"
$gtm_tst/com/wait_for_log.csh -log pidone.mjo1 -message "PID"
set pidone=`sed -n 's/PID=\([0-9]*\)/\1/p' pidone.mjo1`
echo "#Launching DSE to hold access control semaphore"
($gtm_exe/dse dump -fileheader -all >&! ftok_halt.out; echo "DSE DONE" &) >&! ftok_halt.log
# Wait for DSE to hang
$gtm_tst/com/wait_for_log.csh -log ftok_halt.out -message "Holding semaphores..."
echo "#Signaling 1 MUMPS process to go"
$gtm_exe/mupip intrpt $pidone >& intrpt_$pidone
echo "#Wait for bypassers to pass and DSE to quit"
$gtm_tst/com/wait_for_proc_to_die.csh $pidone 120
$gtm_tst/com/wait_for_log.csh -log ftok_halt.log -message "DSE DONE"
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
unsetenv gtm_white_box_test_case_count
echo "#Sending interrupts to the rest of the processes"
foreach pid ( $pidlist)
    $gtm_exe/mupip intrpt $pid >& intrpt_$pid
end
echo "#Now waiting for all MUMPS processes to die"
foreach pid ( $pidlist )
    $gtm_tst/com/wait_for_proc_to_die.csh $pid 120
end
# There must be at least one bypass. We can understand this by checking out DSE DUMP -f -a output. DSE itslf may bypass in
# gds_rundown (Because semaphores might be held by MUMPS processes). But this will NOT be reflected in the DSE DUMP output.
# Because the counters are updated AFTER we dump the output. Therfore the counters reflect MUMPS bypasses only.
$grep "Access control rundown bypasses         0  FTOK rundown bypasses            0" ftok_halt.out
$gtm_tst/com/dbcheck.csh
