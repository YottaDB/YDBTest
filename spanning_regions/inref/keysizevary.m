;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
keysizevary
	set $ztrap="goto errorAndCont^errorAndCont"
	set ^a(1,$j(1,180))=$j(2,2000)	; maps to AREG    : keysize=200, recsize=4000
	set ^a(2,$j(10,50))=$j(2,2000)	; maps to BREG    : keysize= 64, recsize=4000
	set ^a(3,$j(1,480))=$j(2,2000)	; maps to CREG    : keysize=500, recsize=4000
	set ^a(4,$j(1,930))=$j(2,2000)	; maps to DEFAULT : keysize=960, recsize=4000
	f i=1:1:12 s ^a(i)=i
	write $query(@"^a(1,2,3,4,5,6,7,8,9,0,4,$j(1,900))"),!
	write $query(@"^a(1,2,3,4,5,6,7,8,9,0,1,$j(1,900))"),!
	write $query(@"^a(1,2,3,4,5,6,7,8,9,0,2,$j(1,900))"),!
	write $query(@"^a(1,2,3,4,5,6,7,8,9,0,3,$j(1,900))"),!
	write $query(@"^a(4,1,2,3,4,5,6,7,8,9,0,4,$j(1,900))"),!	; maps to DEFAULT - should work
	write $query(@"^a(4,1,2,3,4,5,6,7,8,9,0,1,$j(1,900))"),!
	write $query(@"^a(4,1,2,3,4,5,6,7,8,9,0,2,$j(1,900))"),!
	write $query(@"^a(4,1,2,3,4,5,6,7,8,9,0,3,$j(1,900))"),!
	write $query(@"^a(8,1,2,3,4,5,6,7,8,9,0,4,$j(1,900))"),!	; maps to DEFAULT - should work
	write $query(@"^a(8,1,2,3,4,5,6,7,8,9,0,1,$j(1,900))"),!
	write $query(@"^a(8,1,2,3,4,5,6,7,8,9,0,2,$j(1,900))"),!
	write $query(@"^a(8,1,2,3,4,5,6,7,8,9,0,3,$j(1,900))"),!
	write $query(@"^a(12,1,2,3,4,5,6,7,8,9,0,4,$j(1,900))"),!	; maps to DEFAULT - should work
	write $query(@"^a(12,1,2,3,4,5,6,7,8,9,0,1,$j(1,900))"),!
	write $query(@"^a(12,1,2,3,4,5,6,7,8,9,0,2,$j(1,900))"),!
	write $query(@"^a(12,1,2,3,4,5,6,7,8,9,0,3,$j(1,900))"),!
	zwr ^a
