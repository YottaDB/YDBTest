;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; tools to aid file operations
        ; writfile: write into a file
        ; readfile: read the contents of a file
        ; readfile will check the file is proper (i.e. as written by writfile)
        ; both expect the file to be OPEN'd already
	; also prints information about a file (dirdev)
readfile(file,check) ;
	set zeof=$ZEOF
	set prevdev=$IO
        use $PRINCIPAL
        if '$DATA(lineno) set lineno=0
	write "File: ",file,!
	if 1=zeof write "Empty file",!  use prevdev quit
        write "#l",?5,"$L(l)",?13,"l",!
        set totx=""
        set fail=0,badlines=""
        set lc=0
        if '$DATA(width) set width=1048576
        for i=1:1 use file:WIDTH=width read x set zeof=$ZEOF use $PRINCIPAL quit:zeof  do:x'=""
        . use $PRINCIPAL
        . do print(.lc,x)
        . if '$DATA(intofile(lc)) set fail=1 set badlines=badlines_","_lc
        . else  if x'=intofile(lc) set fail=2 set badlines=badlines_","_lc
        if $DATA(check),check=0 quit
        if lineno'=lc set fail=3 set badlines=badlines_"(end: "_lineno_" vs "_lc_")"
        set lc=1
	use $PRINCIPAL
        if 'fail write "PASS",!
        if fail do
        . write "TEST-E-FAIL, code: ",fail,!
        . write "at lines: ",badlines,!
        . write "----------------",!
        . write "The file was expected to be:",!
        . for i=0:1 quit:'$DATA(intofile(i))  do
        . . d print(.lc,intofile(i))
        . write !,"----------------",!
	use prevdev
        quit
writfile(file,line) ;
        if '$DATA(lineno) set lineno=0
        set lineno=lineno+1
        set intofile(lineno)=line
        if '$DATA(width) set width=1048576
        use file:(WIDTH=width)
        write line,!
        use $PRINCIPAL
        quit
print(linec,x) ; write one line of output (format: line_no length line)
        set linec=linec+1
        write linec,?5,$L(x),?13
        ;if 70<$L(x) write $E(x,1,50),"<...length=",$L(x),"...> ",!
        w $$shrnkstr^shrnkfil(x),!
        quit
dirdev(device) ; Will print certain fields of dir/full output 
	new prevdev
	set prevdev=$IO
	use $PRINCIPAL
	write "==== File information for file ",device,":",!
	set tmpfile="dirdev.out"
	if '$DATA(unix) set unix=$ZVERSION'["VMS"
	if unix do unixdir
	else  do vmsdir
	quit
unixdir	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	zsystem "$gtm_tst/com/lsminusl.csh "_device_" >&! "_tmpfile
	open tmpfile:(READONLY:REWIND)
	kill notfound
	for i=1:1 use tmpfile read line quit:$ZEOF  do
	. use $PRINCIPAL
	. if line["No such file or directory" set notfound=1
	. if line["not found" set notfound=1
	. if line["does not exist" set notfound=1
	. if $DATA(notfound) write "TEST-I-FNF, file is not found",!
	. else  write $PIECE(line," ",1),"   ",device,!
	close tmpfile:(DELETE)
	quit
vmsdir	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; the fields from dir/full output that we are interested in: 
	set inter(1)="File attributes"
	set inter(2)="Record format"
	set inter(3)="Record attributes"
	set inter(4)="RMS attributes"
	set inter(5)="File protection"
	set inter(6)="Access Cntrl List"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set dummy=$ZSEARCH("dummy.out")
	if ""'=$ZSEARCH(tmpfile) write "TEST-E-TSSERT "_tmpfile_" should not be left behind",! quit
	zsystem "dir/full "_device_" /output="_tmpfile
	open tmpfile:(READONLY:REWIND)
	for i=1:1 use tmpfile read line quit:$ZEOF  do
	. for n=1:1 quit:'$DATA(inter(n))  do
	. . if line[inter(n) use $PRINCIPAL do process(.line) write ?5,line,!
	if 1=i use $PRINCIPAL write "TEST-I-FNF, file is not found",!
	set dummy=$ZSEARCH("dummy.out")
	if ""'=$ZSEARCH(tmpfile) close tmpfile:(DELETE)
	use prevdev
	quit
process(x)	;
	; if allocation is requested (i.e. alloc is set), check if it matches (round
	; up to nearest cluster allocation value), otherwise:
	; mask off the two least significant digits of Allocation, since it is not
	; guaranteed to be the same for each device
	set subs="Allocation: "
	set locat1=$FIND(x,subs)
	if 'locat1 quit
	set locat2=$FIND(x,",",locat1)
	;...Allocation: 789, Extend:...
	;             1^   2^
	set actual=$PIECE($E(x,locat1,locat2),",",1)
	if $DATA(alloc) do
	. ; alloc is sent in, round it up to the device's cluster allocation value
	. ; and print a #PASS# if it matches
	. if 'unix do
	. . ;hoops to avoid compilation warning on UNIX
	. . set xcav="set cav=$ZGETDVI($ZDIRECTORY,""CLUSTER"")"
	. . xecute xcav
	. set exp=((alloc+cav-1)\cav)*cav
	. if actual=exp set $EXTRACT(x,locat1,locat2-2)="#PASS(EXACT)#" quit
	. if actual>exp set $EXTRACT(x,locat1,locat2-2)="#PASS(A>E)#" quit
	. else  set $EXTRACT(x,locat1-1,locat1-1)="#TEST-E-FAIL#exp:"_exp_"actual:->"
	else  do
	. ; mask off allocation, since we did not specify anything, hence
	. ; don't expect anything particular
	. set $EXTRACT(x,locat1,locat2-2)="XXX"
	quit
