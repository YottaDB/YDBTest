badconv2
 	; External filter to do the following very directed changes
	; It's purpose is to show that no FILTERBADCONV error will result from the external filter changing the 
	; jnl_seqno and strm_seqno into bogus values and if the update numbers of a wrapped transaction are not increasing in value
	; NOCHANGE - passes first non-wrapped transaction as is
 	; BADSEQNO - change the jnl_seqno in next non-wrapped transaction to 3 (should be 2) and the strm_seqno to 5.
	;            The strm_seqno should be 2 if test_replic_suppl_type=2 and 0 otherwise.
	;            Also, change the set to a null transaction
	; NOCHANGE2 - pass wrapped transaction as is
 	; BADSEQNO2 - change the jnl_seqno in next wrapped transaction to 5 (should be 4) and the strm_seqno to 5.
	;             The strm_seqno should be 4 if test_replic_suppl_type=2 and 0 otherwise.
	;             The second set should have an update_num of 2 but it is changed to 0
	set maxnonwrappedopcnt=2
	set maxwrappedopcnt=2
	set nonwrappedop(1)="NOCHANGE"
	set nonwrappedop(2)="BADSEQNO"
	set wrappedop(1)="NOCHANGE2"
	set wrappedop(2)="BADSEQNO2"
	set $ztrap="goto err"
	set TSTART="08"
	set TCOMMIT="09"
	set EOT="99"
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
	... do ProcessNonTp(nonwrappedop(nonwrappedcnt),extrRec(1),.filtrOut)
	... if nonwrappedcnt'=maxnonwrappedopcnt set nonwrappedcnt=nonwrappedcnt+1
	.. else  do
	... set linecnt=$$readtrans(.extrRec)
	... do ProcessTp(wrappedop(wrappedcnt),.extrRec,.filtrOut)
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

; process the non-wrapped transaction in extrRec() with the output returned in filterout after performing an operation
ProcessNonTp(operation,extr,filterout)
	goto @operation
NOCHANGE
	set filterout=extr_EOL
	quit
BADSEQNO
	; Below is the format of the SET extract record
	; SET 05\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node=sarg
	; change set from:
	; 05\0,0\1073741825\0\0\2\0\0\0\0\^def="3456"
	; to:
	; 00\0,0\1073741825\0\0\3\0\5\0\0\
	set extr="00"_$extract(extr,"3",1000)
	set filterout=$piece(extr,"\",1,5)_"\3\"_$piece(extr,"\",7)_"\5\"_"0\"_$piece(extr,"\",10)_"\"_EOL
	quit

; process the wrapped transaction in extrRec() with the output returned in filterout after performing an operation
ProcessTp(operation,extr,filterout)
	goto @operation
NOCHANGE2
	for i=1:1:linecnt set filterout=filterout_extr(i)_EOL
	quit
BADSEQNO2
	if (4'=linecnt) use log write !!!,"**** ERROR Wrong number of lines in BADSEQNO2 transaction ****",!!! zshow "*" halt
	set filterout=filterout_extr(1)_EOL_extr(2)_EOL
	; change second set from:
	; 05\0,0\32771\0\0\4\0\4\2\0\^trjkl="4567"
	; into:
	; 05\0,0\32771\0\0\5\0\5\0\0\^trjkl="4567"
	set modified=$piece(extr(3),"\",1,5)_"\5\"_$piece(extr(3),"\",7)_"\5\"_"0\"_$piece(extr(3),"\",10)_"\"
	set modified=modified_$extract(extr(3),$find(extr(3),"^")-1,1000)
	set filterout=filterout_modified_EOL
	set filterout=filterout_extr(4)_EOL
	quit
