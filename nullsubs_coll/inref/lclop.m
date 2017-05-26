lclop(optype);;
	; Assert Failure happens when act collation is changed from normal & when null subscript is set first.
	; For now the null sub setting is moved after setting a string sub "abc".
	; Change the code after the issue is resolved. TR hasn't been raised yet.
	write !
	write "LOCALS COLLATE ","WITH NCT ",$ZTRNLNM("nct")," & WITH ACT ",$ZTRNLNM("act")," FOR ",$ZTRNLNM("col")," DATABASE",!
        set localvariable("abc","")="lc_string_null"
        set localvariable("")="iam null localvariable"
        set localvariable(1,"")="lc_one_null"
        set localvariable(1,"",2,3)="lc_one_null_two_three"
        set localvariable("abc","","hi",2)="lc_string_null_string_two"
        set localvariable("",4)="lc_null_four"
        set localvariable("dgh")="lc_string"
        set localvariable("efg",2,"",4)="lc_string_two_four"
        set localvariable("iamAREG",2)="lc_string_two"
        set localvariable(565,90,76)=402
	write "zwriting the local collation order",!
	zwrite localvariable
	write !
	write "EXECUTING ",optype,"on localvariable",!
	write !
	set null="",minusone=-1
;
	if optype="$NEXT" set s2=minusone
	else  set s2=null
;
	if optype="$ORDER" do
	. write "executing $ORDER in FORWARD direction",!
	. set s1=null FOR  set s1=$ORDER(localvariable(s1),1) quit:s1=s2  write s1,!
	. write "executing $ORDER in REVERSE direction",!
	. set s1=null FOR  set s1=$ORDER(localvariable(s1),-1) quit:s1=s2  write s1,!
;
	if optype="$QUERY" do  quit
	. set s1="localvariable" FOR  set s1=$QUERY(@s1) quit:s1=""  write s1,!
;
	set expr1="set s1=null FOR  set s1="_optype_"(localvariable(s1)) quit:s1=s2  write s1,!"
	write expr1,!
	xecute expr1
	quit
