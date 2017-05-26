lvquery;;;
	
numeric	write "only numeric subscripts",!
	kill x
	set x(1)="one"
	set x(5)="five"
	set x(9)="nine"
	set x(13.5)="thirteen.5"
	set x(17)="seventeen"
	set x(31)="thirty one"
	set x(1,2,3,4,5)="one_two_three_four_five"
	set x(13.5,2.6)="thirteen_.5_2.6"
        zwr x
	w "$query x("""")",!
	w $query(x("")),!
	w "$query(x(0))",!
	w $query(x(0)),!
	w "$query(x(4))",!  
	w $query(x(4)),!
	w "$query(x(10))",!
	w $query(x(10)),!
	w "$query(x(12.5))",!  
	w $query(x(12.5)),! 
	w "First do a zwr",!
	zwr x
	w "Now do $query()",!
	set y="x("""")"
	f  s y=$q(@y) q:y=""  w !,y,"=",@y
	q
string	w "only string subscripts",!
	kill x
	s x("")="null"
	zwr x
	w "$q(x(""""))",!
	w $q(x("")),!
	s x("b")="b"
	s x("e")="e"
	zwr x
	w "$q(x(""""))",!
	w $q(x("")),!
	w "$q(x(0))",!
	w $q(x(0)),!
	w "$q(x(""c""))",!
	w $q(x("c")),!
	kill x("")
	zwr x
	w "$q(x(""""))",!
	w $q(x("")),!
	w "$q(x(0))",!
	w $q(x(0)),!
	w "First do a zwr",!
	zwr x
	w "Now do $query()",!
	set y="x("""")"
	f  s y=$q(@y) q:y=""  w !,y,"=",@y
	q
mixed	kill x
	write "==== Both numeric/string subscripts==",!
	s x("")=1
	s x(1)=1
	s x(1,2)=2
	s x(1,2,"")=3
	s x(1,2,"","")=4
	s x(1,2,"","",4)=5
	s x(1,2,0)=6
	s x(1,2,"abc",5)=7
	s x("x")=1
	w "First do a zwr",!
	zwr x
	w "Now do $query()",!
	s y="x("""")"
	f  s y=$q(@y) q:y=""  w !,y,"=",@y 
	q
