#!/usr/local/bin/tcsh -f
#################################################################
#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################

echo '# Test fusing multiple global accesses into a naked reference'

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
echo "# Raise the maximum key length (for max subscript testing)"
$gtm_exe/mupip set -region DEFAULT -key_size=1019 >& raise_key_size.out
echo "# Create second global directory (for ZGBLDIR and GVEXTNAME testing)"
env gtmgbldir=alt.gld $gtm_exe/mumps -run GDE >& gde_backup_dir.out

echo '# Set up external calls (for FGNCAL testing)'
setenv ydb_xc_c extern_naked.xc
setenv LD_LIBRARY_PATH .
printf "libalways_true.so\nalwaystrue: ydb_int_t always_true()" > $ydb_xc_c
set file = 'always_true'
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_shl_linker ${gt_ld_option_output}lib${file}${gt_ld_shl_suffix} $gt_ld_shl_options $file.o $gt_ld_syslibs

echo '# Test that two consecutive `SET ^X(1),^X(2)` commands are optimized into a naked reference'
echo ' SET ^x="a",^x(1)="b",^x(2)="c"\
	Q:(^x="a")&(^x(1)="b")&(^x(2)="c")\
	W "TEST-E-FAIL: expected ""abc"", got '",^x,^x(1),^x(2),"'",!  Q' > consecutive.m
$gtm_tst/$tst/inref/list.csh consecutive.m 1
$gtm_exe/mumps -run consecutive

echo '# Test that `-machine` works correctly on GVNAMENAKED'
# override gtmcompile for this specific test; we want to compare exact opcodes.
env gtmcompile=-noline_entry $gtm_exe/mumps -machine consecutive.m
grep -E -o '^    [0-9].*|OC_.*' consecutive.lis > filtered.lis
diff filtered.lis $gtm_tst/$tst/inref/consecutive.lis

echo '# Test that two consecutive `SET ^X(1,2),^X(1,3)` commands with multiple subscripts are optimized into a naked reference'
echo ' SET ^x(1,2)="a",^x(1,3)="b"\
	Q:(^x(1,2)="a")&(^x(1,3)="b")\
	W "TEST-E-FAIL: expected ""ab"", got '",^x(1,2),^x(2,3),"'",!  Q' > consecutivemultiple.m
$gtm_tst/$tst/inref/list.csh consecutivemultiple.m 1
$gtm_exe/mumps -run consecutivemultiple

echo '# Test that two consecutive `SET ^X(1,2),^X(1,3)` commands with the maximum number of subscripts are optimized into a naked reference'
echo ' SET ^x(1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1)="a",^x(1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,2)="b"\
	SET right=$REFERENCE,left="^x(1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1)"\
	Q:((@right="b")&(@left="a"))\
	W "TEST-E-FAIL: expected ""ab"", got '",@left,@right,"'",!  Q' > consecutivemultiplemany.m
$gtm_tst/$tst/inref/list.csh consecutivemultiplemany.m 1
$gtm_exe/mumps -run consecutivemultiplemany

echo '# Test that a manual `SET ^X(1),^(2),^X(3)` naked reference still optimizes the last global access'
echo ' set ^x(1)=1,^(2)=2,^x(3)=3' > manualnaked.m
$gtm_tst/$tst/inref/list.csh manualnaked.m 1
$gtm_exe/mumps -run manualnaked

echo '# Test that increasing the number of subscripts still optimizes a naked reference'
echo ' set ^x(1)=1,^x(1,2,3)=2' > moresubs.m
$gtm_tst/$tst/inref/list.csh moresubs.m 1
$gtm_exe/mumps -run moresubs

echo '# Test that decreasing the number of subscripts does not misoptimize'
echo ' set ^x(1,2,3)=2,^x(1)=1' > fewersubs.m
$gtm_tst/$tst/inref/list.csh fewersubs.m 1
$gtm_exe/mumps -run fewersubs

echo '# Test that the last subscript can be an arbitrary expression and still be optimized'
echo ' set ^x(1,6)=1,a=2  write ^x(1,a+1++"3")' > arbitrarylast.m
$gtm_tst/$tst/inref/list.csh arbitrarylast.m 1
$gtm_exe/mumps -run arbitrarylast

echo '# Test that the start of a subroutine does not misoptimize a naked reference'
echo ' set ^x(1)=1\
x set ^x(2)=2  quit' > routine.m
$gtm_tst/$tst/inref/list.csh routine.m 1
$gtm_tst/$tst/inref/list.csh routine.m 2
$gtm_exe/mumps -run routine

