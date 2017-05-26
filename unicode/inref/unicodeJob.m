;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2006-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
unicodeJob;	This test job command arguments as unicode name.
	;
	SET $ZT="g ERROR^unicodeJob"
	;
	set filename="ＡＢＣＤ.input"
	open filename:(newversion:ochset="UTF-8")
	use filename
	write "αβγ我ＡＢＧ玻璃而傷"
	close filename
	;
	;
	lock +^parlock
	; unicode gbldir, unicode output file with unicode data, unicode argument to job
	job unijob1^unicodeJob("ＡＢＣＤＥＦＧ"):(nodet:gbl="ＡＢＣＤ.ＥＦＧ":output="ＡＢＣＤＥＦＧ.out":error="ＡＢＣＤＥＦＧ.err")
	; unicode gbldir, unicode argument to job, unicode error file with unicode error message
	job unijob2^unicodeJob("乴亐亯仑件伞佉佷"):(nodet:gbl="ＡＢＣＤ.ＥＦＧ":output="乴亐亯仑件伞佉佷.job2":error="乴亐亯仑件伞佉佷.err")
	; dynamically create output and error file name from unicode directory adding mjo and mje
	job unijob3^ujob("αβγδε"):(nodet:gbl="ＡＢＣＤ.ＥＦＧ":output="ＡＢＣＤＥＦＧ.job3")
	; Run job in a specified directory. Need to have gld file, DB and ujob.o access in default directory
	job unijob4^ujob("লায়েক"):(nodet:gbl="../ＡＢＣＤ.ＥＦＧ":default="αβγ我ＡＢＧ玻璃而傷")		;output file is ./αβγ我ＡＢＧ玻璃而傷/ujob.mjo
	; Read from input which is a unicode file with unicode data
	job unijob5^ujob("我能吞下玻璃而不伤身体"):(nodet:gbl="ＡＢＣＤ.ＥＦＧ":input="ＡＢＣＤ.input")		; output file is ./ujob.mjo
	;
	;
	view "JOBPID":1
	job unijob1^unicodeJob("JOBPID1"):(nodet:gbl="ＡＢＣＤ.ＥＦＧ":output="ḀḁḂḃḄḅḆḇ.jpidout":error="ḀḁḂḃḄḅḆḇ.jpiderr")
	job unijob1^unicodeJob("JOBPID2"):(nodet:gbl="ＡＢＣＤ.ＥＦＧ":output="ḀḁḂḃḄḅḆḇ.jpidout":error="ḀḁḂḃḄḅḆḇ.jpiderr")
	;
	lock -^parlock
	set maxwait=300 ; wait for 5 minutes max
	set waitinterval=1 ; wait 1 sec at a time
	set done=0
	set allexist=0
	for j=1:1:maxwait quit:done  do
	. if 'allexist&(($data(^utf8("unijob1")))&($data(^utf8("unijob2")))&($data(^utf8("unijob3")))&($data(^utf8("unijob4")))&($data(^utf8("unijob5")))) set allexist=1
	. if allexist&(^utf8("unijob1","ＡＢＣＤＥＦＧ")=3) set done=1
	. hang waitinterval
	if j=maxwait w "Timed out",! ZSHOW "*" halt
	write "zwr ^utf8",!
	zwr ^utf8
	quit

unijob1(arg)
	; save the pid
	do savepid(arg)
	SET $ZT="g ERROR^unicodeJob"
	lock ^parlock($j)
	write "unijob1:Arg=",arg,!
	tstart *:(serial:transaction=$J)
	set ^utf8("unijob1","ＡＢＣＤＥＦＧ")=$GET(^utf8("unijob1","ＡＢＣＤＥＦＧ"))+1
	tc
	quit
unijob2(arg)
	; save the pid
	do savepid(arg)
	SET $ZT="g ERROR^unicodeJob"
	lock ^parlock($j)
	write "unijob2:Arg=",arg,!
	set ^utf8("unijob2","乴亐亯仑件伞佉佷")="There will be an error for this job"
	write "^utf8(""undef-乴亐亯仑件伞佉佷"")=",^utf8("undef-乴亐亯仑件伞佉佷"),!
	quit
savepid(arg)
	set p=arg_"_pid"
	open p:newversion
	use p
	write $job,!
	close p
	quit
ERROR   ;
	SET $ZT=""
        write !,"$zstatus=",$zstatus
        write !,"$zgbldir=",$zgbldir,!
	quit
