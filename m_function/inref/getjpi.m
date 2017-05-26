getjpiwithincorrectparameter ; test getjpi by providing incorrect parameters and also some positive tests 
	;set $ZTRAP="set errpos=$ZPOS goto errorpos",procid=$JOB
	;set $ETRAP="set errpos=$ZPOS goto errorpos",procid=$JOB
	set $ECODE=""
	set $ETRAP="set j=$STACK,errpos=$STACK(j,""PLACE"") goto errorpos",procid=$JOB
	for i="null","@","a",".afdas","-0","+999999999","*" do
	. ;w "before test: ",$STACK,!
	. w "Testing with incorrect item parameter ",i,!,$zgetjpi(procid,i)
	. ;w "after test: ",$STACK,!
	. ZCONTINUE
	for i="ISPROCALIVE","CPUTIM","CSTIME","CUTIME","STIME","UTIME" do
	. w "Testing with correct item parameter ",i,!,$zgetjpi(procid,i),!
	quit
errorpos;
	;w $ECODE
	;w $STACK
	w $PIECE($ZSTATUS,",",3,4),!
	set lab=$PIECE(errpos,"+",1)
	set offset=$PIECE($PIECE(errpos,"+",2),"^",1)+1
	set nextline=lab_"+"_offset
	set $ECODE=""
	goto @nextline
	