echo '# Test a more complicated subroutine does not misoptimize a naked reference'
echo ' set ^x(1)="x1",^x(2)="x2"\
x write ^x(2)\
quit\
y kill ^x(2)  set ^y(1)="y1",^y(2)="y2"  do x  quit' > routinebackjump.m
$gtm_tst/$tst/inref/list.csh routinebackjump.m 1
$gtm_tst/$tst/inref/list.csh routinebackjump.m 2
$gtm_exe/mumps -run y^routinebackjump

echo '# Test that returning a value does not misoptimize a naked reference'
echo 'f()	quit:0 ^x(1)  set ^x(1)=1' > quitval.m
$gtm_tst/$tst/inref/list.csh quitval.m 1
$gtm_exe/mumps -run quitval

echo '# Test that modifying $ZGBLDIR does not misoptimize a naked reference'
echo ' set $zgbldir="mumps.gld",^x(1)=1\
	set $zgbldir="alt.gld",^x(2)=2' > zgbldir.m
$gtm_tst/$tst/inref/list.csh zgbldir.m 1
$gtm_tst/$tst/inref/list.csh zgbldir.m 2
$gtm_exe/mumps -run zgbldir

echo '#  Test that NEW-ing $ZGBLDIR does not misoptimize a naked reference'
echo ' set $zgbldir="alt.gld",^x(1)=1  new $zgbldir  set ^x(2)=2' > newzgbldir.m
$gtm_tst/$tst/inref/list.csh newzgbldir.m 1
$gtm_exe/mumps -run newzgbldir

# `echo` expands \n by default. Use printf instead to disable this behavior.
printf '%s\n' '# Test that consecutive `SET X(1) \n SET X(2)` commands across a newline can be optimized even with -line_entry.'
echo ' SET ^x(1)="a"\
	SET ^x(2)="b"\
	Q:(^x(1)="a")&(^x(2)="b")  W "TEST-E-FAIL: expected ""ab"", got '",^x(1),^x(2),"'",!  Q' > consecutivelines.m
env gtmcompile=-line_entry $gtm_tst/$tst/inref/list.csh consecutivelines.m 1
env gtmcompile=-line_entry $gtm_tst/$tst/inref/list.csh consecutivelines.m 2
env gtmcompile=-line_entry $gtm_exe/mumps -run consecutivelines

echo '# Test that GOTO does not cause a runtime error'
echo '	kill ^x  goto f+1\
f	set ^x(1)=1\
	set ^x(2)=1  zwrite ^x' > goto.m
env gtmcompile=-line_entry $gtm_tst/$tst/inref/list.csh goto.m 3
env gtmcompile=-line_entry $gtm_exe/mumps -run goto

echo '# Test that ZGOTO does not cause a runtime error'
echo '	kill ^x  zgoto $STACK:f+1\
f	set ^x(1)=1\
	set ^x(2)=1  zwrite ^x' > zgoto.m
env gtmcompile=-line_entry $gtm_tst/$tst/inref/list.csh zgoto.m 3
env gtmcompile=-line_entry $gtm_exe/mumps -run zgoto

printf '%s\n' '# Test that two consecutive `SET X(1) \n SET X(2)` commands across a newline are optimized into a naked reference when passed -noline_entry'
$gtm_tst/$tst/inref/list.csh consecutivelines.m 1
$gtm_tst/$tst/inref/list.csh consecutivelines.m 2
$gtm_exe/mumps -run consecutivelines

echo '# Test that an indirect global reference does not misoptimize a naked reference'
echo ' SET y="^Y(2)",^X(1)=1,@y=2,^X(3)=3 \
	Q:(^X(1)=1)&(^X(3)=3)&(^Y(2)=2)  W "FAILED: ",^X(1),^X(3),^Y(2),^Y(3),!  Q' > consecutiveindr.m
$gtm_tst/$tst/inref/list.csh consecutiveindr.m 1
$gtm_exe/mumps -run consecutiveindr

echo '# Test that an expression that uses an indirect global reference does not misoptimize a naked reference'
echo ' S ^Y(2)="a",y="^Y(2)"\
	S ^X(1)=1  W 1+@y,^X(1)' > indglvn.m
$gtm_tst/$tst/inref/list.csh indglvn.m 2
$gtm_exe/mumps -run indglvn

echo '# Test that subroutine calls do not misoptimize a naked reference'
echo ' set ^X(1)=1  do y  write ^X(1)  quit\
y  write 1' > call.m
$gtm_tst/$tst/inref/list.csh call.m 1
$gtm_exe/mumps -run call

