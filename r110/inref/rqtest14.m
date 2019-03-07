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
; See u_inref/rqtest14.csh for purpose of test. Also see reference file outref/rqtest14.txt for a better picture.
;
rqtest14;
	set dir=+$piece($zcmdline," ",1),dir1="dir",dir2="@dir1"
	for y="z(2)","^z(2)" do
	. ; Test cases where direction is -1 or 1 or variable (potentially with indirection)
	. if y="z(2)" set xstr="set z(1)=1,z(2)=2,z(3)=3,x=""@y"""
	. if y="^z(2)" set xstr="set ^z(1)=1,^z(2)=2,^z(3)=3,x=""@y"""
	. write xstr,! xecute xstr
	. write "set y="_$zwrite(y)_" : $query(@x,-1)=",$query(@x,-1),!
	. write "set y="_$zwrite(y)_" : $query(@x,1)=",$query(@x,1),!
	. for dir=-1,1 do
	. . write "set y="_$zwrite(y)_",dir="_$zwrite(dir)_",dir1="_$zwrite(dir1)_",dir2="_$zwrite(dir2)_" : $query(@x,@dir1)=",$query(@x,@dir1),!
	. . write "set y="_$zwrite(y)_",dir="_$zwrite(dir)_",dir1="_$zwrite(dir1)_",dir2="_$zwrite(dir2)_" : $query(@x,@dir2)=",$query(@x,@dir2),!
	quit
