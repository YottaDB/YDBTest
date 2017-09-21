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
; See u_inref/rqtest14.csh for purpose of test. Also see reference file outref/rqtest14.txt for a better picture.
;
rqtest14;
	set dir=+$piece($zcmdline," ",1),dir1="dir",dir2="@dir1"
	set z(1)=1,z(2)=2,z(3)=3,x="@y"
	set ^z(1)=1,^z(2)=2,^z(3)=3,x="@y"
	for y="z(2)","^z(2)" do
	. for dir=1,-1 do
	. . write "set x="_$zwrite(x)_",y="_$zwrite(y)_",dir="_$zwrite(dir)_" : $query(@x,dir)=",$query(@x,@dir2),!
	quit
