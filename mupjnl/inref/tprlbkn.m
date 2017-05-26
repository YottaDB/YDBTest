	;C9D06-002269 Incremental TPROLLBAK command corrupts memory if journaling is enabled
	;Test TP rollback memory corruption
	For try=1:1:50 DO
	. tstart
	. 	for cnt=1:1:500 s ^a(cnt,cnt)=cnt_cnt
	. 	tstart
	.		s ^a(2)=$j(1,200)
	.		tstart
	.			s ^a(3)=$j(1,200)
	.			tstart
	.				s ^a(4)=$j(1,200)
	.				tstart
	.					k ^a
	.					trollback -3 ; rollback 3 $tlevels
	. ;
	.		tstart
	.			s ^a(4)=4
	.			s ^a(5)=5
	.			tcommit
	.		;
	.		tstart
	.			k ^a(4)
	.			trollback 1	; rollback to $tlevel=1
	.	k ^a(5)
	. tcommit
	q
	;
dverify     ; verify the data
	For I=1:1:500 d  q
	. s val=I_I
	. if (I'=5),(^a(I,I)'=val) w "Fail at ^a",I,",",I,"=",^a(I,I),!
	if $data(^a(5))'=0 w "Fail at ^a(5)=" zwr ^a(5)
	for i=1:1:4 d  q
	. if $get(^a(i))'="" w "Fail at ^a(",i,")=",^a(i),!
	q
