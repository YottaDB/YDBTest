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
lotsvar ;
	; create/verify/kill/etc. a lot of names that are of length: [1,31]
	; will create of varying lengths, in a pseudo-random way (predetermined)
	;
	; For general use, (i.e. set some glvns), you can call as:
	; do set^lotsvar
	;
	; the kill and indir entrypoints are to test kill and indirection, respectively.
	;
	; to set locals only, disable globals by (i.e. will not set any globals):
	; set global=0
	;
	; same way, locals can be disabled by:
	; set local=0
	;
	; also allows for requesting one pseudo-random string (upto maxlen)
	; to call:
	; do init^lotsvar
	; do onevar^lotsvar(len,1) ; strnosub will be a string of length len upon return
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	new novars,setdone
	set novars=200
	write "do set^lotsvar",!
	do set
	write "do indir^lotsvar",!
	do indir
	write "do kill^lotsvar",!
	do kill
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set	; SET
	new act,cnt,inc,errcnt,characters,ncharacters,len,countvar,str,varc,firstcharacters,nfirstcharacters,maxerr
	do init
	set act="set"
	do loop
	write "LOTSVAR-I-END_SET",!
	set setdone=1
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ver	; VERIFY
	new act,cnt,inc,errcnt,characters,ncharacters,len,countvar,str,varc,firstcharacters,nfirstcharacters,maxerr
	do init
	set act="ver"
	do loop
	if 'errcnt write "LOTSVAR-I-OK",!
	write "LOTSVAR-I-END_VER",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
kill	; KILL
	new novars,act,cnt,inc,errcnt,characters,ncharacters,len,countvar,str,varc,firstcharacters,nfirstcharacters,maxerr
	set novars=60
	if '$DATA(setdone) do set
	set bkillf="before_kill.out"
	open bkillf:newversion
	use bkillf
	zwrite
	close bkillf
	use $PRINCIPAL
	do init
	set act="kill"
	do loop
	write "LOTSVAR-I-END_KILL",!
	set akillf="before_kill.out"
	open akillf:newversion
	use akillf
	zwrite
	close akillf
	use $PRINCIPAL
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
indir	; indirection
	new act,cnt,inc,errcnt,characters,ncharacters,len,countvar,str,varc,firstcharacters,nfirstcharacters,maxerr
	do init
	set act="indirection"
	do loop
	write "LOTSVAR-I-END_INDIR",!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init	; init is common to all entrypoints in this routine.
	set cnt=0
	set inc=9
	set unix=$ZVERSION'["VMS"
	; novars does not directly show how many variables there will be (as there are loops in
	; each iteration), but indirectly it does show the number of variables.
	if '$DATA(novars) set novars=60
	if '$DATA(maxlen) set maxlen=31 ; names of max length 31
	set countvar=0 ; total count of variables
	if '$DATA(local) set local=1
	if '$DATA(global) set global=1
	set maxerr=5
