	; testing invalid entry references with ZTRAP

NOLAB	w "Testing 'ZTRAP label' with no label present",!
	s $zt="lab+2" ;lab is not present
	kill x
	w x,! q

OFF	w "Testing Ztrap Lable+offset with invalid offset",!
	set y=1000,$ztrap="OFF+y"; offset 1000 doen't exist
	kill x
	w x,!
	quit

MOD	w "Testing Ztrap ^module with no module",!
	set $ztrap="^nowhere"
	kill x
	w x,! q

SUB4	w "Testing Ztrap containing erroneous indirection",!
	s ind="+dummy" ; 
	set $ztrap="@ind"
	kill x
	w x,! q

IND	w "Testing invalid indirection @(lab+off)^mod)",!
	s ind="lab+0"
	set $ztrap="@ind^ztleaf"
	kill x
	w x,! q
