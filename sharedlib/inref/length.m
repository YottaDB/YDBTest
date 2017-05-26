length    ;
        write !,"Executing Shared Copy of length..."
	set ARR=""
        for i=66:1:70 set ARR=ARR_$char(i)
        do len write !,"The Length of ",ARR," is ",LEN,!
        k ARR,AVG,i
        quit
len	;
        set LEN=$l(ARR)
        quit
