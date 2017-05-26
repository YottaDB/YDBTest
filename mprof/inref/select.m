select	; Test of $SELECT function
;	File modified by Hallgarth on  5-JUN-1986 15:19:08.33
;	File modified by Hallgarth on  5-JUN-1986 09:44:03.57
	s x="test",y="test1",z="test2",xx=1,yy=2,zz=3,z1="x",z2="z3",z3="<start>"
	w $s(x="test1":"<enter>",x="test2":"<replace>",x="test":"<begin>"),!
	w $s(x'="test1":"<enter>",x="test2":"<replace>",x="test":"<begin>"),!
	w $s(x_"1"=z:"<finished>",x_"2"=z:"<start>"),!
	w $s(x_"1"'=z:"<finished>",x_"2"=z:"<start>"),!
	w $s(x=$s(xx=2:"<test2>",xx=1:"test"):"<enter>",1=1:"<begin>"),!	
	w $s(@z1=$s(xx=2:"<test2>",xx=1:@z2):"<enter>",1=1:"<begin>"),!	
	w $s(@z1=$s(xx=2:"<test2>",xx=1:@z2):$s(x'="test1":"<enter>",x="test2":"<replace>",x="test":"<begin>"),1=1:"<begin>"),!	
	
