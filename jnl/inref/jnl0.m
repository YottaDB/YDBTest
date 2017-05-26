jnl0(gld);
	set xstr="d in0^jdbfill(""kill"")"  write xstr,!  xecute xstr
	set quote=""""
	set ARG=quote_"set"_quote
	set jmaxwait=0		; spawn off job and dont wait for it to finish
	set jzgbldir=gld	; sets $zgbldir to <input-gld> in the jobbed off command
	do ^job("in0^jdbfill",1,"ARG")
	set xstr="d in1^jdbfill(""set"")"  write xstr,!  xecute xstr
	do wait^job		; wait for spawned off job to finish
	quit
