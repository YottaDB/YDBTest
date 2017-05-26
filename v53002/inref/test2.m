test;
        new $ZT
        ;SET $ZTRAP="GOTO errcont^errcont" 
lab1;
        if cnt=1 set digits="0123456789"
        if cnt=1 set pi=3.141592
        if cnt=1 set @ialpha=alpha
        if cnt=1 set @"qwspace"=wspace
        if cnt=1 set alphamv2=alpha
        if cnt=2 set tstv2("digits")=digits
        if cnt=2 set tstv2("pi")=pi
        if cnt=3 set tstv2("alpha")=alpha
        if cnt=3 set tstv2("wspace")=wspace
        if cnt<3 set tlit1="This is a literal"
        if cnt<3 set t2lit2=tlit2
        if cnt<3 set tlit3="This is a literal"
        merge mrgtstv1=tstv1
        quit
fun2();
        if cnt=1 set fnret3="Ret 1"
        if cnt=2 set fnret3="Ret 2"
        if cnt=3 set fnret3="Ret 3"
        if cnt=4 set fnret3="Ret 4"
        if cnt=5 set fnret3="Ret 5"
        if cnt=6 set fnret3="Last from fun2^test2"
        quit fnret3
fun3(index);
        if cnt=1 set fnret4="Ret 11"
        if cnt=2 set fnret4="Ret 22"
        if cnt=3 set fnret4="Ret 33"
        if cnt=4 set fnret4="Ret 44"
        if cnt=5 set fnret4="Ret 55"
        if cnt=6 set fnret4="Last from fun3^test2"
        set index=fnret4
        quit fnret4
