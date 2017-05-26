badconv4
 	; External filter to do the following very directed changes
	; nochange to first nonwrapped transaction
 	; replace next nonwrapped transaction with dummy wrapped transaction with 2 sets - must be a valid wrapper
	; copied from multifilter.m but no wrapped transactions will be received
	set maxnonwrappedopcnt=2
	set maxwrappedopcnt=1
	set nonwrappedop(1)="NOCHANGE"
	set nonwrappedop(2)="BADWRAP2"
	set wrappedop(1)="NOCHANGE2"
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
BADWRAP2
	; Below is the format of the SET extract record
	; SET 05\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node=sarg
	;
	set filterout="08"_EOL
	set filterout=filterout_"05\0,0\2\0\0\2\0\0\1\0\^a="_"""2"""_EOL
	set filterout=filterout_"05\0,0\2\0\0\2\0\0\2\0\^b="_"""3"""_EOL
	set filterout=filterout_"09"_EOL
	quit

; process the wrapped transaction in extrRec() with the output returned in filterout after performing an operation
ProcessTp(operation,extr,filterout)
	goto @operation
NOCHANGE2
	for i=1:1:linecnt set filterout=filterout_extr(i)_EOL
	quit
