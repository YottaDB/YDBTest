zgonolab	; test zgoto with offset
	;
	s cnt=0
	zg $zl:zgonolab+5
	s cnt=cnt+1,zp=$zpos
	zg $zl:zgonolab+7
	s cnt=cnt+1,zp=$zpos
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
