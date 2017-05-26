;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; install trigger with a zsystem call to mumps to update a
	; GVN affected by the current TX. This will produce an
	; violation of isolation for the transaction.
trigzsyxplode
start
	set $ETRAP="write $ecode,?14,$zstatus,! halt",start=$HOROLOG
	do ^echoline
	write "zsystems inside a trigger violate the isolation of ACID",!
	do setup
test
	write "Begin transaction",!
	tstart ():serial
	write "Run: ",$increment(tr),$char(9)
	write "Restarts: ",$trestart,!
	set $ztwo=tr
	if $trestart>3 write "stopping the insanity",! goto report
	if $data(^c) zwr ^c
	set ^c=tr*5
	set ^a=tr
	set ^b=5
	tcommit
report
	; how many restarts, trollback for the explicit transaction
	if $ztlevel<1 trollback  write tr," restarts occured",!
	if $ztlevel>0 write $trestart," restarts occured",!
	if $data(^a) write "^a exists, ",^a,!
	if $data(^b) write "^b exists, ",^b,!
	if $data(^c) write "^c exists, ",^c,!
	do ^echoline
	if $tlevel>1 tcommit
	quit:$length($ztrnlnm("test_trigzsyxplode_implicit"))
	set zsycmd="$gtm_tst/com/getoper.csh """_$zdate(start,"MON DD 24:60:SS")_""" """" tpnotacidt1.outx """" """_$job_".*TPNOTACID"""
	zsystem zsycmd
	quit

implicit
	write !,"Run the trigzsyxplode from inside an implicit transation",!,!
	kill ^a,^b,^c
	set $ETRAP="write $ecode,?14,$zstatus,! halt",start=$HOROLOG
	set alt=$random(2)
	if alt=0 set ^trigzsy="implicit execution of trigzsyxplode"
	else  ztrigger ^trigzsy
	set zsycmd="$gtm_tst/com/getoper.csh """_$zdate(start,"MON DD 24:60:SS")_""" """" tpnotacidt2.outx """" """_$job_".*TPNOTACID"""
	zsystem zsycmd
	quit

setup
	if $increment(^setup)>1 quit
	set switch=$random(3)
	do text^dollarztrigger("tfile"_switch_"^trigzsyxplode","trigzsyxplode.trg")
	do file^dollarztrigger("trigzsyxplode.trg",1)
	quit

	; exploding trigger uses inline code
tfile0
	;+^a -command=S -xecute="write ""ZTWO:"",$ztwormhole,$c(9),""ZTLE:"",$ztlevel,$c(9),""TL:"",$tlevel,! zwrite ^a,^c zsystem ""$gtm_exe/mumps -run setC^trigzsyxplode"" set ^b=2"
	;+^trigzsy -command=ZTR,S -xecute="do ^trigzsyxplode" -name=trigzsyxplode
	quit

	; exploding trigger uses an M routine
tfile1
	;+^a -command=S -xecute="do mrtn^trigzsyxplode"
	;+^trigzsy -command=ZTR,S -xecute="do ^trigzsyxplode" -name=trigzsyxplode
	quit

mrtn
	write "ZTWO:",$ztwormhole,$c(9)
	write "ZTLE:",$ztlevel,$c(9)
	write "TL:",$tlevel,!
	zwrite ^a,^c
	zsystem "$gtm_exe/mumps -run setC^trigzsyxplode"
	set ^b=2
	quit

tfile2
	;+^a -command=S -xecute=<<
	;inlinemrtn
	;	write "ZTWO:",$ztwormhole,$c(9)
	;	write "ZTLE:",$ztlevel,$c(9)
	;	write "TL:",$tlevel,!
	;	zwrite ^a,^c
	;	zsystem "$gtm_exe/mumps -run setC^trigzsyxplode"
	;	set ^b=2
	;>>
	;+^trigzsy -command=ZTR,S -xecute="do ^trigzsyxplode" -name=trigzsyxplode
	quit

setC
	set c=$increment(^c),^c=101
	quit
