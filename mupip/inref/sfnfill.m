sfnfill ;
        ; act="set"  fills data in
	; act="ver"  verifies that the data is in data base
	; act="kill" kills the data from the database

in0(act)
	set ITEM="Random database fill 0 ",ERR=0
	set prime=29
	set root=2
	do filling^sfnfill(act,prime)
	q

in1(act)
	set ITEM="Random database fill 1 ",ERR=0
	set prime=251
	set root=6
	do filling^sfnfill(act,prime)
	q

in2(act)
	set ITEM="Random database fill 2 ",ERR=0
	set prime=503
	set root=5
	do filling^sfnfill(act,prime)
	q

in3(act)
	set ITEM="Random database fill 3 ",ERR=0
	set prime=1009
	set root=11
	do filling^sfnfill(act,prime)
	q

in4(act)
	set ITEM="Random database fill 4 ",ERR=0
	set prime=10007
	set root=5
	do filling^sfnfill(act,prime)
	q

in5(act)
	set ITEM="Random database fill 5 ",ERR=0
	set prime=100003
	set root=2
	do filling^sfnfill(act,prime)
	q

in6(act)
	set ITEM="Data base fill 6 ",ERR=0
	set prime=1000003
	set root=2
	do filling^sfnfill(act,prime)
	q


filling(act,prime)
	set ndx=root
	SET istp=1
	IF $ztrnlnm("gtm_test_tp")="NON_TP"  SET istp=0  
	f i=0:1:prime-2 D
	. S tndx=$$^genstr(ndx) 
	. ; right justify 
	. set rhssize=i#5+10
	. set y=$j(ndx,rhssize)
	. if (istp=1),(ndx#2=1) TSTART ():(serial:transaction="BA")
	. set subs=$$^genstr(ndx)
	. if act="set"  DO
	. .  SET ^afill(subs)=y
	. .  SET ^bfill(subs)=y
	. .  SET ^cfill(subs)=y
	. .  SET ^dfill(subs)=y
	. .  SET ^efill(subs)=y
	. if act="ver"  DO
	. .  do EXAM(ITEM,"^afill("_subs_")",y,$GET(^afill(subs)))
	. .  do EXAM(ITEM,"^bfill("_subs_")",y,$GET(^bfill(subs)))
	. .  do EXAM(ITEM,"^cfill("_subs_")",y,$GET(^cfill(subs)))
	. .  do EXAM(ITEM,"^dfill("_subs_")",y,$GET(^dfill(subs)))
	. .  do EXAM(ITEM,"^efill("_subs_")",y,$GET(^efill(subs)))
	. if act="kill" DO
	. .  k ^afill(subs)
	. .  k ^bfill(subs)
	. .  k ^cfill(subs)
	. .  k ^dfill(subs)
	. .  k ^efill(subs)
        . if (istp=1),(ndx#2=1) TCOMMIT
	. S ndx=(ndx*root)#prime
	i ERR=0 w act," PASS",!
	q

EXAM(item,pos,vcorr,vcomp)
	if (ERR>100)  q
	i vcorr=vcomp  q
	w ?10," ** FAIL ",item," verifying global ",pos,!
	w ?10,"CORRECT  = ",vcorr,!
	w ?10,"COMPUTED = ",vcomp,!
	set ERR=ERR+1
	if ERR>100 w "!!!!! TOO MANY ERRORS !!!!",!  q
	q