echo '# Test that extrinsic calls do not misoptimize a naked reference'
echo ' set ^X(1)=1  do y(1)  write ^X(1)  quit\
y(a)  write a' > excall.m
$gtm_tst/$tst/inref/list.csh excall.m 1
$gtm_exe/mumps -run excall

echo '# Test that global calls do not misoptimize a naked reference'
echo ' set ^X(1)=1  do y^extcall  write ^X(1)  quit\
y  write 1' > extcall.m
$gtm_tst/$tst/inref/list.csh extcall.m 1
$gtm_exe/mumps -run extcall

echo '# Test that global calls to extrinsic functions do not misoptimize a naked reference'
echo ' set ^x(1)=1  do y^extexcal(1)  set ^x(2)=2\
	quit\
y(a) set ^y(3)=3  quit' > extexcal.m
$gtm_tst/$tst/inref/list.csh extexcal.m 1
$gtm_exe/mumps -run extexcal

echo '# Test that non-consecutive global references do not misoptimize a naked reference'
echo ' SET ^a(1)="a",^b(2)="b",^a(2)="c"\
	Q:(^a(1)="a")&(^b(2)="b")&(^a(2)="c")  W "TEST-E-FAIL: ",^a(1),^b(2),^a(2),!  Q' > nonconsecutive.m
$gtm_tst/$tst/inref/list.csh nonconsecutive.m 1

$gtm_exe/mumps -run nonconsecutive
echo '# Test that accessing a global reference with no subscripts does not misoptimize the next global access'
echo ' SET ^x(1)=1,^x=0,^x(2)=2\
	Q:(^x=0)&(^x(1)=1)&(^x(2)=2)  W "TEST-E-FAIL: expected ""123"", got """,^x,^x(1),^x(2),"""",!  Q' >nonsubscripted.m
$gtm_tst/$tst/inref/list.csh nonsubscripted.m 1
$gtm_exe/mumps -run nonsubscripted

echo '# Test that a JMPEQU conditional expression does not misoptimize the next global access'
echo ' s ^X(1)=1  s:^X(1)=2 ^Y(1)=1  s ^Y(2)=2' > jumpequ.m
$gtm_exe/mumps -run jumpequ
$gtm_tst/$tst/inref/list.csh jumpequ.m 1

echo '# Test that a JMPNEQ conditional expression does not misoptimize the next global access. Minimized from ydb449.m'
echo '	kill ^x\
	set isOrder=0\
	if isOrder set x=$data(^x("sub0","sub1"))\
	else  set x=$query(^x("sub0","sub1"),-1)\
	quit' > jmpneq.m
$gtm_exe/mumps -run jmpneq
$gtm_tst/$tst/inref/list.csh jmpneq.m 4

echo '# Test that a DO block does not misoptimize the next global access'
echo ' do  if $data(^names(1)) do\
	. if $data(^names(2))\
	quit' > dosequence.m
$gtm_exe/mumps -run dosequence
$gtm_tst/$tst/inref/list.csh dosequence.m 1 | head -n3

echo '# Test that a global reference with a variable subscript does optimize the next global access'
echo ' set x=1,^Y(x,2)=2,^Y(x,3)=3' > varsubscript.m
$gtm_tst/$tst/inref/list.csh varsubscript.m 1
$gtm_exe/mumps -run varsubscript

echo '# Test that a call to an extrinsic function does not misoptimize the next global access'
echo ' set x($data(^x1(1)),$$x2,$data(^x1(3)))=1\
	quit\
x2() quit $data(^x2(2))' >extrinsic.m
$gtm_tst/$tst/inref/list.csh extrinsic.m 1
$gtm_exe/mumps -run extrinsic

echo '# Test that a non-literal subscript does not misoptimize the next global access'
echo ' S X=2,^V1B(1)=50,^A(X,21)=60,^V1B(1)=70' > nonliteralsub.m
$gtm_tst/$tst/inref/list.csh nonliteralsub.m 1
$gtm_exe/mumps -run nonliteralsub

echo '# Test that FOR loops do not misoptimize a naked reference across iterations'
echo '	set ^x(1)=1,^x(2)=2  for i=1:1:2  write ^x(i)  set ^x("a",i)=1' > forloop.m
$gtm_tst/$tst/inref/list.csh forloop.m 1
$gtm_exe/mumps -run forloop

