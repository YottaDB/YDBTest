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
; See u_inref/rqtest02.csh for purpose of test. Also see reference file outref/rqtest02.txt for a better picture.
;
rqtest02 ;
	set x=0
	set x(1,0)=1
	set x(1,2,1)=2,x(1,2,2)=3,x(1,2,3)=4
	set x(1,2,2,4)=5
	write " --> Local variable tree on which $query operations are performed",!
	zwrite x
	set prev="x"
	write !," ---> $query(lvn,1) and $query(lvn,-1) on existing lv tree nodes",!
	for  set next=$query(@prev,1) quit:next=""  do  set prev=next
	. set revquery=$query(@next,-1)
	. if revquery'=prev  write "TEST-E-FAIL",! zwrite  halt
	. write "$query(",prev,",1)=",next,!
	. write "$query(",next,",-1)=",revquery,!
	write "$query(",prev,",1)=",next,!
	;
	set input($incr(i))="x(-0.5)"
	set input($incr(i))="x(0.5)"
	set input($incr(i))="x(1.5)"
	set input($incr(i))="x(1,-1)"
	set input($incr(i))="x(1,0.5)"
	set input($incr(i))="x(1,2.5)"
	set input($incr(i))="x(1,2,0.5)"
	set input($incr(i))="x(1,2,1.5)"
	set input($incr(i))="x(1,2,2.5)"
	set input($incr(i))="x(1,2,3.5)"
	set input($incr(i))="x(1,2,2,3.5)"
	set input($incr(i))="x(1,2,2,4.5)"
	write !," ---> $query(lvn,1) on non-existing lv tree nodes",!
	for j=1:1:i  do
	. set forwquery=$query(@input(j),1)
	. write "$query(",input(j),",1)=",forwquery,!
	write !," ---> $query(lvn,-1) on non-existing lv tree nodes",!
	for j=1:1:i  do
	. set revquery=$query(@input(j),-1)
	. write "$query(",input(j),",-1)=",revquery,!
	quit
