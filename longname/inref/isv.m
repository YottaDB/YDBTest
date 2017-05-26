isv	; test intrinsic special variables
	; see basic test for $zstep, $ztrap and $zyerror
	; see v234/inref/dzro.m for $zroutine
	set seperator="#############################################"
reference	; $reference
	write seperator,!
	write "Test $reference",!
	write $reference,!
	do ^examine($reference,"","at "_$ZPOSITION)
	set ^a234567890123456789012345678901="a"
	write $reference,!
	do ^examine($reference,"^a234567890123456789012345678901","at "_$ZPOSITION)
	set ^a234567890123456789012345678901(1)="a1"
	write $reference,!
	do ^examine($reference,"^a234567890123456789012345678901(1)","at "_$ZPOSITION)
	set ^(2)="a2"
	write $reference,!
	do ^examine($reference,"^a234567890123456789012345678901(2)","at "_$ZPOSITION)
	set ^(3,1)="a31"
	write $reference,!
	do ^examine($reference,"^a234567890123456789012345678901(3,1)","at "_$ZPOSITION)
	write "$GET(^a23456789012345678901234567890a(3,""subca"",1))=",$GET(^a23456789012345678901234567890a(3,"subsca",1)),!
	set ^(2)="a30"
	write $reference,!
	do ^examine($reference,"^a23456789012345678901234567890a(3,""subsca"",2)","at "_$ZPOSITION)
	set ^(2,3,"abc")="a30"
	write $reference,!
	do ^examine($reference,"^a23456789012345678901234567890a(3,""subsca"",2,3,""abc"")","at "_$ZPOSITION)
	; $reference works for global only
	set ^gbl=1
	set abcdefghijklmn="local variable"
	write $reference,!
	do ^examine($reference,"^gbl","at "_$ZPOSITION)
	;
zsource	;
	write seperator,!
	write "Test $zsource",!
	write $zsource,!
	set unix=$ZVERSION'["VMS"
	set rout="x234567890123456789012345678901a"
	zlink rout
	write $zsource,!
	do ^examine($zsource,$SELECT(unix:rout,1:$$FUNC^%UCASE(rout))," at "_$ZPOSITION)
	; this routine does not test different paths for $ZSOURCE
	quit
