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
echo '# [YDB#1272] MUPIP STOP stops a process in a long pattern match                                       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Routine pt.m matches $char(17,17)_"PP" followed by n copies of "je" and $char(13) against the pattern'
echo '# .3C2e3.(2.2(.(2."je",."t")))0.C0.C of YDB#1272, which has nested alternations. The time the match'
echo '# takes doubles with every 2 more copies of "je". The routine writes its $JOB to the file pt.pid before'
echo '# the match, and the match result and "end" after the match.'
echo 'pt	new n,s,i' > pt.m
echo '	set n=$zcmdline,s=$char(17,17)_"PP" for i=1:1:n set s=s_"je"' >> pt.m
echo '	set s=s_$char(13)' >> pt.m
echo '	open "pt.pid":newversion use "pt.pid" write $job,! close "pt.pid"' >> pt.m
echo '	write "match=",s?.3C2e3.(2.2(.(2."je",."t")))0.C0.C,!' >> pt.m
echo '	write "end",!' >> pt.m
echo '	quit' >> pt.m
echo
echo '# Stage 1 : $gtm_dist/mumps -run pt 10 (a control)'
echo '# Before the fix : the match ended at once with a match (this stage is a control)'
echo '# With the fix   : expect the match to end at once with a match'
$gtm_dist/mumps -run pt 10 >& stage1.out
if ((1 == `$grep -Fxc "match=1" stage1.out`) && (1 == `$grep -Fxc "end" stage1.out`)) then
	echo "PASS : the pattern matched, and the routine ended"
else
	echo "FAIL : the pattern did not match, or the routine did not end (see stage1.out)"
endif
echo
echo '# Stage 2 : $gtm_dist/mumps -run pt 60 in the background, and after 90 seconds, while the match is still'
echo '# running, MUPIP STOP the process. The match would take far longer than this test runs. If the process'
echo '# is still running 60 seconds after the MUPIP STOP, the stage kills it with SIGKILL.'
echo '# Before the fix : Debug and Release builds did not stop, because nothing in the match handled the'
echo '#                  deferred SIGTERM of the MUPIP STOP once the pattern cache stopped growing'
echo '# With the fix   : expect the process to stop within 60 seconds with a FORCEDHALT error'
rm -f pt.pid
($gtm_dist/mumps -run pt 60 >& stage2.out &) >& /dev/null
set i = 0
while ((! -e pt.pid) && (60 > $i))
	sleep 1
	@ i = $i + 1
end
if (! -e pt.pid) then
	echo "FAIL : the process did not write pt.pid within 60 seconds"
	exit 1
endif
set pid = `cat pt.pid`
sleep 90
if (`$grep -Fxc "end" stage2.out`) then
	echo "FAIL : the match ended before the MUPIP STOP (see stage2.out)"
else
	echo "PASS : the match was still running after 90 seconds"
endif
$gtm_dist/mupip stop $pid >& mupip_stop.out
$gtm_tst/com/wait_for_proc_to_die.csh $pid 60 >& /dev/null
if ($status) then
	echo "FAIL : the process was still running 60 seconds after the MUPIP STOP"
	kill -9 $pid
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 120 >& /dev/null
else
	echo "PASS : the process stopped within 60 seconds of the MUPIP STOP"
endif
set nhalt = `$grep -c -- "-F-FORCEDHALT," stage2.out`
set nfatal = `$grep -c -- "-F-" stage2.out`
set nend = `$grep -Fxc "end" stage2.out`
if ((1 == $nhalt) && (1 == $nfatal) && (0 == $nend)) then
	echo "PASS : the process issued FORCEDHALT once and no other fatal error, and the match did not end"
else
	echo "FAIL : FORCEDHALT $nhalt times, fatal errors $nfatal times, end $nend times (expected 1, 1 and 0)"
endif
if ($nhalt) $gtm_tst/com/check_error_exist.csh stage2.out FORCEDHALT >& /dev/null
echo
echo '# Routine pn.m matches n copies of "a" followed by e with acute accent, then "a", against a pattern of 16'
echo '# copies of .E."e with acute accent" then 1.N, which has no alternation. The routine builds the pattern at'
echo '# run time with $zchar(195,169) (the UTF-8 bytes of e with acute accent). The string literal with a'
echo '# non-ASCII character keeps the pattern from being compiled to a DFA, so do_pattern() tries every'
echo '# permutation of the 33 pattern atoms. The match with 8 copies takes far longer than this test runs.'
echo 'pn	new n,s,i,c,p' > pn.m
echo '	set n=$zcmdline,c=$zchar(195,169),s="",p=""' >> pn.m
echo '	for i=1:1:n set s=s_"a"_c' >> pn.m
echo '	set s=s_"a"' >> pn.m
echo '	for i=1:1:16 set p=p_".E."""_c_""""' >> pn.m
echo '	set p=p_"1.N"' >> pn.m
echo '	open "pn.pid":newversion use "pn.pid" write $job,! close "pn.pid"' >> pn.m
echo '	write "match=",s?@p,!' >> pn.m
echo '	write "end",!' >> pn.m
echo '	quit' >> pn.m
echo
echo '# Stage 3 : $gtm_dist/mumps -run pn 8 in the background, and after 10 seconds, while the match is still'
echo '# running, MUPIP STOP the process. If the process is still running 60 seconds after the MUPIP STOP, the'
echo '# stage kills it with SIGKILL.'
echo '# Before the fix : Debug and Release builds did not stop, because nothing in a match without an'
echo '#                  alternation handled the deferred SIGTERM of the MUPIP STOP'
echo '# With the fix   : expect the process to stop within 60 seconds with a FORCEDHALT error'
rm -f pn.pid
($gtm_dist/mumps -run pn 8 >& stage3.out &) >& /dev/null
set i = 0
while ((! -e pn.pid) && (60 > $i))
	sleep 1
	@ i = $i + 1
end
if (! -e pn.pid) then
	echo "FAIL : the process did not write pn.pid within 60 seconds"
	exit 1
endif
set pid = `cat pn.pid`
sleep 10
if (`$grep -Fxc "end" stage3.out`) then
	echo "FAIL : the match ended before the MUPIP STOP (see stage3.out)"
else
	echo "PASS : the match was still running after 10 seconds"
endif
$gtm_dist/mupip stop $pid >& mupip_stop3.out
$gtm_tst/com/wait_for_proc_to_die.csh $pid 60 >& /dev/null
if ($status) then
	echo "FAIL : the process was still running 60 seconds after the MUPIP STOP"
	kill -9 $pid
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 120 >& /dev/null
else
	echo "PASS : the process stopped within 60 seconds of the MUPIP STOP"
endif
set nhalt = `$grep -c -- "-F-FORCEDHALT," stage3.out`
set nfatal = `$grep -c -- "-F-" stage3.out`
set nend = `$grep -Fxc "end" stage3.out`
if ((1 == $nhalt) && (1 == $nfatal) && (0 == $nend)) then
	echo "PASS : the process issued FORCEDHALT once and no other fatal error, and the match did not end"
else
	echo "FAIL : FORCEDHALT $nhalt times, fatal errors $nfatal times, end $nend times (expected 1, 1 and 0)"
endif
if ($nhalt) $gtm_tst/com/check_error_exist.csh stage3.out FORCEDHALT >& /dev/null
