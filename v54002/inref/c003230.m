c003230       ;
; Create 100000 TP transactions
        set ^x=1
        hang 1
        for i=1:1:100000 do
        . tstart ():(serial:transaction="BATCH")
        . set ^a(i)=i,^b(i)=i
        . tcommit
        hang 1
        quit
