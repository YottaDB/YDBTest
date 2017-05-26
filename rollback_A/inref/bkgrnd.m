bkgrnd	;
	set output="bkgrnd.mjo0",error="bkgrnd.mje0"
        open output:newversion,error:newversion
        use output
        ; Must write PID to *.mjo files
        write "PID: ",$J,!
        close output
	set unix=$zv'["VMS"
	if 'unix do
	.	set pout="PNAME.JOB0"
	.	open pout:newversion
	.	use pout
	.	write $ZGETJPI("","PRCNAM"),!
	.	close pout
	set dummy=1_$j(1,200)
	set cnt=1
	for j=1:1:10000000000 do
	. set ^a(cnt)=dummy  set cnt=cnt+1
	. set ^b(cnt)=dummy  set cnt=cnt+1
	. set ^c(cnt)=dummy  set cnt=cnt+1
	. set ^d(cnt)=dummy  set cnt=cnt+1
	. set ^e(cnt)=dummy  set cnt=cnt+1
	. set ^f(cnt)=dummy  set cnt=cnt+1
	. set ^g(cnt)=dummy  set cnt=cnt+1
	. set ^h(cnt)=dummy  set cnt=cnt+1
	. set ^i(cnt)=dummy  set cnt=cnt+1
	quit
chkdata	;
	set endi(1)=$o(^a(""),-1)
	set endi(2)=$o(^b(""),-1)
	set endi(3)=$o(^c(""),-1)
	set endi(4)=$o(^d(""),-1)
	set endi(5)=$o(^e(""),-1)
	set endi(6)=$o(^f(""),-1)
	set endi(7)=$o(^g(""),-1)
	set endi(8)=$o(^h(""),-1)
	set endi(9)=$o(^i(""),-1)
	set max=0
	for i=1:1:9 do
	. if endi(i)>max  set max=endi(i)
	set dummy=1_$j(1,200)
	set cnt=1
	set errcnt=0
	for  q:cnt>max   do
	. if $GET(^a(cnt))'=dummy  write "FAILED ","^a(",cnt,")=",$GET(^a(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^b(cnt))'=dummy  write "FAILED ","^b(",cnt,")=",$GET(^b(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^c(cnt))'=dummy  write "FAILED ","^c(",cnt,")=",$GET(^c(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^d(cnt))'=dummy  write "FAILED ","^d(",cnt,")=",$GET(^d(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^e(cnt))'=dummy  write "FAILED ","^e(",cnt,")=",$GET(^e(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^f(cnt))'=dummy  write "FAILED ","^f(",cnt,")=",$GET(^f(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^g(cnt))'=dummy  write "FAILED ","^g(",cnt,")=",$GET(^g(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^h(cnt))'=dummy  write "FAILED ","^h(",cnt,")=",$GET(^h(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if $GET(^i(cnt))'=dummy  write "FAILED ","^i(",cnt,")=",$GET(^i(cnt)),!  set errcnt=errcnt+1
	. set cnt=cnt+1  if cnt>max halt
	. if errcnt>100  write "Too many errors. max index=",max,!  halt
	quit
	;
chkextr(before) ;
	write "Checking AREG...",!
	set seq(1)=$$averify
	write "Checking BREG...",!
	set seq(2)=$$bverify
	write "Checking CREG...",!
	set seq(3)=$$cverify
	write "Checking DREG...",!
	set seq(4)=$$dverify
	write "Checking EREG...",!
 	set seq(5)=$$everify
	write "Checking FREG...",!
	set seq(6)=$$fverify
	write "Checking GREG...",!
	set seq(7)=$$gverify
	write "Checking HREG...",!
	set seq(8)=$$hverify
	write "Checking DEFAULT...",!
	set seq(9)=$$mverify
	; if before rollback, we don't need to check the holes between regions
 	if '(before) do chkseq
	quit
	;
chkseq	; check holes between regions
	write "Checking between regions...",!
	set failed=0
	set ano=seq(1)
	set bno=seq(2)
	set cno=seq(3)
	set dno=seq(4)
	set eno=seq(5)
	set fno=seq(6)
	set gno=seq(7)
	set hno=seq(8)
	set mno=seq(9)
	;
	if '((bno-ano=1)!(ano-bno=8)) do
	. write "Holes between AREG and BREG.",! 
	. write "End seqno for AREG is ",ano,!
	. write "End seqno for BREG is ",bno,!
	. set failed=1
        if '((cno-bno=1)!(bno-cno=8)) do 
	. write "Holes between BREG and CREG.",!
	. write "End seqno for BREG is ",bno,!
	. write "End seqno for CREG is ",cno,!
	. set failed=1
        if '((dno-cno=1)!(cno-dno=8)) do 
	. write "Holes between CREG and DREG.",!
	. write "End seqno for CREG is ",cno,!
	. write "End seqno for DREG is ",dno,!
	. set failed=1
        if '((eno-dno=1)!(dno-eno=8)) do 
	. write "Holes between DREG and EREG.",!
	. write "End seqno for DREG is ",dno,!
	. write "End seqno for EREG is ",eno,!
	. set failed=1
        if '((fno-eno=1)!(eno-fno=8)) do 
	. write "Holes between EREG and FREG.",!
	. write "End seqno for EREG is ",eno,!
	. write "End seqno for FREG is ",fno,!
	. set failed=1
        if '((gno-fno=1)!(fno-gno=8)) do
	. write "Holes between FREG and GREG.",!
	. write "End seqno for FREG is ",fno,!
	. write "End seqno for GREG is ",gno,!
	. set failed=1
        if '((hno-gno=1)!(gno-hno=8)) do
	. write "Holes between GREG and HREG.",!
	. write "End seqno for GREG is ",gno,!
	. write "End seqno for HREG is ",hno,!
	. set failed=1
        if '((mno-hno=1)!(hno-mno=8)) do 
	. write "Holes between HREG and DEFAULT.",!
	. write "End seqno for HREG is ",hno,!
	. write "End seqno for DEFAULT is ",mno,!
	. set failed=1
	if '((ano-mno=1)!(mno-ano=8)) do
        . write "Holes between DEFAULT and AREG.",!
        . write "End seqno for DEFAULT is ",mno,!
	. write "End seqno for AREG is ",ano,!
        . set failed=1
	if '(failed) write "VERIFICATION PASSED.",!
        quit
	;
averify()	;
	new endseq
	set startno=1
	set pointer=startno
	set exfile="a.mjf"
	do goverify(.endseq)
	quit endseq
bverify()	;
	new endseq
        set startno=2
        set pointer=startno
        set exfile="b.mjf"
        do goverify(.endseq)
        quit endseq
	;
cverify()	;
	new endseq
        set startno=3
        set pointer=startno
        set exfile="c.mjf"
        do goverify(.endseq)
        quit endseq
	;
dverify();
	new endseq
        set startno=4
        set pointer=startno
        set exfile="d.mjf"
        do goverify(.endseq)
        quit endseq
	;
everify()	;
	new endseq
        set startno=5
        set pointer=startno
        set exfile="e.mjf"
        do goverify(.endseq)
        quit endseq
	;
fverify()	;
	new endseq
        set startno=6
        set pointer=startno
        set exfile="f.mjf"
        do goverify(.endseq)
        quit endseq
	;
gverify()	;
	new endseq
        set startno=7
        set pointer=startno
        set exfile="g.mjf"
        do goverify(.endseq)
        quit endseq
	;
hverify()	;
	new endseq
        set startno=8
        set pointer=startno
        set exfile="h.mjf"
        do goverify(.endseq)
        quit endseq
	;
mverify() ;
	new endseq
        set startno=9
        set pointer=startno
        set exfile="mumps.mjf"
        do goverify(.endseq)
        quit endseq
	;
goverify(end) ;
	open exfile:(readonly)
	use exfile:excepton="G eof"
	set failed=0
	set done=0
	for  do  q:done
	. use exfile
	. r line
	. set type=$p(line,"\",1)
	. if type="05" do  q:failed
	.. set seqno=$p(line,"\",6)
	.. set value=$p(line,"\",$length(line,"\"))
	.. if (pointer'=seqno) do
	... use $p write "VERIFICATION FAILED at seqno: ",seqno,"."
	... write "It should be :",pointer,!
	... set pointer=seqno
	... set failed=1
	.. set pointer=pointer+9
	. if $ZEOF set done=1
	quit
	;
eof	;
	if $ZEOF set done=1
	close exfile
	use $p
	set end=pointer-9
	if done write "VERIFICATION PASSED",!
	q
	
