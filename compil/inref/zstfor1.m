zstfor1	; tst for zstep-for interaction
	;
	s cnt=0,zstact="i $zpos'=""here^"_$t(+0)_""" s cnt=cnt+1,zp=$zpos"
	zb lev2:"zst outof:zstact"
	d lev2
here	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
lev2	f i=1,1 d lev3
	q
lev3	;zst should never stop here
	q
