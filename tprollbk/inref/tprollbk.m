;;####################################################################################
;;					BASIC
;;####################################################################################

test0
	set errcnt=0
	tstart
	tstart
	tstart
	if $tlevel'=3 set errcnt=errcnt+1
	trollback -3
	if $tlevel'=0 set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST0^TPROLLBK",!
	else  write "FAIL from TEST0^TPROLLBK",!
	halt
test1
	tstart
	set ^x(323)="different"
	set ^x(120)="different"
	set ^x(999)="data changed"
	set ^x(3000)="new index"
	tstart
	set ^x(999)="very different"
	set ^x(3000)="undo new index"
	trollback 1
	tcommit
	do chktst1^tprollbk
	halt

chktst1
	set errcnt=0
	if ^x(999)'="data changed" set errcnt=errcnt+1
	if ^x(3000)'="new index" set errcnt=errcnt+1
	if ^x(323)'="different" set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST1^TPROLLBK",!
	else  write "FAIL from TEST1^TPROLLBK",!
	quit

test2
	set errcnt=0
	tstart
	for i=1:2:1000 do
	.	set ^x(i)=i
	.	quit
	for i=2:2:1000 do
	.	set ^x(i)="second"
	.	quit
	tstart
	for i=2:2:1000 do
	.	set ^x(i)="different"
	.	quit
	if ^x(1)'=1 set errcnt=errcnt+1
	if ^x(2)'="different" set errcnt=errcnt+1
	if ^x(999)'=999 set errcnt=errcnt+1
	if ^x(1000)'="different" set errcnt=errcnt+1
	trollback -1
	write "After Rollback ...",!
	if ^x(1)'=1 set errcnt=errcnt+1
	if ^x(2)'="second" set errcnt=errcnt+1
	if ^x(999)'=999 set errcnt=errcnt+1
	if ^x(1000)'="second" set errcnt=errcnt+1
	for i=1:1:1000 do
	.	if $data(^x(i))'=1 write "DATA LOST - ^x(",i,")",! set errcnt=errcnt+1
	tcommit
	if errcnt=0 write "PASS from TEST2^TPROLLBK",!
	else  write "FAIL from TEST2^TPROLLBK",!
	halt

test3
	tstart
	set ^x(923)="different"
	set ^x(913)="different"
	set ^x(413)="different"
	set ^x(417)="different"
	tstart
	set ^x(123)="different"
	set ^x(417)="not different"
	trollback 1
	tcommit
	do chktst3^tprollbk
	halt

chktst3
	set errcnt=0
	for i=1:1:1000 do
	.	if $data(^x(i))'=1 write "DATA LOST - ^x(",i,")",! set errcnt=errcnt+1
	if ^x(923)'="different" set errcnt=errcnt+1
	if ^x(123)'=123 set errcnt=errcnt+1
	if ^x(417)'="different" set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST3^TPROLLBK",!
	else  write "FAIL from TEST3^TPROLLBK",!
	quit

test4
	tstart
	set ^x=3
	trollback -1
	tstart
	tstart
	trollback -1
	tcommit
	do chktst4^tprollbk
	halt

chktst4
	set errcnt=0
	if $data(^x)'=0 write "FAIL from TEST4^TPROLLBK",!
	else  write "PASS from TEST4^TPROLLBK",!
	quit

test5
	tstart
	set ^x="new one"
	set ^x(10000)="different"
	set ^x(9990)="different"
	tstart
	set ^y=32
	set ^y("andweqrerwqwqerewrewqerw")="new in second level"
	set ^x(9990)="different"
	tstart
	set ^x(10000)="not different"
	trollback -2
	tcommit
	do chktst5^tprollbk
	halt

chktst5
	set errcnt=0
	for i=1:1:1000 do
	.	if $data(^x(i))'=1 write "DATA LOST - ^x(",i,")",!
	if ^x(10000)'="different" set errcnt=errcnt+1
	if ^x(9990)'="different" set errcnt=errcnt+1
	if $data(^z)'=0 set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST5^TPROLLBK",!
	else  write "FAIL from TEST5^TPROLLBK",!
	quit

test6
	tstart
	set ^x=45
	tstart
	set ^y=45
	tstart
	set ^z=45
	tcommit
	trollback -1
	tcommit
	do chktst6^tprollbk
	halt

chktst6
	set errcnt=0
	if ^x'=45 set errcnt=errcnt+1
	if $data(^y)'=0 set errcnt=errcnt+1
	if $data(^z)'=0 set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST6^TPROLLBK",!
	else  write "FAIL from TEST6^TPROLLBK",!
	quit

