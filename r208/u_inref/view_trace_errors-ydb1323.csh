#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1323] VIEW "TRACE" after an error turning tracing on or off                                   #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# An error writing the profiling data left a subscript count one higher each time. An invalid global'
echo '# name in VIEW "TRACE":0 left tracing on with a partly overwritten name, under which the profiling data'
echo '# was written at exit.'
echo '#'
echo '# Each stage runs its lines in direct mode in a new process, and checks its output for the lines'
echo '# named, and for no fatal error.'
echo
set dm = "$tst_tcsh $gtm_tst/$tst/u_inref/ydbfuzzdm.csh ydb1323dm"
# The test framework can turn on M profiling for every process through the environment, which would change the results
source $gtm_tst/com/unset_ydb_env_var.csh ydb_trace_gbl_name gtm_trace_gbl_name
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

echo '# Stage 1 : 35 cycles of VIEW "TRACE" on and off, with no global directory'
echo '#   expect ZGBLDIRACC and ENO2 for each of the 35 attempts to write the profiling data and for the one'
echo '#   at exit, then MPROFRUNDOWN at exit'
echo '#   previously a Release build failed with GTMASSERT2 in callg.c, and a Debug build failed an assert in'
echo '#   callg.c, after 31 to 35 cycles'
set save_gbldir = `printenv gtmgbldir`
setenv gtmgbldir nonexistent.gld
$dm -count vtnogld ZGBLDIRACC ENO2 MPROFRUNDOWN
setenv gtmgbldir $save_gbldir
echo

foreach case (vtcert vtgarbage)
	if ("vtcert" == $case) then
		echo '# Stage 2 : VIEW "TRACE":0 with the invalid global name "^ race" while VIEW "GDSCERT" is on'
		echo '#   expect VIEWNOTFOUND, the profiling data to be written to ^trace at exit, and MUPIP INTEG to find'
		echo '#   no errors'
		echo '#   previously a Release build failed with GTMASSERT2 in cert_blk.c at exit, writing into a global'
		echo '#   with an invalid name, and a Debug build failed an assert in gv_srch_map.c'
	else
		echo '# Stage 3 : VIEW "TRACE":0 with the invalid global name "^max set x(i)=$trace"'
		echo '#   expect VIEWNOTFOUND, the profiling data to be written to ^trace at exit, and MUPIP INTEG to find'
		echo '#   no errors'
		echo '#   previously a Release build issued no error at exit but wrote into a global with an invalid'
		echo '#   name, which MUPIP INTEG reported, and a Debug build failed an assert in gvnh_spanreg_init.c'
	endif
	$dm $case VIEWNOTFOUND
	echo '# Command : $gtm_dist/mumps -run %XCMD '"'"'write $data(^trace)'"'"
	$gtm_dist/mumps -run %XCMD 'write $select(10=$data(^trace):"PASS",1:"WRONG")," : $data(^trace) is ",$data(^trace),!'
	echo '# Command : $gtm_dist/mupip integ -region "*"'
	$gtm_dist/mupip integ -region "*" >& integ_$case.out
	if ({ $grep -q "No errors detected by integ" integ_$case.out }) then
		echo "PASS : MUPIP INTEG found no errors"
	else
		echo "WRONG : MUPIP INTEG found errors. See integ_$case.out"
	endif
	echo
end

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
