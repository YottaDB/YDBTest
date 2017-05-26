maxrsno(srcfile,subtract,resfile);
	SET $ZT="s $ZT="""" g ERROR"
	set maxsno=0
	OPEN srcfile:(READONLY:REC=32000)
	F  U srcfile Q:$ZEOF  R sseqno D
	.	set hseqno=$p(sseqno,"0x",2)
	.	set dseqno=$$FUNC^%HD(hseqno)
	.	if dseqno>maxsno set maxsno=dseqno
	C srcfile
	set maxsno=maxsno-subtract
	if maxsno<1 set maxsno=1
	O resfile:new
	U resfile
	W maxsno
	C resfile
	q 
	;

ERROR   ZSHOW "*"
        IF $TLEVEL TROLLBACK
        ZM +$ZS  

