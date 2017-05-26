gblop(optype);;
	; $ORDER under forward condition will display no output for nct "1" with GT.M null collation.
	; this has to be corrected once the issue is resolved
	write !
	write "GLOBALS COLLATE IN ",$ZTRNLNM("col")," WITH NCT ",$ZTRNLNM("nct")," & WITH ACT ",$ZTRNLNM("act"),!
	write "zwriting the collation order",!
	zwrite ^aregionvar
	write !
	write "EXECUTING ",optype,"on ^aregionvar",!
	write !
;
	set null="",minusone=-1
;
	if optype="$NEXT" set s2=minusone
	else  set s2=null
;
        if optype="$ORDER" do
        . write "executing $ORDER in FORWARD direction",!
        . set s1=null FOR  set s1=$ORDER(^aregionvar(s1),1) quit:s1=s2  write s1,!
        . write "executing $ORDER in REVERSE direction",!
        . set s1=null FOR  set s1=$ORDER(^aregionvar(s1),-1) quit:s1=s2  write s1,!
;
	if optype="$QUERY" do  quit
	. set s1="^aregionvar" for  set s1=$QUERY(@s1) quit:s1=""  write s1,!
;
	set expr1="set s1=null for  set s1="_optype_"(^aregionvar(s1)) quit:s1=s2  write s1,!"
	write expr1,!
	xecute expr1
	quit
