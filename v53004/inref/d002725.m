d002725 ; $NAME() should always place a value in the extended reference field
	kill
	set undef=$s($v("undef"):"",1:"no")_"undef" 
	view "noundef" 
	write $select($l($name(^[x,y]a)_$name(^|x|a),"""")=7:"PASS",1:"FAIL")," from ",$T(+0) 
	view undef
	quit
