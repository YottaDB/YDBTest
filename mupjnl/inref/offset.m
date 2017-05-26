offset	;validates the offsets from -EXTRACT -DETAIL output.
	s mjf="mumps.mjf"
	s outfile=$P
	s next=0
	o mjf u mjf
	r header
	u $P w "#",header,!
	u mjf r line
	for  q:$zeof=1  do
	. u $P
	. s offorig=$E(line,1,10),lenorig=$E(line,12,20)
	. s off=$E(offorig,3,10),len=$E(lenorig,4,7)
	. i "        "=off s off=0
	. s docheck=0
	. s prefix="FINE  >"_off_"< VS "_next
	. s prefix="                            "
	. i 0'=next,""'=line,0'=off d
	. . i off'=next set prefix="ERROR >"_off_"< VS "_next
	. w prefix
	. s off=$$FUNC^%HD(off)
	. s len=$$FUNC^%HD(len)
	. i 0'=off s next=$$FUNC^%LCASE($$FUNC^%DH(off+len,8))
	. w " ===> ",line,!
	. u mjf r line
	q
