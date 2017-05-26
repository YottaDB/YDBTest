gtm7234	;check that a job with no parameters doesn't pass one
        ;
        kill ^a
        set jmaxwait=120
        do ^job("Label1^gtm7234",1,1)
        do ^job("Label3^gtm7234",1,1)
	for i=1:1:jmaxwait quit:'$data(^a)  hang 1
        write $select((0'=$g(^a))!'$data(^a("V",1))!("P"=$extract(^a("V",2))):"FAIL",1:"PASS")," from ",$text(+0)
        quit
Label1(Param1)
        set jmaxwait=120
        do ^job("Label2^gtm7234",1,"""""")
        quit
Label2(Param2)
        set ^a=+$g(Param2)
        quit
Label3(Param1,Param2,Paran3)
        zshow "v":^a
        quit
