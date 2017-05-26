#!/usr/local/bin/tcsh -f
# set up the environment for speed test
if ($tst_image != "pro") then
	echo "TEST-W-Speed test reference data is for PRO only"
	exit
endif
echo "#Following env variable modifications done in speed/setvar.csh" >> settings.csh
echo "setenv test_align 131072" >> settings.csh
setenv test_align 131072 
setenv tst_jnl_str "-journal=enable,on,before,align=$test_align,alloc=5000,exten=5000,auto=1000000,buff=2000"
echo "setenv tst_jnl_str $tst_jnl_str" >> settings.csh
if ($acc_meth == "MM") source $gtm_tst/com/mm_nobefore.csh
if ($?gtm_gvdupsetnoop) then
	echo "unsetenv gtm_gvdupsetnoop" >> settings.csh;unsetenv gtm_gvdupsetnoop  
endif
echo "setenv gtm_zlib_cmp_level 0" >> settings.csh
setenv gtm_zlib_cmp_level 0 
if ($?gtm_tp_allocation_clue) then 
	echo "unsetenv gtm_tp_allocation_clue" >> settings.csh;unsetenv gtm_tp_allocation_clue
endif
echo "#End speed/setvar.csh" >> settings.csh

if ($?test_speed_runs == 0 ) setenv test_speed_runs 1
if (0 != $?test_replic) then
	# If replication is used, force maximum buffer we can use accross platforms
	setenv speed_replic "REPL"
	setenv tst_buffsize 32000000
else
	# if coming through the weekly test runs, use the remote directory disk for journal directory
	if ($?gtm_tst_remote) then
		setenv test_jnldir $gtm_tst_remote/$gtm_tst_out/$testname/tmp
		mkdir -p $test_jnldir
		echo "# remove jnldir as well: " >> $tst_general_dir/cleanup.csh
		echo "rm -rf $test_jnldir:h:h/*$testname >& /dev/null" >> $tst_general_dir/cleanup.csh
	endif
	setenv speed_replic "NOREPL"
endif
#
#
echo "Ops/CPU_sec     = No of Operations/CPU second/CPU>"
echo "Ops/Elapsed_sec = No of Operations/Elapsed second>"
echo "PASS/FAIL reported on Ops/CPU_sec"
$gtm_exe/mumps $gtm_tst/$tst/inref/seqgbl.m
$gtm_exe/mumps $gtm_tst/$tst/inref/randgbl.m
$gtm_exe/mumps $gtm_tst/$tst/inref/seqlcl.m
$gtm_exe/mumps $gtm_tst/$tst/inref/randlcl.m
setenv cur_dir `pwd`
echo "Find number of processors"
\cp $gtm_tst/com/numproc.c $cur_dir
$gt_cc_compiler $cur_dir/numproc.c  -o $cur_dir/numproc >>& compile.out

setenv numproc `$cur_dir/numproc`
#
echo "Create executable $cur_dir/prime_root to be used later"
\cp $gtm_tst/$tst/inref/prime_root.c $cur_dir
$gt_cc_compiler $cur_dir/prime_root.c  -o $cur_dir/prime_root >>& compile.out
#
\cp $gtm_tst/$tst/inref/symbols.arrays .
\cp $gtm_tst/$tst/inref/symbols.variables .
#
cat >> $tst_general_dir/result.txt << EOF
Speed test was run with following parameters
ACCESS METHOD		: $acc_meth 
REPLICATION		: $speed_replic
ALIGN SIZE		: $test_align 
JOURNALING		: $tst_jnl_str 
DUP SET OPTIMIZATION	: OFF
COMPRESSION		: $gtm_zlib_cmp_level 
TP ALLOCATION CLUE	: OFF
BUFFER SIZE		: $tst_buffsize
EOF
cat >> $tst_general_dir/sp_data.txt << EOF
ACCESS METHOD           : $acc_meth
REPLICATION             : $speed_replic
ALIGN SIZE              : $test_align
JOURNALING              : $tst_jnl_str
DUP SET OPTIMIZATION    : OFF
COMPRESSION             : $gtm_zlib_cmp_level
TP ALLOCATION CLUE      : OFF
BUFFER SIZE             : $tst_buffsize
EOF


