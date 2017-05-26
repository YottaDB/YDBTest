c001266 ;
	;	Test case for TR entry : C9909-001266
	;
	; assumes the following .gld settings
	;	-block_size=1024 -global_buffer_count=64 -record_size=1000 -key_size=255
	;
	f k=1:1:60  d
	.	i k#10=0 w "k = ",k,!
	.	f j=1:1:100  d
	.	.	tstart ():serial
	.	.	f i=1:1:10 s ^a(j,i)=$j(k_j_i,600+$r(200))
	.	.	tcommit
	.	.	f i=1:1:10 s ^a(j,i)=$j(k_j_i,600+$r(200))
	q
