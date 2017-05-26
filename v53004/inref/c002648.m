c002648	;
	; NOTE: For any changes to this file, check gtcm_gnp/basic is working.
	; C9E10-002648 $O(^GBL(""),-1) gives incorrect result if ^GBL($C(255))) is defined
	;
	; Note : The global names below ("^tst", "^TST" and "^x") are chosen such that they will map to a
	; remote server location in case this is used by the gtcm_gnp test. Do not choose ^A as it is local.
	;
	set linestr="----------------------------------------------------"
	do test1
	do test2
	do test3
	;
	; Test that $REFERENCE is maintained properly by $QUERY (also fixed as part of C9E10-002648)
	do test4
	quit
	;
test1	; -------------------------------------------------------------------------
	; First test case that resulted in creation of C9E10-002648
	; -------------------------------------------------------------------------
	write !,"Running test1",!,linestr,!
	kill ^tst
	set ^tst($c(1))=1
	set ^tst("A")=2
	set ^tst($c(255))=3
	merge tst=^tst
	set subs="" write "Testing $O(-1) for Global",!   for  set subs=$order(^tst(subs),-1)  quit:subs=""  write $a(subs),!
	set subs="" write !,"Testing $O(-1) for Local ",! for  set subs=$order(tst(subs),-1)   quit:subs=""  write $a(subs),!
	write !
	quit
	;
test2	; -------------------------------------------------------------------------
	; Second test case that was attributed to C9E10-002648
	; -------------------------------------------------------------------------
	write !,"Running test2",!,linestr
	new dir,i,totsubs,loop
	kill ^TST
	set totsubs=255
	for i=1:1:255 set ^TST($c(i))=""
	for dir=1,-1  write !,"Direction=",dir,!  set i="" for  set i=$o(^TST(i),dir) quit:i=""  write $a(i)," "
	write !
	quit
	;
test3	; -------------------------------------------------------------------------
	; Complex test case that tests leaf and non-leaf subscripts containing multiple occurrences of $c(255) 
	; -------------------------------------------------------------------------
	write !,"Running test3",!,linestr,!
	new cnt,i,j,totsubs,str,len
	kill ^x,x
	set cnt=64	; test 64 occurrences of $c(255) in subscripts
	;
	; Test 3A : Test $O for leaf subscript 
	;
	; Set $c(1) to $c(255)
	set str="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	set len=$length(str)
	for i=1:1:len  set subs=$extract(str,i) set x(subs)=i,^x(subs)=i,expect(i)=subs
	; Set $c(255,255) through $c(255,255,...64 times)
	set i=255,subs=$c(i)
	for j=len+1:1:len+cnt set subs=subs_$c(i),x(subs)=i_j,^x(subs)=i_j,expect(j)=subs
	set totsubs=j
	do verify(totsubs)
	;
	; Test 3B : Test $O for non-leaf subscript 
	;
	for i=1:1:totsubs for j=1:1:10 set (x(expect(i),j),^x(expect(i),j))=i_j
	do verify(totsubs)
	write "PASS from test3",!
	quit
	;
test4	; -------------------------------------------------------------------------
	; Test that $REFERENCE is maintained properly by $QUERY (also fixed as part of C9E10-002648)
	; Take this opportunity to also test $REFERENCE after $ORDER and $ZPREVIOUS
	; -------------------------------------------------------------------------
	write !,"Running test4",!,linestr,!
	kill ^x,xstr,xresult
	set ^x(1)=1
	set ^x(1,3)=4
	set ^x(1,3,5)=5
	set ^x(1,5,7)=7
	set ^x(1,7,9)=9
	set xstr="^x(1,3)"
	set xresult=$query(@xstr)
	write "$REFERENCE after $query("_xstr_")=",$reference,!
	set xresult=$order(^x(1,5),1)
	write "$REFERENCE after $order(^x(1,5),1)=",$reference,!
	set xresult=$order(^x(1,5),-1)
	write "$REFERENCE after $order(^x(1,5),-1)=",$reference,!
	quit
	;
verify(totsubs);
	new loop,dir
	; verify FORWARD and BACKWARD $Order works fine for GLOBALS & LOCALS
	for dir=1,-1  do
	.	if dir=-1 set start=totsubs,end=1
	.	else      set start=1,end=totsubs
	.	for gname="^x","x" do
	.	.	set subs="" for loop=start:dir  set subs=$order(@gname@(subs),dir)  quit:subs=""  do
	.	.	.	if subs'=expect(loop) do error
	.	.	if loop'=(end+dir) do error
	; verify FORWARD $Order works fine for GLOBALS & LOCALS
	quit
	;
error	;
	write "Verify fail",! zshow "*"
	halt
