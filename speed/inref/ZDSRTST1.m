ZDSRTST1; Test PROCDEP^BTTDRV section with arrays
	;
	Write "Test PROCDEP^BTTDRV section with arrays",!
	if ($data(^size)=0)  W "^size is UNDEFINED",!  q
	set ^totdata=^size
	s totdata=^totdata
	W "Total Data=",totdata,!
	set ^opname(1)="ZDSRTST1"
	;
	; load symbol table
	s io="symbols.arrays"
	o io
	u io f  r zzz q:$zeof  s @zzz
	c io
	;
	s et1=$h
	SET t1=$ZGETJPI(0,"CPUTIM")
	f i=1:1:totdata d PROCDEP(.dep,.tmpttl,lsttype)
	SET t2=$ZGETJPI(0,"CPUTIM")
	s et2=$h
	SET ^cputime(^image,^typestr,^jnlstr,^typestr,^order,1,^run)=t2-t1
        SET ^elaptime(^image,^typestr,^jnlstr,^typestr,^order,1,^run)=$$^difftime(et2,et1)
	q
	;
	;----------------------------------------------------------------------
PROCDEP(dep,tmpttl,lsttype)	; Process deposit accounts
	;----------------------------------------------------------------------
	;
	; ** Runtype type checking will be inserted **
	N acr,balint,ichndflg,index,irn,maxacr,minacr,segflg
	N AF,BAL,DIP,NOHIST,RATE
	S (AF,DIP)=""
	;
	N vo84
	S vo84=vobj(dep,-3)
	S vobj(dep,49)=$G(^ACN(vo84,49))
	S vobj(dep,51)=$G(^ACN(vo84,51))
	S vobj(dep,52)=$G(^ACN(vo84,52))
	S vobj(dep,53)=$G(^ACN(vo84,53))
	S vobj(dep,57)=$G(^ACN(vo84,57))
	S vobj(dep,60)=$G(^ACN(vo84,60))
	S vobj(dep,428)=$G(^ACN(vo84,428))
	;
	S BAL=$P(vobj(dep,51),"|",1)
	;
	I TYPE'=lsttype
	I 'BAL,$P(vobj(dep,51),"|",21)=4
	;
	S ichndflg=0
	;
	S:$D(vobj(tmpttl))#2=0 vobj(tmpttl)=$S($G(vobj(tmpttl,-2)):$G(^TMPTTL(vobj(tmpttl,-3),vobj(tmpttl,-4),vobj(tmpttl,-5),vobj(tmpttl,-6),vobj(tmpttl,-7),vobj(tmpttl,-8),vobj(tmpttl,-9),vobj(tmpttl,-10))),1:"")
	;
	S $P(vobj(tmpttl),"|",11)=$P(vobj(tmpttl),"|",11)+1
	S $P(vobj(tmpttl),"|",1)=$P(vobj(tmpttl),"|",1)+BAL
	S $P(vobj(tmpttl),"|",3)=$P(vobj(tmpttl),"|",3)+$P(vobj(dep,51),"|",7)
	S $P(vobj(tmpttl),"|",53)=$P(vobj(tmpttl),"|",53)+$P(vobj(dep,51),"|",17)
	;
	I BAL'<0
	I BAL<0
	;
	; If account meets one of the following conditions then it should be
	; considered for reclassification.
	;
	I tRCLSBAL'="",BAL<tRCLSBAL
	;
	S iacm=$P(vobj(dep,49),"|",5)
	S ircb=$P(vobj(dep,49),"|",12)
	S segflg=$P(vobj(dep,57),"|",48)
	S minacr=$P(vobj(dep,49),"|",22)
	S maxacr=$P(vobj(dep,49),"|",46)
	;
	I segflg,'$P(vobj(dep,428),"|",25)
	;
	S irn=+$P(vobj(dep,57),"|",1)
	S index=$P(vobj(dep,60),"|",1)
	;
	S RATE=irn
	S oldirn=irn
	S oldcmp=$P(vobj(dep,54),"|",2)
	;
	I segflg,$P(vobj(dep,428),"|",25)
	;
	D
	. I ircb=1 S balint=BAL Q 
	. Q 
	;
	I maxacr'="",balint>maxacr S balint=maxacr
	;
	I $P(vobj(dep,57),"|",3)=TJD
	;
	I $P(vobj(dep,57),"|",7)=TJD
	;
	I index'="" 
	;
	; Determine calc parameters if acct uses scheduled period int calc
	I '$E(iacm)
	;
	I 'ircb S acr=0
	;
	; Continuous method or daily compounding?
	I $E(iacm)=2!($P(vobj(dep,57),"|",7)-$P(vobj(dep,57),"|",8)=1)
	;
	;S acr=$$DETACR(.dep,irn,$P(vobj(dep,54),"|",1))
	S acr=$P(vobj(dep,54),"|",1)
	;
	I $E(iacm)=0
	;D STATDEP(.dep,.tmpttl,acr)
	;
	Q
