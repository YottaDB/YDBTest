sptp3(bottom,top);
	W "sptp3 Started",!
	S $ZT="g ERROR"
	F i=bottom:1:top D
	. TStart ():Serial
	. set ^alongglobalnameforzqgblmod(i)=$GET(^alongglobalnameforzqgblmod(i))_$J(i,10)
	. set ^b(i)=$GET(^b(i))_$J(i,10)
	. set ^d(i)=$GET(^d(i))_$J(i,10)
	. set ^e(i)=$GET(^e(i))_$J(i,10)
	. TCommit
	W "sptp3 Ends",!
	Q		
ERROR	S $ZT=""
	ZSHOW "*"
	ZM +$ZS
