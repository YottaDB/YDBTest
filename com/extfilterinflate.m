;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2006, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; External filter to inflate node value by $ztrnlnm("gtm_tst_ext_filter_spaces") # of spaces
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
	; keep width at maximum and set nowrap so we dont incorrectly split long lines (with newlines) while reading
	use $p:(width=(2**20):nowrap)
	set spaces=+$ztrnlnm("gtm_tst_ext_filter_spaces")
	for  do
	. read extrRec
	. if $zeof halt
	. set rectype=$zpiece(extrRec,"\",1)
	. set modify=(rectype=SET)
	. if 'modify do echoback(extrRec,log) quit
	. set delim="="""	; =" occurs just before the value part of the SET
	. ; if delimiter occurs more than once in extract string, it is complicated to figure out where exactly the
	. ; value part of the SET record starts and so skip inflation in that case. If delimiter occurs only once
	. ; then we are guaranteed no confusion. Only then do the inflation.
	. if $zlength(extrRec,delim)'=2 do echoback(extrRec,log) quit
	. ; In some cases, the value part of the SET might be a binary stream of data i.e. $c(0,1,2) in which case it
	. ; wont start with a " like we normally expect it to. In that case, doing the inflation is not easy so we
	. ; skip inflation in that case too. To test that we check if = occurs only ONCE. If not we skip inflation.
	. if $zlength(extrRec,"=")'=2 do echoback(extrRec,log) quit
	. set piece1=$zpiece(extrRec,delim,1)
	. set middle=$justify(" ",spaces),middle=$translate(middle," ","-")
	. set piece2=$zpiece(extrRec,delim,2,100)
	. set filtrOut=piece1_delim_middle_piece2
	. write filtrOut,!
	. use log write filtrOut,! use $p
	quit

echoback(str,log)
	write str,!  use log write str,! use $p
	quit

err
	set $ztrap=""
	use log
	write !!!,"**** ERROR ENCOUNTERED ****",!!!
	zshow "*"
	halt
