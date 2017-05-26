; Used by gtm6892 to test errors during fsync(s) done as part of tcommit
manytp	;
	set $ztrap="do err^manytp"
	for i=1:1:10  do
	. tstart ():(serial:t="CS")	; CS because we want every transaction to invoke jnl_fsync to harden the updates
	. set ^a(i)=$j(i,10)
	. set ^b(i)=$j(i,10)
	. tcommit
	quit

err	;
	; print the error and continue in the outer frame
	write $zstatus,!		; Print the error
	set $ecode=""
	quit				; Ignore the error
