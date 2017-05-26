test13(cnt); 
 	set tflag=$r(2)
	; 
	; Since ZTP in this test can cause DUPTOKEN errors we are disabling ZTSTART/ZTCOMMIT which was previously
	; allowed in this test (see <ZTP_and_DUPTOKEN>)
	;
	if tflag=1 TSTART ():SERIAL
 	if $r(2)=1 set ^apini(cnt)=$j
 	if $r(2)=1 set ^bpini(cnt)=$j
 	if $r(2)=1 set ^cpini(cnt)=$j
 	if $r(2)=1 set ^dpini(cnt)=$j
 	if $r(2)=1 set ^epini(cnt)=$j
 	if $r(2)=1 set ^fpini(cnt)=$j
 	if $r(2)=1 set ^gpini(cnt)=$j
 	if $r(2)=1 set ^hpini(cnt)=$j
 	if tflag=1 TCOMMIT
 	Quit
wait    ;
        set status=$$^waitchrg(0,300,"*")        ; wait for process to halt out of all regions 
        quit
