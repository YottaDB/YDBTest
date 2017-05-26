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
wranyfix
	; Test for write anywhere fixed for M, utf-8 with and without BOM, and utf-16 with BOM and UTF-16LE
	; with and without BOM
	; If bomlen is 3 it is utf-8 with BOM and if it is 2 it is utf-16 with which will add a BE bom during init
	; If bomlen passed on command line is 4 or 5 it will be used to test UTF-16LE without BOM and with BOM
	; This will set bomlen to 0(no bom) or 2(with bom and also set bomsel to 1 and 2 respectively for
	; initialization during tests.  The test adjusts sizes of the lines so that the same recordsize of 100 will be
	; used for all cases
	set bomsel=0
	if $zcmdline set bomlen=$zcmdline
	else  set bomlen=0
	if "M"=$zchset set p="Mfix",prname="echo "_p_":; cat "_p,usedev="p:width=100"
	else  do
	. if 'bomlen set p="utf8fix_NOBOM",prname="echo "_p_":; cat "_p,usedev="p:width=99"
	. if 2=bomlen do
	.. set p="utf16fix_BOM"
	.. write "Debugging outputs from ",p," will be in "_p_".outx",!!
	.. set prname="cat "_p_" >> "_p_".outx"
	.. set usedev="p:width=50"
	. if 4=bomlen do
	.. set bomlen=0
	.. set bomsel=1
	.. set p="utf16LEfix_NOBOM"
	.. write "Debugging outputs from ",p," will be in "_p_".outx",!!
	.. set prname="cat "_p_" >> "_p_".outx"
	.. set usedev="p:width=50"
	. if 5=bomlen do
	.. set bomlen=2
	.. set bomsel=2
	.. set p="utf16LEfix_BOM"
	.. write "Debugging outputs from ",p," will be in "_p_".outx",!!
	.. set prname="cat "_p_" >> "_p_".outx"
	.. set usedev="p:width=50"
	. if 3=bomlen  set p="utf8fix_BOM",prname="echo "_p_":; tail -c +4 "_p,usedev="p:width=99"
	if 2=bomlen!0'=bomsel do
	. set zap="ZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZA"
	. set nw1="NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW"
	. set nw2="NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW"
	. set nw3="NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW"
	. set zz1="ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ"
	. set zz2="ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ"
	. set zz3="ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ"
	. set zz4="ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ"
	. set zz5="ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ"
	. if 0=bomsel do
	.. set devpar="p:(chset=""UTF-16"":fixed:recordsize=100)"
	.. set devparwo="p:(chset=""UTF-16"":writeonly:fixed:recordsize=100)"
	.. set devparwonv="p:(chset=""UTF-16"":writeonly:newversion:fixed:recordsize=100)"
	. else  do
	.. set devpar="p:(chset=""UTF-16LE"":fixed:recordsize=100)"
	.. set devparwo="p:(chset=""UTF-16LE"":writeonly:fixed:recordsize=100)"
	.. set devparwonv="p:(chset=""UTF-16LE"":writeonly:newversion:fixed:recordsize=100)"
	if "M"=$zchset do
	. set zap="ZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZ"
	. set nw1="NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1N"
	. set nw2="NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2N"
	. set nw3="NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3N"
	. set zz1="ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1Z"
	. set zz2="ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2Z"
	. set zz3="ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3Z"
	. set zz4="ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4Z"
	. set zz5="ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5Z"
	. set devpar="p:(fixed:recordsize=100)"
	. set devparwo="p:(fixed:recordsize=100:writeonly)"
	. set devparwonv="p:(fixed:recordsize=100:writeonly:newversion)"
	; for utf8 with and without BOM
	if ("M"'=$zchset)&(2'=bomlen)&(0=bomsel) do
	. set zap="ZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAPZAՇ"
	. set nw1="NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NW1NWՇ"
	. set nw2="NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NW2NWՇ"
	. set nw3="NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NW3NWՇ"
	. set zz1="ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZ1ZZՇ"
	. set zz2="ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZ2ZZՇ"
	. set zz3="ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZ3ZZՇ"
	. set zz4="ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZ4ZZՇ"
	. set zz5="ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZ5ZZՇ"
	. set devpar="p:(fixed:recordsize=100)"
	. set devparwo="p:(fixed:recordsize=100:writeonly)"
	. set devparwonv="p:(fixed:recordsize=100:writeonly:newversion)"
	do init(p,bomlen,bomsel)
	do output(p)
	close p
	open @devpar
	use $p
	write !,"Do some reads and writes followed by truncates",!
	write "seek to record 4 and truncate",!
	use @usedev
	use p:(seek="4":truncate)
	do testzkey(p,4)
	zsystem prname
	use p
	write nw1
	use $p
	write !,"write line of NW1 at eof",!
	do testzkey(p,5)
	zsystem prname
	use p:seek="-3"
	write nw2
	use $p
	write !,"relative seek -3 records and write line of NW2",!
	do testzkey(p,3)
	zsystem prname
	use p:truncate
	use $p
	write !,"truncate after NW2 line",!
	zsystem prname
	use p:rewind
	do testzkey(p,0)
	read x
	do testzkey(p,1)
	use $p
	write !,"rewind, read first line then truncate",!
	write "x= ",x,!
	use p:truncate
	zsystem prname
	use $p
	write !,"rewind, replace first line with line of NW3",!
	use p:rewind
	do testzkey(p,0)
	write nw3
	do testzkey(p,1)
	zsystem prname
	use $p
	write !
	use p:seek="0"
	set i=0
	for  read y quit:$zeof  use $p write i,"  ",y,! use p
	close p
;;;
	write !,"Do some writes followed by close nodestroy then reopen in various ways",!
	do init(p,bomlen,bomsel)
	close p
	open @devpar
	use @usedev
	use p:rewind
	read x set zk=$zkey
	use $p write "read offset=0"," x= ",x," zkey= ",zk,!
	use p
	write zz1
	close p:nodestroy
	write "1  BBB -> ZZ1",!
	open p
	use p
	do testzkey(p,2)
	write zz2
	do testzkey(p,3)
	close p:nodestroy
	write "2  SSS -> ZZ2",!
	open p:seek="+1"
	do testzkey(p,4)
	use p
	write zz3
	do testzkey(p,5)
	close p:nodestroy
	write "4  GGG -> ZZ3",!
	open p:nowrap
	use p
	do testzkey(p,0)
	write zz4
	do testzkey(p,1)
	close p:nodestroy
	write "0  EEE -> ZZ4",!
	set relseek="-"_1
	open p:(append:seek=relseek)
	use p
	write zz5
	do testzkey(p,11)
	use $p
	write "10  fff -> ZZ5",!
	zsystem prname
	write !
	do output(p)
	close p
;;;
	write !," choose absolute seek values from t(1,...), read then seek to beginning of word and write a ZAP line",!
        write "have a pipe process(zap2pipfix.m) write a PIP line in same location",!
	set t(1,0)=6,t(1,1)=4,t(1,2)=3,t(1,3)=3,t(1,4)=10,t(1,5)=4,t(1,6)=1,t(1,7)=0

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	use @usedev
	set pp="PP"
	open pp:(comm="$gtm_exe/mumps -r zap2pipfix "_p_" "_bomlen_" "_bomsel)::"pipe"
	for i=0:1:7  do
	. set choice=t(1,i)
	. use p:seek=choice
	. read x set zk=$zkey
	. use $p write "choice = ",choice," x= ",x," zkey= ",zk,!
	. use p:seek="-1"
	. set zkblk=$piece(zk,",",1)
	. do testzkey(p,zkblk-1)
	. write zap
	. do testzkey(p,zkblk)
	. use pp write choice,!
	. read reply
	zsystem prname
	use $p
	write !
	do output(p)
	close p
;;;

	write !,"choose absolute seek values from t(2,...), write ZAP",!
	set t(2,0)=3,t(2,1)=0,t(2,2)=10,t(2,3)=1,t(2,4)=6,t(2,5)=3,t(2,6)=6

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	use @usedev
	for i=0:1:6  do
	. set choice=t(2,i)
	. use p:seek=choice
	. do testzkey(p,choice)
	. write zap,!
	. do testzkey(p,choice+1)
	. use $p write "choice = ",choice,!

	zsystem prname
	write !
	do output(p)
	close p
;;;
	write !," choose relative seek from t(3,...) then use t(4,...) to decide to WRITE ZAP or read and output",!
	; relative seek values
	set t(3,0)="+2",t(3,1)="-0",t(3,2)="+1"
	set t(3,3)="+0",t(3,4)="-1",t(3,5)="-5"
	set t(3,6)="-0",t(3,7)="-4",t(3,8)="+4"
	set t(3,9)="-3",t(3,10)="-3",t(3,11)="+8",t(3,12)="-3"

	; 1 for read, 0 for write ZAP
	set t(4,0)=1,t(4,1)=1,t(4,2)=0
	set t(4,3)=0,t(4,4)=0,t(4,5)=0
	set t(4,6)=0,t(4,7)=1,t(4,8)=0
	set t(4,9)=0,t(4,10)=1,t(4,11)=0,t(4,12)=1

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	use @usedev
	set offset=0
	use $p
	for i=0:1:12  do
	. set newv=t(3,i)
	. write "relative seek value=",newv,!
	. use p:seek=newv
	. set offset=offset+newv+1
	. set readorwrite=t(4,i)
	. if readorwrite  do
	.. read x set zk=$zkey
	.. use $p write "offset before read = ",offset-1," x= ",x," zkey= ",zk,!
	. if 'readorwrite  do
	.. write zap,!
	.. set zk=$zkey
	.. use $p write "offset before write ZAP = ",offset-1," zkey= ",zk,!

	zsystem prname
	write !
	do output(p)
	close p
;;;
	write !," choose absolute seek from t(5,...) then use t(6,...) to decide to WRITE ZAP or read and output",!
	set t(5,0)="6",t(5,1)="4",t(5,2)="5"
	set t(5,3)="6",t(5,4)="2",t(5,5)="2"
	set t(5,6)="0",t(5,7)="0",t(5,8)="10",t(5,9)="6",t(5,10)=5
	set t(5,11)=1

	set t(6,0)=1,t(6,1)=0,t(6,2)=1
	set t(6,3)=1,t(6,4)=1,t(6,5)=1
	set t(6,6)=1,t(6,7)=0,t(6,8)=0,t(6,9)=1
	set t(6,10)=1,t(6,11)=0

	do init(p,bomlen,bomsel)
	close p
	open @devpar
	use @usedev
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

	write !," OPEN WRITEONLY an empty file and write to it, seek=-1 and write again",!!
	open @devparwonv
	use p
	write zap,!
	use p:seek="-1"
	write nw1,!
	close p

	zsystem "cat "_p
	write !

	quit

init(p,bomlen,bomsel)
	; setup for M mode
	if "M"=$zchset do
	. open p:(fixed:recordsize=100:newversion)
	. use p:width=100
	. write "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
	. write "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
	. write "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"
	. write "3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333"
	. write "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
	. write "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
	. write "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
	. write "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
	. write "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
	. write "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
	. write "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
	else  do
	.; setup for utf-8 no bom
	. if (0=bomlen)&(0=bomsel) do
	.. open p:(fixed:recordsize=100:newversion)
	.. use p:width=99
	.. write "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEՇ"
	.. write "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBՇ"
	.. write "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSՇ"
	.. write "33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333Շ"
	.. write "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGՇ"
	.. write "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHՇ"
	.. write "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbՇ"
	.. write "ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccՇ"
	.. write "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddՇ"
	.. write "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeՇ"
	.. write "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffՇ"
	.; setup for utf-8 with bom
	. if 3=bomlen do
	.. ; create a file with utf-8 bom characters in it
	.. open p:(chset="M":newversion)
	.. use p
	.. write $zchar(239,187,191)
	.. set $x=0
	.. close p
	.. open p:(append:fixed:recordsize=100)
	.. use p:width=99
	.. write "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEՇ"
	.. write "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBՇ"
	.. write "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSՇ"
	.. write "33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333Շ"
	.. write "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGՇ"
	.. write "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHՇ"
	.. write "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbՇ"
	.. write "ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccՇ"
	.. write "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddՇ"
	.. write "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeՇ"
	.. write "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffՇ"
	.; open utf-16 to generate BE BOM
	. if 2=bomlen!0'=bomsel do
	.. if 0=bomsel do
	... open p:(chset="UTF-16":fixed:recordsize=100:newversion)
	.. if 1=bomsel do
	... open p:(chset="UTF-16LE":fixed:recordsize=100:newversion)
	.. if 2=bomsel do
	... ; create a file with utf-16LE bom characters in it
	... open p:(chset="M":newversion)
	... use p
	... write $zchar(255,254)
	... set $x=0
	... close p
	... open p:(chset="UTF-16LE":fixed:recordsize=100:append)
	.. use p:width=50
	.. write "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEՇ"
	.. write "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBՇ"
	.. write "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSՇ"
	.. write "3333333333333333333333333333333333333333333333333Շ"
	.. write "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGՇ"
	.. write "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHՇ"
	.. write "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbՇ"
	.. write "cccccccccccccccccccccccccccccccccccccccccccccccccՇ"
	.. write "dddddddddddddddddddddddddddddddddddddddddddddddddՇ"
	.. write "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeՇ"
	.. write "fffffffffffffffffffffffffffffffffffffffffffffffffՇ"
	set $X=0
	quit

output(p)
	use p:rewind
	for i=0:1:10  do
	. read y
	. set zkey=$zkey-1
	. use $p
	. write zkey,"  ",y,!
	. use p
	quit

testzkey(file,expected)
	new %io,zkey
	set %io=$io
	use file
	set zkey=$zkey
	set expected=expected_",0"
	if zkey'=expected use $p write !,"Expected zkey: "_expected_", Actual zkey: "_zkey,!
	use %io
	quit
