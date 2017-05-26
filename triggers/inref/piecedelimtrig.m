;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2010-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
piecedelimtrig
	new i,p,ztname,delim,x
	set delim=$ZTDElim
	set ztname=$ZTName,$piece(ztname,"#",$length(ztname,"#"))=""  ; nullify region disambigurator
	set x=$increment(^fired(ztname))
	for i=1:1:$length($ZTUPdate,",") do
	.	set p=$piece($ZTUPdate,",",i)
	.	if $piece($ZTVA,delim,p)=$piece($ZTOL,delim,p) write "MISMATCH",x,! set ^fail=1
	; increment the first piece only for the "first" trigger, this does cause
	; problems for trigger execution order, but we can filter out the difference
	if ztname="allrange#" do
	.	set y=$ZTVAlue
	.	set $piece(y,delim,1)=1+$piece(y,delim,1)
	.	set $ZTVAlue=y
	set ^fired(ztname,x,"$ZTUP")=$ZTUPdate
	set ^fired(ztname,x,"$ZTVA")=$ZTVAlue
	set ^fired(ztname,x,"$ZTOL")=$ZTOLdvalue
	set ^fired(ztname,x,"zzzzz")=$translate($justify("",32)," ","=")
	quit
