d9002426
main;
	for index=1:1:1000 do
	. set ^b(index)=index
	. set ^c(index)=index
	. set ^a(index)=index
	q
bkgrnd;
	set ^c($h)=$j	; Flushes CREG
	hang 1
	set ^b($h)=$j	; Flushes BREG
	set jmaxwait=0
	do ^job("bkjob^d9002426",2,"""""")
	quit
bkjob;
        write "PID: ",$J,!,"In hex: ",$$FUNC^%DH($j),!
	If $zv["VMS" DO ^jobname(jobindex)
	for index=1:1:1000000000 do
	. set ^b(index,index)=$j(index,200)
	. set ^c(index,index)=$j(index,200)
	. if jobindex=1 h 10
	q
verify;
	for index=1:1:1000 do
	. if $get(^a(index))'=index write "Verify fail for ^a(",index,"): Expected ",index," Found ",$get(^a(index)),!
	. if $get(^b(index))'=index write "Verify fail for ^b(",index,"): Expected ",index," Found ",$get(^b(index)),!
	. if $get(^c(index))'=index write "Verify fail for ^c(",index,"): Expected ",index," Found ",$get(^c(index)),!
	quit
 
