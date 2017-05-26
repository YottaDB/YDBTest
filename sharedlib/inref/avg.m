avg    ;
        W !,"Executing Shared Copy of AVG..."
        For i=1:1:10 S ARR(i)=i*i
        Do average W !,"The AVERAGE is ",AVG
	W !
        K ARR,AVG,i
        Q
average ;calc average
	S Sum=0
        For i=1:1:10 S Sum=Sum+ARR(i)
        Set AVG=Sum/i K Sum,i
        Q
