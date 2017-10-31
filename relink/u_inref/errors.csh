#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a test of various error code paths possible with autorelink.

# We do not want autorelink-enabled directories that have been randomly assigned by the test system because we are explicitly
# testing the autorelink functionality, as opposed to the rest of the test system which may be testing it implicitly.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

# Keep things local to avoid affecting concurrent tests.
setenv gtm_linktmpdir .

# Make sure only the current directory is autorelink-enabled.
setenv gtmroutines ".* $gtmroutines"

# Create a simple routine for testing.
cat > a.m <<eof
a
 quit
eof

# Remember the environment variable for library preload.
if ("AIX" == $HOSTOS) then
	set lib_preload_var = LDR_PRELOAD64
else
	set lib_preload_var = LD_PRELOAD
endif

# Note: The "grep -v mumps" bit in this and subsequent cases is to filter out the messages about the completion of the
# backgrounded mumps process that certain tcsh versions may spew.
echo "1. Change permissions on an active relinkctl file and start a concurrent process to access it."
$gtm_dist/mumps -direct > mumps_direct1.log <<eof
set x="pid-1.1.out"
open x:newversion
use x
write \$job,!
close x
set \$zroutines=".*"
do ^a
zshow "A":rctl
set rctlfile=\$piece(rctl("A",2),": ",2)
if \$&gtmposix.chmod(rctlfile,0,.errno)
zsystem "(\$gtm_dist/mumps -run a &; echo \$! > pid-1.2.out; wait) | grep -v mumps"
eof

@ pid1 = `cat pid-1.1.out`
@ pid2 = `cat pid-1.2.out`
$gtm_tst/$tst/u_inref/report_new_ipcs.csh 1 "$pid1|$pid2"
echo

echo "2. Change permissions on an active relinkctl shared memory and start a concurrent process to access it."
$gtm_dist/mumps -direct > mumps_direct2.log <<eof
set x="pid-2.1.out"
open x:newversion
use x
write \$job,!
close x
set \$zroutines=".*"
do ^a
zshow "A":rctl
set shmid=+\$piece(rctl("A",5),"shmid: ",2)
if \$&relink.chShmMod(shmid,0)
zsystem "(\$gtm_dist/mumps -run a &; echo \$! > pid-2.2.out; wait) | grep -v mumps"
eof

@ pid1 = `cat pid-2.1.out`
@ pid2 = `cat pid-2.2.out`
$gtm_tst/$tst/u_inref/report_new_ipcs.csh 2 "$pid1|$pid2"
echo

echo "3. Preload a library to return ENOMEM on relinkctl shmget() allocations and have a process allocate relinkctl shared memory."

# Compile a special library to fail shmget() when we need it.
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_dist $gtm_tst/$tst/inref/shmget.c -o shmget.o
$gt_ld_shl_linker ${gt_ld_option_output}libshmget${gt_ld_shl_suffix} $gt_ld_shl_options shmget.o $gt_ld_sysrtns -ldl

# We want the loading of libhugetlbfs.so to fail, thus making GT.M reference the shmget() we provide.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 86
setenv gtm_white_box_test_case_count 1

# Since the huge pages library is unloadable, disable the huge page settings.
unsetenv HUGETLB_MORECORE
unsetenv HUGETLB_SHM
unsetenv HUGETLB_VERBOSE

# Fail shmget() on the first attempt.
setenv gtm_test_shmget_count 1

# Start a MUMPS process with the library preloaded.
setenv $lib_preload_var ./libshmget${gt_ld_shl_suffix}
($gtm_dist/mumps -run %XCMD 'set $zroutines=".*" do ^a' >&! mumps-3.outx &; unsetenv $lib_preload_var; echo $! > pid-3.out; wait) >&! /dev/null
unsetenv $lib_preload_var
cat mumps-3.outx

@ pid = `cat pid-3.out`
$gtm_tst/$tst/u_inref/report_new_ipcs.csh 3 "$pid"
echo

echo "4. Preload a library to return ENOMEM on relinkctl shmat() and have a process allocate and attach to relinkctl shared memory."

# Compile a special library to fail shmat() when we need it.
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_dist $gtm_tst/$tst/inref/shmat.c -o shmat.o
$gt_ld_shl_linker ${gt_ld_option_output}libshmat${gt_ld_shl_suffix} $gt_ld_shl_options shmat.o $gt_ld_sysrtns -ldl

# Fail shmat() on the first attempt.
setenv gtm_test_shmat_count 1

# Start a MUMPS process with the library preloaded.
setenv $lib_preload_var ./libshmat${gt_ld_shl_suffix}
($gtm_dist/mumps -run %XCMD 'set $zroutines=".*" do ^a' >&! mumps-4.outx &; unsetenv $lib_preload_var; echo $! > pid-4.out; wait) >&! /dev/null
unsetenv $lib_preload_var
cat mumps-4.outx

@ pid = `cat pid-4.out`
$gtm_tst/$tst/u_inref/report_new_ipcs.csh 4 "$pid"
echo

echo "5. Change permissions on an active rtnobj shared memory and start a concurrent process to access it."
$gtm_dist/mumps -direct > mumps_direct5.log <<eof
set x="pid-5.1.out"
open x:newversion
use x
write \$job,!
close x
set \$zroutines=".*"
do ^a
zshow "A":rctl
set shmid=+\$piece(rctl("A",6),"shmid: ",2)
if \$&relink.chShmMod(shmid,0)
zsystem "(\$gtm_dist/mumps -run a &; echo \$! > pid-5.2.out; wait) | grep -v mumps"
eof

@ pid1 = `cat pid-5.1.out`
@ pid2 = `cat pid-5.2.out`
$gtm_tst/$tst/u_inref/report_new_ipcs.csh 5 "$pid1|$pid2"
echo

echo "6. Preload a library to return ENOMEM on rtnobj shmget() allocations and have a process allocate relinkctl shared memory."

# Fail shmget() on the second attempt.
setenv gtm_test_shmget_count 2

# Start a MUMPS process with the library preloaded.
setenv $lib_preload_var ./libshmget${gt_ld_shl_suffix}
($gtm_dist/mumps -run %XCMD 'set $zroutines=".*" do ^a' >&! mumps-6.outx &; unsetenv $lib_preload_var; echo $! > pid-6.out; wait) >&! /dev/null
unsetenv $lib_preload_var
cat mumps-6.outx

@ pid = `cat pid-6.out`
$gtm_tst/$tst/u_inref/report_new_ipcs.csh 6 "$pid"
echo

echo "7. Preload a library to return ENOMEM on rtnobj shmat() and have a process allocate and attach to rtnobj shared memory."

# Fail shmat() on the second attempt.
setenv gtm_test_shmat_count 2

# Start a MUMPS process with the library preloaded.
setenv $lib_preload_var ./libshmat${gt_ld_shl_suffix}
($gtm_dist/mumps -run %XCMD 'set $zroutines=".*" do ^a' >&! mumps-7.outx &; unsetenv $lib_preload_var; echo $! > pid-7.out; wait) >&! /dev/null
unsetenv $lib_preload_var
cat mumps-7.outx

@ pid = `cat pid-7.out`
$gtm_tst/$tst/u_inref/report_new_ipcs.csh 7 "$pid"