test7
	tstart
	set ^x=45
	tstart
	set ^y=45
	tcommit
	tstart
	set ^z=45
	trollback -1
	tstart
	set ^w=45
	tstart
	set ^p=400
	trollback -2
	tcommit
	do chktst7^tprollbk
	halt

chktst7
	set errcnt=0
	if ^x'=45 set errcnt=errcnt+1
	if ^y'=45 set errcnt=errcnt+1
	if $data(^z)'=0 set errcnt=errcnt+1
	if $data(^w)'=0 set errcnt=errcnt+1
	if $data(^p)'=0 set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST7^TPROLLBK",!
	else  write "FAIL from TEST7^TPROLLBK",!
	quit

test8
	tstart
	set ^x(1)=1
	set ^x(2)=1
	set ^x(3)=1
	tstart
	set ^y(1)=1
	set ^y(2)=1
	set ^x(3)=1
	tstart
	set ^x(2)=2
	trollback -2
	tcommit
	do chktst8^tprollbk
	halt

chktst8
	set errcnt=0
	for i=1:1:3 do
	.	if ^x(i)'=1 write "DATA LOST - ^x(",i,")",! set errcnt=errcnt+1
	if $data(^y)'=0 set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST8^TPROLLBK",!
	else  write "FAIL from TEST8^TPROLLBK",!
	quit

test9
	set errcnt=0
	tstart
	set ^x=1
	tstart
	set ^y=1
	tstart
	set ^z=1
	trollback -1
	if $data(^z)'=0 set errcnt=errcnt+1
	if $data(^x)=0 set errcnt=errcnt+1
	if $data(^y)=0 set errcnt=errcnt+1
	trollback -1
	if $data(^x)=0 set errcnt=errcnt+1
	if $data(^y)'=0 set errcnt=errcnt+1
	if $data(^y)'=0 set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST9^TPROLLBK",!
	else  write "FAIL from TEST9^TPROLLBK",!
	halt

test10
	tstart
	set ^x=45
	tstart
	set ^x=45
	set ^y=45
	tstart
	set ^x=45
	trollback -2
	tcommit
	do chktst10^tprollbk
	halt

chktst10
	set errcnt=0
	if $data(^x)=0 set errcnt=errcnt+1
	if $data(^y)'=0 set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST10^TPROLLBK",!
	else  write "FAIL from TEST10^TPROLLBK",!
	quit

test11
	tstart
	set ^x(1,500.5,$j(500.5,170))=$j(500.5,170)
	tstart
	kill ^x(1)
	trollback 1
	tcommit
	do chktst11^tprollbk
	do test12
	halt

chktst11
	set errcnt=0
	for i=1:1:1000 do
	.	if $data(^x(1,i,$j(i,170)))'=1 write "DATA LOST - ^x(",i,",$j(",i,170,")",! set errcnt=errcnt+1
	if errcnt=0 write "PASS from TEST11^TPROLLBK",!
	else  write "FAIL from TEST11^TPROLLBK",!
	quit

test12
	set (errcnt,^xx(0))=0
	for iso=0,1 d
	. if iso view "NOISOLATION":"^xx"
	. tstart
	. tstart
	. set ^xx(0)=1
	. trollback 1
	. if $incr(errcnt,^xx(0))
	. tcommit
	if errcnt write "FAIL from ",$ZPOS,!
	quit 

undooff
	set ^x=1
	tstart ():serial
	for i=1:2:53 set ^x($j(i,200))=$j(i,250)
	tstart ():serial
	set ^x($j(i/2,200))=$j(i/2,250)
	zwrite ^x
	trollback -1
	tcommit
	do chkundo^tprollbk
	halt

chkundo
	set errcnt=0
	for i=1:2:53 do
	.	if $data(^x($j(i,200)))'=1 write "DATA LOST - ^x(",",$j(",i,200,")",! set errcnt=errcnt+1
	if $data(^x($j(i/2,200)))'=1 set errcnt=errcnt
	else  set errcnt=errcnt+1
	if errcnt=0 write "PASS from UNDOOFF^TPROLLBK",!
	else  write "FAIL from UNDOOFF^TPROLLBK",!
	quit

creundo
	set ^x=1
	tstart ():serial
	for i=1:2:53 set ^x($j(i,200))=$j(i,250)
	set ^x($j(i/2,200))=$j(i/2,250)
	tcommit
	halt

killundo
	for i=1:2:53 kill ^x($j(i,200))
	kill ^x($j(i/2,200))
	halt