echo '# Test that function calls in FOR loops with local variables do not misoptimize a naked reference'
echo ' set delta=1 for i=1:delta:2 set ^x(1)=1 do y set ^x(2)=2\
	quit\
y	set ^y(3)=3  quit' > forlcldo.m
$gtm_tst/$tst/inref/list.csh forlcldo.m 1
$gtm_exe/mumps -run forlcldo

echo '# Test that indirection through XECUTE does not misoptimize the next global access'
echo ' SET ^y(1)=1  XECUTE "set ^x(1)=2"  WRITE ^y(1)' > xecute.m
$gtm_tst/$tst/inref/list.csh xecute.m 1
$gtm_exe/mumps -run xecute

echo '# Test that indirection in an intrinsic function does not misoptimize a naked reference'
echo ' set x="^y(2)",^x(1)=1,^x(2)=$data(@x)' > indfun.m
$gtm_tst/$tst/inref/list.csh indfun.m 1
$gtm_exe/mumps -run indfun

echo '# Test that indirection in ZSHOW does not misoptimize a naked reference'
echo ' set a=1,^x(1)=1 zshow "a":@"^y(3)" set ^x(2)=2' > indrzshow.m
$gtm_tst/$tst/inref/list.csh indrzshow.m 1
$gtm_exe/mumps -run indrzshow

echo '# Test that indirection through READ does not misoptimize a naked reference'
echo ' set x="^y(2)",^x(1)=1 read @x:0 set ^x(2)=2' > indset.m
$gtm_tst/$tst/inref/list.csh indset.m 1
$gtm_exe/mumps -run indset

echo '# Test that indirection through $INCR does not misoptimize a naked reference'
echo ' set z="^y(2)",^x(1)=1,y=$incr(@z),^x(2)=2' > indincr.m
$gtm_tst/$tst/inref/list.csh indincr.m 1
$gtm_exe/mumps -run indincr

echo '# Test that indirection through $ORDER does not misoptimize a naked reference'
echo ' set z="^y(2)",a=1,^x(1)=1,y=$order(@z,a),^x(2)=2' > indo2.m
$gtm_tst/$tst/inref/list.csh indo2.m 1
$gtm_exe/mumps -run indo2

echo '# Test that indirection through OPEN does not misoptimize a naked reference'
echo ' set ^a="UTF-8",p="ICHSET=(^a)",^x(1)=1  open "/dev/stdin":@p  w ^x(2)=2' > inddevparms.m
$gtm_tst/$tst/inref/list.csh inddevparms.m 1
$gtm_exe/mumps -run inddevparms

echo '# Test that indirection through MERGE does not misoptimize a naked reference'
echo ' set x="^b",^b=1,^y(1)=1  merge a=@x   w ^y(2)=2' > indmerge.m
$gtm_tst/$tst/inref/list.csh indmerge.m 1
$gtm_exe/mumps -run indmerge

echo '# Test that indirection through `SET $extrinsic` does not misoptimize a naked reference'
echo ' set x="a",a="hello",^y(1)=1,$zpiece(@x,1)="x"  w ^y(2)=2' > indget1.m
$gtm_tst/$tst/inref/list.csh indget1.m 1
$gtm_exe/mumps -run indget1

echo '# Test that indirection through `$GET` does not misoptimize a naked reference'
echo ' set x="a",a="hello",^y(1)=1  w $get(@x,1),^y(2)=2' > indget2.m
$gtm_tst/$tst/inref/list.csh indget2.m 1
$gtm_exe/mumps -run indget2

echo '# Test that indirection through MERGE with side effects does not misoptimize a naked reference'
echo ' set x="a",^b=1  merge @x=^b  w ^b' > indmerge2.m
env ydb_side_effects=1 $gtm_tst/$tst/inref/list.csh indmerge2.m 1
$gtm_exe/mumps -run indmerge2

echo '# Test that indirection through `$QUERY` does not misoptimize a naked reference'
echo ' set x="a",a=1,^y(1)=1  w $query(@x,a),^y(2)=2' > indq2.m
$gtm_tst/$tst/inref/list.csh indq2.m 1
$gtm_exe/mumps -run indq2

echo '# Test that indirection through `$NAME` does not misoptimize a naked access'
echo '	set x=$data(^x(1)),x=$name(@"x($data(^y(1)))"),x=$data(^x(2))' > indfnname.m
$gtm_tst/$tst/inref/list.csh indfnname.m 1
$gtm_exe/mumps -run indfnname

