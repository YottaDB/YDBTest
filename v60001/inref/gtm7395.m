gtm7395 ;
	; OPEN with READONLY should return EISDIR 
	;

	; handle EISDIR trap
	new $ETRAP
	set $ETRAP="do errorHandler"
	write "Producing two GTM-EISDIRs",!
	do readonlyTest
	do noreadonlyTest
	write "Done",!
	quit


readonlyTest
	open "gtm7395_dummy_dir":(READONLY)
	quit


noreadonlyTest
	open "gtm7395_dummy_dir":(NOREADONLY)
	quit

errorHandler
	set errMsg=$PIECE($ZSTATUS,",",3)
	if errMsg="%GTM-E-GTMEISDIR" write $ZSTATUS,! set $ECODE=""
	else  write $ZSTATUS,! 
	quit
