unicodeJnlrec;
	if $zv["VMS" quit
	write "unicodeJnlrec Starts",!
	K ^acn
	set ^acn("＠ＡＢＣＤＥＦＧ")="｀ａｂｃｄｅｆｇ"
	w "SET,TSET,USET",!
	S ^acn($CHAR(1000))="this is SET"
	TS
	S ^acn($char(1001))="this is TSET"
	S ^acn($char(1002))="this is USET"
	S ^acn($char(1002),1)="this is USET"
	TC
	TS
	S ^acn(5)="this is TSET"
	S ^acn(6)="this is USET"
	S ^acn(6,1)="this is USET"
	TC
	;
	w "KILL,TKILL,UKILL",!
	K ^acn($char(1000))
	TS
	K ^acn($char(1001))
	K ^acn($char(1002))
	K ^acn($char(1002),1)
	TC
	TS
	K ^acn(5)
	K ^acn(6)
	K ^acn(6,1)
	TC
	if $data(^acn)=10 w "Passed SET and KILL",!
	else  w "Failed SET and KILL",!
	;
	w "SET,TSET,USET",!
	S ^acn(10)="this is SET"
	TS ():(serial:transaction="我能吞下玻璃而不伤身体")
	S ^acn(11)="this is TSET"
	S ^acn(11,11)="this is USET"
	S ^acn(12)="this is USET"
	S ^acn(12,12)="this is USET"
	S ^acn(12,$C(128,255),128,255)="this is USET with $C(128,255),128,255)"
	TC
	TS
	S ^acn($char(2000))="this is TSET"
	S ^acn($char(2000),$char(2000))="this is USET"
	S ^acn($char(3000))="this is USET"
	S ^acn($char(3000),$char(3000))="this is USET"
	TC
	;
	w "ZKILL,TZKILL,UZKILL",!
	ZKILL ^acn(10)
	TS
	ZKILL ^acn(11)
	ZKILL ^acn(12)
	TC
	TS
	ZKILL ^acn($char(2000))
	ZKILL ^acn($char(3000))
	TC
	;
	do verify
	if +$get(errcnt)=0 write "Passed from unicodeJnlrec",!
	else   write "Failed from unicodeJnlrec",!
	q
	;
verify;
	do ^examine(^acn(11,11),"this is USET","^acn(11,11)")
	do ^examine(^acn(12,12),"this is USET","^acn(12,12)")
	do ^examine(^acn(12,$C(128,255),128,255),"this is USET with $C(128,255),128,255)","^acn(12,$C(128,255),128,255)")
	do ^examine(^acn($C(2000),$C(2000)),"this is USET","^acn($C(2000),$C(2000))")
	do ^examine(^acn($C(3000),$C(3000)),"this is USET","^acn($C(3000),$C(3000))")
	do ^examine(^acn("＠ＡＢＣＤＥＦＧ"),"｀ａｂｃｄｅｆｇ","^acn(""＠ＡＢＣＤＥＦＧ"")")
	q
