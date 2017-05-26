tprlbk3(iterate);
	set $ztrap="goto ERROR^tprlbk3"
        tstart
	do in1^pfill1("set",1+1#10+1,1+iterate)
        tstart
	do in1^pfill1("set",1+1#10+1,1+iterate)
        tstart
	do in1^pfill1("set",1+1#10+1,1+iterate+1)
        tstart
	do in1^pfill1("kill",1+1#10+1,1+iterate+1)
        trollback -3
        tstart
	do in1^pfill1("set",1+2#10+1,1+iterate+1)
	do in1^pfill1("set",1+2#10+1,1+iterate+2)
	tcommit
        tstart
	do in1^pfill1("kill",1+3#10+1,1+iterate+1)
	trollback 1
	do in1^pfill1("kill",1+2#10+1,1+iterate+1)
	tcommit
	write "verifying...",!
	do in1^pfill1("ver",1+1#10+1,1+iterate)
	do in1^pfill1("ver",1+1#10+1,1+iterate+2)
	for iter=1:1:100 do
	.	if $data(^a(iter,1+iterate+1))'=0 write "unexpected data present",!
	.	if $data(^i(iter,1+iterate+1))'=0 write "unexpected data present",!
	quit
	; grep for FAIL in *.mjo*

ERROR   set $ZT=""
        if $tlevel trollback
        zshow "*"
        zmessage +$zstatus
	quit
