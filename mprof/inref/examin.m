examin(i)       s t=i;
        w "The number of executions:",!
        f  s t=$Q(@t) q:t=""  d
        . s value=@t
        . s no=$P(value,":",1)
        . s ut=$P(value,":",2)
        . s st=$P(value,":",3)
        . s ct=$P(value,":",4)
        . i ((t["*RUN")!((ct="")&(ut'="")&(st'=""))) q
        . w t,": ",no
        . i (no=0) W "     INVALID COUNT"
        . i (ut<0) W " User Time ",ut," Invalid"
        . i (st<0) W " System Time ",st," Invalid"
        . w !
        q
