;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c002861	;
	; C9H05-002861 BADCHAR in expression causes GTMASSERT in emit_code.c during compile in V52000
	;
	; The intent of this test is multifold
	;	a) Test various type of compile-errors (including the BADCHAR error that raised this TR in the first place).
	;	b) Test multiple errors (some of type IS_STX_WARN and some not) in the same M source line.
	;	c) Test that if multiple errors show up in the same line at compile time, the first error shows up at runtime.
	;		Prior versions used to show only the latest parse error in that line at runtime.
	;
	; To test c, what we do is collect all testcases into two sets of M programs "c002861_profile.m" and "c002861_misc.m"
	; and take each line from them and create a separate M program. This will be compiled and executed individually.
	;
	; c002861_profile.m : original test case from PROFILE in-house : profile.dat
	; c002861_misc.m    : misc test cases created by looking at all usages of setcurtchain in the codebase
	;
	set unix=$zv'["VMS"
	if 'unix set helperfile="c002861.com" open helperfile use helperfile write "$ set noon",!
	if $piece($zv," ",2)']"V5.2-000" set openparms="exception=""if $zeof=1 quit"""
	else  set openparms="(CHSET=""M"":exception=""if $zeof=1 quit"")"
	for rdfile="c002861_profile.m","c002861_misc.m" do
	.	open rdfile:@openparms
	.	use rdfile
	.	set wtfileprefix=$piece($piece(rdfile,"_",2),".",1)	; will be "profile" or "misc"
	.	set cnt=0
	.	for  quit:$zeof=1  do
	.	.	use rdfile
	.	.	read line
	.	.	set cnt=cnt+1
	.	.	set wtfile=wtfileprefix_cnt_".m"
	.	.	set ts1=$ZDATE($H,"60SS")
	.	.	open wtfile:@openparms
	.	.	use wtfile
	.	.	write " set $zt=""write $zstatus,!  halt""",!
	.	.	write line,!
	.	.	close wtfile
	.	.	if unix  do
	.	.	.	use $p
	.	.	.	write "######################################################################",!
	.	.	.	write "------------------------ Compiling ",wtfile," ------------------------",!
	.	.	.	zsystem "$gtm_dist/mumps "_wtfile
	.	.	.	write !
	.	.	.	write "------------------------ Checking if .o file was created ",wtfile," ------------------------",!
	.	.	.	zsystem "ls -1 "_wtfileprefix_cnt_".o"
	.	.	.	zsystem "touch -t ""200001010000.00"" "_wtfile_" >& /dev/null "
	.	.	.	write !
	.	.	.	write "------------------------ Running   ",wtfile," ------------------------",!
	.	.	.	zsystem "$gtm_dist/mumps -run "_wtfileprefix_cnt
	.	.	.	write !
	.	.	if 'unix do
	.	.	.	use helperfile
	.	.	.	write "$ write sys$output ""######################################################################""",!
	.	.	.	write "$ write sys$output ""------------------------ Compiling ",wtfile," ------------------------""",!
	.	.	.	write "$ MUMPS "_wtfile,!
	.	.	.	write "$ write sys$output ""------------------------ Checking if .o file was created ",wtfile," ------------------------""",!
	.	.	.	write "$ write sys$output f$search("""_wtfileprefix_cnt_".obj"")",!
	.	.	.	write "$ write sys$output ""------------------------ Running   ",wtfile," ------------------------""",!
	.	.	.	write "$ GTM ",!
	.	.	.	write "    do ^"_wtfileprefix_cnt,!
	.	.	.	write "$ ",!
	.	.	use rdfile
	.	close rdfile
	quit
