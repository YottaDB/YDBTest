per3313 ; ; Test division bug
	;
	set top=100000000.000000001
	Do div(top,100000000.000000002)
	Do div(top,top)
	Do div(top,100000000)
	quit

div(d1,d2)

	set q=d1/d2
	set p=q*d2,plusq=+q
	If (q=plusq)&($Extract(q,1)'="0") Write "PER 3313 succeeded",!
	Else 				  Write "PER 3313 FAILED -- d1 = ",d1,",d2 = ",d2,", d1/d2 = ",q,!
	quit 
