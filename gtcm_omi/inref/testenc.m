
viagtcm	;set via gtcm and verify.
	n (act)
	i '$d(act) n act s act="w ! zsh ""*"""
	s %ZL=$ZLEVEL
	do ^cmclient(2,101,$ZPARSE("mumps.gld"))
	set portfile="portno.txt" open portfile use portfile
	read port
	close portfile
	i $$^connect("127.0.0.1",port,"user","pw")=0 w "Attempted connection to GT.CM server failed!",! q
	s cnt=0
	w "Updates some globals to database without gtm_passwd",!
	set i=1
	s res(1,i)=$$^set("^default"_"("_i_")",i) 
	Quit
