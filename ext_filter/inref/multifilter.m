multifilter
 	; External filter to do the following very directed changes
	; Wrapped and non-wrapped mods can be overlapped in any order, but the sequence of each must match the order in 
	; nonwrappedop() and wrappedop()
	; NON-WRAPPED operations:
	; WRAP2 - changes non-wrapped transaction into a wrapped transaction with 2 sets ^Aa=2 and ^Bb=3
	;         both TSTART and TCOMMIT are valid
 	; MAKENULL - replaces non-wrapped set ^abc="1234" with null with same journal seqno
	; MAKENULL0 - replaces non-wrapped set ^abc2="1234" with null with zero journal seqno to make sure it 
	;             is modified correctly
	; MAKENULL1 - replaces non-wrapped transaction with 08_EOL_09_EOL to show old filter delete method still works
	; NOCHANGE - passed non-wrapped transaction as is
	; WRAPIT - passes non-wrapped transaction 08_EOL_transaction_EOL_09_EOL to show old filter method still works
	; MODSCHEMA - replaces next non-wrapped "set ^aaa=5555" with "set ^aaa=A|B|C"
 	; 
	; WRAPPED operations:
	; CHANGE2 - assume wrapped transaction 08,^def=3456,^ghi=4567,09 
	;           delete the set ^def=3456 and changes second set to ^dd="2"
	; MAKENULL - replaces wrapped transaction with null transaction with same journal seqno
	; MAKENULL0 - replace next wrapped transaction with null transaction with zero journal seqno to make sure it
	;             is modified correctly
	; NOCHANGE2 - pass wrapped transaction as is
	; GOBBLETP - replace wrapped transaction with 08_EOL_09_EOL.
	; GOBBLETP2 - replace wrapped transaction with <tstart>_EOL_<tcommit>_EOL with original seqno
	; ADD1 - add a second line ^de="2" to the wrapped transaction
	; NULLSINTR - change 1st and 3rd entries in a transaction to nulls
 	; 
	; jcnt will be the current journal seqno
	set maxwrappedopcnt=9
	set maxnonwrappedopcnt=9
	set nonwrappedop(1)="WRAP2"
	set nonwrappedop(2)="MAKENULL"
	set nonwrappedop(3)="MAKENULL0"
	set nonwrappedop(4)="MAKENULL1"
	set nonwrappedop(5)="NOCHANGE"
	set nonwrappedop(6)="WRAPIT"
	set nonwrappedop(7)="MODSCHEMA"
	set nonwrappedop(8)="NOCHANGE"
	set nonwrappedop(9)="NOCHANGE"
	set wrappedop(1)="CHANGE2"
	set wrappedop(2)="MAKENULL"
	set wrappedop(3)="MAKENULL0"
	set wrappedop(4)="GOBBLETP"
	set wrappedop(5)="NOCHANGE2"
	set wrappedop(6)="GOBBLETP"
	set wrappedop(7)="GOBBLETP2"
	set wrappedop(8)="ADD1"
	set wrappedop(9)="NULLSINTR"
	set $ztrap="goto err"
	set TSTART="08"
	set TCOMMIT="09"
	set EOT="99"
	set NULL="00\0,0\1\0\0\"
	set nonwrappedcnt=1
	set wrappedcnt=1
	set jcnt=0
	set log=$ztrnlnm("filterlog")	; use environment variable "filterlog" (if defined) to indicate which logfile to use
	if log="" set log="log.extout"
	if $zv["VMS" set EOL=$C(13)_$C(10)
	else  set EOL=$C(10)
	open log:newversion
	use $p:(nowrap)
	for  do
	. set filtrOut=""
	. set linecnt=1
	. set jcnt=jcnt+1
	. use $p
	. read extrRec(1)
	. if $zeof halt
	. set rectype=$p(extrRec(1),"\",1)
	. if rectype'=EOT do
	.. if rectype'=TSTART  do 
	... do Process(nonwrappedop(nonwrappedcnt),extrRec(1),.filtrOut)
	... if nonwrappedcnt'=maxnonwrappedopcnt set nonwrappedcnt=nonwrappedcnt+1
	.. else  do
	... set linecnt=$$readtrans(.extrRec)
	... do Process(wrappedop(wrappedcnt),.extrRec,.filtrOut)
	... if wrappedcnt'=maxwrappedopcnt set wrappedcnt=wrappedcnt+1
	.. ; set $x=0 is needed so every write starts at beginning of record position
	.. ; don't write more than "width" characters in one output operation to avoid "chopping" of output 
	.. ; and/or eol in the middle of output stream
	.. ; default width=32K-1 
	.. ; use $zsubstr to chop at valid character boundary (single or multi byte character)
	.. set cntr=0,tmp=filtrOut
	.. for  quit:tmp=""  do
	... set cntr=cntr+1,$x=0,record(cntr)=$zsubstr(tmp,1,32767),tmp=$ze(tmp,$zl(record(cntr))+1,$zl(tmp))
	... write record(cntr)
	. use log
	. write "Received: ",EOL
	. for i=1:1:linecnt write extrRec(i)_EOL
	. if rectype'=EOT write "Sent: ",EOL,filtrOut
	. else  write "EOT received, halting..." halt
	quit

err
	set $ztrap=""
	use log
	write !!!,"**** ERROR ENCOUNTERED ****",!!!
	zshow "*"
	halt


; after we received a TSTART this is called to read in the rest of the lines.  It returns the total including the TSTART
readtrans(in)
	set lcnt=2
	for  read in(lcnt) q:$e(in(lcnt),1,2)=TCOMMIT  set lcnt=lcnt+1
	if $zeof halt
	quit lcnt

; process the wrapped or non-wrapped transaction in extrRec() with the output returned in filterout after performing an operation
Process(operation,extr,filterout)
	goto @operation

MAKENULL
	set filterout=NULL_jcnt_EOL
	quit
MAKENULL0
	set filterout=NULL_"0"_EOL
	quit
MAKENULL1
	set filterout=TSTART_EOL_TCOMMIT_EOL
	quit
MODSCHEMA
	set filterout=$extract(extr,1,$find(extr,"=")-1)_"""A|B|C"""_EOL
	quit
NOCHANGE
	set filterout=extr_EOL
	quit
WRAP2
	set caretoffset=$find(extr,"^")-1
	set filterout="08"_$extract(extr,3,caretoffset-6)_EOL
    	set filterout=filterout_$extract(extr,1,caretoffset-6)_"\1\0\^Aa="_"""2"""_EOL
    	set filterout=filterout_$extract(extr,1,caretoffset-6)_"\2\0\^Bb="_"""3"""_EOL
	set filterout=filterout_"09"_$extract(extr,3,caretoffset-3)_EOL
	quit
WRAPIT
	set filterout=TSTART_EOL_extr_EOL_TCOMMIT_EOL
	quit
ADD1
	if (3'=linecnt) use log write !!!,"**** ERROR Wrong number of lines in ADD1 transaction ****",!!! zshow "*" halt
	set filterout=filterout_extr(1)_EOL
	set filterout=filterout_$extract(extr(2),1,$find(extr(2),"^")-1)_"df="_"""2"""_EOL
	set filterout=filterout_$extract(extr(2),1,$find(extr(2),"^")-1)_"de="_"""2"""_EOL
	set filterout=filterout_extr(3)_EOL
	quit
CHANGE2
	if (4'=linecnt) use log write !!!,"**** ERROR Wrong number of lines in CHANGE2 transaction ****",!!! zshow "*" halt
	set filterout=filterout_extr(1)_EOL
	set filterout=filterout_$extract(extr(3),1,$find(extr(3),"^")-1)_"dd="_"""2"""_EOL
	set filterout=filterout_extr(4)_EOL
	quit
NOCHANGE2
	for i=1:1:linecnt set filterout=filterout_extr(i)_EOL
	quit
GOBBLETP
	if (3'=linecnt) use log write !!!,"**** ERROR Wrong number of lines in GOBBLETP transaction ****",!!! zshow "*" halt
	set filterout=TSTART_EOL_TCOMMIT_EOL
	quit
GOBBLETP2
	if (3'=linecnt) use log write !!!,"**** ERROR Wrong number of lines in GOBBLETP2 transaction ****",!!! zshow "*" halt
	set filterout=filterout_extr(1)_EOL
	set filterout=filterout_extr(3)_EOL
	quit
NULLSINTR
	if (5'=linecnt) use log write !!!,"**** ERROR Wrong number of lines in NULLSINTR transaction ****",!!! zshow "*" halt
	set filterout=filterout_extr(1)_EOL
	set filterout=filterout_NULL_jcnt_EOL
	set filterout=filterout_extr(3)_EOL
	set filterout=filterout_NULL_jcnt_EOL
	set filterout=filterout_extr(5)_EOL
	quit
