sptp2(bottom,top);
	W "sptp2 Started",!
	S $ZT="g ERROR"
	S ^alongglobalnameforzqgblmod="AREG"
	S ^b="BREG"
	S ^clongglobalnameforzqgblmod="CREG"
	S ^d="DREG"
	S ^e="EREG"
	F i=bottom:1:top D
	. TStart ():Serial
	. set ^alongglobalnameforzqgblmod(i)=$GET(^alongglobalnameforzqgblmod(i))_$J(i,10)
	. set ^b(i)=$GET(^b(i))_$J(i,10)
	. set ^clongglobalnameforzqgblmod(i)=$GET(^clongglobalnameforzqgblmod(i))_$J(i,10)
	. set ^d(i)=$GET(^d(i))_$J(i,10)
	. set ^e(i)=$GET(^e(i))_$J(i,10)
	. TCommit
	W "sptp2 Ends",!
	Q		
ERROR	S $ZT=""
	ZSHOW "*"
	ZM +$ZS