echo '# Test that a global extrinsic function call does not misoptimize the next global access'
echo ' set ^x(1)=1,^x(2)=2,^y(3)=3\
	write ^x(1),$$f^exfun,^x(2)\
	quit\
\
f()\
	quit ^y(3)' > exfun.m
$gtm_tst/$tst/inref/list.csh exfun.m 2
$gtm_exe/mumps -run exfun


echo '# Test that transaction restarts preserve $REFERENCE and so optimizing is valid'
echo ' kill ^x,^y  set ^x(1)=1  tstart ():serial  zwrite $reference\
	set ^x(2)=2\
	set ^y(3)=3\
	trestart:$trestart<1  tcommit\
	zwrite ^x,^y' > transaction.m
$gtm_tst/$tst/inref/list.csh transaction.m 2
$gtm_exe/mumps -run transaction

echo '# Test that misoptimizations do not happen across a transaction rollback'
echo '	tstart\
	k ^a(4)  trollback 0  k ^a(5)' > trollback.m
$gtm_tst/$tst/inref/list.csh trollback.m 2
$gtm_exe/mumps -run trollback

echo '# Test that $NEXT is not misoptimized. This was minimized from mugj/V1IDNM3.m.'
echo ' S ^V1A(1000)=1,D="D(1)",D(1)="500"\
	S VCOMP=$N(^V1A(1000))_^V1A(1000)' > gvnext.m
$gtm_tst/$tst/inref/list.csh gvnext.m 2
$gtm_exe/mumps -run gvnext

echo '# Test that side effects that generate a STOTEMP do not crash the compiler'
echo '# Read SUBS_ARRAY_2_TRIPLES in compiler.h if this breaks.'
echo ' set a=1,^x(a,$incr(a))=2' > stotemp.m
$gtm_tst/$tst/inref/list.csh stotemp.m 1
$gtm_exe/mumps -run stotemp

echo '# Test that accessing a different global directory resets $REFERENCE'
echo ' s ^y=1,^|"alt"|x=1  w ^y' > gvextname.m
$gtm_tst/$tst/inref/list.csh gvextname.m 1
$gtm_exe/mumps -run gvextname

echo '# Test that external calls reset $REFERENCE'
echo ' s ^y=1  do &c.alwaystrue  w ^y' > fgncal.m
$gtm_tst/$tst/inref/list.csh fgncal.m 1
$gtm_exe/mumps -run fgncal

echo '# Test that external calls used in an expression reset $REFERENCE'
echo ' s ^y=1  w $&c.alwaystrue,^y' > fnfgncal.m
$gtm_tst/$tst/inref/list.csh fnfgncal.m 1
$gtm_exe/mumps -run fnfgncal

echo '# Test that $ZSTEP interrupts do not misoptimize a naked reference'
echo '	set $zstep="set x=$get(^y(3)) zstep into"  zbreak f:"zstep into"\
f	set ^x(1)=1\
	set ^x(2)=2' > zstep.m
$gtm_tst/$tst/inref/list.csh zstep.m 3
$gtm_exe/mumps -run zstep

echo '# Test that ZBREAK interrupts do not misoptimize a naked reference'
echo '	kill ^x,^y  zbreak f+1:"set ^y=1  zstep into:"""""\
f	set ^x(1)=1\
	set ^x(2)=2' > zbreak.m
$gtm_tst/$tst/inref/list.csh zbreak.m 3
$gtm_exe/mumps -run zbreak

echo '# Test that ZTRAP interrupts do not misoptimize a naked reference'
echo '	kill ^y  set $ZTRAP="write $ZSTATUS,!  quit:$data(^y)  set ^y=1"\
	set ^x(1)=1  \
	set ^x(2)=2  write notarealvariableb' > ztrap.m
$gtm_tst/$tst/inref/list.csh ztrap.m 3
$gtm_exe/mumps -run ztrap

echo '# Test that ETRAP interrupts do not misoptimize a naked reference'
echo '	set $etrap="set ^y=1  w $ecode,$zstatus  zstep into"\
f	set ^x(1)=1  w notarealvariable\
	set ^x(2)=2' > etrap.m
$gtm_tst/$tst/inref/list.csh etrap.m 3
$gtm_exe/mumps -run etrap

echo '# Test that EXCEPTION handlers do not misoptimize a naked reference'
echo '	kill ^y  set ^x(1)=1\
	write $REFERENCE,!  set ^x(2)=2  open "/not/here":(EXCEPTION="write $zstatus,!  quit:$data(^y)  set ^y=1")\
	' > openexception.m
