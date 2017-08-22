;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rqtest10;
	set stdnullcoll=$piece($zcmdline," ",1)
	set nullcoll=$select(stdnullcoll="true":"STDNULLCOLL",1:"GTMNULLCOLL")
	set ^x="" for i="0","","a" for j="0","","a" for k="0","","a" set ^x(i,j,k)=""
	set y="^x"
	set $etrap="write $zstatus,! zwrite  halt"
	for  set nexty=$query(@y,1) set query(y)=nexty,expect(nexty)=y quit:nexty=""  set y=nexty
	set y="^x(""zz"")"
	set expect(y)=expect("")
	set expect("^x")=""
	;
	write !,"##### Executing ",$text(+0)," with ",nullcoll," #####",!
	for  set prevy=$query(@y,-1) do  set y=prevy  quit:y=""
	. write "nullcoll = ",nullcoll," : $query(",y,"),-1)=",prevy,!
	. set prevquery(y)=prevy
	. if prevy'=expect(y)  write "TEST-E-FAIL : $query(",y,",-1) : Actual = ",prevy," : Expected = ",expect(y),!  zwrite  halt
	kill ^x
	quit
