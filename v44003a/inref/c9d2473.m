c9d2473;
set1;
	; Followings will create journal file of 0x200000 bytes (almost); 
	; Then an EPOCH and a later set will cause it to go beyond 0x200000
	;
	f i=1:1:297 s ^a(i)=$j(i,7000-8)
	s ^a(298)=$j(i,1184-56-8)
	q
set2;
	f i=1:1:500 s ^b(i)=$j(i,7000)
	q
verify;
	f i=1:1:297 if ^a(i)'=$j(i,7000-8) w "Verify Fail for index=",i,!
	if ^a(298)'=$j(i,1184-56-8) w "Verify Fail for index=298",!
	q
