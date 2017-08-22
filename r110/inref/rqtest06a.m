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
rqtest06a;
	set querydir=+$zcmdline
	set y=4,x(1)="",x(3)="",x(5)="",x(7)=""
	if $get(^x(2))
	write "$query(x(y),$$I())=",$select($random(2):$query(x(y),$$I()),1:$query(@"x(y)",$$I())),!
	write "$reference=",$reference,!
	quit
I()	;
	quit querydir
