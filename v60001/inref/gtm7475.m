;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7475	;test of $zwrite() function
	;
	New (act)
	if '$Data(act) New act Set act="write !,$zstatus zshow ""sv"""
	new $etrap,$estack
	set $ecode="",$etrap="do ^incretrap"
	do nogbls^incretrap
	set indira="a",f=1,indirf="f",indirt="t",t=0
	for a="a",12,$c(1,2),$c(1,65,2),$c(1,65,2,66),$c(67,1,65,2,66) zshow "v":d do
	. if $zwrite(a)'=$p(d("V",1),"=",2,999),$increment(cnt) xecute act
	. if $zwrite(@indira)'=$p(d("V",1),"=",2,999),$increment(cnt) xecute act
	. if $zwrite($zwrite(a,0),1)'=a,$increment(cnt) xecute act
	. if $zwrite($zwrite(a,t),f)'=a,$increment(cnt) xecute act
	. set x=$zwrite(@indira,@indirt)
	. set x=$zwrite(x,'@indirt)
	. if x'=a,$increment(cnt) xecute act
	if ""'=$zwrite("1_$C13",1),$increment(cnt) xecute act	; expect an empty string from malformed argument
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
	quit
