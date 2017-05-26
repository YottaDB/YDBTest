c001087	;
	; Test miscellaneous fixes that went in as part of the C9905-001087 project (improve LV performance)
	;
	write "Setting GT.M     null subscript collation returned ",$$set^%LCLCOL(0,0)
	do test1
	do test2
	write !!,"Setting Standard null subscript collation returned ",$$set^%LCLCOL(0,1)
	do test1
	do test2
	;
	do test3
	do test4
	write !
	quit
	;
test1	;
	; Test $query handling of null subscripts
	;
	new
	set str(0)="GT.M",str(1)="Standard"
	set ncol=$$getncol^%LCLCOL
	write !!,"--> test1 : Test $query handling of null subscripts with "_str(ncol)_" Null collation"
	set a("")=0
	set a("",1)=0
	set ref="a("""")"
	for  set ref=$q(@ref) Quit:ref=""  write !,ref
	quit
	;
test2	;
	; Test $query handling of null subscripts
	;
	new
	set str(0)="GT.M",str(1)="Standard"
	set ncol=$$getncol^%LCLCOL
	write !!,"--> test2 : One more test of $query handling of null subscripts with "_str(ncol)_" Null collation"
	set lcl("")=1
	set lcl("",1)=1
        set lcl(1)=1
        set lcl(1,2)=2
        set lcl(1,2,"")=3
        set lcl(1,2,"","")=4
        set lcl(1,2,"","",4)=5
        set lcl(1,2,0)=6
        set lcl(1,2,"abc",5)=7
        set lcl("x")=1
	set y="lcl("""")" for  set y=$query(@y)  quit:y=""  write !,y,"=",@y
	quit
	;
test3	;
	; Test $next issue
	;
	new
	write !!,"--> test3 : Test $next handling"
	set x="-" 
	set y="1"
	set z=x_y
	set x(1)=1
	set x(-2)=1
	write !,z		; expected -1
	write !,$next(x(z))	; expected -2 but pre-V54002 reported 1
	write !,$next(x(-1))	; expected -2
	quit
	;
test4	;
	; As part of unw_mv_ent, if a symbol table pops, we need to go through its hashtable
	; and find all local variable trees and FREE them up. Note: This is a regression that occurred
	; during the C9905-001087 project so this test wont fail in pre-V54002 or post-V54002.
	; Note down $zrealstor value at iteration 100 and at iteration 1000. We expect them to be identical
	; that way we know for sure there is no memory leak. We start with iteration 100 (not iteration 1) since
	; it might take a few iterations to reach steady state.
	;
	new
	write !!,"--> test4 : Test for no memory-leaks during symbol table pop"
	for i=1:1:1000  do memleakhelper  do
	.	if i=100 set startmem=$zrealstor
	.	if i=1000 set endmem=$zrealstor
	if startmem'=endmem  write !,"FAIL from test4",!  zshow "*"
	else  write !,"PASS from test4"
	quit
	;
memleakhelper ;
	new
	for j=1:1:100 s (x(j),y(j),z(j))=$j(j,20)
	quit
	;
