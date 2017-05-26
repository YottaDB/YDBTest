c002596	;
        set ^secgldno=8
        set ^secgldnm="mumpssec"
        ;
        set numjobs=8
        set jmaxwait=0    ; signals d ^job() to job off processes and return right away without waiting
        do ^job("tpntpupd",numjobs,"""""")
        hang 15
        set ^stop=1
        do wait^job
        quit
