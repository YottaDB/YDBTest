mixfill;
in0(act,strlen);
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database
	if strlen>20 w "String length exceeded 20"
	if $data(^prefix)=0 SET ^prefix="^"
	s ITEM="Random database fill 0",ERR=0
	SET prime=211
	SET root(1)=17
	SET root(2)=22
	SET root(3)=29
	SET root(4)=35
	SET root(5)=39
	SET root(6)=41
	SET root(7)=48
	SET root(8)=57
	SET root(9)=72
	SET root(10)=75
	SET root(11)=85
	SET root(12)=91
	SET root(13)=92
	SET root(14)=106
	SET root(15)=108
	SET root(16)=112
	SET root(17)=116
	SET root(18)=118
	SET root(19)=127
	SET root(20)=130                
	do filling^mixfill(act,prime,strlen)
	do morefill^mixfill
	q

in1(act,strlen);
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database
	if strlen>20 w "String length exceeded 20"
	if $data(^prefix)=0 SET ^prefix="^"
	s ITEM="Random database fill 1",ERR=0
	SET prime=503
	SET root(1)=202
	SET root(2)=203
	SET root(3)=204
	SET root(4)=206
	SET root(5)=209
	SET root(6)=210
	SET root(7)=211
	SET root(8)=212
	SET root(9)=213
	SET root(10)=214
	SET root(11)=215
	SET root(12)=217
	SET root(13)=218
	SET root(14)=220
	SET root(15)=221
	SET root(16)=222
	SET root(17)=227
	SET root(18)=228
	SET root(19)=230
	SET root(20)=232                     
	do filling^mixfill(act,prime,strlen)
	do morefill^mixfill
	q

in2(act,strlen);
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database
	if strlen>20 w "String length exceeded 20"
	if $data(^prefix)=0 SET ^prefix="^"
	s ITEM="Random database fill 2",ERR=0
	SET prime=1009
	SET root(1)=301
	SET root(2)=304
	SET root(3)=305
	SET root(4)=307
	SET root(5)=308
	SET root(6)=310
	SET root(7)=311
	SET root(8)=318
	SET root(9)=319
	SET root(10)=321
	SET root(11)=325
	SET root(12)=326
	SET root(13)=329
	SET root(14)=340
	SET root(15)=342
	SET root(16)=358
	SET root(17)=364
	SET root(18)=366
	SET root(19)=367
	SET root(20)=368                  
	do filling^mixfill(act,prime,strlen)
	do morefill^mixfill
	q