charinit ;
	set characters=""
	set ncharacters=0
	; M names can be XYYY<...upto 31 char total> where X=[%a-zA-Z], Y=[a-zA-Z0-9]
	for varc=0:1:25 set ncharacters=ncharacters+1,characters(ncharacters)=$CHAR(97+varc) ;[a-z]
	for varc=0:1:25 set ncharacters=ncharacters+1,characters(ncharacters)=$CHAR(65+varc) ;[A-Z]
	;
	merge firstcharacters=characters
	set nfirstcharacters=ncharacters
	;
	for varc=0:1:9 set ncharacters=ncharacters+1,characters(ncharacters)=varc ;[0-9]
	set nfirstcharacters=nfirstcharacters+1,firstcharacters(nfirstcharacters)="%"
	if '$DATA(act) set act=""
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop	;
	; this is the main loop, it will loop through the alphabet (in inc increments, which varies as well)
	; and create variable names of lengths 1 through maxlen (31).
	set errcnt=0
	for nvlotsvar=1:1:novars  do  quit:(errcnt>maxerr)
	. set inc=nvlotsvar*nvlotsvar
	. for len=1:1:(maxlen)  do onevar(len,0)
	. write:(maxerr'>errcnt) "too many errors...",!
	quit
onevar(len,looparg)	;
	; len shows which length a string it should generate,
	; looparg shows whether it should return one string only (1), or go on with the test (0)
	; looparg=1 can be used to generate pseudo-random strings for other uses.
	set str=""
	if 0=len set strnosub="" quit
	;there is also the first char added later, so this loop should be up to maxlen-1
	new firstch,secondch
	for vari=1:1:len-1  do
	. set cnt=((cnt+inc)#ncharacters)+1
	. set str=characters(cnt)_str	; [a-z]
	set firstch=firstcharacters(((cnt+inc)#nfirstcharacters)+1)
	set secondch=$select(len=1:"",1:characters(cnt))
	if ("%"=firstch)&("Y"=secondch) set firstch="A" ; if ^%Y.. change it to ^AY... as ^%Y is reserved for statsdbs
	set str=firstch_str
	set countvar=countvar+1
	set subsc=""""_str_""","_countvar
	set strnosub=str
	set strshort=$EXTRACT(str,1,8) ; to have shorter variables of different values
	if ((countvar#5)) set subsc="1,"""_str_""",2,"_countvar
	if ((countvar#13)) set str=str_"("_subsc_")",strshort=strshort_"("_subsc_")" ; make some vars: var(1,"var",2)="var(1,""var"",2)"
	if 1=looparg quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "set"=act  do
	. if local set @strshort=strshort,@str=str
	. if global set @("^"_strshort)="^"_strshort,@("^"_str)="^"_str
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "ver"=act  do
	. if local do exam(str) do exam(strshort)
	. if global do exam("^"_str) do exam("^"_strshort)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "kill"=act  do
	. if local kill @str
	. if global kill @("^"_str)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if "indirection"=act  do
	. if local  do
	.. set variableforindirection=@str
	.. ; create an lvn that has one more subscript
	.. if '$FIND(variableforindirection,")") set variableforindirection=variableforindirection_"(""indir"")"
	.. else  set variableforindirection=$EXTRACT(variableforindirection,1,$LENGTH(variableforindirection)-1)_",""indir"")"
	.. set cmd1="set "_variableforindirection_"=variableforindirection"
	.. set cmd2=variableforindirection_"=variableforindirection"
	.. if (countvar#2) xecute cmd1
	.. if '(countvar#2) set @cmd2
	.. do exam(variableforindirection)
	. if global  do
	.. set ^variableforindirection=@("^"_str)
	.. ; create a gvn that has one more subscript
	.. if '$FIND(^variableforindirection,")") set ^variableforindirection=^variableforindirection_"(""indir"")"
	.. else  set ^variableforindirection=$EXTRACT(^variableforindirection,1,$LENGTH(^variableforindirection)-1)_",""indir"")"
	.. set cmd1="set ^"_variableforindirection_"=^variableforindirection"
	.. set cmd2="^"_variableforindirection_"=^variableforindirection"
	.. if (countvar#2) xecute cmd1
	.. if '(countvar#2) set @cmd2
	.. do exam(^variableforindirection)
	..
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if errcnt write "LOTSVAR-E-ERRORS errcnt: ",errcnt,!
	quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
exam(item) ; EXAMINE if the value is correct
	set vard=$DATA(@item)
	if ('vard)!(10=vard) set errcnt=errcnt+1 write:(maxerr>errcnt) "LOTSVAR-E-UNDEF:",item,! quit
	else  if item'=@item set errcnt=errcnt+1 write:(maxerr>errcnt) "LOTSVAR-E-VAL:",item," vs ",@item,! quit
	if $NAME(@item)'=@item set errcnt=errcnt+1 write:(maxerr>errcnt) "LOTSVAR-E-NAME:",$NAME(@item)," vs ",@item,! quit
	; note that because the value was set to str, it uses the value of the unsubscripted
	; variable. So one error for one variable, might propagate as other errors.
	quit
