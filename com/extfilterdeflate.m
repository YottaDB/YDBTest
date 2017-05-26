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
	; External filter to deflate node value by $ztrnlnm("gtm_tst_ext_filter_spaces") # of spaces
	set $ztrap="goto err"
	set TSTART="08"
	set TCOMMIT="09"
	set SET="05"
	set KILL="04"
	set ZKILL="10"
	set EOT="99"
	set log=$ztrnlnm("filterlog")	; use environment variable "filterlog" (if defined) to indicate which logfile to use
	if log="" set log="log.extout"
	if $zv["VMS" set EOL=$C(13)_$C(10)
	else  set EOL=$C(10)
	open log:(newversion:stream:nowrap)
	; keep width at maximum and set nowrap so we dont incorrectly split long lines (with newlines) while writing
	use $p:(width=(2**20):nowrap)
	set spaces=+$ztrnlnm("gtm_tst_ext_filter_spaces")
	for  do
	. read extrRec
	. if $zeof halt
	. set rectype=$zpiece(extrRec,"\",1)
	. set modify=(rectype=SET)
	. if 'modify do echoback(extrRec,log) quit
	. set delim="="""	; =" occurs just before the value part of the SET
	. ; if delimiter occurs more than once in extract string, extfilterinflate.m would have skipped inflation
	. ; so skip deflation too in that case.
	. if $zlength(extrRec,delim)'=2 do echoback(extrRec,log) quit
	. if $zlength(extrRec,"=")'=2 do echoback(extrRec,log) quit	 ; see extfilterinflate.m comment for why we do this
	. set middle=$justify(" ",spaces),middle=$translate(middle," ","-")
	. set piece1=$zpiece(extrRec,delim_middle,1)
	. if piece1=extrRec do echoback(extrRec,log) quit
	. set piece2=$zpiece(extrRec,delim_middle,2,100)
	. set filtrOut=piece1_delim_piece2
	. write filtrOut,!
	. use log write filtrOut,! use $p
	quit

echoback(str,log)
	write str,! use log write str,! use $p
	quit

err
	set $ztrap=""
	use log
	write !!!,"**** ERROR ENCOUNTERED ****",!!!
	zshow "*"
	halt
