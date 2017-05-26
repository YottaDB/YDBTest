viewlab	;Test VIEW "LABELS"
	set $ZTRAP="set zs=$ZSTATUS,erbeg=$FIND(zs,""-E-"") write ""ERROR ("",$EXTRACT(zs,erbeg,$FIND(zs,"","",erbeg)-2),"") at line: "",$ZPOSITION,"":"",$TEXT(@$ZPOSITION),! zgoto $ZLEVEL-1"
	set vl=$VIEW("LABELS")
	if vl  do
	. write "$VIEW(""LABELS"") is 1",!
	. write "Those lines marked with an [X] are not expected to work when case sensitivity is enabled,",!
	. write "Those lines marked with a [Y] are expected to error with LABELMISSING at compile time",!
	else  do
	. write "$VIEW(""LABELS"") is 0",!
	. write "Those lines marked with an [X] are expected to work when case sensitivity is disabled,",!
	. write "However, this time round, the labels marked with a [Z] are expected to error with MULTLAB",!
	;will testing the following give us any benefit?:
	;for x="lAb1","LaB1","llab","LLAB","ulab","ULAB","lAb2^vlabels",... do
	;. do @x
	;quit
	do t1
	do t2
	do t3
	do t4
	do t5
	do t6
	do t7
	do t8
	do t9
	do t10
	do t11
	do t12
	quit
t1	write "calling longLABelloweranduppercase2222^vlabels       : " do longLABelloweranduppercase2222^vlabels quit
t2	write "calling LONGLABElloweRANDUPPERCASE2222^vlabels    [Z]: " do LONGLABElloweRANDUPPERCASE2222^vlabels quit
t3	write "calling lowercaseonlylabel222222222222^vlabels      : " do lowercaseonlylabel222222222222^vlabels quit
t4	write "calling LOWERCASEONLYLABEL222222222222^vlabels   [X]: " do LOWERCASEONLYLABEL222222222222^vlabels quit
t5	write "calling uppercaseonlylabel222222222222^vlabels   [X]: " do uppercaseonlylabel222222222222^vlabels quit
t6	write "calling UPPERCASEONLYLABEL222222222222^vlabels      : " do UPPERCASEONLYLABEL222222222222^vlabels quit
t7	write "calling longLABelloweranduppercase1111         : " do longLABelloweranduppercase1111 quit
t8	write "calling LONGLABElloweRANDUPPERCASE1111      [Z]: " do LONGLABElloweRANDUPPERCASE1111 quit
t9	write "calling lowercaseonlylabel111111111111        : " do lowercaseonlylabel111111111111 quit
t10	write "calling LOWERCASEONLYLABEL111111111111   [X,Y]: " do LOWERCASEONLYLABEL111111111111 quit
t11	write "calling uppercaseonlylabel111111111111   [X,Y]: " do uppercaseonlylabel111111111111 quit
t12	write "calling UPPERCASEONLYLABEL111111111111        : " do UPPERCASEONLYLABEL111111111111 quit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
longLABelloweranduppercase1111	write $ZPOSITION,":->",$TEXT(@$ZPOSITION),!	quit
LONGLABElloweRANDUPPERCASE1111	write $ZPOSITION,":->",$TEXT(@$ZPOSITION),!	quit
lowercaseonlylabel111111111111	write $ZPOSITION,":->",$TEXT(@$ZPOSITION),!	quit
UPPERCASEONLYLABEL111111111111	write $ZPOSITION,":->",$TEXT(@$ZPOSITION),!	quit
