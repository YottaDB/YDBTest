	;;  h300s.m
	s ^procid=$J
	f i=0:1:300  s ^a(i)=i  h 1  q:$d(^stop)
	s ^stopack=1
	q
