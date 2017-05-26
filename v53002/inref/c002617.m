c002617	;
        quit
test0	;
	; This is actually the testcase of C9D01-002234 which is the same issue as C9E08-002617
	;
        set $etrap="write $zstatus,! set $ecode="""" set x=1/0  quit"
        set x=1/0
        quit
	;
	; Following is a lot of testcases that demonstrated C9E08-002617
	; Although most of them exercise similar code, we include all the tests just to be safe.
	;
test1	;
	do A^c002617a
	quit
test2	;
	do ^stacktst
	quit
test3	;
	do ^stacktst1
	quit
test4	;
        set mainv1="alphamv1"
        ;
	set unix=$zversion'["VMS"
        if unix  set cpstr="\cp -f",rmstr="\rm -f",exten="o"
        if 'unix  set cpstr="copy/nolog",rmstr="delete/nolog",exten="obj"
	zsystem cpstr_" test1.m test.m"
        zlink "test"
        do ^test
        set fnarr("alpha")=alpha
        set fnarr("wspace")=wspace
        zsystem rmstr_" test."_exten
        ;
        zsystem cpstr_" test2.m test.m"
        zlink "test"
        do lab1^test
        set fnarr("digits")=digits
        set fnarr("pi")=pi
        ;
        for cnt=1:1:8 do
        . new ialpha,iwspace
        . set index=cnt
        . ;w !,"====START==========",!
        . zsystem rmstr_" test."_exten
        . zsystem cpstr_" test1.m test.m"
        . zlink "test"
        . do ^test
        . set fnarr(1111,cnt)=$$fun1^test(.index)
        . set indarr(1,cnt)=index
        . set fnarr(2222,cnt)=$$fun2^test(.index)
        . set indarr(2,cnt)=index
        . ;
        . zsystem rmstr_" test."_exten
        . zsystem cpstr_" test2.m test.m"
        . zlink "test"
        . do lab1^test
        . set fnarr(3333,cnt)=$$fun2^test()
        . set indarr(3,cnt)=index
        . set fnarr(4444,cnt)=$$fun3^test(index)
        . set indarr(4,cnt)=index
        . ;
        . if cnt=3 set tmlit1=tlit1
        . if cnt=3 set tmlit2(1)=tlit2
        . if cnt=3 set tmlit2(2)=t2lit2
        . if cnt=3 set tmlit3=tlit3
        . ;w !,"----END-----------",!
        zsystem rmstr_" test."_exten
        merge tstv(1)=tstv1
        merge tstv(2)=tstv2
        zwr
        w $h,!
        quit
ERROR
        write "In ZTRAP",$zstatus,!
        zshow "*"
        halt
test5	;
	set:$zversion'["VMS" $ETRAP="Write:(0=$STACK) ""Error occurred: "",$ZSTATUS,!"
	do ^TestTrap
	quit
