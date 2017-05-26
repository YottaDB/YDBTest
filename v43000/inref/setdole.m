setdole;
	;
	; testcases for set $extract

	Write "setdole starting",!

	;case 1
	set s="abcdefghijklmnopqrstuvwxyz"
	set t="ABCDEFGH"
	set k=$length(s)
	set m=-300
	set n=-10
	do cattest^setdole(s,m,n,k,t)
	K
	;
	set s="abcdefghijklmnopqrstuvwxyz"
	set t="ABCDEFGH"
	set k=$length(s)
	set m=20
	set n=-10
	do cattest^setdole(s,m,n,k,t)
	;
	;case 2
	; delta>=0
	set delta=0
	set s="abcdefghijklmnopqrstuvwxyz"
	set t="ABCDEFGH"
	set k=$length(s)
	set m=k+2+delta
	set n=m-1+delta
	do cattest^setdole(s,m,n,k,t)
	K
	;
	;case 3
	; delta>=0
	set delta=0
	set s="abcdefghijklmnopqrstuvwxyz"
	set t="ABCDEFGH"
	set k=$length(s)
	set m=k+1-delta
	set n=k+1+delta
	do cattest^setdole(s,m,n,k,t)
	K
	;
	; case 4
	set delta=5
	set s="abcdefghijklmnopqrstuvwxyz"
	set t="ABCDEFGH"
	set k=$length(s)
	set m=k+1-delta
	set n=k-1
	do cattest^setdole(s,m,n,k,t)
	K
	;
	FOR I=-60:1:60 DO
	. set s="abcdefghijklmnopqrstuvwxyz"
	. set t="ABCDEFGH"
	. set k=$length(s)
	. set m=I
	. set n=k-I
	. do cattest^setdole(s,m,n,k,t)
	. K (I)
	Q
cattest(s,m,n,k,t)
	new result1,result2,saves
	set saves=s
	set $e(s,m,n)=t
	set result1=s
	if ((m>n)!(n<1))  set result2=saves  goto endlab
	if n'<(m-1),(m-1)>k  set result2=saves_$J("",m-1-k)_t  goto endlab
	if (m-1)'>k,k<n  set result2=$e(saves,1,m-1)_t  goto endlab
	set result2=$e(saves,1,m-1)_t_$e(saves,n+1,k)
endlab;
	if result1'=result2 w "FAIL",! zshow "v"
	else  w "PASS",!
	q
