chkgbldef ;
	;new $ZTRAP
	;set $ZTRAP="GOTO continue"
	write "^aregionvar collates with nct=1 & act=10",!
	write !
	write !,$$set^%GBLDEF("^aregionvar",1,10),!
	do mergefill^varfill
	zwrite ^aregionvar
	write !
;
	write "^defregvar collates in ",$ZTRNLNM("coltype")," & act=10",!
	write !
	zwrite ^defregvar
	write !
	write !,"merge of ^aregionvar with ^defregvar would give error here due to different nct",!!
	merge ^aregionvar=^defregvar
	quit
;
cont;
	kill ^aregionvar
	write "^aregionvar now collates with nct=0 & act=0",!
	write !
	write !,$$set^%GBLDEF("^aregionvar",0,0),!
;
;
	do chkMfunc^varfill
	write "zwrite ^aregionvar =",!
	write !
	zwrite ^aregionvar
	write "zwrite ^defregvar =",!
	write !
	zwrite ^defregvar
	write !,"merge should be successful now even though aregionvar & defregvar have different act",!!
	write !
;
	write "MERGING ^aregionvar("""")=^defregvar(""abc"","""")",!!
	write !
	write "BEFORE MERGE ^aregionvar ^defregvar",!
	zwrite ^aregionvar,^defregvar
	write !
	merge ^aregionvar("")=^defregvar("abc","")
	write "AFTER MERGE ^aregionvar ^defregvar",!
	zwrite ^aregionvar,^defregvar
;
	write !,"MERGING ^aregionvar(1,"""")=^defregvar(907)",!!
	write !
	write "BEFORE MERGE ^aregionvar ^defregvar",!
	zwrite ^aregionvar,^defregvar
	write !
	merge ^aregionvar(1,"")=^defregvar(907)
	write "AFTER MERGE ^aregionvar ^defregvar",!
	zwrite ^aregionvar,^defregvar
;
	write !,"MERGING, ^aregionvar=^defregvar",!!
	write !
	write "BEFORE MERGE ^aregionvar ^defregvar",!
	zwrite ^aregionvar,^defregvar
	write !
	merge ^aregionvar=^defregvar
	write "AFTER MERGE ^aregionvar ^defregvar",!
	zwrite ^aregionvar,^defregvar
	quit
reversemerge ;
; 	merging the above combination of globals the reverse way.
;
	kill ^aregionvar,^defregvar
;
;	fill aregionvar & defregvar again with values
	do mergefill^varfill
;
	write "MERGING ^defregvar(""abc"","""")=^aregionvar("""")",!!
	write !
	write "BEFORE MERGE ^defregvar ^aregionvar",!
	zwrite ^defregvar,^aregionvar
	write !
	merge ^defregvar("abc","")=^aregionvar("")
	write "AFTER MERGE ^defregvar ^aregionvar",!
	zwrite ^defregvar,^aregionvar
;
	write !,"MERGING ^defregvar(907)=^aregionvar(1,"""")",!!
	write !
	write "BEFORE MERGE ^defregvar ^aregionvar",!
	zwrite ^defregvar,^aregionvar
	write !
	merge ^defregvar(907)=^aregionvar(1,"")
	write "AFTER MERGE ^defregvar ^aregionvar",!
	zwrite ^defregvar,^aregionvar
;
	write !,"MERGING, ^defregvar=^aregionvar",!!
	write !
	write "BEFORE MERGE ^defregvar ^aregionvar",!
	zwrite ^defregvar,^aregionvar
	write !
	merge ^defregvar=^aregionvar
	write "AFTER MERGE ^defregvar ^aregionvar",!
	zwrite ^defregvar,^aregionvar
	quit
