d002197	;
	; D9C08-002197 Multiple local array based extended references on left of SET causes ACCVIO
	;
	quit
init	;
	kill
	set $zt="write $zstatus  halt"
	quit
test11	;
	; Test case of ONE SETLEFT having a subscripted local variable that is UNDEFINED 
	;
	do init
        set b=2
	set d="one-setleft"
        set (^[a(b)]c)=d
	zwrite ^c
	quit
	;
test12	;
	; Test case of ONE SETLEFT having a subscripted local variable that is DEFINED 
	;
	do init
        set b=2
	set d="one-setleft"
	set a(b)="mumps.gld"
        set (^[a(b)]c)=d
	zwrite ^c
	quit
	;
test21	;
	; Test case of TWO SETLEFT with subscripted local variables that are UNDEFINED
	;
	do init
	set V=1
	set X="two-setleft"
	set I=12
	set (^[%VS(V)]C(I),^[%VS(V)]B(I))=X
	zwrite ^B
	quit
test22	;
	; Test case of TWO SETLEFT with subscripted local variables that are DEFINED
	;
	do init
	set V=1
	set X="two-setleft"
	set %VS(V)="mumps.gld"
	set I=12
	set (^[%VS(V)]C(I),^[%VS(V)]B(I))=X
	zwrite ^B
	quit
