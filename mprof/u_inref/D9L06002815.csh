#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
###################################################################################
# This subtest exercises a number of new MPROF features, including the following: #
#   1.	Implicit tracing initialization via an environment variable               #
#   	gtm_trace_gbl_name, which should be set to '' for MPROF to trace all line #
#   	executions; and to a valid global name, such as '^abc', to additionally   #
#   	save MPROF data into the specified global.                                #
#   2.	Absolute time field for every instruction, indicating the actual number   #
#   	of milliseconds the instruction took.                                     #
#   3.	Special '*RUN' entry that contains cumulative user, system, and their     #
#   	combined CPU time for the current process.                                #
#   4.	Special '*CHILDREN' entry that contains cumulative user, system, and      #
#   	their combined CPU time for all subprocesses spawned by the current       #
#   	process.                                                                  #
# Additionally, the subtest verifies how generic stats for labels are recorded in #
# combination with FOR loops.                                                     #
###################################################################################
$gtm_tst/com/dbcreate.csh .

echo ""

# define the maximum integer to avoid overflows
set MAX_INT = `getconf INT_MAX`
@ HALF_MAX_INT = $MAX_INT / 2

# until we get a 10-second runtime, keep increasing the upper limit for 3n+1 problem
@ i = 0
@ limit = 250
@ total_time_round = 0
set total_time = 1

while ($total_time_round < 10 && $limit <= $HALF_MAX_INT)
	@ i = $i + 1
	if ($i > 50) then
		echo "Failed to get a 10-second runtime!"
		exit 1
	endif
	@ limit = $limit + $limit
	set total_time = `source $gtm_tst/$tst/u_inref/threeen.csh $limit threeen_mprof_time_$i 1 1 |& $head -1 | $tst_awk -F '[us ]' '{print $1 + $3}'`
	@ total_time_round = `echo "$total_time" | $tst_awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}'`
end

echo $limit > limit.txt

##########################################################################
# Testing of implicit tracing without saving to the db                   #
##########################################################################
echo "Implicit tracing, no saving..."
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name ""
source $gtm_tst/$tst/u_inref/threeen.csh $limit no_expl_mem_only 3 1

$echoline

##########################################################################
# Testing of explicit and implicit tracing without saving to the db      #
##########################################################################
echo "Implicit and explicit tracing, no saving..."
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name ""
source $gtm_tst/$tst/u_inref/threeen.csh $limit expl_mem_only 4 1

$echoline

##########################################################################
# Testing of implicit tracing with saving to the db                      #
##########################################################################
echo "Implicit tracing, saving..."

# first, a few bad global names
set name = "^"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name $name
source $gtm_tst/$tst/u_inref/threeen.csh $limit no_expl_with_db1 5 1 $name

echo ""

set name = "a"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name $name
source $gtm_tst/$tst/u_inref/threeen.csh $limit no_expl_with_db2 5 1 $name

echo ""

set name = "\~sdf"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name $name
source $gtm_tst/$tst/u_inref/threeen.csh $limit no_expl_with_db3 5 1 $name

echo ""

set name = " "
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name "$name"
source $gtm_tst/$tst/u_inref/threeen.csh $limit no_expl_with_db4 5 1 "$name"

echo ""

# then, with a valid global name
set name = "^abc"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name $name
source $gtm_tst/$tst/u_inref/threeen.csh $limit no_expl_with_db5 5 1 $name

$echoline

##########################################################################
# Testing of explicit and implicit tracing with saving to the db         #
##########################################################################
echo "Implicit and explicit tracing, saving..."
set name = "^abc"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name $name
source $gtm_tst/$tst/u_inref/threeen.csh $limit expl_with_db 6 1 $name

$echoline

##########################################################################
# Testing of implicit tracing without saving to the db (other global)    #
##########################################################################
echo "Implicit and explicit tracing, saving to other global..."
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_trace_gbl_name gtm_trace_gbl_name "^abc"
source $gtm_tst/$tst/u_inref/threeen.csh $limit expl_with_other_db 8 1 "^cba"

$echoline

##########################################################################
# Testing absolute time field                                            #
##########################################################################
echo "Absolute time testing..."
source $gtm_tst/com/unset_ydb_env_var.csh ydb_trace_gbl_name gtm_trace_gbl_name
source $gtm_tst/$tst/u_inref/threeen.csh $limit abs_time_run 2 1 >& abs_time_run_time.txt
$gtm_tst/com/wait_for_log.csh -log pids.outx -message "PID is printed" -waitcreation -duration 120
set child_pid = `$head -1 pids.outx`
$gtm_tst/com/wait_for_proc_to_die.csh $child_pid 120
\rm pids.outx
$gtm_dist/mumps -direct <<EOF >&! abs_time_run.logx
	set file="abs_time_run"
	set value=^trc("threeen","cyclehelper")
	set total=\$piece(value,":",5)
	set value=^trc("threeen","docycle")
	set total=total+\$piece(value,":",5)
	set value=^trc("threeen","iterate")
	set total=total+\$piece(value,":",5)
	open file:writeonly
	use file
	write (total/1000000),!
	write ^hor
	close file