d001618 ;
	view "GDSCERT":1
	set ^x(3)=5
	tstart ():serial
	set ^x(2)=$j(2,900)
	set ^x(1)=$j(1,900)
	tstart
	set ^x(0.5)=1
	tcommit
	set ^x(4)=$j(4,200)
	tcommit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; do application-check on data
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	set errcnt=0
	if ^x(0.5)'=1 set errcnt=errcnt+1
	if ^x(1)'=$j(1,900) set errcnt=errcnt+1
	if ^x(2)'=$j(2,900) set errcnt=errcnt+1
	if ^x(3)'=5 set errcnt=errcnt+1
	if ^x(4)'=$j(4,200) set errcnt=errcnt+1
	if errcnt=0 write "PASS from d001618^TPROLLBK",!
	else  write "FAIL from d001618^TPROLLBK",!
	halt

;;####################################################################################
;;					STRESS
;;####################################################################################


stress0
	tstart ()
	tstart ()
	for i=1:1:10 set ^y(i)=$j(i,100)
	trollback -1
	tstart ()
	for i=1:1:10 set ^z(i)=$j(i,100)
	trollback -1
	trollback -1
	do chkstr0^tprollbk
	halt

chkstr0
	set errcnt=0
	if $data(^y)'=0 write "ERROR",! set errcnt=errcnt+1
	if $data(^z)'=0 write "ERROR",! set errcnt=errcnt+1
	if errcnt=0 write "PASS from STRESS0",!
	else  write "FAIL from STRESS0",!
	quit

stress1
	tstart ()
	for i=1:1:1000 set ^x(i)=$j(i,100)
	tstart ()
	for i=1:1:1000 set ^y(i)=$j(i,100)
	trollback -1
	tstart ()
	for i=1:1:100 set ^z(i)=$j(i,100)
	trollback -1
	trollback -1
	do chkstr1^tprollbk
	halt

chkstr1
	set errcnt=0
	if $data(^x)'=0 write "ERROR",! set errcnt=errcnt+1
	if $data(^y)'=0 write "ERROR",! set errcnt=errcnt+1
	if $data(^z)'=0 write "ERROR",! set errcnt=errcnt+1
	if errcnt=0 write "PASS from STRESS1",!
	else  write "FAIL from STRESS1",!
	quit

stress2
	tstart ()
	tstart ()
	for i=1:1:2000 set ^x(i)=$j(i,100)
	tstart ()
	for i=1:1:2000 set ^y(i)=$j(i,100)
	trollback -2
	tstart ()
	for i=1:1:2000 set ^z(i)=$j(i,100)
	trollback -1
	trollback -1
	do chkstr2^tprollbk
	halt

chkstr2
	set errcnt=0
	if $data(^x)'=0 write "ERROR",! set errcnt=errcnt+1
	if $data(^y)'=0 write "ERROR",! set errcnt=errcnt+1
	if $data(^z)'=0 write "ERROR",! set errcnt=errcnt+1
	if errcnt=0 write "PASS from STRESS2",!
	else  write "FAIL from STRESS2",!
	quit

stress3
	for i=1:1:1000 do
	.	tstart ()
	.	for i=1:1:1000 set ^x(i)=$j(i,100)
	.	tstart ()
	.	for i=1:1:1000 set ^y(i)=$j(i,100)
	.	trollback -1
	.	trollback -1
	.	quit
	do chkstr3^tprollbk
	halt

chkstr3
	set errcnt=0
	if $data(^x)'=0 write "ERROR",! set errcnt=errcnt+1
	if $data(^y)'=0 write "ERROR",! set errcnt=errcnt+1
	if errcnt=0 write "PASS from STRESS3",!
	else  write "FAIL from STRESS3",!
	quit

;;####################################################################################
;;					LOCKS
;;####################################################################################

lock0
	tstart
	for i=1:1:4 lock +^a(i)
	for i=1:1:4 lock +^b(i)
	zshow "L"
	write "******************",!
	tstart
	for i=3:1:8 lock +^a(i)
	for i=3:1:8 lock +^c(i)
	zshow "L"
	write "******************",!
	trollback 1
	zshow "L"
	write "******************",!
	lock
	tcommit
	zshow "L"
	write "******************",!
	halt

lock1
	tstart
	for i=1:1:4 lock +^a(i)
	for i=1:1:4 lock +^b(i)
	zshow "L"
	write "******************",!
	tstart
	for i=3:1:8 lock +^a(i)
	for i=3:1:8 lock +^c(i)
	zshow "L"
	tcommit
	write "******************",!
	tstart
	for i=3:1:8 lock +^a(i)
	for i=3:1:8 lock +^c(i)
	zshow "L"
	write "******************",!
	trollback 1
	zshow "L"
	write "******************",!
	lock
	tcommit
	zshow "L"
	write "******************",!
	halt
