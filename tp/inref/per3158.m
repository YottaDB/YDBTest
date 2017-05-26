PER3158	; ; ; test MUM_TSTART
	;
	n (act)
	i '$d(act) n act s act="w var,"" = "",@$g(var,""**UNDEF**""),!"
	s cnt=0
	Tstart ():transactionid="transaction 1"
	For i=0:1:2 Set ^a(i)=i
	;Zwrite ^a
	;Write "$TLEVEL = ",$Tlevel,!
	;Write "$TRESTART = ",$Trestart,!
	; ERR_TPRETRY appears to be the only way to get into MUM_TSTART
	TRestart:(1>$TRestart)
	Tcommit
	f i=1:1:2 Do
	. s var="^a(i)"
	. s cmp=i
	. i @var'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	Quit	
