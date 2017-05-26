hdate 	;convert $H to DATE format
	s mjf=$ZCMDLINE
	s outfile=$P
	s next=0
	o mjf u mjf
	u mjf r line
	for  q:$zeof=1  do
	. u $P
	. s dollarh=line
	. s line=$ZDATE(dollarh,"DD-MON-YEAR")_" "_$ZDATE(dollarh,"24:60:SS")
	. w line,!
	. u mjf r line
	q
