	s x="shear,r"
	s ^temp(x)="data"
	d dump
	s x=$o(^temp(""))
	d dump
	q
dump	w !,"$l(x)=",$l(x),?10,"x=",x,!
	f i=1:1:$l(x) w $j($a(x,i),4)
	w !
	q
