d002238 ;
	; this test needs two global directories mumps.gld and other.gld 
	; both pointing to mumps.dat
	; $gtmgbldir (or gtm$gbldir in VMS) should be pointing to mumps.gld
	;
	kill ^XX
	write !,$$set^%GBLDEF("XX",1,0)
        do ^sstep
	write !,$zgbldir
	set ^XX(0,2,1,1)="x"
	;
	; test that numeric subscripts work fine through normal/naked/extended 
	; reference if numeric collation is turned on
        ;
	write !,^XX(0,2,1,1)
	write !,^(1)
	write !,^|"other.gld"|XX(0,2,1,1)
	quit
