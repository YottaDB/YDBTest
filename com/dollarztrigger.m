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
dollarztrigger
	new expect,fn,mode,output
	set fn=$piece($zcmdline," ",1)
	set expect=$piece($zcmdline," ",2) set:expect="" expect=1 ; default to successful
	set mode=$random(2)
	if mode do file(fn,expect,.output)
	else  do mupip(fn,.output)
	halt

select(gvn,outfile)
	if '$data(gvn) set gvn="*"
	open outfile:newversion
	use outfile
	do selectmain(gvn)
	close outfile
	quit

all
selectall
	do selectmain("*")
	quit

selectmain(gvn)
	set x=$ztrigger("select",gvn)
	quit

file(file,expected,resp)
	new output,i,line,prevIO
	set prevIO=$IO
	set fqp=$zparse(file)
	set output=$extract(fqp,$length($zparse(fqp,"DIRECTORY"))+1,$length(fqp))_".trigout"
	open output:newversion
	use output
	set status=$ztrigger("file",file)
	close output
	use prevIO
	if expected'=status write "FAIL, see ",output,!
	if $data(resp) do
	.	open output:readonly
	.	for  quit:$zeof  read line set resp($increment(i))=line
	.	close output
	quit

mupip(file,resp)
	new i,pstr,pipe,line,prevIO
	set prevIO=$IO
	set pipe="mupipztrigger"
	set pstr="(shell=""/bin/sh"":command=""$MUPIP trigger -noprompt  -triggerfile="_file_$char(34,41)
	open pipe:@(pstr)::"pipe" use pipe
	if '$data(resp) for  quit:$zeof  read line use $p write line,! use pipe
	if $data(resp) for  quit:$zeof  read line set resp($increment(i))=line
	use prevIO
	close pipe
	quit

	; this assumes that the triggers are at the
	; END of the M file or terminated by a quit.
	; double up the comments to ensure proper
	; loading of the trigger file
text(labelrtn,outfile)
	new prevIO
	set prevIO=$IO
	open outfile:newversion
	use outfile
	do textmain(labelrtn)
	close outfile
	use prevIO
	quit

textmain(labelrtn)
	new label,rtn,line,i
	set label=$piece(labelrtn,"^",1)_"+"
	set rtn="^"_$piece(labelrtn,"^",2)
	set line=labelrtn
	for i=1:1  quit:line=""  do
	. set target=label_i_rtn
	. set line=$text(@target)
	. if line=" quit" set line="" quit
	. if line'="" write $extract(line,3,$length(line)),!
	quit

item(labelrtn,outfile)
	new prevIO
	set prevIO=$IO
	open outfile:newversion
	use outfile
	do itemmain(labelrtn)
	close outfile
	use prevIO
	quit

itemmain(labelrtn)
	new label,rtn,line,i,status,errors,noerrors,x
	set label=$piece(labelrtn,"^",1)_"+"
	set rtn="^"_$piece(labelrtn,"^",2)
	quit:rtn="^"  quit:label="+"
	set line=labelrtn
	for i=1:1  quit:line=""  do
	. set target=label_i_rtn
	. set line=$text(@target)
	. if line=" quit" set line="" quit
	. if line'=""  do
	. . set op=$extract(line,3,3)
	. . if $select(op="-":1,op="+":1,1:0)  do
	. . . set status=$ztrigger("item",$extract(line,3,$length(line)))
	. . . write $select(status:"PASS",1:"FAIL")," - ",line,!
	. . . if status=1 set x=$increment(noerrors)
	. . . else  set x=$increment(errors)
	write $translate($justify("",41)," ","="),!
	write:$data(errors) errors," trigger file entries have errors",!
	write noerrors," trigger file entries have no errors",!
	write $translate($justify("",41)," ","="),!
	quit

check(file)
	set marker=$translate($justify("",41)," ","=")
	open file:readonly
	use file
	for  quit:$zeof  read line if line=marker quit
	for  quit:$zeof  use $p write line,! use file read line
	close file
	quit

delete(item)
	new x
	if '$data(item) set item="-*"
	set x=$ztrigger("item",item)
	if 'x write "FAILED to ",item,!
	quit

	; use these fucntions to avoid compilation errors on platforms that don't support triggers
direct(cmd,line)
	quit $ztrigger(cmd,line)

setztwo(arg)
	set $ztwormhole=arg
	quit

appendztwo(arg)
	set $ztwormhole=$ztwormhole_arg
	quit
