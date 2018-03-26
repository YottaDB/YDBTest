#################################################################
#								#
# Copyright (c) 2011-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
# this script tests various improvements to MPROF done as a part of D9L03-002804 (mostly) and C9L04-003409.
$gtm_tst/com/dbcreate.csh .

echo ""

# testing of nested FORs
$gtm_exe/mumps -run nestedfors
echo ""

# testing of stack overflow
$gtm_exe/mumps -run overflow
echo ""

@ num_of_fatal_errors = `ls -l YDB_FATAL_ERROR* | wc -l`
if ($num_of_fatal_errors == 1) then
	# move the YDB_FATAL_ERROR.* files, so that error catching mechanism do not show invalid failures
	foreach file ( `ls -l YDB_FATAL_ERROR* | $tst_awk '{print $NF}'` )
		mv $file `echo $file | $tst_awk -F 'YDB' '{print $2}'`
	end
endif

# testing of disabling tracing on the same line with other code
$gtm_exe/mumps -run inline
echo ""

# testing of discrepancy between CPU times reported by the time utility and aggregate of MPROF numbers
@ i = 0
@ scale = 5
@ limit = 250
@ total_time_round = 0
set total_time = 1

# until we get a 30-second runtime, keep increasing the upper limit for 3n+1 problem
while ($total_time_round < 30)
	@ i = $i + 1
	if ($i > 50) then
		echo "Failed to have a 30-second runtime!"
		exit 1
	endif
	@ limit = $limit + $limit
	@ scale = $scale + $scale
	set total_time = `source $gtm_tst/$tst/u_inref/threeen.csh $limit threeen_mprof_time_$i 1 1 |& $tst_awk -F '[us ]' '{print $1 + $3}'`
	$gtm_dist/mumps -direct <<EOF >&! threeen_$i.logx
		S file="threeen_mprof_time_$i"
		S value=^trc("*RUN")
		S total=\$P(value,":",3)
		O file:writeonly
		U file
		W (total/1000000),!
		W ^hor
		C file
EOF
	@ total_time_round = `echo "$total_time" | $tst_awk '{printf("%d\n",$0+=$0<0?-0.5:0.5)}'`
end

set total_mprof = `cat threeen_mprof_time_$i`

# if (total_time - total_mprof) / total_time < 0.5, the test will pass
# we initially had a much smaller threshold, but it was getting exceeded on slower and heavily loaded machines,
# so we readjusted the tolerance; however, we are still within the same order of magnitude, hence no worries yet
$gtm_dist/mumps -run discr <<EOF
$total_time $total_mprof 0.5
EOF
echo ""

# testing that MPROF is not leaking memory; using a low upper limit, so that the same code would get executed
# hundreds of times, for the total duration of about 30 seconds
source $gtm_tst/$tst/u_inref/threeen.csh 50 threeen_mprof_storage 7 $scale > /dev/null
set storage_diff = `cat threeen_mprof_storage`
if (0 == $storage_diff) then
	echo "PASSED: storage difference is tolerable"
else
	echo "FAILED: storage difference $storage_diff > threshold 0"
endif

echo ""

$gtm_tst/com/dbcheck.csh
