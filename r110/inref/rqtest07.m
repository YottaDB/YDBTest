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
; See u_inref/rqtest07.csh for purpose of test. Also see reference file outref/rqtest07.txt for a better picture.
;
rqtest07;
	set querydir=+$piece($zcmdline," ",1)
	set stdnullcoll=$piece($zcmdline," ",2)
	set nullcoll=$select(stdnullcoll="true":"STDNULLCOLL",1:"GTMNULLCOLL")
	write !,"##### Executing ",$text(+0)," : querydir=",querydir," : nullcoll=",nullcoll," #####",!
	do init
	if querydir=1 do
	. set y="^x" for  set nexty=$query(@y,1) write "$query(",y,",",querydir,")=",nexty,!  quit:nexty=""  set y=nexty
	else  do
	. set y="^x(""z"")" for  set prevy=$query(@y,querydir) write "$query(",y,",",querydir,")=",prevy,!  set y=prevy  quit:y=""
	kill ^x
	quit

init	;
	set ^x(1)=1,^x("")=2,^x("abcd")=3
	quit
