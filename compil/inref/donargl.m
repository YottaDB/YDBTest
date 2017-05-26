donargl	;test of argumentless do behavior with missing and excess levels
	;
	s cnt=0,base=$zl
	d
	. i base+1'=$zl s cnt=cnt+1,zp=$zpos
	. d
	i base'=$zl s cnt=cnt+1,zp=$zpos
	d
	. i base+1'=$zl s cnt=cnt+1,zp=$zpos
	. d
	. i base+1'=$zl s cnt=cnt+1,zp=$zpos
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$T(+0)
	q
	d
	.. w !,"too many levels"
