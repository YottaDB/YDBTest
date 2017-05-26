;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test;
        new $ET
        ;SET $ZTRAP="GOTO errcont^errcont"
lab1;
        if cnt=1 set alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        if cnt=1 set wspace="!@#$%^&*(){}[]|\,./<>?`~;:"
        if cnt=1 set ialpha="mainv1"
        if cnt=2 set tstv1("alpha")=alpha
        if cnt=2 set tstv1("wspace")=wspace
        if cnt=3 set tstv1("digits")=digits
        if cnt=3 set tstv1("pi")=pi
        if cnt<3 set tlit1="This is a literal"
        if cnt<3 set tlit2="This is a literal"
        if cnt<3 set tlit3="This is a literal"
        merge mrgtstv2=tstv2
        quit
fun1(index);
        if cnt=1 set fnret1="Ret 1"
        if cnt=2 set fnret1="Ret 2"
        if cnt=3 set fnret1="Ret 3"
        if cnt=4 set fnret1="Ret 4"
        if cnt=5 set fnret1="Ret 5"
        if cnt=6 set fnret1="Last from fun1^test1"
        set index=fnret1
        quit fnret1
fun2(index);
        if cnt=1 set fnret2="Ret 11"
        if cnt=2 set fnret2="Ret 22"
        if cnt=3 set fnret2="Ret 33"
        if cnt=4 set fnret2="Ret 44"
        if cnt=5 set fnret2="Ret 55"
        if cnt=6 set fnret2="Last from fun2^test1"
        set index=fnret2
        quit fnret2
