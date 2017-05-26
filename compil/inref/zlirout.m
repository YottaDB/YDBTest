zlirout	; test zlinking of over-length names
	;
	n $zt s $zt="zg @targ"
	s cnt=0,rou=$t(+0)
	f i=$l(rou)+1:1:18 s rou=rou_(i#10) d test
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
test	s targ=$zl_":trap"
	d ^@rou
	s cnt=cnt+1,zp=$zpos
	q
trap	i $zs'["ZLINKFILE" s cnt=cnt+1,zp=$zpos
	q
