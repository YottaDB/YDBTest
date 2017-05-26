inclock(top)	; test speed of various increment operations
	L +^permit($j)
	SET ^x=0
	SET jobno=jobindex
	SET ^opname(1)="LOCKI"
        SET et1=$H
        SET t1=$ZGETJPI(0,"CPUTIM")
	f i=1:1:top l +^x  s ^x=^x+1 l -^x
	SET t2=$ZGETJPI(0,"CPUTIM")
        SET et2=$H
        do RESULT^inclock(t1,t2,et1,et2)
	q

RESULT(t1,t2,et1,et2)
        SET ^cputime(^image,^typestr,^jnlstr,^typestr,^order,jobno,^run)=t2-t1
        SET ^elaptime(^image,^typestr,^jnlstr,^typestr,^order,jobno,^run)=$$^difftime(et2,et1)
        q

