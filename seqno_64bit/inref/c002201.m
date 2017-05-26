c002201;
	ts ():(serial:transaction="online")
	s ^x=1
	tc
	ts ():(serial:transaction="BA")
	s ^y=1
	tc
	ts ():(serial:transaction="BATCH")
	s ^z=1
	tc
        q
