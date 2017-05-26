per0508	; ; ; per0508 - zlink fails if many Do's
	;
	Set vms=$ZVERSION["VMS"
	For i="b","c","d","e","f","g"  Do
	.	ZSYSTEM $Select(vms:"COPY inrefdir:",1:"\cp $gtm_tst/$tst/inref/")_"per0508"_i_".m temp0508.m"
	.	ZLINK "temp0508.m"
	.	Do ^temp0508
	ZSYSTEM $select(vms:"DELETE temp0508.m;*",1:"\rm temp0508.m")
	Write !,"OK from test of Zlink doing a shuffle"
	Quit
