per0343	;per0343 - $J and $FN round incorrectly under certain circumstances
	;
	s c=0
	f j=-.9:.1:.9 s k=+$J(j,0,0) i k'=(j+($s($e(j)="-":"-",1:"")_".5")\1) s c=c+1 w !,"$J rounded ",j," to ",k
	f j=-.04:.01:0 s k=$J(j,0,1) i k'="0.0" s c=c+1 w !,"$J rounded ",j," to ",k
	s j=".95",l=1 f i=1:1:10 s j=+("9"_j),l=l*10,k=$j(j,0,1) i k'=(l_".0") s c=c+1 w !,"$J rounded ",j," to ",k
	f j=-.9:.1:.9 s k=+$FN(j,"",0) i k'=(j+($s($e(j)="-":"-",1:"")_".5")\1) s c=c+1 w !,"$FN rounded ",j," to ",k
	f j=-.04:.01:0 s k=$FN(j,"",1) i k'="0.0" s c=c+1 w !,"$FN rounded ",j," to ",k
	s j=".95",l=1 f i=1:1:10 s j=+("9"_j),l=l*10,k=$FN(j,"",1) i k'=(l_".0") s c=c+1 w !,"$FN rounded ",j," to ",k
	w !,$s(c:"BAD result",1:"OK")," from test of $J and $FN rounding"
