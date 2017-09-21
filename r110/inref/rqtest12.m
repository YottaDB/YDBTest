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
; See u_inref/rqtest12.csh for purpose of test. Also see reference file outref/rqtest12.txt for a better picture.
;
rqtest12;
	set querydir=+$piece($zcmdline," ",1)
	if querydir=1 do
	. set y="^x" for  set nexty=$query(@y,1) write "$query(",y,",",querydir,")=",nexty,!  quit:nexty=""  set y=nexty
	else  do
	. set y="^x(""z"")" for  set prevy=$query(@y,querydir) write "$query(",y,",",querydir,")=",prevy,!  set y=prevy  quit:y=""
        quit
init	;
	new i,j
	set val1=1,val2=$j(1,4096)	; randomly choose spanning 
	set node($incr(i))="^x"
	set node($incr(i))="^x(1)"
	set node($incr(i))="^x(1,2)"
	set node($incr(i))="^x(1,2,3)"
	set node($incr(i))="^x(1,2,3,"""")"
	set node($incr(i))="^x(1,2,3,"""","""")"
	set node($incr(i))="^x(1,2,3,"""","""","""")"
	set node($incr(i))="^x(1,2,3,7)"
	for j=1:1:i do set(node(j))
	quit

set(str);
	set val=$select($random(2):val1,1:val2)
	set @str=val
	quit
