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
; See u_inref/rqtest05.csh for purpose of test. Also see reference file outref/rqtest05.txt for a better picture.
;
rqtest05;
	set querydir=+$piece($zcmdline," ",1)
	set nullcoll=$select($$getncol^%LCLCOL=1:"STDNULLCOLL",1:"GTMNULLCOLL")
	write !,"##### Executing ",$text(+0)," with ",nullcoll," #####",!
	set x(1)=1
	set x("")=2
	set x("abcd")=3
	set y="x("""")"
	for  set prevy=$query(@y,querydir) write "$query(",y,"),",querydir,")=",prevy,!  set y=prevy  quit:y=""
	quit
