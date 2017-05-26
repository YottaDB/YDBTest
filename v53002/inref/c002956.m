c002956	;
	quit
	;
test1	;
        ; Test that MUPIP INTEG issues DBINVGBL integrity error in case ^bntp GVT contains ^antp records
	; This tests the case where actual global name is LESSER than desired global name
	;
	do common("^bntp","^antp")
	quit

test2	;
        ; Test that MUPIP INTEG issues DBINVGBL integrity error in case ^bntp GVT contains ^bntpx records
	; This tests the case where actual global name is EQUAL to the desired global name but is longer otherwise
	;
	do common("^bntp","^bntpx")
	quit

test3	;
        ; Test that MUPIP INTEG issues DBINVGBL integrity error in case ^bntp GVT contains ^cntp records
	; This tests the case where actual global name is GREATER than desired global name
	;
	do common("^bntp","^cntp")
	quit

common(agbl,bgbl);
	for i=1:1:10   set @bgbl@(i)=$j(i,20)	; will use up index block (4) and ONE leaf block (3)
	for i=1:1:100  set @agbl@(i)=$j(i,20)	; will use up index block (6) and THREE leaf blocks (7), (8) and (5)
	quit	

