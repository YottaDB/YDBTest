ZDSRTST2; Test PROCDEP^BTTDRV section with variables
	;
	Write "Test PROCDEP^BTTDRV section with variables",!
	if ($data(^size)=0)  W "^size is UNDEFINED",!  q
	s ^totdata=^size         
	s totdata=^totdata         
	W "Total Data=",totdata,!
	set ^opname(1)="ZDSRTST2"
	;
	; load symbol table
	s io="symbols.variables"
	o io
	u io f  r zzz q:$zeof  s @zzz
	c io
	s et1=$h
        SET t1=$ZGETJPI(0,"CPUTIM")
	f i=1:1:totdata d PROCDEP(.dep,.tmpttl,lsttype)
        SET t2=$ZGETJPI(0,"CPUTIM")
	s et2=$h
	SET ^cputime(^image,^typestr,^jnlstr,^typestr,^order,1,^run)=t2-t1
	SET ^elaptime(^image,^typestr,^jnlstr,^typestr,^order,1,^run)=$$^difftime(et2,et1)
        q

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
	S vo84=vdpm3
	S vdp49=$G(^ACN(vo84,49))
	S vdp51=$G(^ACN(vo84,51))
	S vdp52=$G(^ACN(vo84,52))
	S vdp53=$G(^ACN(vo84,53))
	S vdp57=$G(^ACN(vo84,57))
	S vdp60=$G(^ACN(vo84,60))
	S vdp428=$G(^ACN(vo84,428))
	;
	S BAL=$P(vdp51,"|",1)
	;
	I TYPE'=lsttype
	I 'BAL,$P(vdp51,"|",21)=4
	;
	S ichndflg=0
	;
	S:$D(vtt)#2=0 vtt=$S($G(vttm2):$G(^TMPTTL(vttm3,vttm4,vttm5,vttm6,vttm7,vttm8,vttm9,vttm10)),1:"")
	;
	S $P(vtt,"|",11)=$P(vtt,"|",11)+1
	S $P(vtt,"|",1)=$P(vtt,"|",1)+BAL
	S $P(vtt,"|",3)=$P(vtt,"|",3)+$P(vdp51,"|",7)
	S $P(vtt,"|",53)=$P(vtt,"|",53)+$P(vdp51,"|",17)
	;
	I BAL'<0
	I BAL<0
	;
	; If account meets one of the following conditions then it should be
	; considered for reclassification.
	;
	I tRCLSBAL'="",BAL<tRCLSBAL
	;
	S iacm=$P(vdp49,"|",5)
	S ircb=$P(vdp49,"|",12)
	S segflg=$P(vdp57,"|",48)
	S minacr=$P(vdp49,"|",22)
	S maxacr=$P(vdp49,"|",46)
	;
	I segflg,'$P(vdp428,"|",25)
	;
	S irn=+$P(vdp57,"|",1)
	S index=$P(vdp60,"|",1)
	;
	S RATE=irn
	S oldirn=irn
	S oldcmp=$P(vdp54,"|",2)
	;
	I segflg,$P(vdp428,"|",25)
	;
	D
	. I ircb=1 S balint=BAL Q 
	. Q 
	;
	I maxacr'="",balint>maxacr S balint=maxacr
	;
	I $P(vdp57,"|",3)=TJD
	;
	I $P(vdp57,"|",7)=TJD
	;
	I index'="" 
	;
	; Determine calc parameters if acct uses scheduled period int calc
	I '$E(iacm)
	;
	I 'ircb S acr=0
	;
	; Continuous method or daily compounding?
	I $E(iacm)=2!($P(vdp57,"|",7)-$P(vdp57,"|",8)=1)
	;
	;S acr=$$DETACR(.dep,irn,$P(vdp54,"|",1))
	S acr=$P(vdp54,"|",1)
	;
	I $E(iacm)=0
	;D STATDEP(.dep,.tmpttl,acr)
	;
	Q
