#!/usr/local/bin/tcsh -f
# test case 27: test LCL part of speed test with alignment enabled and disabled.
#
# $1 = Local or, Global or, Global+reorg or, TP
# $2 = Sequential collating order of Keys or, Random Keys for successive updates
# $3 = Journal vs No journal
# $4 = number of region
# $5 = number of processes
# $6 = Number of types of operations to test (SET is one type, READ is another, $GET is another)
# $7 = Number of repeat of inner most test loop
#
echo "ALIGN_STRINGS Test Starts..."
# since we need to call the scripts and M routines of speed test, reset $tst
set orig_tst=$tst
set orig_routines="$gtmroutines"
setenv tst "speed"
if ($?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
			setenv gtmroutines ".($gtm_tst/$orig_tst/inref $gtm_tst/$tst/inref $gtm_tst/com .) $gtm_exe/utf8"
		else
			setenv gtmroutines ".($gtm_tst/$orig_tst/inref $gtm_tst/$tst/inref $gtm_tst/com .) $gtm_exe"
	endif
endif
if ("pro" == "$tst_image") then
	# log files are deleted as a part of speed test. So preserve the original log file of this test
	mkdir perserve_logs
	cp *.log* preserve_logs/
	source $gtm_tst/$tst/u_inref/setvar.csh
	#
	#
	#setenv no_align_strings
	setenv gtm_disable_alignstr "TRUE"
	echo "Local Variable: Ordered Keys : No Journaling: Single-Process"
	$gtm_tst/$tst/u_inref/main.csh "LCL" "SEQOP" "NOJNL" "6" "1" "2" "1" 
	#
	echo "Local Variable: Random Keys : No Journaling: Single-Process"
	$gtm_tst/$tst/u_inref/main.csh "LCL" "RANDOP" "NOJNL" "6" "1" "8" "1" 
	#
	#unsetenv no_align_strings
	setenv gtm_disable_alignstr "FALSE"
	echo "Local Variable: Ordered Keys : No Journaling: Single-Process"
	$gtm_tst/$tst/u_inref/main.csh "LCL" "SEQOP" "NOJNL" "6" "1" "2" "1" 
	#
	echo "Local Variable: Random Keys : No Journaling: Single-Process"
	$gtm_tst/$tst/u_inref/main.csh "LCL" "RANDOP" "NOJNL" "6" "1" "8" "1" 
	#
	###
	### Following is for computing speed test reference speed from ^run number of runs
	### And Save the result files to LOGS directory
	###
	$gtm_tst/$tst/u_inref/check_result.csh
	#
	cp preserve_logs/* .
endif
setenv tst $orig_tst
setenv gtmroutines "$orig_routines"
# for test case 31, take a few M files from the test system with all symbols 8-char 
# or below, then take a new M file, lotsvar.m, compile them with align_string and 
# noalign_string. Report the diference of object code sizes.
echo "Compile M routines with align_strings qualifier"
$gtm_exe/mumps -align_strings $gtm_tst/com/waitchrg.m
$gtm_exe/mumps -align_strings $gtm_tst/com/umjrnl.m
$gtm_exe/mumps -align_strings $gtm_tst/com/imptp.m
$gtm_exe/mumps -align_strings $gtm_tst/com/checkdb.m
$gtm_exe/mumps -align_strings $gtm_tst/com/lotsvar.m
# get the object code sizes
set sizew1=`ls -l waitchrg.o | $tst_awk '{print $5}'`
set sizeu1=`ls -l umjrnl.o | $tst_awk '{print $5}'`
set sizei1=`ls -l imptp.o | $tst_awk '{print $5}'`
set sizec1=`ls -l checkdb.o | $tst_awk '{print $5}'`
set sizel1=`ls -l lotsvar.o | $tst_awk '{print $5}'`
#
echo "Compile M routines with noalign_strings qualifier"
$gtm_exe/mumps -noalign_strings $gtm_tst/com/waitchrg.m
$gtm_exe/mumps -noalign_strings $gtm_tst/com/umjrnl.m
$gtm_exe/mumps -noalign_strings $gtm_tst/com/imptp.m
$gtm_exe/mumps -noalign_strings $gtm_tst/com/checkdb.m
$gtm_exe/mumps -noalign_strings $gtm_tst/com/lotsvar.m
# get the object code sizes
set sizew2=`ls -l waitchrg.o | $tst_awk '{print $5}'`
set sizeu2=`ls -l umjrnl.o | $tst_awk '{print $5}'`
set sizei2=`ls -l imptp.o | $tst_awk '{print $5}'`
set sizec2=`ls -l checkdb.o | $tst_awk '{print $5}'`
set sizel2=`ls -l lotsvar.o | $tst_awk '{print $5}'`
# compare the object code sizes
@ diffw = $sizew1 - $sizew2
@ diffu = $sizeu1 - $sizeu2
@ diffi = $sizei1 - $sizei2
@ diffc = $sizec1 - $sizec2
@ diffl = $sizel1 - $sizel2

# Comments from Steve/Malli
# Until we extend GT.M stringpool management to retain the alignment even after garbage collection, we will disable the align_string feature
# The option align_strings is currently ignored and so there will not be any difference reported here.
echo "M filename  object size with align  object size with noalign  difference"
echo "waitchrg.m  $sizew1		  $sizew2		    $diffw"
echo "umjrnl.m    $sizeu1		  $sizeu2		    $diffu"
echo "imptp.m     $sizei1		  $sizei2		    $diffi"
echo "checkdb.m   $sizec1		  $sizec2		    $diffc"
echo "lotsvar.m   $sizel1		  $sizel2		    $diffl"
#
# how to test the runtime memory usage and speed?
echo "ALIGN_STRINGS Test Ends..."
