#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
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
source $gtm_tst/com/portno_acquire.csh > portno.out
@ portno=`cat portno.out`
set host=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`

$gt_cc_compiler -o nanoinetd.o $gtt_cc_shl_options $gt_cc_option_debug $gtm_tst/$tst/inref/nanoinetd.c # >& makeobj.out
$gt_ld_linker $gt_ld_option_output nanoinetd $gt_ld_options_common $gt_ld_options_dbg nanoinetd.o $gt_ld_sysrtns $gt_ld_syslibs >& makeexe.out

(nanoinetd $portno $gtm_exe/mumps -run dollarp >& nanoinetd.out & ; echo $! > nanoinetd.pid) >& /dev/null
@ pid=`cat nanoinetd.pid`
$gtm_exe/mumps -run '%XCMD' 'do tclient^dollarp("'${host:q}'",'${portno:q}')'
cat question.out
mv question.out question1.out
cat answer.out
mv answer.out answer1.out

$gtm_tst/com/wait_for_proc_to_die.csh $pid
source $gtm_tst/com/portno_release.csh

echo
echo "Again with GT.M as inetd:"

source $gtm_tst/com/portno_acquire.csh > portno.out
@ portno=`cat portno.out`

$gtm_exe/mumps -run '%XCMD' 'job nanoinetd^dollarp('${portno:q}',"server"):(OUTPUT="mnanoinetd.out":ERROR="mnanoinetd.err")  write $zjob,!' > mnanoinetd.pid
@ pid=`cat mnanoinetd.pid`
$gtm_exe/mumps -run '%XCMD' 'do tclient^dollarp("'${host:q}'",'${portno:q}')'
cat question.out
mv question.out question2.out
cat answer.out
mv answer.out answer2.out

$gtm_tst/com/wait_for_proc_to_die.csh $pid

$tst_cmpsilent answer1.out answer2.out || echo "TEST-E-diff,C and M nanoinetd results differ (answer)"
$tst_cmpsilent question1.out question2.out || echo "TEST-E-diff,C and M nanoinetd results differ (question)"

source $gtm_tst/com/portno_release.csh

echo
echo "Again with GT.M and LOCAL socket:"

set sf="local.sock"
$gtm_exe/mumps -run '%XCMD' 'job nanolocd^dollarp("'${sf}'","server"):(OUTPUT="mnanolocd.out":ERROR="mnanolocd.err")  write $zjob,!' > mnanolocd.pid
@ pid=`cat mnanolocd.pid`
$gtm_exe/mumps -run '%XCMD' 'do lclient^dollarp("'${sf}'")'
cat question.out
mv question.out question3.out
cat answer.out
mv answer.out answer3.out

$gtm_tst/com/wait_for_proc_to_die.csh $pid

$tst_cmpsilent answer2.out answer3.out || echo "TEST-E-diff,M nanoinetd and nanolocd results differ (answer)"
$tst_cmpsilent question2.out question3.out || echo "TEST-E-diff,M nanoinetd and nanolocd results differ (question)"

echo ""
echo "And now some file descriptor checks:"

set outopts="o oe io ioe"
set optslist="x e o oe i ie io ioe"

source $gtm_tst/com/portno_acquire.csh > portno.out
@ portno=`cat portno.out`

$gtm_exe/mumps -run '%XCMD' 'do tcheckfds^dollarp("'${host:q}'",'${portno:q}')'

cat fdworker_t{${optslist:as/ /,/}}_read.out
cat fdclient_t{${outopts:as/ /,/}}.out

foreach opts ($optslist)
	echo t$opts":"
	# Handle quirks in lsof output
	# Note that Solaris zones do not support lsof, and the fake lsof returns nothing,
	# so the output is excluded in the outref for those hosts
	$tst_awk '$4 ~ /^[0-2].$/ {if ($7 == "TCP") print $4, $5, $7, $9; else if ($6 == "TCP") print $4,$5,$6,"n/a"; else print $4, $5, $8, $10}' fdworker_t${opts}_lsof.out
end

source $gtm_tst/com/portno_release.csh

$gtm_exe/mumps -run '%XCMD' 'do lcheckfds^dollarp("'${sf:q}'")'

cat fdworker_l{${optslist:as/ /,/}}_read.out
cat fdclient_l{${outopts:as/ /,/}}.out

foreach opts ($optslist)
	echo l$opts":"
	# Handle quirks in lsof output
	# Note that Solaris zones do not support lsof, and the fake lsof returns nothing,
	# so the output is excluded in the outref for those hosts
	$tst_awk '$4 ~ /^[0-2].$/ {if ($5 == "unix") print $4, $5; else print $4, $5, $8, $10}' fdworker_l${opts}_lsof.out
end


echo ""
echo "And check heredoc:"

source $gtm_tst/com/portno_acquire.csh > portno.out
@ portno=`cat portno.out`

setenv gtm_principal "abc"

cat > heredoc.csh <<ENDSCRIPT
$gtm_dist/mumps -direct <<ENDMUMPS
write "\\\$P=",\\\$P
zshow "D"
zshow "D":A
open "zoutA.out"
use "zoutA.out"
zwrite A
ENDMUMPS
ENDSCRIPT

(nanoinetd $portno /usr/local/bin/tcsh heredoc.csh >& nanoinetd2.out & ; echo $! > nanoinetd2.pid) >& /dev/null
@ pid=`cat nanoinetd2.pid`

$gtm_exe/mumps -run '%XCMD' 'do netcat^dollarp("'${host:q}'",'${portno:q}')'

$gtm_tst/com/wait_for_proc_to_die.csh $pid

echo ""
echo 'ZSHOW "D" output saved in A:'
if (-f zoutA.out) cat zoutA.out

echo ""
echo 'Check ZSHOW "D" for split $PRINCIPAL with in being a socket and out being a file:'

#set echo verbose
source $gtm_tst/com/portno_release.csh

source $gtm_tst/com/portno_acquire.csh > portno.out
@ portno=`cat portno.out`

$gtm_exe/mumps -run '%XCMD' 'job nanoinetd^dollarp('${portno:q}',"justzshowd","justzshowd.out"):(OUTPUT="jznanoinetd.out":ERROR="jznanoinetd.err")  write $zjob,!' > jznanoinetd.pid
@ pid=`cat jznanoinetd.pid`

$gtm_exe/mumps -run '%XCMD' 'do netcat^dollarp("'${host:q}'",'${portno:q}')'

$gtm_tst/com/wait_for_proc_to_die.csh $pid

if (-f justzshowd.out) cat justzshowd.out
#set echo verbose
source $gtm_tst/com/portno_release.csh

echo "Done."
