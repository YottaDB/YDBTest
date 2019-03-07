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
; See u_inref/rqtest01.csh for purpose of test. Also see reference file outref/rqtest01.txt for a better picture.
;
rqtest01	;
	set num=+$piece($zcmdline," ",1)
	set querydir=+$piece($zcmdline," ",2)
	if num=0 set sub2="",sub3=""
	if num=1 set sub2="",sub3="3"
	if num=2 set sub2="2",sub3=""
	if num=3 set sub2="2",sub3="3"
	set nullcoll=$select($$getncol^%LCLCOL=1:"STDNULLCOLL",1:"GTMNULLCOLL")
	write !,"##### Executing ",$text(+0)," : querydir=",querydir," : num=",num," : nullcoll=",nullcoll," #####",!
	set $etrap="write !,$zstatus,!  halt"
	set x(0)=1,x(1,4)=5,x(10)=1
	for nullsubs="LVNULLSUBS","NOLVNULLSUBS","NEVERLVNULLSUBS" do
	. view nullsubs
	. write "nullcoll = ",nullcoll," : nullsubs = ",$j(nullsubs,15)," : $query(x(1,",$zwrite(sub2),",",$zwrite(sub3),"),",querydir,")="
	. set y=$select($random(2):$query(x(1,sub2,sub3),querydir),1:$query(@"x(1,sub2,sub3)",querydir))
	. write y,!
	quit
