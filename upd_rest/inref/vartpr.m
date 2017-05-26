vartpr;
	do ^job("readjob^vartpr",6,"""""")
	quit
	;
readjob
	set $ZT="SET $ZT="""" g ERROR^cnflread"
	write "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	for timeout=100:-1:0 quit:$DATA(^arandom)  hang 1 	;wait for at least one of the globals
	if 'timeout write "TEST-E-TIMEOUT, waited too long for ^arandom",!  write "End   Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),! quit
	write "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	write "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	for repeat=1:1:3 do
	.	set begstr=$o(^arandom(""))
	.	set endstr=$o(^arandom(""),-1)
	.	set begtr=$tr(begstr," ",0)
	.	set endtr=$tr(endstr," ",0)
	.	set beg=+begtr
	.	set end=+endtr
	.	if end>beg+1024 set end=beg+1024
	.	write "Index for zwr:",beg,":",end,!
	.	zwrite ^arandom(beg:end)
	.	zwrite ^brandomv(beg:end)
	.	zwrite ^crandomva(beg:end)
	.	zwrite ^drandomvariable(beg:end)
	.	zwrite ^erandomvariableimptp(beg:end)
	.	zwrite ^frandomvariableinimptp(beg:end)
	.	zwrite ^grandomvariableinimptpfill(beg:end)
	.	zwrite ^hrandomvariableinimptpfilling(beg:end)
	.	zwrite ^irandomvariableinimptpfillprgrm(beg:end)
	.	zwrite ^jrandomvariableinimptpfillprogram(beg:end)
	write "End   Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!
	;
	quit
ERROR	zshow "*"
	if $TLEVEL trollback
	quit
