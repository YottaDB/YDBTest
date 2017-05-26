c002201a;
	ts ():(serial:transaction="online")
	s ^x=1
	tc
	ts ():(serial:transaction="BA")
	s ^y=1
	tc
	ts ():(serial:transaction="BATCH")
	s ^z=1
	tc
	;
	ts ():(serial:transaction="我能吞下玻璃而不伤身体")
	s ^tptype1="chinese"
	tc
        q
