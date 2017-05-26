;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2006, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; External filter, simplistic echo back filter
	set $ztrap="goto err"
	set TSTART="08"
	set TCOMMIT="09"
	set EOT="99"
	set log=$ztrnlnm("filterlog")	; use environment variable "filterlog" (if defined) to indicate which logfile to use
	if log="" set log="log.extout"
	if $zv["VMS" set EOL=$C(13)_$C(10)
	else  set EOL=$C(10)
	open log:newversion
	use $p:(nowrap)
	for  do
	. use $p
	. set preReadTime=$Horolog
	. read extrRec
	. set postReadTime=$Horolog
	. if $zeof halt
	. set rectype=$p(extrRec,"\",1)
	. if rectype'=EOT do
	.. if rectype'=TSTART set filtrOut=extrRec_EOL
	.. else  do
	... set filtrOut=extrRec_EOL
	... for  read extrRec set filtrOut=filtrOut_extrRec_EOL quit:$ze(extrRec,1,2)=TCOMMIT
	... if $zeof halt
	.. ; set $x=0 is needed so every write starts at beginning of record position
	.. ; don't write more than "width" characters in one output operation to avoid "chopping" of output
	.. ; and/or eol in the middle of output stream
	.. ; default width=32K-1
	.. ; use $zsubstr to chop at valid character boundary (single or multi byte character)
	.. set cntr=0,tmp=filtrOut
	.. for  quit:tmp=""  do
	... set cntr=cntr+1,$x=0,record(cntr)=$zsubstr(tmp,1,32767),tmp=$ze(tmp,$zl(record(cntr))+1,$zl(tmp))
	... set preWriteTime=$Horolog
	... write record(cntr)
	... set postWriteTime=$Horolog
	. use log
	. write "Received: ",EOL,$s(rectype'=TSTART:extrRec_EOL,1:filtrOut)
	. if rectype'=EOT write "Sent: ",EOL,filtrOut
	. else  write "EOT received, halting..." halt
	quit

err
	set $ztrap=""
	use log
	write !!!,"**** ERROR ENCOUNTERED ****",!!!
	zshow "*"
	halt
