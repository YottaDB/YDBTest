bug302	s n=0,m=999
	r !,"maximum: ",max,!
loop	s n=n+1,m=m+1,^a=n
	i n>max b
	i m>100 s m=0,str=""
	s str=str_"X"
	s @("x"_m_"=str")
	g loop
