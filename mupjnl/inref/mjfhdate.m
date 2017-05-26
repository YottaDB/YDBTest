mjfhdate ;convert $H in mjf output to DATE format
	s mjf=$ZCMDLINE
	s outfile=$P
	s next=0
	o mjf u mjf
	r header
	u $P w "#",header,!
	u mjf r line
	for  q:$zeof=1  do
	. u $P
	. s dollarh=$P(line,"\",2)
	. s $E(line,4,14)="#"_$ZDATE(dollarh)_" "_$ZDATE(dollarh,"24:60:SS")_"#"
	. w line,!
	. u mjf r line
	q
	. s %DT=$P(dollarh,",",1)
	. s %TM=$P(dollarh,",",2)
	. if 0<%DT d
	. . d %CDS^%H
	. . d %CTS^%H
	. . s $E(line,4,14)="#"_%DAT_" "_%TIM_"#"
