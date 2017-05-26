	; testing invalid entry references with ZYERROR

NOLAB	w "Testing 'ZYERROR label' with no label present",!
	s $zt="do ^ztraph"
	s $zyerror="lab+2" ;lab is not present
	kill x
	set x=x+1 ;badline
	q

OFF	w "Testing ZYERROR Lable+offset with invalid offset",!
	s $zt="do ^ztraph"
	set $zyerror="OFF+x"
	kill x
	w x,!
	quit

MOD	w "Testing ZYERROR ^module with no module",!
	s $zt="do ^ztraph"
	set $zyerr="^nowhere"
	kill x
	w x,! q

IND	w "Testing ZYERROR containing erroneous indirection",!
	s $zt="do ^ztraph"
	s ind="+dummy" ; 
	set $zyerr="@ind",x=0
	w 1/x,!
	quit

ZTERR	w "Testing ZYERROR with syntactically erroneous ZTRAP value",!
	s $zt="w:$zv'[""VMS"" $p($zs,"","",3,99),! d0 ^ztraph" ; badline
 	set $zyerr="report^zeleaf"	
	kill x
	s x=x+1
	quit
 
