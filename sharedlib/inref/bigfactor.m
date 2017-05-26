factor ;
       ;
fact(X) ;
        If X=0 Set factrl=1
        If X=1 Set factrl=1
        If X=2 Set factrl=2
        If X=3 Set factrl=6
        If X=4 Set factrl=24
        If X=5 Set factrl=120
        If X=6 Set factrl=720
        If X=7 Set factrl=5040
        If X=8 Set factrl=40320
        If X=9 Set factrl=362880
        If X=10 Set factrl=3628800
        Q factrl
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