EOF
set total_time = `cat abs_time_run_time.txt | $tst_awk '{print $3}' | $tst_awk -F '[:.]' '{print $1 * 60 + $2 + $3 * 0.01}'`
set total_mprof = `$head -1 abs_time_run`

# if (total_time - total_mprof) / total_time < 0.5, the test will pass
$gtm_dist/mumps -run discr <<EOF
$total_time $total_mprof 0.5
EOF

$echoline

##########################################################################
# Testing external calls                                                 #
##########################################################################
echo "External calls testing..."

# compile the library
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/threeen.c
$gt_ld_shl_linker ${gt_ld_option_output}libthreeenr${gt_ld_shl_suffix} $gt_ld_shl_options threeen.o $gt_ld_syslibs $tst_ld_sidedeck >&! threeenlink.map

# make sure compilation went fine
if( $status != 0 ) then
    cat threeenlink.map
endif

# remove temporary files
rm -f threeenlink.map
rm -f threeen.o

# prepare the mapping
setenv GTMXC threeen.tab
echo "`pwd`/libthreeenr${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
s3nP1:	void	solve3nPlus1(I:gtm_long_t)
xx

# figure out the good limit for the C code, so that it
# takes at least 10 seconds to run
alias date_s "echo '' | $tst_awk '{print systime()}'"
@ i = 0
@ limit = 250
@ time1 = 0
@ time2 = 0

while ($time2 - $time1 < 10 && $limit <= $HALF_MAX_INT)
	@ i = $i + 1
	if ($i > 50) then
		echo "Failed to get a 10-second runtime!"
		exit 1
	endif
	@ limit = $limit + $limit
	@ time1 = `date_s`
	(time $gtm_dist/mumps -run threeenwrapper) <<EOF >& threeen_time_$i.txt
$limit
EOF
	@ time2 = `date_s`
	$gtm_dist/mumps -direct <<EOF >>&! threeen_time_$i.txt
		set cpu=0,time=0
		for i=2:1:12 set value=^threeentrc("threeenwrapper","threeenwrapper",i),cpu=cpu+\$P(value,":",4),time=time+\$P(value,":",5)
		write (cpu/1000000),!,(time/1000000),!,^hor,!
EOF
end

echo $limit > "ext_limit.txt"

# obtain the CPU and absolute time from both MPROF and time utility
set mprof_cpu = `$tail -5 threeen_time_$i.txt | $head -1`
set mprof_time = `$tail -4 threeen_time_$i.txt | $head -1`
set time_cpu = `$head -1 threeen_time_$i.txt | $tst_awk -F '[us ]' '{print $1 + $3}'`
set time_time = `$head -1 threeen_time_$i.txt | $tst_awk '{print $3}' | $tst_awk -F '[:.]' '{print $1 * 60 + $2 + $3 * 0.01}' `

# if (time_cpu - mprof_cpu) / time_cpu < 0.4, the test will pass
$gtm_dist/mumps -run discr <<EOF
$time_cpu $mprof_cpu 0.4
EOF

# if (time_time - mprof_time) / time_time < 0.4, the test will pass
$gtm_dist/mumps -run discr <<EOF
$time_time $mprof_time 0.4
EOF

$echoline

##########################################################################
# Testing ZSYSTEM calls                                                  #
##########################################################################
echo "ZSYSTEM calls testing..."

# run the M program that does the ZSYSTEM call to loop.csh
(time $gtm_dist/mumps -run subproc) <<EOF >& subproc_time_zsystem.txt
1
EOF

# obtain the CPU time from both MPROF and time utility
set mprof_cpu = `$head -1 subproc_time_zsystem.txt`
set time_cpu = `$tail -1 subproc_time_zsystem.txt | $tst_awk -F '[us ]' '{print $1 + $3}'`

# if (time_cpu - mprof_cpu) / time_cpu < 0.3, the test will pass
$gtm_dist/mumps -run discr <<EOF
$time_cpu $mprof_cpu 0.3
EOF

$echoline

##########################################################################
# Testing PIPEs                                                          #
##########################################################################
echo "PIPEs testing..."

# run the M program that does the PIPE call to loop.csh
(time $gtm_dist/mumps -run subproc) <<EOF >& subproc_time_pipe.txt
2
EOF

# obtain the CPU time from both MPROF and time utility
set mprof_cpu = `$head -1 subproc_time_pipe.txt`
set time_cpu = `$tail -1 subproc_time_pipe.txt | $tst_awk -F '[us ]' '{print $1 + $3}'`

# if (time_cpu - mprof_cpu) / time_cpu < 0.3, the test will pass
$gtm_dist/mumps -run discr <<EOF
$time_cpu $mprof_cpu 0.3
EOF

$echoline

##########################################################################
# Testing label invocations with FORs                                    #
##########################################################################
echo "Label invocations with FORs..."

$gtm_dist/mumps -run forinvocs

echo ""

$gtm_tst/com/dbcheck.csh
