;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2002-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test31	;
	; Test that if total length of ecodes becomes > 32K, as many ecodes are deleted to accommodate the latest one
	; this is a CPU intensive program that prints only the interesting portions of $ECODE
x       ;
        set num=12
        set incr=-1
        set count=0
        set $ztrap="do ztr"
        do sety
        ; at this point y will be a 1024 byte string.
        set $ecode=y_","
        quit
ztr     ;
        write !,"$l($ecode) = ",$l($ecode),!
        ;write "$ecode = ",$ecode,!
        do ecprint
        set count=count+1
        if count>35 set $ztrap="goto ztr"
        do sety
        ; at this point y will be a 1024 byte string.
        quit
sety    ;
        s y=",M"_(10+count)
        f i=1:1:num s y=y_y
        set num=num+incr
        if num=0 set num=1,incr=1
        if incr=1&(num=8) set incr=-1
        quit
ecprint ;
        new x,y,l,count,curlength,start,done
        set y=$ecode
        set l=$length(y,",")
        set curlength=0
        set start=1
        for  quit:start>l  do
        .       s x=$piece(y,",",start)
        .       s count=1,done=0
        .       for i=start+1:1:l quit:done=1  do
        .       .       if $piece(y,",",i)=x s count=count+1
        .       .       else  set done=1
        .       set curlength=curlength+(($length(x)+1)*count)
        .       ;write """"_x_","_""" ["_curlength_"] "
        .       write """"_x_","_""" "
        .       set start=start+count
        quit
