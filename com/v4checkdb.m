v4checkdb;
	;	v4checkdb -- short names version of checkdb. Use sparingly, i.e. only when a V4 version
	;	is in the picture, since this version would not be maintained upto the latest changes in imptp.m
	;	Checks the database, if database has correct data
	;	Check if nothing is lost or, nothing is duplicate
	;   This program for database fills using primitive root of a field.
        ;   Say, w is the primitive root and we have 5 jobs
        ;   Job 1 : Sets index w^0, w^5, w^10 etc.
        ;   Job 2 : Sets index w^1, w^6, w^11 etc.
        ;   Job 3 : Sets index w^2, w^7, w^12 etc.
        ;   Job 4 : Sets index w^3, w^8, w^13 etc.
        ;   Job 5 : Sets index w^4, w^9, w^14 etc.
        ;   In above example nroot = w^5
        ;   In above example root =  w
	;
	set $ZT="SET $ZT="""" g ERROR^v4checkdb"
	;
	set crash=+$ztrnlnm("gtm_test_crash")	; Do not use ^%imptp("crash") as test might have redefined the logical
	set fid=+$ztrnlnm("gtm_test_dbfillid")	; Do not use ^%imptp("totaljob",fid), as test might have redefined the logical
	set skipreg=^%imptp("skipreg")
	set istp=^%imptp("istp")
	set gtcm=^%imptp("gtcm")
	set prime=^%imptp("prime")
	set root=^%imptp("root")
	set jobcnt=^%imptp(fid,"totaljob")
	;
	if jobcnt=0 write "TEST-E-CHECKDB Cannot do v4checkdb, jobcnt=",jobcnt,! h
	if (gtcm=1)&(crash=1) w "TEST-E-CHECKDB Cannot verify database, gtcm=",gtcm,"crash=",crash,! h
	if (crash=0)&(skipreg'=0) w "TEST-E-CHECKDB Cannot do v4checkdb, skipreg=",skipreg,"crash=",crash,! h
	;
	set callcrash=crash
	if istp=0 set callcrash=0
	set fl=0
	set maxerr=10
	set fltconst=3.14
        set nroot=1
	set cntloop=0
        for J=1:1:jobcnt do
	.	set nroot=(nroot*root)#prime
	.	set cntloop=cntloop+$GET(^lasti(fid,J))
	if callcrash=0 do nocrash^v4checkdb
	if callcrash'=0 do
	. if istp=2 do crashztp^v4checkdb
	. if istp'=2 do crash^v4checkdb
	;
	if (crash=0)&(istp=1)&(cntloop'=$GET(^cntloop(fid))) w "Verify Fail: ^cntloop(",fid,")=",$GET(^cntloop(fid))," Expected=",cntloop,! set fl=fl+1
	;
	if fl=0 write "v4checkdb PASSED.",!
	else  write "v4checkdb FAILED.",!
	q
	;
crash;
	set ival=1
	for jobno=1:1:jobcnt D
	. set I=ival
	. for loop=1:1:$GET(^lasti(fid,jobno)) do  q:(fl>maxerr)
	. . set subs=$$^genstr(I)
	. . set val=$$^genstr(loop)
	. . set val800=$j(val,800)
	. . set complete=$DATA(^andxarr(fid,jobno,loop))
	. . ;
	. . ; First tp
	. . if $GET(^a(fid,subs))'=val write "Verify Fail: ^a(",fid,",",subs,")=",$GET(^a(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^b(fid,subs))'=val write "Verify Fail: ^b(",fid,",",subs,")=",$GET(^b(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^c(fid,subs))'=val write "Verify Fail: ^c(",fid,",",subs,")=",$GET(^c(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^d(fid,subs))'=val write "Verify Fail: ^d(",fid,",",subs,")=",$GET(^d(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^e(fid,subs))'=val write "Verify Fail: ^e(",fid,",",subs,")=",$GET(^e(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^f(fid,subs))'=val write "Verify Fail: ^f(",fid,",",subs,")=",$GET(^f(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^g(fid,subs))'=val write "Verify Fail: ^g(",fid,",",subs,")=",$GET(^g(fid,subs))," Expected=",val,! set fl=fl+1
	. . if skipreg<1 do
	. . . if $GET(^h(fid,subs))'=val write "Verify Fail: ^h(",fid,",",subs,")=",$GET(^h(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^i(fid,subs))'=val w "Verify Fail: ^i(",fid,",",subs,")=",$GET(^i(fid,subs))," Expected=",val,! set fl=fl+1
	. . if $GET(^j(fid,I,I,subs))'=val write "Verify Fail: ^j(",fid,",",I,",","I",",",subs,")=",$GET(^j(fid,I,I,subs))," Expected=",val,! set fl=fl+1
	. . if complete do
	. . . if $GET(^j(fid,I))'="" write "Verify Fail: ^j(",fid,",",I,")=",$GET(^j(fid,I))," Expected=null",! set fl=fl+1
	. . . if $GET(^j(fid,I,I))'="" write "Verify Fail: ^j(",fid,",",I,",",I,")=",$GET(^j(fid,I,I))," Expected=null",! set fl=fl+1
	. . . ; Continue tp for the second subscripts
	. . if complete set jmax=jobcnt
	. . else  do
	. . .  set jmax=$ZPREVIOUS(^a(fid,subs,""))
	. . .  ; verify TP partners
	. . .  if jmax'=$ZPREVIOUS(^b(fid,subs,"")) write "Verify Fail: $zprev ^b(",fid,",",subs,")=",$ZPREVIOUS(^b(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^c(fid,subs,"")) write "Verify Fail: $zprev ^c(",fid,",",subs,")=",$ZPREVIOUS(^c(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^d(fid,subs,"")) write "Verify Fail: $zprev ^d(",fid,",",subs,")=",$ZPREVIOUS(^d(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^e(fid,subs,"")) write "Verify Fail: $zprev ^e(",fid,",",subs,")=",$ZPREVIOUS(^e(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^f(fid,subs,"")) write "Verify Fail: $zprev ^f(",fid,",",subs,")=",$ZPREVIOUS(^f(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^g(fid,subs,"")) write "Verify Fail: $zprev ^g(",fid,",",subs,")=",$ZPREVIOUS(^g(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . .  if skipreg<1 do
	. . .  . if jmax'=$ZPREVIOUS(^h(fid,subs,"")) write "Verify Fail: $zprev ^h(",fid,",",subs,")=",$ZPREVIOUS(^h(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . .  if jmax'=$ZPREVIOUS(^i(fid,subs,"")) write "Verify Fail: $zprev ^i(",fid,",",subs,")=",$ZPREVIOUS(^i(fid,subs,""))," Expected=",jmax,! set fl=fl+1
	. . for J=1:1:+jmax do
	. . . set rval=val_J
	. . . if ((J=1)&((complete)!($DATA(^a(fid,subs,1))=0))) set rval=""
	. . . if $GET(^a(fid,subs,J))'=rval write "Verify Fail: ^a(",fid,",",subs,",",J,")=",$GET(^a(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if $GET(^b(fid,subs,J))'=rval write "Verify Fail: ^b(",fid,",",subs,",",J,")=",$GET(^b(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if $GET(^c(fid,subs,J))'=rval write "Verify Fail: ^c(",fid,",",subs,",",J,")=",$GET(^c(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if $GET(^d(fid,subs,J))'=rval write "Verify Fail: ^d(",fid,",",subs,",",J,")=",$GET(^d(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if $GET(^e(fid,subs,J))'=rval write "Verify Fail: ^e(",fid,",",subs,",",J,")=",$GET(^e(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if $GET(^f(fid,subs,J))'=rval write "Verify Fail: ^f(",fid,",",subs,",",J,")=",$GET(^f(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if $GET(^g(fid,subs,J))'=rval write "Verify Fail: ^g(",fid,",",subs,",",J,")=",$GET(^g(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if skipreg<1 do
	. . . .  if $GET(^h(fid,subs,J))'=rval write "Verify Fail: ^h(",fid,",",subs,",",J,")=",$GET(^h(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . . if $GET(^i(fid,subs,J))'=rval write "Verify Fail: ^i(",fid,",",subs,",",J,")=",$GET(^i(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. . if complete do
	. . . ; Now ntp
	. . . if $DATA(^antp(fid,subs))'=0 write "Verify Fail: ^antp(",fid,",",subs,")=",$GET(^antp(fid,subs))," Expected=null",! set fl=fl+1
	. . . if $DATA(^bntp(fid,subs))'=0 write "Verify Fail: ^bntp(",fid,",",subs,")=",$GET(^bntp(fid,subs))," Expected=null",! set fl=fl+1
	. . . if $DATA(^cntp(fid,subs))'=0 write "Verify Fail: ^cntp(",fid,",",subs,")=",$GET(^cntp(fid,subs))," Expected=null",! set fl=fl+1
	. . . if $DATA(^dntp(fid,subs))'=0 write "Verify Fail: ^dntp(",fid,",",subs,")=",$GET(^dntp(fid,subs))," Expected=null",! set fl=fl+1
	. . if (complete)!(+jmax'=0) do
	. . . if $GET(^entp(fid,subs))'=val write "Verify Fail: ^entp(",fid,",",subs,")=",$GET(^entp(fid,subs))," Expected=",val,! set fl=fl+1
	. . . if $GET(^fntp(fid,subs))'=val write "Verify Fail: ^fntp(",fid,",",subs,")=",$GET(^fntp(fid,subs))," Expected=",val,! set fl=fl+1
	. . . if $GET(^gntp(fid,subs))'=val800 write "Verify Fail: ^gntp(",fid,",",subs,")=",$GET(^gntp(fid,subs))," Expected=",val800,! set fl=fl+1
	. . . if skipreg<1 do
	. . . . if $GET(^hntp(fid,subs))'=val800 write "Verify Fail: ^hntp(",fid,",",subs,")=",$GET(^hntp(fid,subs))," Expected=",val800,! set fl=fl+1
	. . . if $GET(^intp(fid,subs))'=val800 write "Verify Fail: ^intp(",fid,",",subs,")=",$GET(^intp(fid,subs))," Expected=",val800,! set fl=fl+1
	. . if (fl>maxerr) write "Too many errors for job:",jobno,!
	. . set I=(I*nroot)#prime
        . set ival=(ival*root)#prime
	q
	;
crashztp;
	set maxcrash=3
	set ival=1
	set crashcnt=0
	for jobno=1:1:jobcnt D
	. set I=ival
	. for loop=1:1:$GET(^lasti(fid,jobno))-1  do  q:(fl>maxerr)
	. . set datacnt=0
	. . if $DATA(^andxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^bndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^cndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^dndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^endxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^fndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^gndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^hndxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if $DATA(^indxarr(fid,jobno,loop)) set datacnt=datacnt+1
	. . if datacnt'=9  set crashcnt=crashcnt+1
	. . else  do compiter^v4checkdb(fid,I,loop)
	. . set I=(I*nroot)#prime
        . set ival=(ival*root)#prime
	q
	;
nocrash;
	set ival=1
	for jobno=1:1:jobcnt D
	. set I=ival
	. for loop=1:1:$GET(^lasti(fid,jobno)) do  q:(fl>maxerr)
	. . do compiter^v4checkdb(fid,I,loop)
	. . if (fl>maxerr) write "Too many errors for job:",jobno,!
	. . set I=(I*nroot)#prime
        . set ival=(ival*root)#prime
	q
	;
compiter(fid,I,loop)
	set subs=$$^genstr(I)
	set val=$$^genstr(loop)
	set val800=$j(val,800)
	; First tp
	if $GET(^a(fid,subs))'=val write "Verify Fail: ^a(",fid,",",subs,")=",$GET(^a(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^b(fid,subs))'=val write "Verify Fail: ^b(",fid,",",subs,")=",$GET(^b(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^c(fid,subs))'=val write "Verify Fail: ^c(",fid,",",subs,")=",$GET(^c(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^d(fid,subs))'=val write "Verify Fail: ^d(",fid,",",subs,")=",$GET(^d(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^e(fid,subs))'=val write "Verify Fail: ^e(",fid,",",subs,")=",$GET(^e(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^f(fid,subs))'=val write "Verify Fail: ^f(",fid,",",subs,")=",$GET(^f(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^g(fid,subs))'=val write "Verify Fail: ^g(",fid,",",subs,")=",$GET(^g(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^h(fid,subs))'=val write "Verify Fail: ^h(",fid,",",subs,")=",$GET(^h(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^i(fid,subs))'=val write "Verify Fail: ^i(",fid,",",subs,")=",$GET(^i(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^j(fid,I))'="" write "Verify Fail: ^j(",fid,",",I,")=",$GET(^j(fid,I))," Expected=null",! set fl=fl+1
	if $GET(^j(fid,I,I))'="" write "Verify Fail: ^j(",fid,",",I,",",I,")=",$GET(^j(fid,I,I))," Expected=null",! set fl=fl+1
	if $GET(^j(fid,I,I,subs))'=val write "Verify Fail: ^j(",fid,",",I,",","I",",",subs,")=",$GET(^j(fid,I,I,subs))," Expected=",val,! set fl=fl+1
	; Continue tp for the second subscripts
	for J=1:1:jobcnt do
	. set valj=val_J		; Not killed
	. if J=1 set rval=""
	. else  set rval=valj
	. if $GET(^a(fid,subs,J))'=rval write "Verify Fail: ^a(",fid,",",subs,",",J,")=",$GET(^a(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^b(fid,subs,J))'=rval write "Verify Fail: ^b(",fid,",",subs,",",J,")=",$GET(^b(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^c(fid,subs,J))'=rval write "Verify Fail: ^c(",fid,",",subs,",",J,")=",$GET(^c(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^d(fid,subs,J))'=rval write "Verify Fail: ^d(",fid,",",subs,",",J,")=",$GET(^d(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^e(fid,subs,J))'=rval write "Verify Fail: ^e(",fid,",",subs,",",J,")=",$GET(^e(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^f(fid,subs,J))'=rval write "Verify Fail: ^f(",fid,",",subs,",",J,")=",$GET(^f(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^g(fid,subs,J))'=rval write "Verify Fail: ^g(",fid,",",subs,",",J,")=",$GET(^g(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^h(fid,subs,J))'=rval write "Verify Fail: ^h(",fid,",",subs,",",J,")=",$GET(^h(fid,subs,J))," Expected=",rval,! set fl=fl+1
	. if $GET(^i(fid,subs,J))'=rval write "Verify Fail: ^i(",fid,",",subs,",",J,")=",$GET(^i(fid,subs,J))," Expected=",rval,! set fl=fl+1
	if $DATA(^antp(fid,subs))'=0 write "Verify Fail: ^antp(",fid,",",subs,")=",$GET(^antp(fid,subs))," Expected=null",! set fl=fl+1
	if $DATA(^bntp(fid,subs))'=0 write "Verify Fail: ^bntp(",fid,",",subs,")=",$GET(^bntp(fid,subs))," Expected=null",! set fl=fl+1
	if $DATA(^cntp(fid,subs))'=0 write "Verify Fail: ^cntp(",fid,",",subs,")=",$GET(^cntp(fid,subs))," Expected=null",! set fl=fl+1
	if $DATA(^dntp(fid,subs))'=0 write "Verify Fail: ^dntp(",fid,",",subs,")=",$GET(^dntp(fid,subs))," Expected=null",! set fl=fl+1
	if $GET(^entp(fid,subs))'=val write "Verify Fail: ^entp(",fid,",",subs,")=",$GET(^entp(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^fntp(fid,subs))'=val write "Verify Fail: ^fntp(",fid,",",subs,")=",$GET(^fntp(fid,subs))," Expected=",val,! set fl=fl+1
	if $GET(^gntp(fid,subs))'=val800 write "Verify Fail: ^gntp(",fid,",",subs,")=",$GET(^gntp(fid,subs))," Expected=",val800,! set fl=fl+1
	if $GET(^hntp(fid,subs))'=val800 write "Verify Fail: ^hntp(",fid,",",subs,")=",$GET(^hntp(fid,subs))," Expected=",val800,! set fl=fl+1
	if $GET(^intp(fid,subs))'=val800 write "Verify Fail: ^intp(",fid,",",subs,")=",$GET(^intp(fid,subs))," Expected=",val800,! set fl=fl+1
	q
ERROR	ZSHOW "*"
	h
