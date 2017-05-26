setsome	;	
	s ibase=$ZCMDLINE
	s itop=ibase*20
	f i=ibase:1:itop s ^a(i)=i,^b(i)=i
	q
