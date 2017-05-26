;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2010, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
longline
	; The trigger line parser starts AFTER the ^GVN, getting the paren onwards
	set file="longline.trg"
	do init
	do triggerfile
	quit

	; setup the long line data
	; - maxlen is used to JUSTIFY the line to and over the 32k limit. All
	; uses are written as maxlen+X because its easier to read.  remember
	; that the maxlen is the limit after the parser is done with the GVN
	; - the res(i)={0 | 1} are used to indicate whether we expect the line to
	; fail or not. $ztrigger returns 1 for all non-failing lines and 0 for
	; all failing lines. Success is determined by what we expect $ztrigger
	; to return
init
	set maxlen=33023 ; 32768+255 from cli.h
start
	;
	; JUNK lines
	; these fail because there is no +/- at the beginning if the line, note line length
	set line($increment(i))=$justify("*",maxlen),res(i)=0
	set line($increment(i))=$justify("+^a"_$$fmt^longline(i),maxlen),res(i)=0
	; over flows
	; these fail because there is no +/- at the beginning if the line, note line length
	set line($increment(i))=$justify("*",maxlen+1),res(i)=0
	set line($increment(i))=$justify("+^a"_$$fmt^longline(i),maxlen+1),res(i)=0
	;
	; ADD
	; the first fails because the global is not next to the plus sign, the following should pass
	set line($increment(i))="+"_$justify("^a -command=Set -xecute=""s x=1"" -name=fail",maxlen),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=pass",maxlen),res(i)=1
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=passagain -piece=1 -delim=$char(61)",maxlen),res(i)=1
	; over flows
	; these should fail because something has fallen off the end of the line
	; part of name can fall off the line, push it to and before the equal sign
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail",maxlen+4),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail",maxlen+5),res(i)=0
	; no cmd
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-xecute=""s x=1"" -name=fail",maxlen),res(i)=0
	; no xecute
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -name=fail",maxlen),res(i)=0
	; no name - this WORKs
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1""",maxlen),res(i)=1
	; cmd falls off the line , push cmd to and before the equals sign or a comma
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-xecute=""s x=1"" -name=fail -piece=1 -delim=$char(61) -command=S",maxlen+1),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-xecute=""s x=1"" -name=fail -piece=1 -delim=$char(61) -command=S,K",maxlen+1),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-xecute=""s x=1"" -name=fail -piece=1 -delim=$char(61) -command=S",maxlen+2),res(i)=0
	; xecute falls off the line , drop the last quotation mark, in the middle of the string and at the equals sign
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -name=fail -piece=1 -delim=$char(61) -xecute=""s x=1""",maxlen+1),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -name=fail -piece=1 -delim=$char(61) -xecute=""s x=1""",maxlen+9),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -name=fail -piece=1 -delim=$char(61) -xecute=""s x=1""",maxlen+10),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -name=fail -piece=1 -delim=$char(61) -xecute=""s x=1""",maxlen+5),res(i)=0
	; delim falls off the line
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -piece=1 -delim=$char(61)",maxlen+1),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -piece=1 -delim=$char(61)",maxlen+9),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -piece=1 -delim=$char(61)",maxlen+10),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -piece=1 -delim="".""",maxlen+1),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -piece=1 -delim="".""",maxlen+2),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -piece=1 -delim="".""",maxlen+3),res(i)=0
	; piece falls off the line
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -delim=$char(61) -piece=1",maxlen+1),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -delim=$char(61) -piece=1",maxlen+2),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -delim=$char(61) -piece=1:5",maxlen+1),res(i)=0
	set line($increment(i))="+^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=fail -delim=$char(61) -piece=1;5",maxlen+1),res(i)=0
	;
	; DELETE
	set line($increment(i))="-"_$justify("^a",maxlen+4),res(i)=0
	; the overflow preceeds the working deletes, but the working deletes no longer targets the right trigger ...
	; the use of +1 makes the delete try to delete a trigger with the name 'pas', the following delete uses 'pass'
	set line($increment(i))="-^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=pass",maxlen+1),res(i)=1
	set line($increment(i))="-^a"_$$fmt^longline(i)_$justify("-command=Set -xecute=""s x=1"" -name=pass",maxlen),res(i)=1
	kill i
	quit

	; this was written to make 0-9 write as 00 through 09 so that the
	; long lines would all get written with a GVN of the same length to
	; facilitate reading the code
fmt(num)
	quit $translate($justify(num,2)," ",0)

	; write the long line trigger file, not the width and wrap shenanigans
	; they worked fine in M mode, but UTF-8 mode threw a curveball because
	; it always wraps at 32k-1. The code writes out till 32k-2 (aka 1 before
	; the line wrapping point), fiddles with $x and continues writing.
	;
	; if you need to see the line endings execute 'mumps -run longline'
	; and read longline.trg in VIM with ':set nowrap' and vertically split ':vs'
triggerfile
	set unilinewrap=32768-2
	open file:(newversion:nowrap)
	use file:width=65536
	set next=""
	for  set next=$order(line(next)) quit:next=""  do
	.	write $extract(line(next),1,unilinewrap)
	.	set $X=0
	.	write $extract(line(next),unilinewrap+1,$length(line(next))),!
	close file
	use $p
	quit

	; rip up the init function with $text and write the lines to another M
	; routine a generated script file then calls those M routines in the
	; order that they were written
	; we do this to give each trigger a fresh environment to xecute in
script
	set script="ztrig.csh"
	open script:newversion
	set next="",tab=$char(9)
	for i=1:1:60 quit:$piece(next," ",1)="quit"  do
	.	set next=$text(start+i^longline),next=$extract(next,2,$length(next))
	.	if $piece(next," ",1)="set" do
	.	. ; generate the M routine
	.	. set ztrgf="ztrig"_$increment(instance)_".m"
	.	. open ztrgf:newversion
	.	. use ztrgf
	.	. write "ztrig",instance,!
	.	. write tab,"set i=",(instance-1),!
	.	. write tab,"set maxlen=33023 ; 32768+255 from cli.h",!
	.	. write tab,next,!
	.	. write tab,"write ",instance,",!",!
	.	. write tab,"set x=$ztrigger(""item"",line(i))",!
	.	. write tab,"if x'=res(i) write ""Unexpected result"",!",!
	.	. write tab,"halt",!
	.	. close ztrgf
	.	. ; update the CSH script file
	.	. use script write "$gtm_exe/mumps -run ztrig",instance,! use $p
	close script
	quit

	; use each long line in the line(i) array with $ztrigger
	; this test differs from the script test in that all the triggers are
	; loaded in one routine to stress loading in one runtime
item
	set $etrap="write $zstatus,! set $ecode="""" halt"
	do init
	set next=""
	for  set next=$order(line(next)) quit:next=""  write next,! set x=$ztrigger("item",line(next)) if x'=res(next) write "Unexpected result",!
	quit
