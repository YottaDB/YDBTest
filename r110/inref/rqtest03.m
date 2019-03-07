;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; See u_inref/rqtest03.csh for purpose of test. Also see reference file outref/rqtest03.txt for a better picture.
;
rqtest03;
	set x="" for i="0","","a" for j="0","","a" for k="0","","a" set x(i,j,k)=""
	set y="x"
	set $etrap="write $zstatus,! zwrite  halt"
	for  set nexty=$query(@y,1) set query(y)=nexty,expect(nexty)=y quit:nexty=""  set y=nexty
	set y="x(""zz"")"
	set expect(y)=expect("")
	set expect("x")=""
	;
	set nullcoll=$select($$getncol^%LCLCOL=1:"STDNULLCOLL",1:"GTMNULLCOLL")
	write !,"##### Executing ",$text(+0)," with ",nullcoll," #####",!
	for  set prevy=$query(@y,-1) do  set y=prevy  quit:y=""
	. write "nullcoll = ",nullcoll," : $query(",y,"),-1)=",prevy,!
	. set prevquery(y)=prevy
	. if prevy'=expect(y)  write "TEST-E-FAIL : $query(",y,",-1) : Actual = ",prevy," : Expected = ",expect(y),!  zwrite  halt
	quit
