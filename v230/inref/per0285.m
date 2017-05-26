per0285	; ; ; per0285 - ACCVIO at entryref to a label removed by a zlink
	;
	Set vms=$ZVERSION["VMS"
	Set c=0
	ZSYSTEM $Select(vms:"COPY inrefdir:",1:"\cp $gtm_tst/$tst/inref/")_"per0285b.m temp0285.m"
	ZLINK "temp0285.m"
	Set x=$TEXT(label^temp0285)
	ZSYSTEM $Select(vms:"COPY inrefdir:",1:"\cp $gtm_tst/$tst/inref/")_"per0285c.m temp0285.m"
	ZLINK "temp0285.m"
	If $TEXT(label^temp0285)=x  Set c=c+1  Write !,"$TEXT returned stale code"
	ZSYSTEM $Select(vms:"DELETE temp0285.*.*",1:"\rm temp0285.*")
	Write !,$SELECT(c:"BAD result",1:"OK")," from test of reference to a label removed by ZLINK"
	Quit
