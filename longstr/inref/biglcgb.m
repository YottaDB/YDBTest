biglcgb;
	new unix,xstr
	set unix=$ZVersion'["VMS"
	if unix do
	.	set xstr="view ""NOBADCHAR""" ; avoid default BADCHAR startup due to usage of $zch(128) and $zch(155) literals
	.	xecute xstr
	set unix=$zversion'["VMS"
	SET $ZTRAP="GOTO errproc^errproc" 
	write "Time: ",$h,!
	set TOTAL=10
	kill ^gbl
	if unix set xstr="set index=$ZCHAR(128)"
	else    set xstr="set index=$CHAR(128)"
	xecute xstr
	set index=index_"A"
	set oldind=index
	if unix set xstr="set val=$ZCHAR(155)"
	else    set xstr="set val=$CHAR(155)"
	xecute xstr
	SET val=val_"A"
	set oldval=val
	for i=1:1:118 set index=index_oldind
	for i=1:1:16253 set val=val_oldval
	for i=1:1:TOTAL set ^gbl(i,index)=val
	set ^gbl(i,index,"a")="for naked"
	set ^("naked")=val
	set ^x=$o(^gbl(1,""))
	set ^y=$q(^gbl(1,""))
	set ^name=$name(^gbl(1,index),3)
	;
	write "merge mglcl=^gbl",!   merge mglcl=^gbl
	write "$DATA(mglcl)=",$DATA(mglcl),!
	if $DATA(mglcl)=0  write "TEST-E-FAIL: biglcgb subtest failed",!
	;
	if unix set xstr="set val=$ZCHAR(159)"
	else    set xstr="set val=$CHAR(159)"
	xecute xstr
	SET val=val_"A"
	set oldval=val
	for i=1:1:(16253*32)+4191 set val=val_oldval
	for i=1:1:TOTAL set lcl(i,index)=val
	;
	write "index length=",$length(index),!
	write "val length=",$length(val),!
	kill (lcl)
	; zshow has known problem splitting locals, so zshow is avoided
	;ZSHOW "V":^zwrtst
	;
	write "merge newlcl=lcl",!   merge newlcl=lcl
	write "$DATA(newlcl)=",$DATA(newlcl),!
	if $DATA(newlcl)=0  write "TEST-E-FAIL: biglcgb subtest failed",!
	;
	;; following section will give error
	write "merge ^newgbl=lcl",!   merge ^newgbl=lcl
	if $DATA(^newgbl)'=0  write "TEST-E-FAIL: biglcgb subtest failed",!
	;
	;; following section will give error
	set lcl="lcl"
        tstart (lcl):serial
	write "merge ^newgbl=lcl",!   merge ^newgbl=lcl
	if $tlevel tcommit
	write "Partial commit is done. zwrite ^newgbl=",!  zwrite ^newgbl
	write "Done",!
	q
