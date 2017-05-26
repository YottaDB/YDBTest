; Test $query() and set/get facilities.
; This code assumes block size is set to 1024, maximum record size is 10000.
; Character set is NOT UTF-8. This script is called from basic.csh.
dollardata
	write "Parent: SP Child: SP",!
	do testdata("BEGIN"_$justify(" ",9000)_"END","BEGIN"_$justify(" ",9000)_"END")
	write "Parent: SP Child: NON-SP",!
	do testdata("BEGIN"_$justify(" ",9000)_"END","abc")
	write "Parent: NON-SP Child: SP",!
	do testdata("abc","BEGIN"_$justify(" ",9000)_"END")
	write "Parent: NON-SP Child: NON-SP",!
	do testdata("abc","abc")
	; Some other interesting cases
	write "Testing interesting cases",!
	kill ^nsgbl
	set ^nsgbl="root"
	set ^nsgbl(1)=1
	set ^nsgbl(1,1)="BEGIN"_$justify(" ",8900)_"END"
	set ^nsgbl(1,1,1)=2
	set val=$data(^nsgbl(1,1))
	if (val'=11) write "FAILED. $data should be 11 but it is "_val,! halt
	set val=$data(^nsgbl(1,1,1))
	if (val'=1) write "FAILED. $data should be 1 but it is "_val,! halt
	zkill ^nsgbl(1,1)
	set val=$data(^nsgbl(1,1))
	if (val'=10) write "FAILED. $data should be 10 but it is "_val,! halt
	set val=$data(^nsgbl(1,1,0))
	if (val'=0) write "FAILED. $data should be 0 but it is "_val,! halt
	set val=$data(^nsgbl(1,1,1))
	if (val'=1) write "FAILED. $data should be 1 but it is "_val,! halt
	; Another case
	kill ^nsgbl
	set ^nsgbl="BEGIN"_$justify(" ",8900)_"END"
	set ^nsgbl(1)="BEGIN"_$justify(" ",8900)_"END"
	set ^nsgbl(2)="BEGIN"_$justify(" ",8900)_"END"
	set val=$data(^nsgbl(1))
	if (val'=1) write "FAILED. $data should be 1 but it is "_val,! halt
	set val=$data(^nsgbl(2))
	if (val'=1) write "FAILED. $data should be 1 but it is "_val,! halt
	quit

testdata(parent,child)
	kill ^nsgbl
	set ^nsgbl=parent
	set val=$data(^nsgbl)
	if (val'=1) write "FAILED. $data should be 1 but it is "_val,! halt
	set ^nsgbl(1)=child
	set val=$data(^nsgbl)
	if (val'=11) write "FAILED. $data should be 11 but it is "_val,! halt
	zkill ^nsgbl
	set val=$data(^nsgbl)
	if (val'=10) write "FAILED. $data should be 10 but it is "_val,! halt
	kill ^nsgbl
	set val=$data(^nsgbl)
	if (val'=0) write "FAILED. $data should be 0 but it is "_val,! halt
	write "PASSED",!
	quit
