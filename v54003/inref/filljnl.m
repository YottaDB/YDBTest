fill
	s foo=$tr($j("",16000)," ","0")
	s bar=$tr($j("",16000)," ","1")
	for i=1:1:66559 d
	. s ^a=foo
	. s ^b=bar
	. s ^a=bar
	. s ^b=foo
	q
