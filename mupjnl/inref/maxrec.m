maxrec;
	new unix,xstr
	set unix=$zversion'["VMS"
	SET $ZT="SET $ZT="""" g ERROR^maxrec"
	if unix set xstr="SET index=$ZCHAR(128)"
	else    set xstr="SET index=$CHAR(128)"
	xecute xstr
	set index=index_"A"
	SET oldind=index
	if unix set xstr="SET val=$ZCHAR(155)"
	else    set xstr="SET val=$CHAR(155)"
	xecute xstr
	SET val=val_"A"
	SET oldval=val
	k ^var
	For i=1:1:80 S index=index_oldind
	For i=1:1:369 S val=val_oldval
	For i=1:1:1200 SET ^var(i,index)=val
        S ^var(i,index,"a")="for naked"
        S ^("naked")=val
        S ^x=$o(^var(1,""))
        S ^y=$q(^var(1,""))
        merge ^z=^y
        S ^name=$name(^var(1,index),3)
	q
ERROR	ZSHOW "*"
	q
