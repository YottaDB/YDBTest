sptp1(bottom,top);
	W "sptp1 Started",!
	S $ZT="g ERROR"
	F i=1:1:10000 D
	. set ^aaaalongglobalnameforzqgblmod(i,$j(i,200))=$j(i,700)
	. set ^bbbb(i,$j(i,200))=$j(i,700)
	. set ^cccclongglobalnameforzqgblmod(i,$j(i,200))=$j(i,700)
	. set ^eeee(i,$j(i,200))=$j(i,700)
	
	F i=bottom:1:top D
	. TStart ():Serial
	. set ^alongglobalnameforzqgblmod(i)=$GET(^alongglobalnameforzqgblmod(i))_$J(i,10)
	. set ^b(i)=$GET(^b(i))_$J(i,10)
	. TCommit
	W "sptp1 Ends",!
	Q		
ERROR	S $ZT=""
	ZSHOW "*"
	ZM +$ZS
