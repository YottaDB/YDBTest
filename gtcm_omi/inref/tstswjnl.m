
tstswjnl ;testing switching journal files on the fly.

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
	;do sets for all regions to exercise the journalling code
	w "do sets for all regions to exercise the journalling code",!
	for i=1:1:100 s res(1,i)=$$^set("^default"_"("_i_")",i) if res(1,i)'=1 s cnt=cnt+1 
	i cnt'=0 x act zgoto %ZL
	e  kill res
	for i=1:1:100 s res(2,i)=$$^set("^A"_"("_i_")",i) if res(2,i)'=1 s cnt=cnt+1 
	i cnt'=0 x act zgoto %ZL 
	e  kill res
	for i=1:1:100 s res(3,i)=$$^set("^B"_"("_i_")",i) if res(3,i)'=1 s cnt=cnt+1 
	i cnt'=0 x act zgoto %ZL 
	e  kill res
	for i=1:1:100 s res(4,i)=$$^get("^default"_"("_i_")") if res(4,i)'=i s cnt=cnt+1 
	i cnt'=0 x act zgoto %ZL
	e  kill res
	set res=$$^disc()
	Quit

normal	;Not via GT.CM!
	for i=1:1:10	set ^A(i)=i set ^default(i)=i set ^B(i)=i
	Quit
