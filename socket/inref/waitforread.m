;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2008-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitforread;
	set h1=$h,read=0,timedout=0,maxtime=120,j=0
	View "NOUNDEF"
        f  quit:(read=1)!(timedout=1)  do
        .       set j=j+1
        .       if ((^dataread(4)=1)&(^dataread(5)=1)) s read=1
        .       if (j#100=0) do
        .       .       set h2=$h
        .       .       set dif=$$^difftime(h2,h1)
        .       .       if dif>maxtime set timedout=1
	View "UNDEF"
	if (timedout=1) w "Client did not end reading the data after "_maxtime_" sec at: "_$h
	q
clientdone(maxtime);
	set h1=$h,done=0,timedout=0,j=0
	f  quit:(done=1)!(timedout=1)  do
	.       set j=j+1
	.       if ($d(^client2done)) s done=1
	.       if (j#100=0) do
	.       .       set h2=$h
	.       .       set dif=$$^difftime(h2,h1)
	.       .       if dif>maxtime set timedout=1
	if (timedout=1) w "Client did not exit after "_maxtime_" sec at: "_$h
	q
