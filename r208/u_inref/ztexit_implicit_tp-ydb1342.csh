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
echo '# [YDB#1342] With $ZTEXIT true, an update that uses an implicit transaction completes once and       #'
echo '# then $ZINTERRUPT runs once                                                                         #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# A ZTRIGGER command, $ZTRIGGER("ITEM") and a SET or KILL that invokes a trigger use an implicit'
echo '# transaction. With $ZTEXIT true, the end of that transaction issued the same error that a TCOMMIT'
echo '# command issues to run $ZINTERRUPT. But after $ZINTERRUPT, the M command that did the update ran'
echo '# again, so the update and $ZINTERRUPT repeated without end.'
echo '#'
echo '# Each stage runs in its own process, with a time limit so that the stage ends even if the update'
echo '# repeats without end.'
echo

cp $gtm_tst/$tst/inref/ydb1342.m .
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif

set stage = 0
foreach label (settrig ztrignone ztrigtrig killtrig ztrigitem trigerr intp)
	@ stage++
	switch ($label)
	case settrig:
		echo "# Stage $stage : SET ^x(1)=1 with a SET trigger on ^x, and "'$ZTEXIT true'
		echo '# Before the fix : the SET, its trigger and $ZINTERRUPT repeated without end in a Release build. A'
		echo '#                  Debug build failed an assert in gvcst_put.c'
		echo '# With the fix   : expect the SET and its trigger to run once, then $ZINTERRUPT once'
		breaksw
	case ztrignone:
		echo "# Stage $stage : ZTRIGGER ^x(1) with no trigger defined, and "'$ZTEXIT true'
		echo '# Before the fix : the ZTRIGGER and $ZINTERRUPT repeated without end in a Release build. A Debug'
		echo '#                  build failed an assert in gvcst_put.c'
		echo '# With the fix   : expect $ZINTERRUPT to run once after the ZTRIGGER'
		breaksw
	case ztrigtrig:
		echo "# Stage $stage : ZTRIGGER ^x(1) with a ZTRIGGER trigger on ^x, and "'$ZTEXIT true'
		echo '# Before the fix : the ZTRIGGER, its trigger and $ZINTERRUPT repeated without end in a Release'
		echo '#                  build. A Debug build failed an assert in gvcst_put.c'
		echo '# With the fix   : expect the trigger to run once, then $ZINTERRUPT once'
		breaksw
	case killtrig:
		echo "# Stage $stage : KILL ^x(1) with a KILL trigger on ^x, and "'$ZTEXIT true'
		echo '# Before the fix : the KILL, its trigger and $ZINTERRUPT repeated without end in a Release build. A'
		echo '#                  Debug build failed an assert in gvcst_put.c'
		echo '# With the fix   : expect the KILL and its trigger to run once, then $ZINTERRUPT once'
		breaksw
	case ztrigitem:
		echo "# Stage $stage : "'$ZTRIGGER("ITEM") that loads a trigger, and $ZTEXIT true'
		echo '# Before the fix : $ZTRIGGER("ITEM") and $ZINTERRUPT repeated without end'
		echo '# With the fix   : expect $ZTRIGGER("ITEM") to return 1, then $ZINTERRUPT to run once'
		breaksw
	case trigerr:
		echo "# Stage $stage : SET ^x(1)=1 with a SET trigger that issues DIVZERO, an "'$ETRAP, and $ZTEXIT true'
		echo '# Before the fix : $ZINTERRUPT ran again and again from inside the error handling until STACKCRIT'
		echo '# With the fix   : expect the $ETRAP to see the DIVZERO, the SET to be rolled back, then $ZINTERRUPT'
		echo '#                  to run once'
		breaksw
	case intp:
		echo "# Stage $stage : the SET of stage 1 and a ZTRIGGER inside TSTART () ... TCOMMIT, and "'$ZTEXIT true'
		echo '# Before the fix : the same result (this stage is a control)'
		echo '# With the fix   : expect $ZINTERRUPT not to run before the TCOMMIT, and to run once after the TCOMMIT'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1342'
	timeout 60 $gtm_dist/mumps -run $label^ydb1342 >& $label.out
	set stat = $status
	if (124 == $stat) then
		echo "FAIL : the process did not finish within 60 seconds. Its last lines of output follow."
		tail -5 $label.out
	else if (0 != $stat) then
		echo "FAIL : exit status $stat. Output follows."
		cat $label.out
	else
		cat $label.out
	endif
	echo
