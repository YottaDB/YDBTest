c002963	;
	; Test that DSE MAPS -RESTORE works fine even if total_blks is multiple of 512
	; Do a simple set of updates.
	;
	for i=1:1:10 s ^x(i)=$j(i,$r(20)+20)
	quit
