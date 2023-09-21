;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; zshowgfilter provides a way to mask out or keep in specific codes from ZSHOW "G" output.
; the original expected zshvar to be a name used @zshvar@() syntax so it directly handed globals for the first argument
; this expects zshvar to be a local passed by reference, so globals have first to be merged to a clean local
;
out(zshvar,str)
	; Input:
	; zshvar : should contain ZSHOW "G" output redirected to a local or global variable.
	; str : should be one or more items in a list of the form "ggg:[,...]" where ggg is a gvstat code.
	;
	; Output:
	; Has any <ggg:nn> where nn is an arbitrary decimal number occurs in zshvar("G",*) replaced nn with literal XX, e.g. ggg:XX
	;
	; Example:
	; zshvar("G",0) contains "SET:1120,KIL:1300,GET:12,..."
	; If <str> is "KIL:", then zshvar("G",0) is modified to contain "SET:1120,KIL:XX,GET:12,..."
	;
	new gcode,i,outstr,piece1,piece2,subs,vname
	set subs=""
	for  set subs=$order(zshvar("G",subs))  quit:""=subs  do  set zshvar("G",subs)=outstr
	. set outstr=zshvar("G",subs)
	. quit:""=outstr		; if empty input string don't filter as ZSHOW "G" produces empty lines for GT.CM regions
	. for i=1:1:$length(str,",") do						; otherwise strip the values from the gcodes in str
	.. set gcode=$$FUNC^%UCASE($piece(str,",",i))_":"
	.. set piece1=$piece(outstr,gcode)
	.. if outstr=piece1 write gcode," is invalid" zshow "v" quit
	.. set piece2=$piece($piece(outstr,gcode,2),",",2,99999)
	.. set outstr=piece1_gcode_"XX"_$select(""=piece2:"",1:",")_piece2	; Do not append comma when filtering last gvstat
	quit
in(zshvar,str)
	; Input:
	; zshvar : should contain ZSHOW "G" output redirected to a local or global variable.
	; str : should be one or more items in a list of the form "ggg:[,...]" where ggg is a gvstat code.
	;
	; Output:
	; retains zshvar as an array of comma delimited lists consisting of only the representations corresponding to the codes in str
	;
	; Example:
	; zshvar("G",0) contains "SET:1120,KIL:1300,GET:12,..."
	; If <str> is "SET:,KIL:", then tzshvar("G",0) is modified to contain contain "SET:1120,KIL:1300"
	;
	new gcode,i,instr,outstr,p,subs
	set subs=""
	for  set subs=$order(zshvar("G",subs))  quit:""=subs  do  set zshvar("G",subs)=outstr
	. set instr=zshvar("G",subs),outstr=""
	. for i=1:1:$length(str,",") do
	.. set gcode=$$FUNC^%UCASE($piece(str,",",i))_":",p=$find(instr,gcode)
	.. if 'p write:$zversion'["VMS" !,gcode," is invalid" zshow "v" quit  ;skip write on VMS as it doesn't have all
	.. set outstr=outstr_$select(1=i:"",1:",")_gcode_$piece($extract(instr,p,9999),",")
	quit