end

@ stage++
echo "# Stage $stage : ZTRIGGER ^x(1) with the default "'$ZINTERRUPT ($ZJOBEXAM()), and $ZTEXIT true'
echo '# Before the fix : a new *_JOBEXAM.ZSHOW_DMP_* file was written thousands of times per second without'
echo '#                  end in a Release build. A Debug build failed an assert in op_ztrigger.c after'
echo '#                  1 file'
echo '# With the fix   : expect one *_JOBEXAM.ZSHOW_DMP_* file'
echo '# Command : $gtm_dist/mumps -run dflt^ydb1342'
# A 10 second limit is enough for a process that finishes, and limits how many files are written if it does not
timeout 10 $gtm_dist/mumps -run dflt^ydb1342 >& dflt.out
set stat = $status
set ndump = `ls | grep -c '_JOBEXAM.ZSHOW_DMP_'`
if ((0 == $stat) && (1 == $ndump)) then
	echo "PASS : exit status 0 and 1 *_JOBEXAM.ZSHOW_DMP_* file"
else
	echo "FAIL : exit status $stat and $ndump *_JOBEXAM.ZSHOW_DMP_* file(s). Output follows."
	cat dflt.out
endif
if (1000 < $ndump) then
	# Do not keep thousands of dump files in the test output directory
	ls | grep '_JOBEXAM.ZSHOW_DMP_' | xargs rm -f
endif
echo

@ stage++
echo "# Stage $stage : in Direct Mode, SET ^done=1 (a global with no trigger, so the SET loads the triggers of"
echo '#           the region in an implicit transaction), then TSTART () and TCOMMIT, with the default'
echo '#           $ZINTERRUPT ($ZJOBEXAM()) and $ZTEXIT true'
echo '# Before the fix : the SET and $ZINTERRUPT repeated without end in a Release build. A Debug build'
echo '#                  failed an assert in gvcst_put.c'
echo '# With the fix   : expect the line after the TCOMMIT on the principal device, no fatal error, and one'
echo '#                  *_JOBEXAM.ZSHOW_DMP_* file'
# The input lines (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'set x=$ztrigger("item","+^y -commands=S -xecute=""set z=1""")' > dmode.inp
echo 'set $ztexit=1' >> dmode.inp
echo 'set ^done=1' >> dmode.inp
echo 'tstart ()' >> dmode.inp
echo 'tcommit' >> dmode.inp
echo 'write "after the TCOMMIT",!' >> dmode.inp
echo '# Command : $gtm_dist/mumps -direct < dmode.inp, where dmode.inp has these lines'
sed 's/^/#   /' dmode.inp
# Count only the dump files that this stage adds
set ndump0 = `ls | grep -c '_JOBEXAM.ZSHOW_DMP_'`
timeout 10 $gtm_dist/mumps -direct < dmode.inp >& dmode.out
set stat = $status
@ ndump = `ls | grep -c '_JOBEXAM.ZSHOW_DMP_'` - $ndump0
set nafter = `$grep -c -F -x "after the TCOMMIT" dmode.out`
set nfatal = `$grep -c -- "-F-" dmode.out`
if ((0 == $stat) && (1 == $ndump) && (1 == $nafter) && (0 == $nfatal)) then
	echo "PASS : exit status 0, the line after the TCOMMIT on the principal device, no fatal error and 1 dump file"
else
	echo "FAIL : exit status $stat, the line after the TCOMMIT $nafter time(s) on the principal device, $nfatal fatal error(s) and $ndump dump file(s) - see dmode.out"
endif
if (1000 < $ndump) then
	# Do not keep thousands of dump files in the test output directory
	ls | grep '_JOBEXAM.ZSHOW_DMP_' | xargs rm -f
endif
echo

@ stage++
echo "# Stage $stage : controls"
echo '# Before the fix : the same result (this stage is a control)'
echo '# With the fix   : expect no $ZINTERRUPT with $ZTEXIT false, and one after TSTART ()  TCOMMIT with'
echo '#                  $ZTEXIT true'
echo '# Command : $gtm_dist/mumps -run ctrl^ydb1342'
timeout 60 $gtm_dist/mumps -run ctrl^ydb1342
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
