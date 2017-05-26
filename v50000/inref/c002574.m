c002574	;
	; C9E04-002574 cert_blk (database block certification) does not error out for a lot of cases
	; the following test assumes at least 256-byte record-size and 1K GDS block size 
	;
	quit

dbmaxnrsubs	;
	write !,"--> Testing DBMAXNRSUBS error from cert_blk <--",!
	set ^a=1
	quit
	 
dbkeyord	;
	write !,"--> Testing DBKEYORD error from cert_blk <--",!
	set ^a(10)=1
	quit
	 
dbinvgbldbdirtsubsc	;
	write !,"--> Testing DBINVGBL and DBDIRTSUBSC error from cert_blk <--",!
	set ^a=1
	quit
	 
dbbdballoc	;
	write !,"--> Testing DBBDBALLOC error from cert_blk <--",!
	f i=1:1:5 s ^a(i)=$j(i,230)
	quit

