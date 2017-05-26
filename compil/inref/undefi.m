undefi	;test for problem handling indirection UNDEF errors
	;	
	k
	n $zt
	s a=5,b="c",$zt="g lab1"
	w c
lab1	s $zt="g lab2"
	s a=@b
lab2	w !,$s($d(a):"PASS",1:"FAIL")," from ",$t(+0)
	q
