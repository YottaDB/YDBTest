nullntp;
	NEW $ZTRAP
	SET $ZTRAP="GOTO errcont^errcont" 
	W !,!,"Starting nullntp for Non-TP",!
	W "ZWR ^varlongvariablenamesworkfornull",!  ZWR ^varlongvariablenamesworkfornull
	W "Test global to global:",!
	W "M ^xgbl(""newtree"","""")=^varlongvariablenamesworkfornull",!  M ^xgbl("newtree","")=^varlongvariablenamesworkfornull
	W "M ^xgbl=^varlongvariablenamesworkfornull",!  M ^xgbl=^varlongvariablenamesworkfornull
	W "Next Command Will fail",!
	W "M ^agbl(""newtree"","""")=^varlongvariablenamesworkfornull",!  M ^agbl("newtree","")=^varlongvariablenamesworkfornull
	W "Next Command Will fail",!
	W "M ^agbl=^varlongvariablenamesworkfornull",!  M ^agbl=^varlongvariablenamesworkfornull
	W "Verify MERGE",!
	do ^nullfill("ver","^xgbl(""newtree"","""")")
	W "K ^xgbl(""newtree"","""")",!  K ^xgbl("newtree","")
	do ^nullfill("ver","^xgbl")
	if ($data(^agbl))  W "ZWR ^agbl",!  ZWR ^agbl
	W "Test more:",!
	SET ^vvv(100,"",200)="GBL_vvv1"
	SET vvv(100,"",200)="LCL_vvv2"
	SET ^vvv("str","",200)="GBL_vvv1"
	SET vvv("str","",200)="LCL_vvv2"
	W "Next Command Will fail",!
	M ^aaa("I will not be created",1)=^vvv(100)
	W "Next Command Will fail",!
	M ^aaa("I will not be created",2)=vvv(100)
	W "Next Command Will fail",!
	M ^aaa("I will not be created",3)=^vvv("str")
	W "Next Command Will fail",!
	M ^aaa("I will not be created",3)=vvv("str")
	if $data(^aaa) W "Test failed for M ^aaa",!  ZWR  Q
	K (varlongvariablenamesworkfornull)
	;
	W !,!,"Test local to global:",!
	;W "ZWR varlongvariablenamesworkfornull",!  ZWR varlongvariablenamesworkfornull
	W "M ^cgbl=varlongvariablenamesworkfornull",!  M ^cgbl=varlongvariablenamesworkfornull
	W "Next Command Will fail",!
	W "M ^bgbl=varlongvariablenamesworkfornull",!  M ^bgbl=varlongvariablenamesworkfornull
	W "Verify MERGE",!
	do ^nullfill("ver","^cgbl")
	if ($data(^bgbl))  W "ZWR ^bgbl",!  ZWR ^bgbl
	;
	w "view ""LVNULLSUBS""",!
	view "LVNULLSUBS"
	K (varlongvariablenamesworkfornull)
	W !,!,"Test global into local when null enabled for local:",!
	W "M alcl(1,2,3,4,5,6,7,8,9,10,"",12,13,14)=^varlongvariablenamesworkfornull",!  
	M alcl(1,2,3,4,5,6,7,8,9,10,"",12,13,14)=^varlongvariablenamesworkfornull  
	W "M blcl=^varlongvariablenamesworkfornull",!  
	M blcl=^varlongvariablenamesworkfornull  
	do ^nullfill("ver","alcl(1,2,3,4,5,6,7,8,9,10,"""",12,13,14)")
	do ^nullfill("ver","blcl")
	K (varlongvariablenamesworkfornull)
	;
	W !,!,"Test local into local when null disabled for local:",!
	w "view ""NOLVNULLSUBS""",!
	view "NOLVNULLSUBS"
	W "Next Command Will fail",!
	W "M nllcl1=varlongvariablenamesworkfornull",!  M nllcl1=varlongvariablenamesworkfornull
	W "Next Command Will fail",!
	W "M nllcl2(1,"""")=varlongvariablenamesworkfornull",!  M nllcl2(1,"")=varlongvariablenamesworkfornull
	W "K (varlongvariablenamesworkfornull,nllcl1,nllcl2)"  K (varlongvariablenamesworkfornull,nllcl1,nllcl2)
	;
	W "Verify MERGE",!
	W "ZSHOW ""V""",!  ZSHOW "V"
	W "kill",!  kill
	W "ZSHOW ""V""",!  ZSHOW "V"
	W "End nullntp",!,!
	q
