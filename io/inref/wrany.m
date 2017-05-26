;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wrany
	; Test for write anywhere non-fixed for M, UTF-8 with and without BOM, and UTF-16 with BOM, and UTF-16LE
	; with and without BOM
	; the bomlen argument is in $zcmdline and determines the choices as follows
	; If bomlen is 3 it is utf-8 with BOM and if it is 2 it is utf-16 with which will add a BE bom during init
	; If bomlen passed on command line is 4 or 5 it will be used to test UTF-16LE without BOM and with BOM
	; This will set bomlen to 0(no bom) or 2(with bom and also set bomsel to 1 and 2 respectively for
	; initialization during tests.  The test adjusts sizes of the lines so that the same seek offsets will
	; work for all cases
	set bomsel=0
	if $zcmdline set bomlen=$zcmdline
	else  set bomlen=0
	if "M"=$zchset set p="Mvar",prname="echo "_p_":; cat "_p
	else  do
	. if 'bomlen set p="utf8var_NOBOM",prname="echo "_p_":; cat "_p
	. if 2=bomlen do
	.. set p="utf16var_BOM"
	.. write "Debugging outputs from ",p," will be in "_p_".outx",!!
	.. set prname="cat "_p_" >> "_p_".outx"
	. if 4=bomlen do
	.. set bomlen=0
	.. set bomsel=1
	.. set p="utf16LEvar_NOBOM"
	.. write "Debugging outputs from ",p," will be in "_p_".outx",!!
	.. set prname="cat "_p_" >> "_p_".outx"
	. if 5=bomlen do
	.. set bomlen=2
	.. set bomsel=2
	.. set p="utf16LEvar_BOM"
	.. write "Debugging outputs from ",p," will be in "_p_".outx",!!
	.. set prname="cat "_p_" >> "_p_".outx"
	. if 3=bomlen  set p="utf8var_BOM",prname="echo "_p_":; tail -c +4 "_p
	if 2=bomlen!0'=bomsel do
	. set zap="ZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZ"
	. set nw1="NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1N"
	. set nw2="NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2N"
	. set nw3="NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3N"
	. set zz1="ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1Z"
	. set zz2="ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2Z"
	. set zz3="ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3Z"
	. set zz4="ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4Z"
	. set zz5="ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5Z"
	. if 0=bomsel do
	.. set devpar="p:chset=""UTF-16"""
	.. set devparwo="p:(chset=""UTF-16"":writeonly)"
	.. set devparwonv="p:(chset=""UTF-16"":writeonly:newversion)"
	. else  do
	.. set devpar="p:chset=""UTF-16LE"""
	.. set devparwo="p:(chset=""UTF-16LE"":writeonly)"
	.. set devparwonv="p:(chset=""UTF-16LE"":writeonly:newversion)"
	else  do
	. set zap="ZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAP"
	. set nw1="NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1"
	. set nw2="NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2"
	. set nw3="NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3"
	. set zz1="ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1"
	. set zz2="ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2"
	. set zz3="ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3"
	. set zz4="ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4"
	. set zz5="ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5"
	. set devpar="p"
	. set devparwo="p:writeonly"
	. set devparwonv="p:(writeonly:newversion)"
	do init(p,bomlen,bomsel)
	do output(p)
	close p
	open @devpar
	use $p
	write !,"Do some reads and writes followed by truncates",!
	write "seek to "_(400+bomlen)_" and truncate",!
	set abseek=400+bomlen
	use p:(seek=abseek:truncate)
	do testzkey(p,abseek)
	zsystem prname
	use p
	write nw1,!
	use $p
	write "write line of NW1 at eof",!
	; linelen is 100 in bytes for all modes
	set linelen=100
	set abseek=abseek+linelen
	do testzkey(p,abseek)
	zsystem prname
	use p:seek="-300"
	write nw2,!
	use $p
	write "relative seek -300 and write line of NW2",!
	set abseek=abseek-300+linelen
	do testzkey(p,abseek)
	zsystem prname
	use p:truncate
	use $p
	write "truncate after NW2 line",!
	zsystem prname
	use p:rewind
	do testzkey(p,0)
	read x
	set abseek=linelen+bomlen
	do testzkey(p,abseek)
	use $p
	write "rewind, read first line then truncate",!
	write "x= ",x,!
	use p:truncate
	zsystem prname
	use $p
	write "rewind, replace first line with line of NW3",!
	use p:rewind
	do testzkey(p,0)
	write nw3,!
	set abseek=linelen+bomlen
	do testzkey(p,abseek)
	zsystem prname
	use $p
	write !
	use p:seek="0"
	set i=0
	for  read y quit:$zeof  use $p write i*100,"  ",y,! use p
	close p
;;;
	write !,"Do some writes followed by close nodestroy then reopen in various ways",!
	do init(p,bomlen,bomsel)
	close p
	open @devpar
	use p:rewind
	read x set zk=$zkey
	use $p write "read offset=0"," x= ",x," zkey= ",zk,!
	use p
	write zz1,!
	close p:nodestroy
	write (100+bomlen)_"  BBB -> ZZ1",!
	open p
	use p
	set abseek=zk+linelen
	do testzkey(p,abseek)
	write zz2,!
	set abseek=abseek+linelen
	close p:nodestroy
	write (200+bomlen)_"  SSS -> ZZ2",!
	open p:seek="+100"
	use p
	set abseek=abseek+100
	do testzkey(p,abseek)
	write zz3,!
	set abseek=abseek+linelen
	do testzkey(p,abseek)
	close p:nodestroy
	write (400+bomlen)_"  GGG -> ZZ3",!
	open p:nowrap
	use p
	do testzkey(p,0)
	write zz4,!
	do testzkey(p,linelen+bomlen)
	close p:nodestroy
	write "0  EEE -> ZZ4",!
	set relseek="-"_100
	open p:(append:seek=relseek)
	use p
	write zz5,!
	do testzkey(p,1000+linelen+bomlen)
	use $p
	write (1000+bomlen)_"  fff -> ZZ5",!
	zsystem prname
	write !
	do output(p)
	close p
;;;
	write !," choose absolute seek values from t(1,...), read then seek to beginning of word and write a ZAP line",!
        write "have a pipe process(zap2pip.m) write a PIP line in same location",!
	set t(1,0)=600+bomlen,t(1,1)=400+bomlen,t(1,2)=300+bomlen,t(1,3)=300+bomlen,t(1,4)=1000+bomlen,t(1,5)=400+bomlen,t(1,6)=100+bomlen

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	set pp="PP"
	open pp:(comm="$gtm_exe/mumps -r zap2pip "_p_" "_bomlen_" "_bomsel)::"pipe"
	for i=0:1:6  do
	. set choice=t(1,i)
	. use p:seek=choice
	. read x set zk=$zkey
	. use $p write "choice = ",choice," x= ",x," zkey= ",zk,!
	. use p:seek="-100"
	. do testzkey(p,zk-100)
	. write zap,!
	. do testzkey(p,zk)
 	. use pp write choice,!
	. read reply
	zsystem prname
	use $p
	write !
	do output(p)
	close p
;;;
	write !,"choose absolute seek values from t(2,...), write ZAP",!
	set t(2,0)=300+bomlen,t(2,1)=0,t(2,2)=1000+bomlen,t(2,3)=100+bomlen,t(2,4)=600+bomlen,t(2,5)=300+bomlen,t(2,6)=600+bomlen

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	for i=0:1:6  do
	. set choice=t(2,i)
	. use p:seek=choice
	. do testzkey(p,choice)
	. write zap,!
	. if 0=choice set abseek=choice+linelen+bomlen
	. else  set abseek=choice+linelen
	. do testzkey(p,abseek)
	. use $p write "choice = ",choice,!

	zsystem prname
	write !
	do output(p)
	close p
;;;
	write !," choose relative seek from t(3,...) then use t(4,...) to decide to WRITE ZAP or read and output",!
	; relative seek values
	set t(3,0)="+"_(200+bomlen),t(3,1)="-0",t(3,2)="+100"
	set t(3,3)="+0",t(3,4)="-100",t(3,5)="-500"
	set t(3,6)="-0",t(3,7)="-400",t(3,8)="+400"
	set t(3,9)="-300",t(3,10)="-300",t(3,11)="+800",t(3,12)="-300"

	; 1 for read, 0 for write ZAP
	set t(4,0)=1,t(4,1)=1,t(4,2)=0
	set t(4,3)=0,t(4,4)=0,t(4,5)=0
	set t(4,6)=0,t(4,7)=1,t(4,8)=0
	set t(4,9)=0,t(4,10)=1,t(4,11)=0,t(4,12)=1

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	set offset=0
	for i=0:1:12  do
	. set newv=t(3,i)
	. write "relative seek value=",newv,!
	. use p:seek=newv
	. set offset=offset+newv+100
	. set readorwrite=t(4,i)
	. if readorwrite  do
	.. read x set zk=$zkey
	.. use $p write "offset before read = ",offset-100," x= ",x," zkey= ",zk,!
	. if 'readorwrite  do
	.. write zap,!
	.. set zk=$zkey
	.. use $p write "offset before write ZAP = ",offset-100," zkey= ",zk,!

	zsystem prname
	write !
	do output(p)
	close p
;;;
	write !," choose absolute seek from t(5,...) then use t(6,...) to decide to WRITE ZAP or read and output",!
	set t(5,0)=600+bomlen,t(5,1)=400+bomlen,t(5,2)=500+bomlen
	set t(5,3)=600+bomlen,t(5,4)=200+bomlen,t(5,5)=200+bomlen
	set t(5,6)="0",t(5,7)="0",t(5,8)=1000+bomlen,t(5,9)=600+bomlen,t(5,10)=500+bomlen
	set t(5,11)=100+bomlen

	set t(6,0)=1,t(6,1)=0,t(6,2)=1
	set t(6,3)=1,t(6,4)=1,t(6,5)=1
	set t(6,6)=1,t(6,7)=0,t(6,8)=0,t(6,9)=1
	set t(6,10)=1,t(6,11)=0

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	for i=0:1:11  do
	. set choice=t(5,i)
	. use p:seek=choice
	. if t(6,i)  do
	.. read x set zk=$zkey
	.. use $p write "read value, choice = ",choice," x= ",x," zkey= ",zk,!
	. else  do
	.. write zap,!
	.. set zk=$zkey
	.. use $p write "write ZAP, choice = ",choice," zkey= ",zk,!

	zsystem prname
	write !
	do output(p)
	close p

	write !," OPEN WRITEONLY a non-empty file to generate an error if UTF ",!
	set $ztrap="goto errorAndCont^errorAndCont"
	open @devparwo
	close p

	write !," OPEN WRITEONLY an empty file and write to it, rewind and write again",!!
	open @devparwonv
	use p
	write "This is the first line - 1",!
	use p:rewind
	write "This is the first line - 2",!
	close p

	zsystem "cat "_p
	write !
	quit

init(p,bomlen,bomsel)
	new p2
	if 0=bomlen do
	. if 0=bomsel do
	.. open p:newversion
	. else  do
	.. open p:(chset="UTF-16LE":newversion)
	if 3=bomlen do
	. ; create a file with utf-8 bom characters in it
	. open p:(chset="M":newversion)
	. use p
	. write $zchar(239,187,191)
	. set $x=0
	. close p
	. open p:append
	; open utf-16 to generate BE BOM
	if 2=bomlen do
	. if 0=bomsel do
	..  open p:(chset="UTF-16":newversion)
	. else  do
	.. ; create a file with utf-16LE bom characters in it
	.. open p:(chset="M":newversion)
	.. use p
	.. write $zchar(255,254)
	.. set $x=0
	.. close p
	.. open p:(chset="UTF-16LE":append)
	use p
	if "M"=$zchset do
	. write "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE",!
	. write "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",!
	. write "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS",!
	. write "333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333",!
	. write "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",!
	. write "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH",!
	. write "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",!
	. write "ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",!
	. write "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",!
	. write "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",!
	. write "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",!
	; if not M mode then replace last 2 ascii chararcters with a multi-byte char at the end
	if "M"'=$zchset do
	. if (2'=bomlen)&(0=bomsel) do
	.. write "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEՇ",!
	.. write "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBՇ",!
	.. write "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSՇ",!
	.. write "3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333Շ",!
	.. write "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGՇ",!
	.. write "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHՇ",!
	.. write "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbՇ",!
	.. write "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccՇ",!
	.. write "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddՇ",!
	.. write "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeՇ",!
	.. write "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffՇ",!
	. else  do
	.. write "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEՇ",!
	.. write "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBՇ",!
	.. write "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSՇ",!
	.. write "333333333333333333333333333333333333333333333333Շ",!
	.. write "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGՇ",!
	.. write "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHՇ",!
	.. write "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbՇ",!
	.. write "ccccccccccccccccccccccccccccccccccccccccccccccccՇ",!
	.. write "ddddddddddddddddddddddddddddddddddddddddddddddddՇ",!
	.. write "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeՇ",!
	.. write "ffffffffffffffffffffffffffffffffffffffffffffffffՇ",!
	quit

output(p)
	use p:rewind
	for i=0:1:10  do
	. read y
	. set zkey=$zkey-100
	. use $p
	. write zkey,"  ",y,!
	. use p
	quit

testzkey(file,expected)
	new %io,zkey
	set %io=$io
	use file
	set zkey=$zkey
	if zkey'=expected use $p write !,"Expected zkey: "_expected_", Actual zkey: "_zkey,!
	use %io
	quit