$gtm_tst/$tst/inref/list.csh openexception.m 2
$gtm_exe/mumps -run openexception

echo '## Test that ZINTERRUPT handlers save and restore $REFERENCE'
echo '# Run [$gtm_exe/mumps -run zinthandle^ydb665] in the background'
($gtm_exe/mumps -run zinthandle^ydb665 >&! zinthandle.out & ; echo $! >&! zinthandle.pid ) >&! zinthandle-bg.out
echo '# Give signal handlers time to register: [$gtm_exe/mumps -run waitinterrupt]'
$gtm_exe/mumps -run waitinterrupt^ydb665
set zintpid = `cat zinthandle.pid`
echo '# Issue interrupt to [zinthandle^ydb665] process: [$gtm_exe/mupip intrpt $zintpid]'
$gtm_exe/mupip intrpt $zintpid
$gtm_tst/com/wait_for_proc_to_die.csh $zintpid
echo '# Check [zinthandle^ydb665] process output: [cat zinthandle.out]'
cat zinthandle.out

echo '# Test that ZTIMEOUT handlers cannot misoptimize a naked reference'
echo '	set $ZTIMEOUT="1:set ^y=2  write ^y"\
	set ^x(1)=1  hang 2  write ^x(1)' > ztimeout.m
$gtm_tst/$tst/inref/list.csh ztimeout.m 2
$gtm_exe/mumps -run ztimeout

echo '# Test that nested interrupts cannot misoptimize a naked reference'
echo 'x	set x=$data(^x(1))\
	zbreak x+3:"do y"\
	zbreak y+1:"set x=1"\
	set x=$data(^x(2))\
	quit\
y\
	set x=$data(^y(1,2))\
	quit' > nestedzbreak.m
$gtm_tst/$tst/inref/list.csh nestedzbreak.m 4
$gtm_exe/mumps -run nestedzbreak

# Only run the below perf related stage of the subtest if "perf" executable exists and is the YottaDB
# build is not a DBG or ASAN build (both are slow). Also restrict the test to only be on x86_64 linux.
# And only with GCC builds (not CLANG builds which use up 10% more instructions, greater than the 5% allowance).
# This lets us keep strong limits for performance comparison. That helps us quickly determine if any
# performance regression occurs. Also restrict the test to run only if M-profiling is not turned on by
# the test framework (i.e. gtm_trace_gbl_name env var is not defined) as otherwise a lot more instructions get used.
set perf_missing = `which perf >/dev/null; echo $status`
source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# detect asan build into $gtm_test_libyottadb_asan_enabled
if (! $perf_missing && ! $gtm_test_libyottadb_asan_enabled && ("pro" == "$tst_image") && ("x86_64" == `uname -m`)	\
		&& ("GCC" == $gtm_test_yottadb_compiler) && ! $?gtm_trace_gbl_name) then
	echo '# Test the actual number of instructions for a naked reference optimization speedup.'

	echo "# Create and compile our programs. We don't want to measure compilation time."
	echo ' for i=1:1:100000  kill ^x,^y  set ^x(1)=1,^y(2)=2' > simplenoopt.m
	echo ' for i=1:1:100000  kill ^x     set ^x(1)=1,^x(2)=2' > simpleopt.m
	$gtm_exe/mumps simplenoopt.m
	$gtm_exe/mumps simpleopt.m
	echo '# This was benchmarked with a RelWithDebInfo build on an AMD Ryzen 7 7700X 8-Core processor.'
	echo '# On that machine, the optimized version uses 1,645,390,606 instructions and the unoptimized version uses 2,654,613,810'
	echo '# i.e. an improvement of 38%. Allow it to be as low as 30%, but no lower.'
	echo "# Run YDB 3 times and average the number of instructions, once on unoptimized code and once on optimized."
	set noopt_instrs = `$gtm_tst/com/perfstat.csh -r 3 $gtm_exe/mumps -r simplenoopt | cut -d ' ' -f1`
	set   opt_instrs = `$gtm_tst/com/perfstat.csh -r 3 $gtm_exe/mumps -r simpleopt   | cut -d ' ' -f1`
	set in_range = `python3 -c "print(int((${opt_instrs}.0 / ${noopt_instrs}.0) < .7))"`
	if ($in_range > 0) then
		echo PASS
	else
		echo "TEST-E-FAIL: naked reference optimization did not have the expected speedup"
		echo "opt_instrs: $opt_instrs"
		echo "noopt_instrs: $noopt_instrs"
	endif
endif

echo "# Run [dbcheck.csh]"
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
