;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1248 : every spelling of the ZBFSIZE deviceparameter down to the two character ZB is meant to
; be accepted, which is the minimum abbreviation "deviceparameters.c" records for it. Each spelling
; shorter than the full name was rejected instead, so "abbrev" below opens a SOCKET device with each
; of them in turn and "value" checks that the shortest one reaches the deviceparameter the longest
; one does.
;
abbrev	; OPEN a SOCKET device with each spelling of ZBFSIZE
	new abbr,bad,dev,err
	set bad=0
	for abbr="ZB","ZBF","ZBFS","ZBFSI","ZBFSIZ","ZBFSIZE" do
	. set err="",dev="sock"_$zconvert(abbr,"L")
	. do try(dev,abbr,.err)
	. if ""=err  write abbr," : accepted",!  close dev  quit
	. set bad=bad+1
	. write abbr," : rejected with ",err,!
	if 'bad  write "PASS : all six spellings of ZBFSIZE were accepted",!
	else  write "FAIL : ",bad," of the six spellings of ZBFSIZE were rejected",!
	quit
	;
try(dev,abbr,err)	; OPEN dev with "<abbr>=1024", leaving the error mnemonic in err
	new $etrap
	set $etrap="set err=$piece($piece($zstatus,"","",3),""-"",3) set $ecode="""" quit"
	xecute "open """_dev_""":("_abbr_"=1024):0:""SOCKET"""
	quit
	;
value	; the shortest spelling must reach the deviceparameter the longest one does
	new d,err,i,inside,line,zb
	set err=""
	do tryl("sockzb","ZB",.err)
	if ""'=err  write "FAIL : an OPEN with zb=2048 was rejected with ",err,!  quit
	use "sockzb" zshow "D":d
	use $principal
	; ZBFSIZE is reported for each socket of a device, not for the device, so read only the lines
	; between the one naming this device and the one naming the next. A device OPENed without a
	; socket has no ZBFSIZE line at all, and $PRINCIPAL is itself a SOCKET device on some systems,
	; carrying the default ZBFSIZE of 1024 that an unscoped search would find instead.
	set zb="",inside=0
	for i=1:1:64 quit:'$data(d("D",i))  do
	. set line=d("D",i)
	. if " "'=$extract(line,1),$char(9)'=$extract(line,1) set inside=("sockzb"=$piece(line," ",1)) quit
	. if inside,line["ZBFSIZE=" set zb=+$piece($piece(line,"ZBFSIZE=",2)," ",1)
	close "sockzb"
	if 2048=zb  write "PASS : an OPEN with zb=2048 set ZBFSIZE to 2048 on the socket it created",!  quit
	write "FAIL : the socket of a device OPENed with zb=2048 reports ZBFSIZE=",zb,", where 2048 was expected",!
	for i=1:1:64 quit:'$data(d("D",i))  write "  ZSHOW D : ",d("D",i),!
	quit
	;
tryl(dev,abbr,err)	; OPEN dev with "<abbr>=2048" and a listening socket, so the value can be read back
	new $etrap
	set $etrap="set err=$piece($piece($zstatus,"","",3),""-"",3) set $ecode="""" quit"
	xecute "open """_dev_""":("_abbr_"=2048:listen=""0:TCP"":attach=""srv""):0:""SOCKET"""
	quit