filling(act,prime,maxlen)
	SET vname(1)="AGLOBALVAR1"
	SET vname(2)="BGLOBALVAR1"
	; Create a template which has length < prime
	SET temp="%"
	for cur=$A("A"):1:$A("Z") SET temp=temp_""_$C(cur)  
	for cur=$A("0"):1:$A("9") SET temp=temp_""_$C(cur)  
	for cur=$A("a"):1:$A("z") SET temp=temp_""_$C(cur)  
	set len=$length(temp)
	SET template=""
	FOR cur=1:1:(prime+len+maxlen)/len SET template=template_temp
	SET strsub=2
	SET maxsub=4
	;
	FOR varcnt=1:1:2 DO
	. FOR strlen=1:1:maxlen DO
	. . FOR cur=1:1:20 SET ndx(cur)=root(cur)
	. . SET fact=-1
	. . FOR cur=0:1:prime-2 DO
	. . . FOR subcnt=1:1:strsub  SET subs(subcnt)=$e(template,ndx(subcnt),ndx(subcnt)+strlen-1)
	. . . FOR subcnt=1:1:strsub  if $length(subs(subcnt))=0 w "Cannot verify data with this M code",! q
	. . . SET x=^prefix_vname(varcnt)_"("""_subs(1)_""","""_subs(2)_""""
	. . . SET fact=-fact  SET sub3=fact*ndx(3) SET x=x_","_sub3
	. . . SET fact=-fact  SET sub4=fact*ndx(4)*1.01 SET x=x_","_sub4
	. . . SET x=x_")"
	. . . SET y=vname(varcnt)_cur
	. . . if act="kill" k @x
	. . . if act="set"  SET @x=y 
	. . . if act="ver"  do EXAM(ITEM,x,y,$GET(@x))
	. . . FOR j=1:1:maxsub SET ndx(j)=(ndx(j)*root(j))#prime
	i ERR=0 w act," PASS",!
	q

morefill
	if $GET(^prefix)="" DO
	. if act="set" DO
	. . for i=1:1:20 SET morefill("string"_i,12345,"12345",$c(1,2,3,4,5))=$j(i,5)
	. if act="ver" DO
	. . for i=1:1:20 DO
	. . . if $GET(morefill("string"_i,12345,"12345",$c(1,2,3,4,5)))'=$j(i,5)  w "Fail in morefill",!  
	. if act="kill" DO
	. . for i=1:1:20 KILL morefill("string"_i,12345,"12345",$c(1,2,3,4,5))
	else  DO
	. if act="set" DO
	. . for i=1:1:20 SET ^morefill("string"_i,12345,"12345",$c(1,2,3,4,5))=$j(i,5)
	. if act="ver" DO
	. . for i=1:1:20 DO
	. . . if $GET(^morefill("string"_i,12345,"12345",$c(1,2,3,4,5)))'=$j(i,5)  w "Fail in morefill",!  
	. if act="kill" DO
	. . for i=1:1:20 KILL ^morefill("string"_i,12345,"12345",$c(1,2,3,4,5))
	q

EXAM(item,pos,vcorr,vcomp)
	if (ERR>100)  q
	i vcorr=vcomp  q
	if ERR=0 w " ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	s ERR=ERR+1
	if ERR>100 w "!!!!! TOO MANY ERRORS !!!!",!  q
	q

	;;; the requirement for filling data for the chinese collation test
	;;; 1. global name is a parameter
	;;; 2. Chinese in subscripts
	;;; 3. ASCII in subscripts
	;;; 4. Number in subscripts
	;;; 5. Chinese in data
	;;; 6. Illegal UTF-8 sequences in subscripts
s
	write "    SET Global ^a",!
	DO fills("set","^a")
	q
v
	DO fills("ver","^a")
	write "    VERIFY Global ^a : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
k
	write "    KILL Global ^a",!
	DO fills("kill","^a")
	q
ks
	write "    KILLSOME Global ^a",!
	DO fills("killsome","^a")
	q
vs
	DO fills("versome","^a")
	write "    VERIFYSOME Global ^a : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
s1
	write "    SET Global ^A",!
	DO fills1("set","^A")
	q
v1
	DO fills1("ver","^A")
	write "    VERIFY Global ^A : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
k1
	write "    KILL Global ^A",!
	DO fills1("kill","^A")
	q
ks1
	write "    KILLSOME Global ^A",!
	DO fills1("killsome","^A")
	q
vs1
	DO fills1("versome","^A")
	write "    VERIFYSOME Global ^A : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
ls
	write "    SET Local a",!
	DO fills("set","a")
	q
lv
	DO fills("ver","a")
	write "    VERIFY Local a : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
lk
	write "    KILL Local a",!
	DO fills("kill","a")
	q
lks
	write "    KILLSOME Local a",!
	DO fills("killsome","a")
	q
lvs
	DO fills("versome","a")
	write "    VERIFYSOME Local a : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
ls1
	write "    SET Local A",!
	DO fills1("set","A")
	q
lv1
	DO fills1("ver","A")
	write "    VERIFY Local A : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
lk1
	write "    KILL Local A",!
	DO fills1("kill","A")
	q
lks1
	write "    KILLSOME Local A",!
	DO fills1("killsome","A")
	q
lvs1
	DO fills1("versome","A")
	write "    VERIFYSOME Local A : ",$select(errcnt=0:"PASS",1:"FAIL"),!
	q
fills(act,gname)
	;; act :: set ==> sets the full data
	;; act :: ver ==> verifies the full data
	;; act :: kill ==> kills the full data
	;; act :: killsome ==> kills some of the data
	;; act :: versome ==> verfies the remaining data
	;;; ============================ build template first ==================================
	set errcnt=0
	S tempc="啊把玻不擦大饿而二发勾哈几卡拉璃妈吗呐能你欧怕七扰萨伤身他体吞挖我西下行呀杂再"
	S tempa="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	S tempn="0123456789"
	S tempf=tempc_tempa_tempn
	;;; ========================= single subscipt situation ================================
	S end=$length(tempf)-3
	for i=1:3:end DO
	. set x=gname_"("""_$e(tempf,i,i+2)_""")"
	. i act'="versome"  do fillsu(act,x,i)
	; set some non-canonical number single subscripts
	s x=gname_"(""00.10"")"
	i act'="versome"  do fillsu(act,x,"00.10")
	s x=gname_"(""010.10"")"
	i act'="killsome"  do fillsu(act,x,"010.10")
	s x=gname_"(""10E2"")"
	i act'="versome"  do fillsu(act,x,"10E2")
	; set some illegal UTF-8 sequences
	; TODO :: add illegal UTF-8 sequences here
	q
fills1(act,gname)
	set errcnt=0
	S tempc="啊把玻不大而二发几卡拉璃吗能你七伤身体吞我西下行呀"
	S tempa="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	S tempn="0123456789"
	;;; ========================= multiple, different-sized subscripts ======================
	; TODO the following should be updated when Unicode coding is done
	s endc=$length(tempc)
	s enda=$length(tempa)
	s endn=$length(tempn)
	for i=6:3:endc DO
	. s subc=$e(tempc,1,i)
	. s subd=$e(tempc,i-5,i-3)
	. s suba=$e(tempa,1,((i-1)#enda)+1)
	. s subn=$e(tempn,1,((i-1)#endn)+1)
	. s x=gname_"("""_subc_""","""_suba_""","""_subn_""")"
	. s y=subc_"|"_suba_"|"_subn
	. i act'="versome"  do fillsu(act,x,y)
	. s x=gname_"("""_subd_""","""_suba_""","""_subn_""")"
	. s y=subd_"|"_suba_"|"_subn
	. i act'="versome"  do fillsu(act,x,y)
	. s x=gname_"("""_subd_subc_""","""_suba_""","""_subn_""")"
	. s y=subd_subc_"|"_suba_"|"_subn
	. i act'="killsome"  do fillsu(act,x,y)
	. s x=gname_"("""_subc_subd_""","""_suba_""","""_subn_""")"
	. s y=subc_subd_"|"_suba_"|"_subn
	. i act'="versome"  do fillsu(act,x,y)
	. s x=gname_"("""_subc_""","""_suba_subc_""","""_subn_""")"
	. s y=subc_"|"_suba_subc_"|"_subn
	. i act'="killsome"  do fillsu(act,x,y)
	. s x=gname_"("""_subc_""","""_suba_subd_""","""_subn_""")"
	. s y=subc_"|"_suba_subd_"|"_subn
	. i act'="killsome"  do fillsu(act,x,y)
	. s x=gname_"("""_subc_""","""_suba_subn_""","""_subn_""")"
	. s y=subc_"|"_suba_subn_"|"_subn
	. i act'="versome"  do fillsu(act,x,y)
	. s x=gname_"("""_subc_""","""_suba_""","""_subn_subc_""")"
	. s y=subc_"|"_suba_"|"_subn_subc
	. i act'="killsome"  do fillsu(act,x,y)
	. s x=gname_"("""_subc_""","""_suba_""","""_subn_subd_""")"
	. s y=subc_"|"_suba_"|"_subn_subd
	. i act'="killsome"  do fillsu(act,x,y)
	. s x=gname_"("""_subc_""","""_suba_""","""_subn_suba_""")"
	. s y=subc_"|"_suba_"|"_subn_suba
	. i act'="versome"  do fillsu(act,x,y)
	q
filln(act,gname)
	;; act :: set ==> sets the full data
	;; act :: ver ==> verifies the full data
	;; act :: kill ==> kills the full data
	set errcnt=0
	f i=0:1:15,95:1:105,985:1:1005  do
	. s x=gname_"("""_i_""")"
	. s y=i
	. d fillsu(act,x,y)
	q
fillsu(action,name,expected)
	if action="set"  set @name=expected  q
	if action="kill"  k @name  q
	if action="killsome"  k @name  q
	s value=$GET(@name)
	if value=expected  q
	w ?5,"ERROR",!
	w ?10," value for :: ",name,!
	w ?10," expected  :: ",expected,!
	w ?10," is        :: ",value,!
	set errcnt=errcnt+1
	q
