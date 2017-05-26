relinks;
	; This is a stressed test for linking and relinking M routines
	; This covers 	1) setting of literals by a routnine which will be replaced
	;		2) calling a label which has been replaced by a new routine but same label name
	;		3) linkage section testing by a caller to a replaced routines
	; 		4) zbreaks being removed by zlinking and new zbreak still works
	; This is done by three routines lnkrtn0, lnkrtn1 and lnkrtn2
	; lnkrtn1 is moved to lnkrtn and after zlink used as lnkrtn. 
	; lnkrtn2 is moved to lnkrtn and after zlink used as lnkrtn. 
	; The test repeatedly replaces lnkrtn by lnkrtn1 and lnkrtn2.
	; lnkrtn0 is never replaced by relinking.
	;
	new $ZT
	SET $ZTRAP="GOTO errcont^errcont" 
	;
	; Initialization Section
	;
	set max=10
	set begline=4
	set maxline=15
	for lineno=begline:1:maxline  do
	. set zblnkrtn(lineno)=0	; For lnkrtn routines zbreak test
	. set zblnkrtn0(lineno)=0	; For lnkrtn0 routine zbreak test
	. zbreak lnkrtn+lineno^lnkrtn0:"set zblnkrtn0("_lineno_")=zblnkrtn0("_lineno_")+1  zc"
	;
	do ^lnkrtn0			; This is complied and linked only here
	;
	; Following will set data1 and newdata1 by lnkrtn1. Also data2 and newdata2 by lnkrtn2
	for cnt=1:1:2 do
	. do enable("lnkrtn1")
	. do ^lnkrtn
	. do entry1^lnkrtn
	. do entry2^lnkrtn
	. do enable("lnkrtn2")
	. do ^lnkrtn
	. do entry1^lnkrtn
	. do entry2^lnkrtn
	. do ^lnkrtn0
	. do entry1^lnkrtn0
	. do entry2^lnkrtn0
	;
	; entry3 labels of lnkrtn1,lnkrtn2,lnkrtn0 do merge operation
	; entry4 of lnkrtn1 calls entry4 of lnkrtn0. Then entry4 of lnkrtn0 calls back to entry3 of caller
	; entry4 of lnkrtn2 calls entry4 of lnkrtn0. Then entry4 of lnkrtn0 calls back to entry3 of caller
	; entry5 of lnkrtn2 merges data1 set by lnkrtn1 into lnkrtn1Tolnkrtn2Merge
	; entry5 of lnkrtn1 merges data2 set by lnkrtn2 into lnkrtn2Tolnkrtn1Merge
	do entry3^lnkrtn0
	do enable("lnkrtn1")
	do entry4^lnkrtn
	do enable("lnkrtn2")
	do entry4^lnkrtn
	do entry4^lnkrtn0
	do enable("lnkrtn1")
	do entry5^lnkrtn
	do enable("lnkrtn2")
	do entry5^lnkrtn
	do entry5^lnkrtn0
	;
	; This tests some function calls
	for cnt=1:1:max do
	. do enable("lnkrtn1")
	. set num=cnt  do squaresub^lnkrtn(.num) set squaresubArray(cnt)=num	; Passed by reference
	. set squarefnArray(cnt)=$$squarefn^lnkrtn(cnt)				; Function call
	. set litfnArray(cnt)=$$litfn^lnkrtn()					; Value passed as global
	. do enable("lnkrtn2")
	. set halfArray(cnt)=$$half^lnkrtn(cnt)					; Function call
	. ;
	do verifyall^lnkrtn0
	;
	quit
enable(fn)
	write "enable:",fn,!
	k zstr
	zsystem "\rm -f lnkrtn.o"
	set zstr="zsystem ""\cp -f "_fn_".m lnkrtn.m"""
	xecute zstr
	zlink "lnkrtn"
	if cnt=1 do
	. for lineno=begline:1:maxline  do
	. . zbreak lnkrtn+lineno^lnkrtn:"set zblnkrtn("_lineno_")=zblnkrtn("_lineno_")+1  zc"
	quit
ERROR
	write "In ZTRAP",$zstatus,!
	halt
