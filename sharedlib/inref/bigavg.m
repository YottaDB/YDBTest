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
extra   ;extra cruft at the end
        Set a=1,b=2,c=3,d=4,e=5,f=6
        Set z=1,y=2,x=3,w=4,u=5,t=6
        For i=1:1:1000 Set m(i)=i
        Set a=1,b=2,c=3,d=4,e=5,f=6
        Set z=1,y=2,x=3,w=4,u=5,t=6
        For i=1:1:1000 Set m(i)=i
        Set a=1,b=2,c=3,d=4,e=5,f=6
        Set z=1,y=2,x=3,w=4,u=5,t=6
        For i=1:1:1000 Set m(i)=i
        Q
