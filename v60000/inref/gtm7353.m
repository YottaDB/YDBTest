gtm7353 ;
	; ------------------------------------------------------------------------------------------------------
	; GTM-7353 Database integrity errors in v51000/C9E12002698 test
	; ------------------------------------------------------------------------------------------------------
	;
        ; See mails for description of the issue.
        ;
	set val=$j("val",50)
	for j=1:1:17 set ^x(1,j)=val		; ^x(1) will be killed
	for j=1:1:1500 set ^x(3,j)=val		; increase tree depth to 2
	for j=1:1:17 set ^x(2,j)=val		; next update will move level one ^x(1.1) record from block 0x58 to block 0x62
	;
	tstart ():serial
	set ^x(1,1)=$j("update",50)
	set jmaxwait=30				; Wait at most 30 seconds for concurrent update
	if 0=$trestart do ^job("update^gtm7353",1,"""""")	; Have a second process interfere
	tcommit
	;
	write "^x(1,1)="_^x(1,1),!		; TP update should have succeeded
	;
	quit
	
update	;
	set ^x(2,18)=$j("update",50)		; Causes an index block split and moves ^x(1.1) record
	kill ^x(1)				; Deletes ^x(1.1) record and ^x(1) block: concurrent set ^x(1,1) should restart
	quit
