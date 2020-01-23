;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb484	;
	set $ztrap="goto incrtrap^incrtrap"	; Needed to proceed to next M line in case of errors (possible in this test)
	do ydb484a
	do ydb484b
	do ydb484c
	do ydb484d
	do ydb484e
	do ydb484f
	do ydb484g
	do ydb484g2
	quit

ydb484a	;
	write "################################################################",!
	write "# Test : ydb484a : Test following section of functional spec",!
	write "----------------------------------------------------------------",!
	write "# The read-only [$ZYSQ]LNULL intrinsic special variable is conceptually equivalent to a logical value of unknown,",!
	write "#    and can be assigned as the value or a subscript of a lvn (local varible node).",!
	write "# $ZYSQLNULL can be a subscript of an lvn. In that case, it will collate after """", numeric subscripts and string",!
	write "#    subscripts i.e. $ORDER and $QUERY will return that subscript at the very end.",!
	write "################################################################",!
	write !
	write "--> Test setting unsubscripted lvn to $ZYSQLNULL",!
	kill x set x=$ZYSQLNULL  zwrite x
	write "--> Test setting subscripted lvn to $ZYSQLNULL",!
	kill x set x(1)=$ZYSQLNULL,x("abcd")=$ZYSQLNULL,x("")=$ZYSQLNULL zwrite x
	write "--> Test setting $ZYSQLNULL as a subscript",!
	kill x set x($ZYSQLNULL)=$ZYSQLNULL,x($ZYSQLNULL,1)=$ZYSQLNULL zwrite x
	write "--> Test that $ZYSQLNULL setting transfers from lvn subscript back to value",!
	write " -> ZWRITE of y should have subscript of $ZYSQLNULL and z should have value of $ZYSQLNULL",!
	kill x set x=$ZYSQLNULL,y(x)=1,z=$ORDER(y(""))
	zwrite x,y,z
	kill x,y,z
	write "--> Test setting null subscripts as well as $ZYSQLNULL as a subscript and see how ZWRITE works",!
	set z("")=0,z("abcd")=1,z(1)=2,z($ZYSQLNULL)=$ZYSQLNULL zwrite z
	write " -> Test ZWRITE after killing null subscript but leaving $ZYSQLNULL subscript as is",!
	kill z("") zwrite z
	write " -> Test ZWRITE after killing null subscript and killing $ZYSQLNULL subscript",!
	kill z($ZYSQLNULL) zwrite z
	write " -> Test ZWRITE after resetting $ZYSQLNULL subscript",!
	set z($ZYSQLNULL)=3 zwrite z
	write " -> Test ZWRITE after resetting null subscript",!
	set z("")=4 zwrite z
	write "--> Test setting $ZYSQLNULL to a value : Should issue error",!
	set $ZYSQLNULL=x
	set $ZYSQLNULL=""
	write "--> Test setting null subscripts and $ZYSQLNULL as a subscript and see how $ORDER(,1) handles things",!
	kill z set z("")=1,z(2)=3,z("abcd")=2,z("efgh")=1,z($ZYSQLNULL)=1
	write " -> zwrite each subscript as we see it in a $ORDER(,1) loop",!
	set subs="" for  set subs=$order(z(subs),1)  quit:subs=""  zwrite subs
	write " -> Try out specific $ORDER(,1) and zwrite result",!
	for subs="",2,"abcd","efgh","ijkl",$ZYSQLNULL  zwrite subs set rslt=$order(z(subs),1)  zwrite rslt
	write "--> Test setting null subscripts and $ZYSQLNULL as a subscript and see how $ORDER(,-1) handles things",!
	write " -> zwrite each subscript as we see it in a $ORDER(,-1) loop",!
	set subs="" for  set subs=$order(z(subs),-1)  quit:subs=""  zwrite subs
	write " -> Try out specific $ORDER(,-1) and zwrite result",!
	for subs="",2,"aaa","abcd","efgh",$ZYSQLNULL  zwrite subs set rslt=$order(z(subs),-1)  zwrite rslt
	write "--> Test that $ZWRITE($ZYSQLNULL) prints $ZYSQLNULL",!
	kill z set z=$ZYSQLNULL write "$ZWRITE(z)=",$ZWRITE(z),!  write "$ZWRITE($ZYSQLNULL)=",$ZWRITE($ZYSQLNULL),!
	write "--> Test that $ZWRITE($ZYSQLNULL) output can be fed to $ZWRITE(,1) to get back $ZYSQLNULL",!
	kill z set z=$ZWRITE($ZWRITE($ZYSQLNULL),1)  write "$ZWRITE($ZWRITE($ZYSQLNULL),1)=",$ZWRITE(z),!
	write "--> Test setting null subscripts and $ZYSQLNULL as a subscript and see how $QUERY(,1) and (,-1) handles things",!
	for i="",$ZYSQLNULL,1 do
	. set x(i)=$incr(cnt)
	. for j="",$ZYSQLNULL,1 do
	. . set x(i,j)=$incr(cnt)
	. . for k="",$ZYSQLNULL,1 do
	. . . set x(i,j,k)=$incr(cnt)
	write " -> Forward query loop",!
	set y="x" for  set y=$query(@y) quit:y=""  write y,!
	write " -> Reverse query loop (will miss $ZYSQLNULL first-level subscript as there is no greater subscript to start loop)",!
	set y="x($ZYSQLNULL)" for  set y=$query(@y,-1) quit:y=""  write y,!
	kill i,j,k,y
	write "--> Test MERGE command with lvn that has $ZYSQLNULL in subscripts and values",!
	; Use `x` lvn tree from previous test step
	set x("$ZYSQLNULL")=$ZYSQLNULL
	merge y=x
	zwrite y
	write "--> Test VIEW ""LVNULLSUBS"", VIEW ""NOLVNULLSUBS"" and VIEW ""NEVERLVNULLSUBS"" works fine with $ZYSQLNULL",!
	for nullsubs="NOLVNULLSUBS","NEVERLVNULLSUBS","LVNULLSUBS" do
	. new x,y,z
	. write " -> Testing with VIEW """_nullsubs_"""",!
	. set x($ZYSQLNULL)=$ZYSQLNULL
	. set y=x($ZYSQLNULL)
	. merge z=x
	. zwrite x,y,z
	write "--> Test $NAME works with $ZYSQLNULL as subscript",!
	kill x,y,z  set x=3,y=$ZYSQLNULL  write $name(abcd(x,y)),!
	write "--> Test alias base variables and containers with $ZYSQLNULL",!
	do
	. new
	. set x("")=1,x($ZYSQLNULL)=2,x("abcd")=3
	. set *y=x,*z(3)=y,*k=z(3)
	. write " -> zwrite x,y,z,k",!
	. zwrite x,y,z,k
	. write " -> zwrite",!
	. zwrite
	write "--> Test that if TREF(local_collseq) is set, $ZYSQLNULL does not get collation transformed in $ORDER etc.",!
	write " -> Switch to local alternative collation : 1 (reverse collation)",!
	do
	. new
	. if $$set^%LCLCOL(1)
	. write " -> Set a few nodes in `x` lvn and do zwrite",!
	. set x("")=1,x($ZYSQLNULL)=2,x("a")=3,x("z")=4
	. zwrite x
	. write " -> merge `x` into `y` and do zwrite of `y`",!
	. merge y=x
	. zwrite y
	. write " -> Switch back to default alternative collation : 0 (ascii collation)",!
	. if $$set^%LCLCOL(0)	; set alternative collation back to default value of 0
	write "--> FUTURE_TODO: Test that $ZYSQLNULL works fine in SimpleAPI and SimpleThreadAPI",!
	write "This is not easily doable since SimpleAPI does not return an mval but instead just a ydb_buffer_t which has",!
	write "no notion of an mvtype. Maybe we need to set len_used to -1 to indicate $ZYSQLNULL return say from ydb_get_s",!
	write "Something to consider for the future as the need arises.",!
	write !
	quit

ydb484b	;
	write "################################################################",!
	write "# Test : ydb484b : Test following section of functional spec",!
	write "----------------------------------------------------------------",!
	write "# ZSHOW and ZWRITE of $ZYSQLNULL values show a value of $ZYSQLNULL.",!
	write "# WRITE does not show any value for $ZYSQLNULL just like it does with """".",!
	write "################################################################",!
	do
	. new
	. write "--> Test that ZSHOW displays $ZYSQLNULL fine",!
	. write " -> Test ZSHOW ""V"" displays $ZYSQLNULL fine and one can use SET @ syntax to restore values from ZSHOW output",!
	. set xstr="set x=$ZYSQLNULL,x(1,$ZYSQLNULL)=2 zshow ""v"":y zwrite  kill x set @y(""V"",1),@y(""V"",2) zwrite x"
	. write " -> Executing : ",xstr,!  xecute xstr
	. write "--> Test that WRITE $ZYSQLNULL prints an empty string",!
	. write "$ZYSQLNULL=[",$ZYSQLNULL,"]",!
	. write "--> Test that ZWRITE $ZYSQLNULL works",!
	. write " -> ZWRITE $ZYSQLNULL",!
	. zwrite $zysqlnull
	. write " -> ZWRITE @""$ZYSQLNULL""",!
	. zwrite @"$zysqlnull"
	write !
	quit

ydb484c	;
	write "################################################################",!
	write "# Test : ydb484c : Test following section of functional spec",!
	write "----------------------------------------------------------------",!
	write "# The function $ZYISSQLNULL() returns 1 if its sole argument has a value $ZYSQLNULL, and 0 otherwise.",!
	write "################################################################",!
	write "--> Test : write $ZYISSQLNULL($ZYSQLNULL) : ",$ZYISSQLNULL($ZYSQLNULL),!
	write "--> Test : write $ZYISSQLNULL("""") : ",$ZYISSQLNULL(""),!
	write "--> Test : write $ZYISSQLNULL(0) : ",$ZYISSQLNULL(0),!
	write "--> Test : write $ZYISSQLNULL(-2.5) : ",$ZYISSQLNULL(-2.5),!
	write "--> Test : write $ZYISSQLNULL(""abcd"") : ",$ZYISSQLNULL("abcd"),!
	write "--> Test : set x=$ZYSQLNULL write $ZYISSQLNULL(x) : "    set x=$ZYSQLNULL write $ZYISSQLNULL(x),!
	write "--> Test : set x="" write $ZYISSQLNULL(x) : "            set x="" write $ZYISSQLNULL(x),!
	write "--> Test : set x=0 write $ZYISSQLNULL(x) : "             set x=0 write $ZYISSQLNULL(x),!
	write "--> Test : set x=-2.5 write $ZYISSQLNULL(x) : "          set x=2.5 write $ZYISSQLNULL(x),!
	write "--> Test : set x=""abcd"" write $ZYISSQLNULL(x) : "      set x="abcd" write $ZYISSQLNULL(x),!
	write !
	quit

ydb484d	;
	write "################################################################",!
	write "# Test : ydb484d : Test following section of functional spec",!
	write "----------------------------------------------------------------",!
	write "# When $ZYSQLNULL is an operand, the results are as follows:",!
	write "# Operator  : Result",!
	write "# --------------------",!
	write "# Binary !  : If the other operand evaluates to true (1), the result is true, otherwise the result is $ZYSQLNULL",!
	write "# Binary &  : If the other operand evalutes to false (0), the result is false, otherwise the result is $ZYSQLNULL",!
	write "# All binary operators except ! and & : Regardless of the value of the other operand, the result is $ZYSQLNULL",!
	write "# Unary +   : $ZYSQLNULL",!
	write "# Unary -   : $ZYSQLNULL",!
	write "# Unary '   : $ZYSQLNULL",!
	write "################################################################",!
	;
	; Test operators
	;
	write "-----------------------------",!
	write "--> Test Arithmetic Operators",!
	write "-----------------------------",!
	write " -> Test + unary operator  (FORCE CONVERSION TO NUMERIC)",!
	write "set x=+$ZYSQLNULL zwrite x",!  set x=+$ZYSQLNULL  zwrite x
	write "set x=$ZYSQLNULL,y=+x zwrite y",!  set x=$ZYSQLNULL,y=+x  zwrite y
	write " -> Test - unary operator  (NEGATION)",!
	write "set x=-$ZYSQLNULL zwrite x",!  set x=-$ZYSQLNULL  zwrite x
	write "set x=$ZYSQLNULL,y=-x zwrite y",!  set x=$ZYSQLNULL,y=-x  zwrite y
	write " -> Test + binary operator (ADDITION)",!
	do binarytest("+")
	write " -> Test - binary operator (SUBTRACTION)",!
	do binarytest("-")
	write " -> Test * binary operator (MULTIPLICATION)",!
	do binarytest("*")
	write " -> Test / binary operator (FRACTIONAL DIVISION)",!
	do binarytest("/")
	write " -> Test \ binary operator (INTEGER DIVISION)",!
	do binarytest("\")
	write " -> Test # binary operator (MODULO)",!
	do binarytest("#")

	write "-----------------------------",!
	write "--> Test String Operators",!
	write "-----------------------------",!
	write " -> Test _ binary operator (STRING CONCATENATION)",!
	for str="",1,"abcd" do
	.	set xstr="set x="_$zwrite(str)_"_$ZYSQLNULL zwrite x"  write xstr," : " xecute xstr
	.	set xstr="set x=$ZYSQLNULL_"_$zwrite(str)_" zwrite x"  write xstr," : " xecute xstr
	.	for str2="",1,"efgh" do
	.	.	set xstr="set x="_$zwrite(str)_"_"_$zwrite(str2)_"_$ZYSQLNULL zwrite x"  write xstr," : " xecute xstr
	.	.	set xstr="set x="_$zwrite(str)_"_$ZYSQLNULL_"_$zwrite(str2)_" zwrite x"  write xstr," : " xecute xstr
	.	.	set xstr="set x=$ZYSQLNULL_"_$zwrite(str)_"_"_$zwrite(str2)_" zwrite x"  write xstr," : " xecute xstr
	.	.	set xstr="set x=$ZYSQLNULL_$ZYSQLNULL_"_$zwrite(str2)_" zwrite x"  write xstr," : " xecute xstr
	.	.	set xstr="set x=$ZYSQLNULL_"_$zwrite(str2)_"_$ZYSQLNULL zwrite x"  write xstr," : " xecute xstr
	.	.	set xstr="set x="_$zwrite(str2)_"_$ZYSQLNULL_$ZYSQLNULL zwrite x"  write xstr," : " xecute xstr
	set xstr="set x=$ZYSQLNULL_$ZYSQLNULL zwrite x"  write xstr," : " xecute xstr
	set xstr="set x=$ZYSQLNULL_$ZYSQLNULL_$ZYSQLNULL zwrite x"  write xstr," : " xecute xstr

	write "-----------------------------",!
	write "--> Test Logical Operators",!
	write "-----------------------------",!
	write " -> Test ' unary operator  (NOT)",!
	write " -> Test & binary operator (AND)",!
	write " -> Test ! binary operator (OR)",!
	write " -> Test '& binary operator (NAND)",!
	write " -> Test '! binary operator (NOR)",!
	set xstr="do logicaloperatortest" write xstr,!
	xecute xstr

	write "-----------------------------",!
	write "--> Test Numeric Relational Operators",!
	write "-----------------------------",!
	write " -> Test > binary operator (GREATER THAN)",!
	do binarytest(">")
	write " -> Test < binary operator (LESS THAN)",!
	do binarytest("<")
	write " -> Test = binary operator (IS EQUAL TO when operands are NUMBERS)",!
	do binarytest("=")
	write " -> Test '= binary operator (NOT EQUAL TO)",!
	do binarytest("'=")
	write " -> Test '< binary operator (NOT LESS THAN aka GREATER THAN OR EQUAL TO)",!
	do binarytest("'<")
	write " -> Test '> binary operator (NOT GREATER THAN aka LESS THAN OR EQUAL TO)",!
	do binarytest("'>")
	write " -> Test <= binary operator (LESS THAN OR EQUAL TO aka NOT GREATER THAN)",!
	do binarytest("<=")
	write " -> Test >= binary operator (GREATER THAN OR EQUAL TO aka NOT LESS THAN)",!
	do binarytest(">=")

	write "-----------------------------",!
	write "--> Test String Relational Operators",!
	write "-----------------------------",!
	write " -> Test = binary operator (IS EQUAL TO when operands are STRINGS)",!
	do binarytest("=")
	write " -> Test [ binary operator (CONTAINS)",!
	do binarytest("[")
	write " -> Test ] binary operator (FOLLOWS in ascii byte sequence)",!
	do binarytest("]")
	write " -> Test ]] binary operator (FOLLOWS in subscript ordering sequence)",!
	do binarytest("]]")
	write " -> Test '= binary operator (NOT EQUAL TO when operands are STRINGS)",!
	do binarytest("'=")
	write " -> Test '[ binary operator (NOT CONTAINS)",!
	do binarytest("'[")
	write " -> Test '] binary operator (NOT FOLLOWS in ascii byte sequence)",!
	do binarytest("']")
	write " -> Test ']] binary operator (NOT FOLLOWS in subscript ordering sequence)",!
	do binarytest("']]")

	write "-----------------------------",!
	write "--> Test Pattern Match Operator",!
	write "-----------------------------",!
	write " -> Test ? binary operator (PATTERN MATCH)",!
	set xstr="set x=$zysqlnull?1""a"" zwrite x" write xstr,! xecute xstr
	set xstr="set x=$zysqlnull?1$zysqlnull zwrite x" write xstr,! xecute xstr
	set xstr="set x=$zysqlnull?1""abcd""_$zysqlnull zwrite x" write xstr,! xecute xstr
	set xstr="set x=""abcd""?1""abcd""_$zysqlnull zwrite x" write xstr,! xecute xstr
	quit

ydb484e	;
	write "################################################################",!
	write "# Test : ydb484e : Test following section of functional spec",!
	write "----------------------------------------------------------------",!
	write "# $TEST continues to have only 2 values : false (0) and true (1).",!
	write "# An IF statement whose condition evaluates to $ZYSQLNULL will treat $TEST as set to 0 and skip the IF.",!
	write "# Commands with postconditionals that evaluate to $ZYSQLNULL will skip executing the command.",!
	write "################################################################",!
	write " -> Test Command Postconditionals",!
	; Randomly generate boolean expressions that are known to evaluate to 0 or 1 or $ZYSQLNULL and verify
	; that the postconditional evaluates to FALSE, TRUE and FALSE respectively.
	do booltest("SETpostconditionaltest")
	do AllCmdPostConditionalTest
	;
	for operator="=","'=","<",">","'<","'>","<=",">=","]","]]","']","']]","[","'[" do
	. write " -> Test that IF $ZYSQLNULL"_operator_"x does not execute IF block AND sets $TEST to 0",!
	. for nonnull=0,"","abcd","12abcd",(1/3),20,(-1/3),"-18.58" do
        . . set xstr="if $zysqlnull"_operator_$zwrite(nonnull)_" write ""IF block executed. Not expected."",!" write xstr,! xecute xstr
        . . set xstr="else  write ""ELSE block executed as expected"",!" write xstr,! xecute xstr
        . . set xstr="zwrite $test" write xstr,! xecute xstr
        . . set xstr="if "_$zwrite(nonnull)_operator_"$zysqlnull write ""IF block executed. Not expected."",!" write xstr,! xecute xstr
        . . set xstr="else  write ""ELSE block executed as expected"",!" write xstr,! xecute xstr
        . . set xstr="zwrite $test" write xstr,! xecute xstr
	write !
	quit

ydb484f	;
	write "################################################################",!
	write "# Test : ydb484f : Test following section of functional spec",!
	write "----------------------------------------------------------------",!
	write "# Using $ZYSQLNULL as a subscript or value of a gvn (as does an indirect assignment with a MERGE),",!
	write "#   or as a subscript in a LOCK/ZALLOCATE/ZDEALLOCATE command, or in a context that expects an integer",!
	write "#   or a numeric value, raises a ZYSQLNULLNOTVALID error.",!
	write "# If $ZYSQLNULL is used in a context that expects a string and is not an operand to a binary or unary",!
	write "#   operator e.g. $ASCII($ZYSQLNULL,1), it would be treated as if an empty string "" was specified.",!
	write "################################################################",!
	; This test generates lots of errors and moves on to the next M line. The error trap M routine that this uses (^incrtrap)
	; causes $zlevel to go higher for each error so note down the $ZLEVEL at function entry and use that to ZGOTO to
	; at the end of this function
	set origzlevel=$zlevel
	new incrtrapLEVEL
	set incrtrapLEVEL=1	; not sure why but setting this causes incrtrap^incrtrap to go to next M line correctly after error
	write "--> Test $ZYSQLNULL as a subscript in gvn raises an error",!
	for gvn="^x($ZYSQLNULL)","^x(1,2,$ZYSQLNULL)" do
	. set xstr="set "_gvn_"=1" write xstr,! xecute xstr
	. for dbop="$get","$data","$order","$query" do
	. . set xstr="write "_dbop_"("_gvn_")" write xstr,! xecute xstr
	. . kill dummy
	write "--> Test $ZYSQLNULL as a value in gvn raises an error",!
	for gvn="^x","^x(1,2)","^x(1,$ZYSQLNULL)" do
	. set xstr="set "_gvn_"=$ZYSQLNULL"  write xstr,! xecute xstr
	. kill dummy
	write "--> Test $ZYSQLNULL as a subscript in lock/zallocate/zdeallocate command raises an error",!
	for gvn="^x($ZYSQLNULL)","^x(1,2,$ZYSQLNULL)"  do
	. for lkop="lock ","lock -","lock +","zallocate ","zdeallocate " do
	. . set xstr=lkop_gvn  write xstr,! xecute xstr
	. . kill dummy
	write "--> Test $ZYSQLNULL as a gvn subscript in MERGE command raises an error",!
	set xstr="set x(1)=1,x(""abcd"")=""abcd"",x($ZYSQLNULL)="""" merge ^y=x" write xstr,! xecute xstr
	write "-> Test $ZYSQLNULL in context that requires an integer raises an error",!
	write "-> Test $ZYSQLNULL in context that requires a string works as if """" was specified",!
	set tv=1
	write "$ASCII and $ZASCII",!
	set xstr="set res=$ascii($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$ascii("") " result different from $ascii("""")",!
	set xstr="set res=$zascii($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$zascii("") " result different from $ascii("""")",!
	for func="$ascii","$zascii" do
	. for first=$ZYSQLNULL,"abcd" do
	. . for second=$ZYSQLNULL,1 do
	. . . set k="",l=""
	. . . set:first="abcd" k=first
	. . . set:first'="abcd" k=""
	. . . set:second=1 l=second
	. . . set:second'=1 l=""
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res="_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . . kill dummy
	;
	write "$FIND and $ZFIND",!
	for func="$find","$zfind" do
	. for first=$ZYSQLNULL,"HIFI" do
	. . new k,l,m
	. . set k=first
	. . set:$ZYISSQLNULL(first) k=""
	. . for second=$ZYSQLNULL,"I" do
	. . . set l=second
	. . . set:$ZYISSQLNULL(second) l=""
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="write:res'="_func_"(k,l) ""result is different from "_func_"(""_k_"",""_l_"")""" xecute xstr
	. . . for third=$ZYSQLNULL,1 do
	. . . . set m=third
	. . . . set:$ZYISSQLNULL(third) m=""
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_") zwrite res" write xstr," " xecute xstr
	. . . . . set xstr="set res="_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_") zwrite res" write xstr," " xecute xstr
	. . . . kill dummy
	;
	set incrtrapLEVEL=0	; because $TEXT issues TEXTARG error instead of ZYSQLNULLNOTVALID and that causes us
				; to go back one M frame we want to avoid that by setting incrtrapLEVEL to 0 just for this portion
	write "$TEXT",!
	set tvstr=":tv=1"
	set xstr="set res=$text($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	set xstr="set res=$text("""") zwrite res" write xstr," " xecute xstr
	set incrtrapLEVEL=1	; set incrtrapLEVEL back to 1 now that $TEXT portion of the test is done
	write "$ZCHAR",!
	set xstr="set res=$ZCHAR($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write "$CHAR",!
	set xstr="set res=$char($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write "$RANDOM",!
	set xstr="set res=$random($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write "TROLLBACK",!
	set xstr="TROLLBACK $ZYSQLNULL" write xstr," " xecute xstr
	set xstr="TROLLBACK"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr
	write "ZHALT",!
	set xstr="ZHALT $ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZHALT"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr
	write "ZTCOMMIT",!
	set xstr="ZTCOMMIT $ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZTCOMMIT"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr
	;
	write "$REVERSE",!
	set xstr="set res=$reverse($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$reverse("") "result is different from $reverse("""")",!
	write "$QLENGTH",!
	set xstr="set res=$qlength($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	set xstr="set res=$qlength("""") zwrite res" write xstr," " xecute xstr
	write "$ZWIDTH",!
	set xstr="set res=$zwidth($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$zwidth("") "result is different from $zwidth("""")",!
	write "$DATA and $ZDATA",!
	set x1=1,xzynull=$ZYSQLNULL
	set xstr="set res=$data(x1)" write xstr," " xecute xstr write !
	write:res'=$data(xzynull) "result different from $data(xzynull)"
	set xstr="set res=$zdata(x1)" write xstr," " xecute xstr write !
	write:res'=$zdata(xzynull) "result different from $data(xzynull)"
	write "USE",!
	set file="dummy.txt"
	set xstr="use $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="use """"" write xstr," " xecute xstr write !
	set xstr="use file:$ZYSQLNULL=""\r""" write xstr," " xecute xstr write !
	set xstr="use file:""""=""\r""" write xstr," " xecute xstr write !
	set xstr="use file:TERM=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="use file:TERM=""""" write xstr," " xecute xstr write !
	set xstr="use $ZYSQLNULL:TERM=""""" write xstr," " xecute xstr write !
	set xstr="use """":TERM=""""" write xstr," " xecute xstr write !
	set xstr="use:tv=1 $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="use:tv=1 """"" write xstr," " xecute xstr write !
	set xstr="use:tv=1 file:$ZYSQLNULL=""\r""" write xstr," " xecute xstr write !
	set xstr="use:tv=1 file:""""=""\r""" write xstr," " xecute xstr write !
	set xstr="use:tv=1 file:TERM=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="use:tv=1 file:TERM=""""" write xstr," " xecute xstr write !
	set xstr="use:tv=1 $ZYSQLNULL:TERM=""""" write xstr," " xecute xstr write !
	set xstr="use:tv=1 """":TERM=""""" write xstr," " xecute xstr write !
	write "ZCOMPILE",!
	set xstr="zcompile $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zcompile """"" write xstr," " xecute xstr write !
	set xstr="zcompile"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zcompile"_tvstr_" """"" write xstr," " xecute xstr write !
	write "CLOSE",!
	set xstr="close $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="close """"" write xstr," " xecute xstr write !
	set xstr="close"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="close"_tvstr_" """"" write xstr," " xecute xstr write !
	write "ZSHOW",!
	set xstr="zshow $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zshow """"" write xstr," " xecute xstr write !
	set xstr="zshow"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zshow"_tvstr_" """"" write xstr," " xecute xstr write !
	write "XECUTE",!
	set xstr="xecute $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="xecute """"" write xstr," " xecute xstr write !
	set xstr="xecute"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="xecute"_tvstr_" """"" write xstr," " xecute xstr write !
	write "ZSYSTEM",!
	set xstr="zsystem $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zsystem"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zsystem"_tvstr_" """"" write xstr," " xecute xstr write !
	write "ZRUPDATE",!
	set xstr="zrupdate $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zrupdate """"" write xstr," " xecute xstr
	set xstr="zrupdate"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zrupdate"_tvstr_" """"" write xstr," " xecute xstr
	;
	write "$LENGTH and $ZLENGTH",!
	set x="Smith/John/M/124 Main Street/Ourtown/KA/USA",y="/"
	set xstr="set res=$length($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$length("") "result is different from $length("""")"
	set xstr="set res=$length($ZYSQLNULL,$ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$length("","") "result is different from $length("""","""")"
	set xstr="set res=$length($ZYSQLNULL,""/"") zwrite res" write xstr," " xecute xstr
	write:res'=$length("","/") "result is different from $length("""",""/"")"
	set xstr="set res=$length(""Smith/John/M/124 Main Street/Ourtown/KA/USA"",$ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$length("Smith/John/M/124 Main Street/Ourtown/KA/USA","") "result is different from $length(""Smith/John/M/124 Main Street/Ourtown/KA/USA"","""")"
	set xstr="set res=$zlength($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$zlength("") "result is different from $zlength("""")"
	set xstr="set res=$zlength($ZYSQLNULL,$ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$zlength("","") "result is different from $zlength("""","""")"
	set xstr="set res=$zlength($ZYSQLNULL,""/"") zwrite res" write xstr," " xecute xstr
	write:res'=$zlength("","/") "result is different from $zlength("""",""/"")"
	set xstr="set res=$zlength(""Smith/John/M/124 Main Street/Ourtown/KA/USA"",$ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$zlength("Smith/John/M/124 Main Street/Ourtown/KA/USA","") "result is different from $zlength(""Smith/John/M/124 Main Street/Ourtown/KA/USA"","""")"
	;
	write "$ZJOBEXAM",!
	set res1="",res2=""
	set xstr="set res1=$zjobexam($ZYSQLNULL)" write xstr," " xecute xstr write !
	set res2=$zjobexam("")
	write:$extract(res2,0,$length(res2)-1)'=$extract(res1,0,$length(res1)-1) "$zjobexam($ZYSQLNULL) different from $zjobexam("""")",!
	set xstr="set res1=$zjobexam($ZYSQLNULL,$ZYSQLNULL)" write xstr," " xecute xstr write !
	set res2=$zjobexam("","")
	write:$extract(res2,0,$length(res2)-1)'=$extract(res1,0,$length(res1)-1) "$zjobexam($ZYSQLNULL,$ZYSQLNULL) different from $zjobexam("""","""")",!
	set xstr="set res1=$zjobexam($ZYSQLNULL,""Dummy"")" write xstr," " xecute xstr write !
	set res2=$zjobexam("","Dummy")
	write:$extract(res2,0,$length(res2)-1)'=$extract(res1,0,$length(res1)-1) "$zjobexam($ZYSQLNULL,""Dummy"") different from $zjobexam("""",""Dummy"")",!
	set xstr="set res1=$zjobexam(""TEST"",$ZYSQLNULL)" write xstr," " xecute xstr write !
	set res2=$zjobexam("TEST","")
	write:$extract(res2,0,$length(res2)-1)'=$extract(res1,0,$length(res1)-1) "$zjobexam(""TEST"",$ZYSQLNULL) different from $zjobexam(""TEST"","""")",!
	;
	write "$ZSEARCH",!
	set xstr="set res=$zsearch($ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	write:res'=$zsearch("") "result is different from $zsearch("""")",!
	set xstr="set res=$zsearch($ZYSQLNULL,$ZYSQLNULL) zwrite res" write xstr," " xecute xstr	; expect zysql error
	set xstr="set res=$zsearch($ZYSQLNULL,1) zwrite res" write xstr," " xecute xstr
	write:res'=$zsearch("",1) "result is different from $zsearch("""",1)",!
	set xstr="set res=$zsearch(""dummy.txt"",$ZYSQLNULL) zwrite res" write xstr," " xecute xstr	; expect zysql error
	;
	write "$ZGETJPI",!
	set xstr="set res=$zgetjpi($ZYSQLNULL,$ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	set xstr="set res=$zgetjpi($ZYSQLNULL,""UTIME"") zwrite res" write xstr," " xecute xstr
	set xstr="set res=$zgetjpi(1,$ZYSQLNULL) zwrite res" write xstr," " xecute xstr
	set xstr="set res=$zgetjpi(1,"""") zwrite res" write xstr," " xecute xstr
	;
	; stack takes in an integer expression so null is not tested here
	write "$STACK",!
	set x=1
	set y="MCODE"
	for first=$ZYSQLNULL,x do
	. if ($ZYISSQLNULL(first)) set xstr="set res=$stack("_$ZWRITE(first)_") zwrite res" write xstr," " xecute xstr
	. for second=$ZYSQLNULL,"MCODE","ECODE","PLACE" do
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="set res=$stack("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
	. . kill dummy
	;
	write "$ZYHASH",!
	set x="ifembu8r308j243h5g3h84t7yf23h0h"
	set y=1
	for first=$ZYSQLNULL,x do
	. new k,l
	. set k=first
	. if ($ZYISSQLNULL(first)) do
	. . set k=""
	. . set xstr="set res=$zyhash("_$ZWRITE(first)_") zwrite res" write xstr," " xecute xstr
	. . write:res'=$zyhash(k) "result is different from $zyhash("_$ZWRITE(k)_")",!
	. for second=$ZYSQLNULL,y do
	. . set l=second
	. . set:$ZYISSQLNULL(second) l=""
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="set res=$zyhash("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
        . . . set xstr="set res=$zyhash("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . kill dummy
	;
	write "$QSUBSCRIPT",!
	set x="^|""XXX""|ABC(1,2,3,5,6)"
	set y=0
	for first=$ZYSQLNULL,x do
	. for second=$ZYSQLNULL,y do
	. . new k,l
	. . set k=first,l=second
	. . set:$ZYISSQLNULL(first) k=""
	. . set:$ZYISSQLNULL(second) l=""
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="set res=$qsubscript("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
        . . . set xstr="set res=$qsubscript("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . kill dummy
	;
	write "$ZWRITE",!
	set x="dummy"
	set y=1
	for first=$ZYSQLNULL,x do
	. new k,l
	. set k=first
	. if ($ZYISSQLNULL(first)) do
	. . set k=""
	. . set xstr="set res=$zwrite("_$ZWRITE(first)_") zwrite res" write xstr," " xecute xstr
	. . set xstr="set res=$zwrite("_$ZWRITE(k)_") zwrite res" write xstr," " xecute xstr
	. for second=$ZYSQLNULL,1 do
	. . set l=second
	. . set:$ZYISSQLNULL(second) l=""
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="set res=$zwrite("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
        . . . set xstr="set res=$zwrite("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . kill dummy
	;
	write "$ZCONVERT 3 arg form",!
	set x="10",y="DEC",z="HEX"
	for first=$ZYSQLNULL,x do
	. for second=$ZYSQLNULL,y do
	. . for third=$ZYSQLNULL,z  do
	. . . new k,l,m
	. . . set k="",l="",m=""
	. . . set:first=x k=first
	. . . set:second=y l=second
	. . . set:third=z m=third
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . set xstr="set res=$zconvert("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res=$zconvert("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_") zwrite res" write xstr," " xecute xstr
	. . . kill dummy
	write "$ZCONVERT 2 arg form",!
	set x="Happy New Year"
	set y="U"
	for first=$ZYSQLNULL,x do
	. for second=$ZYSQLNULL,y do
	. . new k,l
	. . set k="",l=""
	. . set:first=x k=first
	. . set:second=y l=second
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="set res=$zconvert("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
        . . . set xstr="set res=$zconvert("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . kill dummy
	write "$ZTRNLNM",!
	set a="ydb_dist",b="x",c="",d="",e="",f="VALUE"
	for first=$ZYSQLNULL,a do
	. new k,p
	. set k=first
	. if ($ZYISSQLNULL(first)) do
	. . set k=""
	. . set xstr="set res=$ztrnlnm("_$ZWRITE(first)_") zwrite res" write xstr," " xecute xstr
	. . write:res'=$ztrnlnm(k) "result is different from $ztrnlnm("""_k_""")",!
	. for sixth=$ZYSQLNULL,f do
	. . set p=sixth
	. . set:$ZYISSQLNULL(sixth) p=""
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(sixth)) do
	. . . set xstr="set res=$ztrnlnm("_$ZWRITE(first)_","""","""","""","""","_$ZWRITE(sixth)_") zwrite res" write xstr," " xecute xstr
	. . . write:res'=$ztrnlnm(k,"","","","",p) "result is different from $ztrnlnm("""_k_""","""""","""""","""""","""""","""_p_""")",!
	. . kill dummy
	;
	write "$EXTRACT and $ZEXTRACT",!
	set a="Hello world",b=1,c=3
	for func="$extract","$zextract" do
	. for first=$ZYSQLNULL,a do
	. . new k,l,m set k=""
	. . set:'$ZYISSQLNULL(first) k=a
	. . if $ZYISSQLNULL(first) do
	. . . set xstr="set res="_func_"("_$ZWRITE(first)_") zwrite res" write xstr," " xecute xstr
	. . . set xstr="set res="_func_"("_$ZWRITE(k)_") zwrite res" write xstr," " xecute xstr
	. . for second=$ZYSQLNULL,b do
	. . . set l=""
	. . . set:'$ZYISSQLNULL(second) l=b
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res="_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . . for third=$ZYSQLNULL,c do
	. . . . set m=""
	. . . . set:'$ZYISSQLNULL(third) m=c
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_") zwrite res" write xstr," " xecute xstr
	. . . . . set xstr="set res="_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_") zwrite res" write xstr," " xecute xstr
	. . . . kill dummy
	;
	write "$FNUMBER",!
	set x=923333.22,z="4"
	for first=$ZYSQLNULL,x do
	. for second=$ZYSQLNULL,",","+","-",".","T","P" do
	. . new k,l,m set k="",l=""
	. . set:first=x k=x
	. . set:'$ZYISSQLNULL(second) l=second
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="set res=$fnumber("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
	. . . set xstr="set res=$fnumber("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . for third=$ZYSQLNULL,z do
	. . . set m="" set:third=z m=z
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . set xstr="set res=$fnumber("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res=$fnumber("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_") zwrite res" write xstr," " xecute xstr
	. . . kill dummy
	;
	write "$JUSTIFY and $ZJUSTIFY",!
	write "3 ARG FORM",!
	set x=10.234,y=10,z=2
	for func="$justify","$zjustify" do
	. for first=$ZYSQLNULL,x do
	. . for second=$ZYSQLNULL,y do
	. . . new k,l,m set k="",l=""
	. . . set:first=x k=x
	. . . set:second=y l=y
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res="_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . . for third=$ZYSQLNULL,z do
	. . . . set m="" set:third=z m=z
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_") zwrite res" write xstr," " xecute xstr
	. . . . . set xstr="set res="_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_") zwrite res" write xstr," " xecute xstr
	. . . . kill dummy
	write "2 ARG FORM",!
	set x="Hello"
	set y=10
	for func="$justify","$zjustify" do
	. for first=$ZYSQLNULL,x do
	. . for second=$ZYSQLNULL,y do
	. . . new k,l set k="",l=""
	. . . set:'$ZYISSQLNULL(first) k=x
	. . . set:'$ZYISSQLNULL(second) l=y
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . . set xstr="set res="_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
        . . . . set xstr="set res="_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . . kill dummy
	;
	write "$ZPARSE",!
	set a="test",b="NAME",c="/usr/work/",d="dust.lis",e=""
	for first=$ZYSQLNULL,a do
	. new k,l,m,n,o set k=""
	. set:'$ZYISSQLNULL(first) k=a
	. if $ZYISSQLNULL(first) do
	. . set xstr="set res=$zparse("_$ZWRITE(first)_")" write xstr," " xecute xstr write !
	. . write:res'=$zparse(k) "result different from $zparse("_$ZWRITE(k)_")",!
	. for second=$ZYSQLNULL,b do
	. . set l="" set:'$ZYISSQLNULL(second) l=b
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="set res=$zparse("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . write:res'=$zparse(k,l) "result different from $zparse("_$ZWRITE(k)_","_$ZWRITE(l)_")",!
	. . for third=$ZYSQLNULL,c  do
	. . . set m="" set:'$ZYISSQLNULL(third) m=c
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . set xstr="set res=$zparse("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_")" write xstr," " xecute xstr write !
	. . . . write:res'=$zparse(k,l,m) "result different from $zparse("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_")",!
	. . . for fourth=$ZYSQLNULL,d do
	. . . . set n="" set:'$ZYISSQLNULL(fourth) n=d
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)!$ZYISSQLNULL(fourth)) do
	. . . . . set xstr="set res=$zparse("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_","_$ZWRITE(fourth)_")" write xstr," " xecute xstr write !
	. . . . . write:res'=$zparse(k,l,m,n) "result different from $zparse("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_","_$ZWRITE(n)_")",!
	. . . . for fifth=$ZYSQLNULL,e do
	. . . . . set o="" set:'$ZYISSQLNULL(fifth) o=e
	. . . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)!$ZYISSQLNULL(fourth)!$ZYISSQLNULL(fifth)) do
	. . . . . . set xstr="set res=$zparse("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_","_$ZWRITE(fourth)_","_$ZWRITE(fifth)_")" write xstr," " xecute xstr write !
	. . . . . . write:res'=$zparse(k,l,m,n,o) "result different from $zparse("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_","_$ZWRITE(n)_","_$ZWRITE(o)_")",!
	. . . . . kill dummy
	;
	write "$ORDER",!
	set xzynull=$ZYSQLNULL,y0=0,z1=1,xnull=""
        set xstr="set ^x1=1" xecute xstr
	zwrite xzynull
	zwrite xnull
	zwrite y0
	zwrite z1
	zwrite ^x1
	for first="xzynull","y0","^x1" do
	. new k,l set k="xnull",l="xnull"
	. set:first'="xzynull" k=first
	. if (first="xzynull") do
	. . set xstr="write $order("_first_")" write xstr," " xecute xstr write !
	. . set xstr="write $order("_k_")" write xstr," " xecute xstr write !
	. for second="xzynull",1,"z1" do
	. . set l="xnull" set:second'="xzynull" l=second
	. . if ((first="xzynull")!(second="xzynull")) do
	. . . set xstr="write $order("_first_","_second_")" write xstr," " xecute xstr write !
	. . . set xstr="write $order("_k_","_l_")" write xstr," " xecute xstr write !
	. . kill dummy
	;
	write "$ZBITFIND",!
	set strval=$ZBITSET($ZBITSET($ZBITSTR(8,0),2,1),8,1) ; The binary representation of A is 01000001
	set y1=1,z3=3,xzynull=$ZYSQLNULL,xnull=""
	zwrite xzynull
	zwrite xnull
	zwrite y1
	zwrite z3
	for first="$ZYSQLNULL","xzynull","strval" do
	. for second="$ZYSQLNULL","xzynull",y1,"y1" do
	. . new k,l,m set k="""""",l=""""""
	. . set:((first'="$ZYSQLNULL")&(first'="xzynull")) k=first
	. . set:((second'="$ZYSQLNULL")&(second'="xzynull")) l=second
	. . if ((first="$ZYSQLNULL")!(first="xzynull")!(second="$ZYSQLNULL")!(second="xzynull")) do
	. . . set xstr="set res=$zbitfind("_first_","_second_") zwrite res" write xstr," " xecute xstr
	. . . set xstr="set res=$zbitfind("_k_","_l_") zwrite res" write xstr," " xecute xstr
	. . for third="$ZYSQLNULL","xzynull",z3,"z3" do
	. . . set m="""""" set:((third'="$ZYSQLNULL")&(third'="xzynull")) m=third
	. . . if ((first="$ZYSQLNULL")!(first="xzynull")!(second="$ZYSQLNULL")!(second="xzynull")!(third="$ZYSQLNULL")!(third="xzynull")) do
	. . . . set xstr="set res=$zbitfind("_first_","_second_","_third_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res=$zbitfind("_k_","_l_","_m_") zwrite res" write xstr," " xecute xstr
	. . . kill dummy
	for second="$ZYSQLNULL","xzynull",y1,"y1" do
	. new l,m set m="""""",l=""""""
	. set:((second'="$ZYSQLNULL")&(second'="xzynull")) l=second
	. if ((second="$ZYSQLNULL")!(second="xzynull")) do
	. . set xstr="set res=$zbitfind(strval,"_second_") zwrite res" write xstr," " xecute xstr
	. . set xstr="set res=$zbitfind(strval,"_l_") zwrite res" write xstr," " xecute xstr
	. for third="$ZYSQLNULL","xzynull",z3,"z3" do
	. . set:((third'="$ZYSQLNULL")&(third'="xzynull")) m=third
	. . if ((second="$ZYSQLNULL")!(second="xzynull")!(third="$ZYSQLNULL")!(third="xzynull")) do
	. . . set xstr="set res=$zbitfind(strval,"_second_","_third_") zwrite res" write xstr," " xecute xstr
	. . . set xstr="set res=$zbitfind(strval,"_l_","_m_") zwrite res" write xstr," " xecute xstr
	. . kill dummy
	;
	write "$ZBITAND, $ZBITOR & $ZBITXOR",!
	set strval1=$ZBITSET($ZBITSET($ZBITSTR(8,0),2,1),8,1) ; The binary representation of A is 01000001
	set strval2=$ZBITSET($ZBITSET($ZBITSTR(8,0),2,1),7,1) ; The binary representation of B is 01000010
	set xzynull=$ZYSQLNULL
	for dbop="$zbitand","$zbitor","$zbitxor" do
	. for first="$ZYSQLNULL","xzynull","strval1" do
	. . for second="$ZYSQLNULL","xzynull","strval2" do
	. . . new k,l set k="""""",l=""""""
	. . . set:((first'="$ZYSQLNULL")&(first'="xzynull")) k=first
	. . . set:((second'="$ZYSQLNULL")&(second'="xzynull")) l=second
	. . . if ((first="$ZYSQLNULL")!(first="xzynull")!(second="$ZYSQLNULL")!(second="xzynull")) do
	. . . . set xstr="write "_dbop_"("_first_","_second_")" write xstr," " xecute xstr
	. . . . set xstr="write "_dbop_"("_k_","_l_")" write xstr," " xecute xstr
	. . . kill dummy
	;
	set xzynull=$ZYSQLNULL
	set xnull=""
	zwrite xzynull
	zwrite xnull
	for func="$zbitcount","$zbitlen","$zbitnot" do
	. write func,!
	. set xstr="write "_func_"($ZYSQLNULL)" write xstr," " xecute xstr
	. set xstr="write "_func_"("""")" write xstr," " xecute xstr
	. set xstr="write "_func_"(xzynull)" write xstr," " xecute xstr
	. set xstr="write "_func_"(xnull)" write xstr," " xecute xstr
	. kill dummy
	;
	write "$ZBITGET",!
	set xstrval=$ZBITSET($ZBITSET($ZBITSTR(8,0),2,1),8,1)
	set y2=2
	zwrite xstrval
	zwrite y2
	zwrite xzynull
	for first="$ZYSQLNULL","xzynull","xstrval" do
	. for second=$ZYSQLNULL,y2 do
	. . new k,l
	. . set k="""""",l=""""""
	. . set:(first="xstrval") k=first
	. . set:second=y2 l=second
	. . if ((first="$ZYSQLNULL")!($ZYISSQLNULL(second))!(first="xzynull")) do
	. . . set xstr="write $zbitget("_first_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
        . . . set xstr="write $zbitget("_k_","_l_")" write xstr," " xecute xstr write !
	. . kill dummy
	;
	write "$ZBITSET",!
	set xstrval=$ZBITSET($ZBITSET($ZBITSTR(8,0),2,1),8,1)
	set y3=3,z1=1
	for first="$ZYSQLNULL","xzynull","xstrval" do
	. for second=$ZYSQLNULL,y3 do
	. . for third=$ZYSQLNULL,z1 do
	. . . new k,l,m
	. . . set k="""""",l="""""",m=""""""
	. . . set:(first="xstrval") k=first
	. . . set:second=y3 l=second
	. . . set:third=z1 m=third
	. . . if ((first="$ZYSQLNULL")!(first="xzynull")!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . set xstr="set res=$zbitset("_first_","_$ZWRITE(second)_","_$ZWRITE(third)_")" write xstr," " xecute xstr write !
	. . . . set xstr="set res=$zbitset("_k_","_l_","_m_")" write xstr," " xecute xstr write !
	. . . kill dummy
	;
	write "$ZBITSTR",!
	set a=7,b=1
	for first=$ZYSQLNULL,a do
	. if ($ZYISSQLNULL(first)) set xstr="set res=$zbitstr("_$ZWRITE(first)_")" write xstr," " xecute xstr
	. for second=$ZYSQLNULL,b do
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="set res=$zbitstr("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr
	. . kill dummy
	;
	write "$ZSIGPROC",!
	set x=-999,ysigstr="SIGUSR1",yzynull=$ZYSQLNULL
	zwrite ysigstr
	zwrite yzynull
	for first=$ZYSQLNULL,x do
	. for second="$ZYSQLNULL","yzynull","ysigstr","""SIGUSR1""" do
	. . if ($ZYISSQLNULL(first)!(second="$ZYSQLNULL")!(second="yzynull")) set xstr="set res=$zsigproc("_$ZWRITE(first)_","_second_") zwrite res" write xstr," " xecute xstr
	. . kill dummy
	;
	write "$QUERY",!
	set xzynull=$ZYSQLNULL
	set xnull=""
	set xstr="write $query(xzynull)" write xstr xecute xstr write !
	set xstr="write $query(xnull)" write xstr xecute xstr write !
	;
	write "$SELECT",!
	set xzynull=$ZYSQLNULL,xnull="",x=1
	zwrite xzynull
	zwrite xnull
	for first="xnull","xzynull","$ZYSQLNULL" do
	. set xstr="write $select(tv=1:"_first_")" write xstr," " xecute xstr write !
	. kill dummy
	set xstr="set result=$zysqlnull  write $select(result=0:0,result=1:1,1:2),!" write xstr,! xecute xstr
	set xstr="set result=$zysqlnull  write $select(result=0:0,(result=1)!1:1,1:2),!" write xstr,! xecute xstr
	;
	write "$VIEW",!
	set a=1,*b(1)=a,^x=1
	set xstr="write $view($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="write $view("""")" write xstr," " xecute xstr write !
	for first=$ZYSQLNULL,"LV_REF","LV_CREF" do
	. new k,l set k=first
	. set:$ZYISSQLNULL(first) k=""
	. for second=$ZYSQLNULL,"a" do
	. . set l=second
	. . set:$ZYISSQLNULL(second) l=""
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="write $view("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . set xstr="write $view("_$ZWRITE(k)_","_$ZWRITE(l)_")" write xstr," " xecute xstr write !
	. . . ; generates extra loop without this empty statement
	. . kill dummy
	;
	for first=$ZYSQLNULL,"FREEBLOCKS","FREEZE","GVFILE","GVNEXT","GVSTAT","JNLACTIVE","JNLFILE","POOLLIMIT","PROBECRIT","STATSHARE","TOTALBLOCKS" do
	. new k,l set k=first
	. set:$ZYISSQLNULL(first) k=""
	. for second=$ZYSQLNULL,"name" do
	. . set l=second
	. . set:$ZYISSQLNULL(second) l=""
	. . if (($ZYISSQLNULL(first)!$ZYISSQLNULL(second))&('($ZYISSQLNULL(first)&$ZYISSQLNULL(second)))) do
	. . . set xstr="write $view("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . set xstr="write $view("_$ZWRITE(k)_","_$ZWRITE(l)_")" write xstr," " xecute xstr write !
	. . kill dummy
	;
	for first=$ZYSQLNULL,"NOISOLATION","REGION","YGVN2GDS" do
	. new k,l set k=first
	. set:$ZYISSQLNULL(first) k=""
	. for second=$ZYSQLNULL,"^x" do
	. . set l=second
	. . set:$ZYISSQLNULL(second) l=""
	. . if (($ZYISSQLNULL(first)!$ZYISSQLNULL(second))&('($ZYISSQLNULL(first)&$ZYISSQLNULL(second)))) do
	. . . set xstr="write $view("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . set xstr="write $view("_$ZWRITE(k)_","_$ZWRITE(l)_")" write xstr," " xecute xstr write !
	. . kill dummy
	;
	for first=$ZYSQLNULL,"RTNCHECKSUM","RTNNEXT","YGDS2GVN" do
	. new k,l set k=first
	. set:$ZYISSQLNULL(first) k=""
	. for second=$ZYSQLNULL,"dummydebug" do
	. . set l=second
	. . set:$ZYISSQLNULL(second) l=""
	. . if (($ZYISSQLNULL(first)!$ZYISSQLNULL(second))&('($ZYISSQLNULL(first)&$ZYISSQLNULL(second)))) do
	. . . set xstr="set res=$view("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . set xstr="set res=$view("_$ZWRITE(k)_","_$ZWRITE(l)_")" write xstr," " write:res'=$view(k,l) "result is different from $view("_$ZWRITE(k)_","_$ZWRITE(l)_")" write !
	. . kill dummy
	;
	write "$ZDATE",!
	set aval="65435,29367",zynull=$ZYSQLNULL,bval="DAY, DD/MM/YY",cval="Januar,Februar,Marz,April,Mai,Juni,Juli,August,September,October,November,Dezember",dval="Dimanche,Lundi,Mardi,Mercredi,Jeudi,Vendredi,Samedi"
	for first="$ZYSQLNULL","zynull",$ZWRITE(aval),"aval" do
	. new k,l,m,n
	. set k=aval set:((first="zynull")!(first="$ZYSQLNULL")) k=""
	. if ((first="zynull")!(first="$ZYSQLNULL")) do
	. . set xstr="set res=$zdate("_first_") zwrite res" write xstr," " xecute xstr
	. . set xstr="set res=$zdate("_$ZWRITE(k)_") zwrite res" write xstr," " xecute xstr
	. for second="$ZYSQLNULL","zynull","bval",$ZWRITE(bval) do
	. . set l=bval set:((second="zynull")!(second="$ZYSQLNULL")) l=""
	. . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")) do
	. . . set xstr="set res=$zdate("_first_","_second_") zwrite res" write xstr," " xecute xstr
	. . . set xstr="set res=$zdate("_$ZWRITE(k)_","_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . for third="$ZYSQLNULL","zynull","cval",$ZWRITE(cval)  do
	. . . set m=cval set:((third="zynull")!(third="$ZYSQLNULL")) m=""
	. . . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")!(third="zynull")!(third="$ZYSQLNULL")) do
	. . . . set xstr="set res=$zdate("_first_","_second_","_third_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res=$zdate("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_") zwrite res" write xstr," " xecute xstr
	. . . for fourth="$ZYSQLNULL","zynull","dval",$ZWRITE(dval) do
	. . . . set n=dval set:($ZYISSQLNULL(fourth)!(fourth="zynull")!(fourth="$ZYSQLNULL")) n=""
	. . . . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")!(third="zynull")!(third="$ZYSQLNULL")!(fourth="zynull")!(fourth="$ZYSQLNULL")) do
	. . . . . set xstr="set res=$zdate("_first_","_second_","_third_","_fourth_") zwrite res" write xstr," " xecute xstr
	. . . . . set xstr="set res=$zdate("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_","_$ZWRITE(n)_") zwrite res" write xstr," " xecute xstr
	. . . . kill dummy
	;
	write "$GET and $INCREMENT",!
	set a1=1,bneg2=-2
	set zynull=$ZYSQLNULL
        set xstr="set ^x1=1" write xstr," " xecute xstr
	zwrite a1
	zwrite bneg2
	zwrite zynull
	for func="$get","$increment" do
	. for first="zynull","a1","^x1" do
	. . new k,l
	. . set k=a1 set:((first="zynull")!(first="$ZYSQLNULL")) k=""
	. . if ((first="zynull")!(first="$ZYSQLNULL")) do
	. . . set xstr="set res="_func_"("_first_") zwrite res" write xstr," " xecute xstr
	. . . set xstr="set res="_func_"(k) zwrite res" write xstr," " xecute xstr
	. . for second="$ZYSQLNULL","zynull",bneg2,"bneg2" do
	. . . set l=bneg2 set:((second="zynull")!(second="$ZYSQLNULL")) l=""
	. . . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")) do
	. . . . set xstr="set res="_func_"("_first_","_second_") zwrite res" write xstr," " xecute xstr
	. . . . set xstr="set res="_func_"(k,"_$ZWRITE(l)_") zwrite res" write xstr," " xecute xstr
	. . . kill dummy
	;
	write "$ZTRANSLATE and $TRANSLATE",!
	set a=$char(120),b=$zchar(100),c=$zchar(110)
	for first=$ZYSQLNULL,a do
	. new k,l,m
	. set k="",l="",m=""
	. set:first=a k=first
	. set xstr="set res=$ztranslate("_$ZWRITE(first)_") zwrite res" write xstr," " xecute xstr
	. write:res'=$ztranslate(k) "result is different from $ztranslate("""_k_""")",!
	. for second=$ZYSQLNULL,b do
	. . set:second=b l=second
	. . set:second'=b l=""
	. . set xstr="set res=$ztranslate("_$ZWRITE(first)_","_$ZWRITE(second)_") zwrite res" write xstr," " xecute xstr
	. . write:res'=$ztranslate(k,l) "result is different from $ztranslate("""_k_""","""_l_""")",!
	. . for third=$ZYSQLNULL,c  do
	. . . set:third=c m=third
	. . . set:third'=c m=""
	. . . set xstr="set res=$ztranslate("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_") zwrite res" write xstr," " xecute xstr
	. . . write:res'=$ztranslate(k,l,m) "result is different from $ztranslate("""_k_""","""_l_""","""_m_""")",!
	. . . kill dummy
	;
	set aval="ABC",bval="CB",cval="1"
	set zynull=$ZYSQLNULL
	zwrite aval
	zwrite bval
	zwrite cval
	zwrite zynull
	for first="$ZYSQLNULL","zynull",$ZWRITE(aval),"aval" do
	. new k,l,m set k=aval
	. if ((first="zynull")!(first="$ZYSQLNULL")) do
	. . set k=""
	. . set xstr="set res=$translate("_first_") zwrite res" write xstr," " xecute xstr
	. . write:res'=$translate(k) "result different from $translate("_$ZWRITE(k)_")"
	. for second="$ZYSQLNULL","zynull","bval",$ZWRITE(bval) do
	. . set l=bval set:((second="zynull")!(second="$ZYSQLNULL")) l=""
	. . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")) do
	. . . set xstr="set res=$translate("_first_","_second_") zwrite res" write xstr," " xecute xstr
	. . . write:res'=$translate(k,l) "result different from $translate("_$ZWRITE(k)_","_$ZWRITE(l)_")"
	. . for third="$ZYSQLNULL","zynull",cval,"cval"  do
	. . . set m=cval set:((third="zynull")!(third="$ZYSQLNULL")) m=""
	. . . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")!(third="zynull")!(third="$ZYSQLNULL")!$ZYISSQLNULL(fourth)!(fourth="zynull")!(fourth="$ZYSQLNULL")) do
	. . . . set xstr="set res=$translate("_first_","_second_","_third_") zwrite res" write xstr," " xecute xstr
	. . . . write:res'=$translate(k,l,m) "result different from $translate("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_")"
	. . . kill dummy
	;
	write "$ZCOLLATE",!
	set xexpr="A(""foo"")",y0=0,z1=1,zynull=$ZYSQLNULL
        set ^xgexpr=xexpr
	zwrite xexpr
	zwrite y0
	zwrite z1
	zwrite zynull
	for first="$ZYSQLNULL","zynull","xexpr","^xgexpr" do
	. for second="$ZYSQLNULL","zynull","y0" do
	. . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")) do
	. . . set xstr="set res=$zcollate("_first_","_second_")" write xstr," " xecute xstr write !
	. . . ; generates extra loop without this empty statement
	. . for third="$ZYSQLNULL","zynull","z1" do
	. . . set m=third set:((third="zynull")!(third="$ZYSQLNULL")) m=""""""
	. . . if ((first="zynull")!(first="$ZYSQLNULL")!(second="zynull")!(second="$ZYSQLNULL")!(third="zynull")!(third="$ZYSQLNULL")) do
	. . . . set xstr="set res=$zcollate("_first_","_second_","_third_")" write xstr," " xecute xstr write !
	. . . . ; generates extra loop without this empty statement
	. . . kill dummy
	;
	write "$PIECE and $ZPIECE",!
	set a="1 2",b=" ",c=1,d=2
	for func="$piece","$zpiece" do
	. for first=$ZYSQLNULL,a do
	. . new k,l,m,n
	. . set k="" set:first=a k=first
	. . for second=$ZYSQLNULL,b do
	. . . set l="" set:second=b l=second
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . . set xstr="write "_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . . set xstr="write "_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_")" write xstr," " xecute xstr write !
	. . . for third=$ZYSQLNULL,c do
	. . . . set m="" set:third=c m=third
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . . set xstr="write "_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_")" write xstr," " xecute xstr write !
	. . . . . set xstr="write "_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_")" write xstr," " xecute xstr write !
	. . . . for fourth=$ZYSQLNULL,d do
	. . . . . set n="" set:fourth=d n=fourth
	. . . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)!$ZYISSQLNULL(fourth)) do
	. . . . . . set xstr="write "_func_"("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_","_$ZWRITE(fourth)_")" write xstr," " xecute xstr write !
	. . . . . . set xstr="write "_func_"("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_","_$ZWRITE(n)_")" write xstr," " xecute xstr write !
	. . . . . kill dummy
	;
	write "$NAME",!
	set xlocal="h",y0=0,zynull=$ZYSQLNULL
	set ^xglob=xlocal
	zwrite xlocal
	zwrite ^xglob
	zwrite y0
	zwrite zynull
	for first="zynull","xlocal","^xglob" do
	. new k,l set k=xlocal
	. if (first="zynull") do
	. . set k=""
	. . set xstr="write $name("_first_")" write xstr," " xecute xstr write !
	. . set xstr="write $name(k)" write xstr," " xecute xstr write !
	. for second=$ZYSQLNULL,y0 do
	. . set l=y0
	. . set:$ZYISSQLNULL(second) l=""
	. . if ((first="zynull")!($ZYISSQLNULL(second))) do
	. . . set xstr="write $name("_first_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . set xstr="write $name(k,"_$ZWRITE(l)_")" write xstr," " xecute xstr write !
	. . kill dummy
	;
	write "$ZATRANSFORM",!
	set a="John Smythe",b="",c=0,d=0
	for first=$ZYSQLNULL,a do
	. new k,l,m,n
	. set k=""
	. set:first=a k=first
	. for second=$ZYSQLNULL,b do
	. . set l="" set:second=b l=second
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . set xstr="set res=$zatransform("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . . set xstr="set res=$zatransform("_$ZWRITE(k)_","_$ZWRITE(l)_")" write xstr," " xecute xstr write !
	. . for third=$ZYSQLNULL,c  do
	. . . set m="" set:third=c m=third
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) do
	. . . . set xstr="set res=$zatransform("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_")" write xstr," " xecute xstr write !
	. . . . set xstr="set res=$zatransform("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_")" write xstr," " xecute xstr write !
	. . . for fourth=$ZYSQLNULL,d do
	. . . . set n="" set:fourth=d n=fourth
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)!$ZYISSQLNULL(fourth)) do
	. . . . . set xstr="set res=$zatransform("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_","_$ZWRITE(fourth)_")" write xstr," " xecute xstr write !
	. . . . . set xstr="set res=$zatransform("_$ZWRITE(k)_","_$ZWRITE(l)_","_$ZWRITE(m)_","_$ZWRITE(n)_")" write xstr," " xecute xstr write !
	. . . . kill dummy
	;
	write !,"Testing m commands",!
	write "WRITE",!
	set xlocal="asdf",yval=6,zval="h",zynull=$ZYSQLNULL
        set ^xglobal="hello"
	for tvstr="",":tv=1" do
	. for first="$ZYSQLNULL","zynull",xlocal,"xlocal","^xglobal" do
	. . new k,l,m set k=xlocal
	. . if ((first="$ZYSQLNULL")!(first="zynull")) do
	. . . set k=""
	. . . set xstr="write"_tvstr_" "_first write xstr," " xecute xstr write !
	. . . set xstr="write"_tvstr_" "_$ZWRITE(k) write xstr," " xecute xstr write !
	. . for second="$ZYSQLNULL",yval,"yval" do
	. . . set l=yval
	. . . set:((second="$ZYSQLNULL")!(second="zynull")) l=""
	. . . if ((first="$ZYSQLNULL")!(first="zynull")!(second="$ZYSQLNULL")!(second="zynull")) do
	. . . . set xstr="write"_tvstr_" "_first_",?"_second write xstr," " xecute xstr write !
	. . . . set xstr="write"_tvstr_" "_$ZWRITE(k)_",?"_$ZWRITE(l) write xstr," " xecute xstr write !
	. . . for third="$ZYSQLNULL","zynull",zval,"zval" do
	. . . . set m=zval
	. . . . set:((third="$ZYSQLNULL")!(third="zynull")) m=""
	. . . . if ((first="$ZYSQLNULL")!(first="zynull")!(second="$ZYSQLNULL")!(second="zynull")!(third="$ZYSQLNULL")!(third="zynull")) do
	. . . . . set xstr="write"_tvstr_" "_first_",?"_second_","_third write xstr," " xecute xstr write !
	. . . . . set xstr="write"_tvstr_" "_$ZWRITE(k)_",?"_$ZWRITE(l)_","_$ZWRITE(m) write xstr," " xecute xstr write !
	. . . . kill dummy
	set xstr="write *$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="write"_tvstr_" *$ZYSQLNULL" write xstr," " xecute xstr
	;
	write "FOR",!
	write "Expect error as passing $ZYSQLNULL to integer parameters",!
	set a=1,b=1,c=3,zynull=$ZYSQLNULL,incr=1
	for lvn="$ZYSQLNULL","var" do
	. for first=$ZYSQLNULL,a do
	. . if ($ZYISSQLNULL(first)) set xstr="set incr=1 for "_lvn_"="_$ZWRITE(first)_" write incr set incr=incr+1 quit:incr=3" write xstr," " xecute xstr write !
	. . for second=$ZYSQLNULL,b do
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="set incr=1 for "_lvn_"="_$ZWRITE(first)_":"_$ZWRITE(second)_" write incr set incr=incr+1 quit:incr=3" write xstr," " xecute xstr write !
	. . . for third=$ZYSQLNULL,c  do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) set xstr="set incr=1 for "_lvn_"="_$ZWRITE(first)_":"_$ZWRITE(second)_":"_$ZWRITE(third)_" write incr set incr=incr+1 quit:incr=3" write xstr," " xecute xstr write !
	. . . . kill dummy
	write "Expecting the behavior to be same for $ZYSQLNULL and """,!
	set incrtrapLEVEL=0	; The below FOR loop tests issue a VAREXPECTED error and that causes us to go back one M frame.
				; We want to avoid that by setting incrtrapLEVEL to 0 just for this portion of the test.
	set xstr="for """"=""hello"","""",""test"" write var,!" write xstr," " xecute xstr write !
	set xstr="for var=""hello"","_$ZWRITE($ZYSQLNULL)_",""test"" write var,!" write xstr," " xecute xstr write !
	set xstr="for var=""hello"","""",""test"" write var,!" write xstr," " xecute xstr write !
	set xstr="for i=$zysqlnull:1:1  zwrite i" write xstr,! xecute xstr
	set xstr="for i=1:$zysqlnull:1  zwrite i" write xstr,! xecute xstr
	set xstr="for i=1:1:$zysqlnull  zwrite i" write xstr,! xecute xstr
	set xstr="for i=$zysqlnull:1:$zysqlnull  zwrite i" write xstr,! xecute xstr
	set xstr="for i=1:$zysqlnull:$zysqlnull  zwrite i" write xstr,! xecute xstr
	set xstr="for i=$zysqlnull:$zysqlnull:1  zwrite i" write xstr,! xecute xstr
	set xstr="for i=$zysqlnull:$zysqlnull:$zysqlnull  zwrite i" write xstr,! xecute xstr
	set xstr="for i=""a"",$zysqlnull,""b"" zwrite i" write xstr,! xecute xstr
	write !
	;
	set incrtrapLEVEL=1	; Reset incrtrapLEVEL back to 1 now that the FOR loop section is done.
	write "SET",!
	Set x="I love hotdogs"
        set ^xglob=x
	set xlocal="hello",xextractlocal="$extract(x,3,6)",xextractglob="$extract(^x,3,6)",xpiecelocal="$piece(x,""^"",2)",xpieceglobal="$piece(^x,""^"",2)",xisv="$zprompt"
	set ystr="hello",yint=1,ylocal=x,^yglobal=^xglob
	for tvstr="",":tv=1" do
	. for first="$ZYSQLNULL","xlocal","^xglob",xextractlocal,xextractglob,xpiecelocal,xpieceglobal,xisv do
	. . for second="$ZYSQLNULL","ystr","yint","ylocal","^yglobal" do
	. . . if ((first="$ZYSQLNULL")!(second="$ZYSQLNULL")) set xstr="set"_tvstr_" "_first_"="_second write xstr," " xecute xstr write !
	. . . kill dummy
	;
	write "READ",!
	set xstr="read $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="read """"" write xstr," " xecute xstr write !
	set xstr="read"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="read"_tvstr_" """"" write xstr," " xecute xstr write !
	;
	write "ZLINK",!
	set x="ydb484dummy.m",y="-noobject -list"
	open x:(newversion) use x write "dummydebug",!," write ""In dummy debug"",!",!," quit",! close x
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,x do
	. . new k set k=""
	. . set:first=x k=x
	. . if ($ZYISSQLNULL(first)) do
	. . . set xstr="zlink"_tvstr_" "_$ZWRITE(first) write xstr," " xecute xstr write !
	. . . set xstr="zlink"_tvstr_" "_$ZWRITE(k) write xstr," " xecute xstr write !
	. . for second=$ZYSQLNULL,y do
	. . . new l set l=""
	. . . set:second=y l=y
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) do
	. . . . set xstr="zlink"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . . . set xstr="zlink"_tvstr_" "_$ZWRITE(k)_":"_$ZWRITE(l) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	write "ZMESSAGE",!
	set x=150373850,y="z"
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,x do
	. . if ($ZYISSQLNULL(first)) set xstr="zmessage"_tvstr_" "_$ZWRITE(first) write xstr," " xecute xstr write !
	. . for second=$ZYSQLNULL,y do
	. . . if ($ZYISSQLNULL(second)!$ZYISSQLNULL(first)) set xstr="zmessage"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	write "VIEW",!
	set xstr="view $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="view"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="view ""LABELS"":$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="view $ZYSQLNULL:""UPPER""" write xstr," " xecute xstr write !
	set xstr="view $ZYSQLNULL:""LOWER""" write xstr," " xecute xstr write !
	for tvstr="",":tv=1" do
	. for first="","UN" do
	. . for second=$ZYSQLNULL,"hello" do
	. . . for third=$ZYSQLNULL,1 do
	. . . . if ($ZYISSQLNULL(second)!$ZYISSQLNULL(third)) set xstr="view"_tvstr_" """_first_"SETENV"":"_$ZWRITE(second)_":"_$ZWRITE(third) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	set ^x=0
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,0 do
	. . for second=$ZYSQLNULL,"^x" do
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="view"_tvstr_" ""TRACE"":"_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,"BREAKMSG","GDSCERT","GVDUPSETNOOP","JOBPID","ZDATE_FORM" do
	. . for second=$ZYSQLNULL,1 do
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="view"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,"DBFLUSH" do
	. . for second=$ZYSQLNULL,"name" do
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="view"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . . for third=$ZYSQLNULL,4 do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) set xstr="view"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second)_":"_$ZWRITE(third) write xstr," " xecute xstr write !
	. . . . kill dummy
	;
        for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,"DBSYNC","EPOCH","FLUSH","GVSRESET","JNLFLUSH","PATCODE","PATLOAD" do
        . . for second=$ZYSQLNULL,"name" do
        . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="view"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,"LINK" do
        . . for second=$ZYSQLNULL,y1,"RECURSIVE","NORECURSIVE" do
        . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="view"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for tvstr="",":tv=1" do
	. for first="NO","" do
	. . for second="ONTP","" do
	. . . set xstr="view"_tvstr_" """_first_"LOGN"_second_""":$ZYSQLNULL" write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for tvstr="",":tv=1" do
	. for first="NO","" do
	. . for second="PRESTART","" do
	. . . set xstr="view"_tvstr_" """_first_"LOGT"_second_""":$ZYSQLNULL" write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for tvstr="",":tv=1" do
        . for first=$ZYSQLNULL,"NOISOLATION" do
	. . for second="","+","-" do
        . . . for third=$ZYSQLNULL,"^x,^y" do
        . . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(third)) set xstr="view"_tvstr_" "_$ZWRITE(first)_":"""_second_$ZWRITE(third)_"""" write xstr," " xecute xstr write !
	. . . . kill dummy
	set xstr="view ""NOISOLATION"":""""" write xstr," " xecute xstr write !
	set xstr="view"_tvstr_" ""NOISOLATION"":""""" write xstr," " xecute xstr write !
	;
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,"POOLLIMIT" do
	. . for second=$ZYSQLNULL,"name" do
	. . . for third=$ZYSQLNULL,"0%",1,"*" do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) set xstr="view"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second)_":"_$ZWRITE(third) write xstr," " xecute xstr write !
	. . . . kill dummy
	;
	for tvstr="",":tv=1" do
	. for first="NO","" do
	. . set xstr="view"_tvstr_" "_first_"STATSHARE:$ZYSQLNULL" write xstr," " xecute xstr write !
	. . kill dummy
	;
	write "JOB",!
	set x="dummydebug",y="(""test"")"
	for tvstr="",":tv=1" do
	. for first="$ZYSQLNULL",x do
	. . for second="",y do
	. . . if (first="$ZYSQLNULL") set xstr="JOB"_tvstr_" "_first_second write xstr," " xecute xstr write !
	. . . for third="$ZYSQLNULL","CMDLINE","DEFAULT","ERROR","GBLDIR","INPUT","OUTPUT","STARTUP" do
	. . . . if ((first="$ZYSQLNULL")!(third="$ZYSQLNULL")) do
	. . . . . set xstr="JOB"_tvstr_" "_first_second_":("_third_"=$ZYSQLNULL)" write xstr," " xecute xstr write !
	. . . . . ; prevents extra loop here
	. . . . kill dummy
	;
	write "LOCK",!
	set x=1,^x=1,c="x"
	for tvstr="",":tv=1" do
	. for first="","+","-" do
	. . for second="$ZYSQLNULL" do
	. . . set xstr="LOCK"_tvstr_" "_first_second write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for tvstr="",":tv=1" do
	. for first="","+","-" do
	. . for second="$ZYSQLNULL","x","^x","@c" do
	. . . for third="$ZYSQLNULL",0 do
	. . . . if ((second="$ZYSQLNULL")!(third="$ZYSQLNULL")) set xstr="LOCK"_tvstr_" "_first_second_":"_third write xstr," " xecute xstr write !
	. . . . kill dummy
	;
	write "ZEDIT",!
	set xzynull=$ZYSQLNULL,y=1
	for tvstr="",":tv=1" do
	. set xstr="zedit"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	. set xstr="zedit"_tvstr_" xzynull" write xstr," " xecute xstr write !
	. kill dummy
	;
	write "HANG",!
	set xzynull=$ZYSQLNULL,y=1
	for tvstr="",":tv=1" do
	. set xstr="hang"_tvstr_" $ZYSQLNULL" write xstr," " xecute xstr write !
	. set xstr="hang"_tvstr_" xzynull" write xstr," " xecute xstr write !
	. kill dummy
	;
	write "$ZSOCKET",!
	for first=$ZYSQLNULL,"" do
	. for second=$ZYSQLNULL,"DELIMITER","DESCRIPTOR","HOWCREATED","INDEX","IOERROR","LOCALADDRESS","LOCALPORT","MOREREADTIME","PARENT","PROTOCOL","REMOTEADDRESS","REMOTEPORT","SOCKETHANDLE","STATE","ZBFSIZE","ZFF","ZIBFSIZE","ZDELAY" do
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="write $zsocket("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . for third=$ZYSQLNULL,0 do
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) set xstr="write $zsocket("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_")" write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for first=$ZYSQLNULL,"" do
	. for second="CURRENTINDEX","NUMBER" do
	. . set xstr="write $zsocket("_$ZWRITE(first)_","_$ZWRITE(second)_")" write xstr," " xecute xstr write !
	. . kill dummy
	;
	for first=$ZYSQLNULL,"" do
	. for second="TLS" do
	. . for third=$ZYSQLNULL,0 do
	. . . for fourth="$ZYSQLNULL","SESSION","OPTIONS","CIPHER","ALL" do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(third)!(fourth="$ZYSQLNULL")) set xstr="write $zsocket("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_","_fourth_")" write xstr," " xecute xstr write !
	. . . . kill dummy
	;
	for first=$ZYSQLNULL,"" do
	. for second="DELIMITER" do
	. . for third=$ZYSQLNULL,0 do
	. . . for fourth="$ZYSQLNULL",0 do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(third)!(fourth="$ZYSQLNULL")) set xstr="write $zsocket("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_","_fourth_")" write xstr," " xecute xstr write !
	. . . . kill dummy
	;
	write "$ZPEEK",!
	for first=$ZYSQLNULL,"GRLREPL","JPCREPL","RIHREPL","RPCREPL","UHCREPL","UPLREPL" do
	. for second=$ZYSQLNULL,0 do
	. . for third=$ZYSQLNULL,1 do
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) set xstr="set res=$zpeek("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_")" write xstr," " xecute xstr write !
	. . . for fourth=$ZYSQLNULL,"C","I","U","S","T","X","Z" do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)!$ZYISSQLNULL(fourth)) set xstr="set res=$zpeek("_$ZWRITE(first)_","_$ZWRITE(second)_","_$ZWRITE(third)_","_$ZWRITE(fourth)_")" write xstr," " xecute xstr write !
	. . . . kill dummy
	;
	for first=$ZYSQLNULL,"CSAREG","FHREG","GDRREG","NLREG","JBFREG","JNLREG" do
	. for second="",":name" do
	. . if ($ZYISSQLNULL(first)) set first=$ZYSQLNULL
	. . if ('$ZYISSQLNULL(first)) set first=""_first_second_""
	. . for third=$ZYSQLNULL,0 do
	. . . for forth=$ZYSQLNULL,1 do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(third)!$ZYISSQLNULL(forth)) set xstr="set res=$zpeek("_$ZWRITE(first)_","_$ZWRITE(third)_","_$ZWRITE(forth)_")" write xstr," " xecute xstr write !
	. . . . for fifth=$ZYSQLNULL,"C","I","U","S","T","X","Z" do
	. . . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(third)!$ZYISSQLNULL(forth)!$ZYISSQLNULL(fifth)) set xstr="set res=$zpeek("_$ZWRITE(first)_","_$ZWRITE(third)_","_$ZWRITE(fourth)_","_$ZWRITE(fifth)_")" write xstr," " xecute xstr write !
	. . . . . kill dummy
	;
	for first=$ZYSQLNULL,"GLFREPL","GSLREPL","PEEK" do
	. for second="",0 do
	. . if ($ZYISSQLNULL(first)) set first=$ZYSQLNULL
	. . if (('$ZYISSQLNULL(first))&(second'="")) set first=""_first_":"_second_""
	. . for third=$ZYSQLNULL,0 do
	. . . for forth=$ZYSQLNULL,1 do
	. . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(third)!$ZYISSQLNULL(forth)) set xstr="set res=$zpeek("_$ZWRITE(first)_","_$ZWRITE(third)_","_$ZWRITE(forth)_")" write xstr," " xecute xstr write !
	. . . . for fifth=$ZYSQLNULL,"C","I","U","S","T","X","Z" do
	. . . . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(third)!$ZYISSQLNULL(forth)!$ZYISSQLNULL(fifth)) set xstr="set res=$zpeek("_$ZWRITE(first)_","_$ZWRITE(third)_","_$ZWRITE(fourth)_","_$ZWRITE(fifth)_")" write xstr," " xecute xstr write !
	. . . . . kill dummy
	;
	write "QUIT",!
	set xstr="set res=$$dummydebugresult" write xstr," " xecute xstr write !
	zwrite res
	;
	write "ZWRITE",!
	set xzynull=$ZYSQLNULL
	set xstr="zwrite xzynull" write xstr," " xecute xstr
	set xstr="zwrite $ZYSQLNULL" write xstr," " xecute xstr
	;
	write "OPEN",!
	set x=".",y="READONLY",z=1
	for first=$ZYSQLNULL,x do
	. set xstr="open "_$ZWRITE(first) write xstr," " xecute xstr write !
	. for second=$ZYSQLNULL,y do
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="open "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . for third=$ZYSQLNULL,z do
	. . . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)!$ZYISSQLNULL(third)) set xstr="open "_$ZWRITE(first)_":"_$ZWRITE(second)_":"_$ZWRITE(third) write xstr," " xecute xstr write !
	. . . kill dummy
	;
	for first=$ZYSQLNULL,x do
	. for second=$ZYSQLNULL,z do
	. . if ($ZYISSQLNULL(first)!$ZYISSQLNULL(second)) set xstr="open "_$ZWRITE(first)_"::"_$ZWRITE(second) write xstr," " xecute xstr write !
	. . kill dummy
	;
	set incrtrapLEVEL=0	; for reasons not yet clear, keeping this variable enabled causes the below test to indefinitely
				; loop so disable it for the remainder of the test.
	write "ZGOTO",!
	set xstr="ZGOTO $ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZGOTO $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZGOTO """":""""" write xstr," " xecute xstr
	set xstr="ZGOTO $ZYSQLNULL:dummydebug" write xstr," " xecute xstr
	set xstr="ZGOTO 0:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZGOTO 0:""""" write xstr," " xecute xstr
	set xstr="ZGOTO:tv=1 $ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZGOTO:tv=1 $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZGOTO:tv=1 """":""""" write xstr," " xecute xstr
	set xstr="ZGOTO:tv=1 $ZYSQLNULL:dummydebug" write xstr," " xecute xstr
	set xstr="ZGOTO:tv=1 0:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="ZGOTO:tv=1 0:""""" write xstr," " xecute xstr
	;
	write "ZBREAK",!
	set albl="dummydebug",bval="",c1=1
	set xstr="zbreak $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak """"" write xstr," " xecute xstr write !
	set xstr="zbreak $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak """":""""" write xstr," " xecute xstr write !
	set xstr="zbreak $ZYSQLNULL:$ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak """":"""":""""" write xstr," " xecute xstr write !
	set xstr="zbreak $ZYSQLNULL:$ZYSQLNULL:1" write xstr," " xecute xstr write !
	set xstr="zbreak """":"""":1" write xstr," " xecute xstr write !
	set xstr="zbreak $ZYSQLNULL:""W ! ZP @$ZPOS W !"":$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak """":""W ! ZP @$ZPOS W !"":""""" write xstr," " xecute xstr write !
	set xstr="zbreak $ZYSQLNULL:""W ! ZP @$ZPOS W !"":1" write xstr," " xecute xstr write !
	set xstr="zbreak """":""W ! ZP @$ZPOS W !"":1" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:""""" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:$ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:"""":""""" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:$ZYSQLNULL:1" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:"""":1" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:""W ! ZP @$ZPOS W !"":$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug:""W ! ZP @$ZPOS W !"":""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """"" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """":""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL:$ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """":"""":""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL:$ZYSQLNULL:1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """":"""":1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL:""W ! ZP @$ZPOS W !"":$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """":""W ! ZP @$ZPOS W !"":""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL:""W ! ZP @$ZPOS W !"":1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """":""W ! ZP @$ZPOS W !"":1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:$ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:"""":""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:$ZYSQLNULL:1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:"""":1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:""W ! ZP @$ZPOS W !"":$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug:""W ! ZP @$ZPOS W !"":""""" write xstr," " xecute xstr write !
	;
	set xstr="zbreak $ZYSQLNULL::$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak """"::""""" write xstr," " xecute xstr write !
	set xstr="zbreak $ZYSQLNULL::1" write xstr," " xecute xstr write !
	set xstr="zbreak """"::1" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug::$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak dummydebug::""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL::$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """"::""""" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 $ZYSQLNULL::1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 """"::1" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug::$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zbreak:tv=1 dummydebug::""""" write xstr," " xecute xstr write !
	;
	write "ZPRINT",!
	set tv=1
	set xstr="zprint $ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint """"" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint """":""""" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:$ZYSQLNULL+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint """":""""+""""" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:$ZYSQLNULL+1" write xstr," " xecute xstr
	set xstr="zprint """":""""+1" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:dummydebug" write xstr," " xecute xstr
	set xstr="zprint """":dummydebug" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:dummydebug+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint """":dummydebug+""""" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:dummydebug+1" write xstr," " xecute xstr
	set xstr="zprint """":dummydebug+1" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:""""" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:$ZYSQLNULL+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:""""+""""" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:$ZYSQLNULL+1" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:""""+1" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:dummydebug" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:dummydebug" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:dummydebug+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:dummydebug+""""" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """"" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":""""" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:$ZYSQLNULL+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":""""+""""" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:$ZYSQLNULL+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":""""+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:dummydebug" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":dummydebug" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:dummydebug+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":dummydebug+""""" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:dummydebug+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":dummydebug+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:""""" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:$ZYSQLNULL+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:""""+""""" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:$ZYSQLNULL+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:""""+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:dummydebug" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:dummydebug" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:dummydebug+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:dummydebug+""""" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint """":+""""" write xstr," " xecute xstr
	set xstr="zprint $ZYSQLNULL:+1" write xstr," " xecute xstr
	set xstr="zprint """":+1" write xstr," " xecute xstr
	set xstr="zprint dummydebug^ydb484:+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:+$ZYSQLNULL" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":+""""" write xstr," " xecute xstr
	set xstr="zprint:tv=1 $ZYSQLNULL:+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 """":+1" write xstr," " xecute xstr
	set xstr="zprint:tv=1 dummydebug^ydb484:+$ZYSQLNULL" write xstr," " xecute xstr
	;
	write "ZALLOCATE",!
	set xstr="zallocate $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zallocate """"" write xstr," " xecute xstr write !
	set xstr="zallocate $ZYSQLNULL:1" write xstr," " xecute xstr write !
	set xstr="zallocate """":1" write xstr," " xecute xstr write !
	set xstr="zallocate x:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zallocate @c:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zallocate ^x:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zallocate:tv=1 $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zallocate:tv=1 """"" write xstr," " xecute xstr write !
	set xstr="zallocate:tv=1 $ZYSQLNULL:1" write xstr," " xecute xstr write !
	set xstr="zallocate:tv=1 """":1" write xstr," " xecute xstr write !
	set xstr="zallocate:tv=1 x:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zallocate:tv=1 @c:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zallocate:tv=1 ^x:$ZYSQLNULL" write xstr," " xecute xstr write !
	;
	write "TSTART",!
	set xzynull=$ZYSQLNULL,y=1
	set xstr="tstart $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart """"" write xstr," " xecute xstr write !
	set xstr="tstart $ZYSQLNULL:$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart """":""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart $ZYSQLNULL:TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart """":TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart $ZYSQLNULL:TRANSACTIONID=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart """":TRANSACTIONID=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart $ZYSQLNULL:TRANSACTIONID=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart """":TRANSACTIONID=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart $ZYSQLNULL:($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart """":("""")" write xstr," " xecute xstr write !
	set xstr="tstart $ZYSQLNULL:(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart """":(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart y:$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart y:""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart y:TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart y:TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart y:$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart y:""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart y:$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart y:""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart y:($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart y:("""")" write xstr," " xecute xstr write !
	set xstr="tstart y:(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart y:(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart ():$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart ():""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart ():TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart ():TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart ():$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart ():""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart ():$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart ():""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart ():($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart ():("""")" write xstr," " xecute xstr write !
	set xstr="tstart ():(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart ():(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart ($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart *:$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart *:""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart *:TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart *:TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart *:$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart *:""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart *:$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart *:""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart *:($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart *:("""")" write xstr," " xecute xstr write !
	set xstr="tstart *:(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart *:(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart :$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart :""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart :TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart :TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart :$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart :""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart :$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart :""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart :($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart :("""")" write xstr," " xecute xstr write !
	set xstr="tstart :(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart :(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 """"" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 $ZYSQLNULL:$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 """":""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 $ZYSQLNULL:TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 """":TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 $ZYSQLNULL:TRANSACTIONID=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 """":TRANSACTIONID=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 $ZYSQLNULL:TRANSACTIONID=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 """":TRANSACTIONID=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 $ZYSQLNULL:($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 """":("""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 $ZYSQLNULL:(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 """":(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:("""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 y:(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():("""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 ():(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:("""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 *:(SERIAL:"""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :$ZYSQLNULL=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :""""=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :TRANSACTIONID=$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :TRANSACTIONID=""""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :$ZYSQLNULL=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :""""=""BATCH""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :$ZYSQLNULL=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :""""=""BA""" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :($ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :("""")" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :(SERIAL:$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="tstart:tv=1 :(SERIAL:"""")" write xstr," " xecute xstr write !
	;
	write "LOCK",!
	set xstr="LOCK (x,$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="LOCK +(x,$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="LOCK -(x,$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="LOCK (x,$ZYSQLNULL):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK +(x,$ZYSQLNULL):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK -(x,$ZYSQLNULL):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK (x,$ZYSQLNULL):1" write xstr," " xecute xstr write !
	set xstr="LOCK +(x,$ZYSQLNULL):1" write xstr," " xecute xstr write !
	set xstr="LOCK -(x,$ZYSQLNULL):1" write xstr," " xecute xstr write !
	set xstr="LOCK (x,^x):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK -(x,^x):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK +(x,^x):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 (x,$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 +(x,$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 -(x,$ZYSQLNULL)" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 (x,$ZYSQLNULL):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 +(x,$ZYSQLNULL):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 -(x,$ZYSQLNULL):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 (x,$ZYSQLNULL):1" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 +(x,$ZYSQLNULL):1" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 -(x,$ZYSQLNULL):1" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 (x,^x):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 -(x,^x):$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="LOCK:tv=1 +(x,^x):$ZYSQLNULL" write xstr," " xecute xstr write !
	;
	write "ZSTEP",!
	set xstr="zstep $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep """"" write xstr," " xecute xstr write !
	set xstr="zstep $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep """":""""" write xstr," " xecute xstr write !
	set xstr="zstep INTO:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep INTO:""""" write xstr," " xecute xstr write !
	set xstr="zstep OUTOF:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep OUTOF:""""" write xstr," " xecute xstr write !
	set xstr="zstep OVER:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep OVER:""""" write xstr," " xecute xstr write !
	set xstr="zstep ACTIONS:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep ACTIONS:""""" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 $ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 """"" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 $ZYSQLNULL:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 """":""""" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 INTO:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 INTO:""""" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 OUTOF:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 OUTOF:""""" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 OVER:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 OVER:""""" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 ACTIONS:$ZYSQLNULL" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 ACTIONS:""""" write xstr," " xecute xstr write !
	set xstr="zstep $ZYSQLNULL:""W ! ZP @$ZPOS W !""" write xstr," " xecute xstr write !
	set xstr="zstep """":""W ! ZP @$ZPOS W !""" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 $ZYSQLNULL:""W ! ZP @$ZPOS W !""" write xstr," " xecute xstr write !
	set xstr="zstep:tv=1 """":""W ! ZP @$ZPOS W !""" write xstr," " xecute xstr write !
	;
	write "ZHELP",!
	set znull=""
	for tvstr="",":tv=1" do
	. for first=$ZYSQLNULL,znull do
	. . set xstr="zhelp"_tvstr_" "_$ZWRITE(first) write xstr," " xecute xstr
	. . for second=$ZYSQLNULL,znull do
	. . . set xstr="zhelp"_tvstr_" "_$ZWRITE(first)_":"_$ZWRITE(second) write xstr," " xecute xstr
	. . . kill dummy
	;
	; Now that all tests are done return back to caller (use ZGOTO instead of QUIT because $ZLEVEL is no longer accurate)
	zgoto origzlevel-1
	quit

dummydebug
	set ^result=1
	quit
dummydebugresult()
	quit $ZYSQLNULL

ydb484g	;
	write "################################################################",!
	write "# Test : ydb484g : Miscellaneous tests",!
	write "----------------------------------------------------------------",!
	set origzlevel=$zlevel
	new comment
	set comment="!"
	write !," -> Simple test of OC_CONTAIN : "
	write 0!(comment["a")
	write 1&(comment["a")
	write 0!(comment'["a")
	write 1&(comment'["a")
	write !," -> Simple test of OC_FOLLOW : "
	write 0!(comment]"a")
	write 1&(comment]"a")
	write 0!(comment']"a")
	write 1&(comment']"a")
	write !," -> Simple test of OC_SORTS_AFTER : "
	write 0!(comment]]"a")
	write 1&(comment]]"a")
	write 0!(comment']]"a")
	write 1&(comment']]"a")
	write !," -> Simple test of OC_EQU : "
	write 0!(comment="a")
	write 1&(comment="a")
	write 0!(comment'="a")
	write 1&(comment'="a")
	write !," -> Simple test of OC_PATTERN : "
	write 0!(comment?1"a")
	write 1&(comment?1"a")
	write 0!(comment'?1"a")
	write 1&(comment'?1"a")
	write !," -> Simple test of OC_NUMCMP : "
	write 0!(comment<"a")
	write 1&(comment<"a")
	write 0!(comment'>"a")
	write 1&(comment'<"a")
	write 0!(comment>="a")
	write 1&(comment<="a")
	write !
	; Below is a simple test that frequently failed the v230/v230 subtest so captured here
	new A,B,comparison
	set comparison="A>B",A=2,B=1
	if @comparison write "set comparison=""A>B"",A=2,B=1 if @comparison : IF block reached as expected",!
	else  write "set comparison=""A>B"",A=2,B=1 if @comparison : ELSE block reached. NOT EXPECTED.",!
	set comparison="A<B"
	if @comparison write "set comparison=""A<B"",A=2,B=1 if @comparison : IF block reached. NOT expected",!
	else  write "set comparison=""A<B"",A=2,B=1 if @comparison : ELSE block reached as expected",!
	;
	new incrtrapLEVEL
	set incrtrapLEVEL=1	; not sure why but setting this causes incrtrap^incrtrap to go to next M line correctly after error
	new xstr,FALSE,result,i
	set xstr($incr(xstr))="set result=$zysqlnull=$zysqlnull  zwrite result"
	set xstr($incr(xstr))="set result=$zysqlnull=""""  zwrite result"
	set xstr($incr(xstr))="set result=$zysqlnull'=$zysqlnull  zwrite result"
	set xstr($incr(xstr))="set result=$zysqlnull'=""""  zwrite result"
	set xstr($incr(xstr))="set result=+$zysqlnull=0  zwrite result"
	set xstr($incr(xstr))="set result=$zysqlnull=$zysqlnull=$zysqlnull  zwrite result"
	set xstr($incr(xstr))="set result=$zysqlnull=($zysqlnull=$zysqlnull)  zwrite result"
	set xstr($incr(xstr))="set result=$zysqlnull=$zysqlnull=($zysqlnull=$zysqlnull)  zwrite result"
	set xstr($incr(xstr))="set result=+$zysqlnull  zwrite result"
	; Below are a few random boolean expression tests that failed in the v60000/gtm7277 subtest so captured here
	set xstr($incr(xstr))="set FALSE=0 Write (($Test'[$Test)!(($Select(FALSE:1,1:0)'=$Select(FALSE:1,1:0))'=FALSE)),!"
	set xstr($incr(xstr))="set FALSE=0 Write ((($Select(FALSE:1,1:0)'=$Select(FALSE:1,1:0))'=FALSE)!($Test'[$Test)),!"
	set xstr($incr(xstr))="set FALSE=0 Write ((($Select(FALSE:1,1:0)'=$Select(FALSE:1,1:0))'=FALSE)!(($Select(FALSE:1,1:0)'=$Select(FALSE:1,1:0))'=FALSE)),!"
	;
	set xstr($incr(xstr))="goto +($zysqlnull="""")"
	set xstr($incr(xstr))="kill x set result=$incr(x,$zysqlnull) zwrite result,x"
	set xstr($incr(xstr))="set result=$zpeek(""PEEK"",0,""Z"",""X"")"
	set xstr($incr(xstr))="set result=$zpeek(""PEEK:"",0,""Z"",""X"")"
	set xstr($incr(xstr))="set result=$zpeek(""PEEK:0"",0,""Z"",""X"")"
	set xstr($incr(xstr))="set result=$zpeek(""PEEK:0x"",0,""Z"",""X"")"
	set xstr($incr(xstr))="set result=$zpeek(""PEEK:0x1"",0,""Z"",""X"")"
	;
	for i=1:1:xstr do
	. write xstr(i),!
	. xecute xstr(i)
	. quit
	;
	write " -> Test that VIEW NOUNDEF continues to work fine with boolean expressions",!
	set xstr=0
	set xstr($incr(xstr))="if undefvar"
	set xstr($incr(xstr))="if undefvar1[$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull[undefvar2"
	set xstr($incr(xstr))="if undefvar1[undefvar2"
	set xstr($incr(xstr))="if undefvar1'[$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull'[undefvar2"
	set xstr($incr(xstr))="if undefvar1'[undefvar2"
	set xstr($incr(xstr))="if undefvar1]]$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull]]undefvar2"
	set xstr($incr(xstr))="if undefvar1]]undefvar2"
	set xstr($incr(xstr))="if undefvar1']]$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull']]undefvar2"
	set xstr($incr(xstr))="if undefvar1']]undefvar2"
	set xstr($incr(xstr))="if undefvar1]$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull]undefvar2"
	set xstr($incr(xstr))="if undefvar1]undefvar2"
	set xstr($incr(xstr))="if undefvar1']$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull']undefvar2"
	set xstr($incr(xstr))="if undefvar1']undefvar2"
	set xstr($incr(xstr))="if undefvar1?1A"
	set xstr($incr(xstr))="if undefvar1'?1A"
	set xstr($incr(xstr))="if undefvar1<$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull<undefvar2"
	set xstr($incr(xstr))="if undefvar1<undefvar2"
	set xstr($incr(xstr))="if undefvar1'<$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull'<undefvar2"
	set xstr($incr(xstr))="if undefvar1'<undefvar2"
	set xstr($incr(xstr))="if undefvar1>$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull>undefvar2"
	set xstr($incr(xstr))="if undefvar1>undefvar2"
	set xstr($incr(xstr))="if undefvar1'>$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull'>undefvar2"
	set xstr($incr(xstr))="if undefvar1'>undefvar2"
	set xstr($incr(xstr))="if undefvar1=$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull=undefvar2"
	set xstr($incr(xstr))="if undefvar1=undefvar2"
	set xstr($incr(xstr))="if undefvar1'=$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull'=undefvar2"
	set xstr($incr(xstr))="if undefvar1'=undefvar2"
	set xstr($incr(xstr))="if undefvar1+$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull+undefvar2"
	set xstr($incr(xstr))="if undefvar1+undefvar2"
	set xstr($incr(xstr))="if undefvar1-$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull-undefvar2"
	set xstr($incr(xstr))="if undefvar1-undefvar2"
	set xstr($incr(xstr))="if undefvar1*$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull*undefvar2"
	set xstr($incr(xstr))="if undefvar1*undefvar2"
	set xstr($incr(xstr))="if undefvar1/$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull/undefvar2"
	set xstr($incr(xstr))="if undefvar1/undefvar2"
	set xstr($incr(xstr))="if undefvar1\$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull\undefvar2"
	set xstr($incr(xstr))="if undefvar1\undefvar2"
	set xstr($incr(xstr))="if undefvar1#$zysqlnull"
	set xstr($incr(xstr))="if $zysqlnull#undefvar2"
	set xstr($incr(xstr))="if undefvar1#undefvar2"
	set xstr($incr(xstr))="for loopcnt=1:undefvar:-1 write loopcnt,!"
	set ystr="zwrite $test"
	for undef="NOUNDEF","UNDEF" do
	. write " -> Testing VIEW """,undef,"""",!
	. view undef
	. for i=1:1:xstr do
	. . write xstr(i),!
	. . xecute xstr(i)
	. . write ystr,!  xecute ystr
	;
	set incrtrapLEVEL=0	; for reasons not yet clear, keeping this variable set to 0 is necessary for the below test
				; to execute and return to caller fine.
	set xstr="set result=$get($zysqlnull)  zwrite result" write xstr,! xecute xstr write !
	;
	; Now that all tests are done return back to caller (use ZGOTO instead of QUIT because $ZLEVEL is no longer accurate)
	zgoto origzlevel-1
	quit

ydb484g2
	; For reasons not yet clear, this test when placed at the end of `ydb484g` does not execute.
	; So it is placed in a separate section called `ydb484g2` which is invoked after `ydb484g` from `ydb484`.
	set xstr="for $ZYSQLNULL=""hello"","_$ZWRITE($ZYSQLNULL)_",""test"" write var,!" write xstr," " xecute xstr write !
	quit

binarytest(binaryOperator);
	new (binaryOperator)
	for nonnull=0,"","abcd","12abcd",(1/3),20,(-1/3),"-18.58" do
	. ; Try $ZYSQLNULL on left side of binary operator
	. set xstr="set x=$ZYSQLNULL"_binaryOperator_$zwrite(nonnull)_" zwrite x"
	. write xstr,!
	. xecute xstr
	. ; Try $ZYSQLNULL on right side of binary operator
	. set xstr="set x="_$zwrite(nonnull)_binaryOperator_"$ZYSQLNULL zwrite x"
	. write xstr,!
	. xecute xstr
	; Try $ZYSQLNULL on both sides of binary operator
	set xstr="set x=$ZYSQLNULL"_binaryOperator_"$ZYSQLNULL zwrite x"
	write xstr,!
	xecute xstr
	quit

logicaloperatortest;
	; Randomly generate boolean expressions that are known to evaluate to 0 or 1 or $ZYSQLNULL and verify that is the case
	do booltest("logicaloperatortest")
	quit

booltest(testname)
	new i,depth,boolexpr,xstr,failcnt,value,boolrslt,result,starttime,elapsedtime,maxwait,dlrtest
	; Note: Cannot set ^null(...)=$zysqlnull below as $ZYSQLNULL value is not yet supported for gvn nodes
	do valueinit	; sets value() array (needed by below code)
	set false=0,true=1,null=$zysqlnull
	set false(false)=false,true(true)=true,null(false)=null
	set ^false=false,^true=true,^false(false)=false,^true(true)=true
	set ifalse="false",itrue="true",inull="null",^ifalse="^false",^itrue="^true",^inull="null"
	set incrvar=0,iincrvar="incrvar"
	set starttime=$horolog,elapsedtime=0,maxwait=1+$random(15),failcnt=0
	for i=1:1 do  quit:(maxwait<elapsedtime)
	. for boolrslt=0,1,$zysqlnull do
	. . do getboolexpr(.dlrtest,.boolexpr)
	. . set:"logicaloperatortest"=testname xstr="set result="_boolexpr
	. . set:"SETpostconditionaltest"=testname result=0,xstr="set:"_boolexpr_" result=1"
	. . if dlrtest          ; sets $test to dlrtest before boolexpr is evaluated
	. . set ^boolexpr(testname,i)=xstr	; record for later debugging
	. . xecute xstr
	. . if "SETpostconditionaltest"=testname do
	. . . if ((value(boolrslt)'=1)&result) do
	. . . . write "FAIL from "_testname_" : dlrtest=",dlrtest
	. . . . write " : boolexpr : [",boolexpr,"] evaluates to ",value(boolrslt)," but postconditional evaluated to TRUE",!
	. . . . if $increment(failcnt)
	. . . if ((value(boolrslt)=1)&'result) do
	. . . . write "FAIL from "_testname_" : dlrtest=",dlrtest
	. . . . write " : boolexpr : [",boolexpr,"] evaluates to ",value(boolrslt)," but postconditional evaluated to FALSE",!
	. . . . if $increment(failcnt)
	. . if "logicaloperatortest"=testname do
	. . . if value(result)'=value(boolrslt) do
	. . . . write "FAIL from "_testname_" : dlrtest=",dlrtest
	. . . . write " : Expected : ",$zwrite(boolrslt),", Actual : ",$zwrite(result)," : boolexpr = ",boolexpr,!
	. . . . if $increment(failcnt)
	. if i#10=0 set elapsedtime=$$^difftime($horolog,starttime)
	if '$get(failcnt) write "    -> PASS from "_testname,!
	quit

zero(depth)	; Returns a random boolean expression that is guaranteed to evaluate to 0
	new rand,depth1,depth2,ret
	if depth=0 do  quit ret
	. set rand=$random(13)
	. if rand=0 set ret="0"
	. if rand=1 set ret="('true)"
	. if rand=2 set ret="false"
	. if rand=3 set ret=$select(dlrtest:"'$test",1:"$test")
	. if rand=4 set ret="('^true)"
	. if rand=5 set ret="^false"
	. if rand=6 set ret="('@itrue)"
	. if rand=7 set ret="@ifalse"
	. if rand=8 set ret="('@^itrue)"
	. if rand=9 set ret="@^ifalse"
	. if rand=10 set ret=$$incrementhelper(0)
	. if rand=11 set ret="($$Always0)"
	. if rand=12 set ret="('$$Always1)"
	set depth1=$random(depth),depth2=$random(depth)
	set rand=$random(43)
	if rand=0 quit "("_$$one(depth1)_"="_$$zero(depth2)_")"
	if rand=1 quit "("_$$zero(depth1)_"="_$$one(depth2)_")"
	if rand=2 quit "("_$$zero(depth1)_"'="_$$zero(depth2)_")"
	if rand=3 quit "("_$$one(depth1)_"'="_$$one(depth2)_")"
	if rand=4 quit "("_$$zero(depth1)_">"_$$one(depth2)_")"
	if rand=5 quit "("_$$one(depth1)_"<"_$$zero(depth2)_")"
	if rand=6 quit "("_$$zero(depth1)_"'<"_$$one(depth2)_")"
	if rand=7 quit "("_$$one(depth1)_"'>"_$$zero(depth2)_")"
	if rand=8 quit "("_$$zero(depth1)_">="_$$one(depth2)_")"
	if rand=9 quit "("_$$one(depth1)_"<="_$$zero(depth2)_")"
	if rand=10 quit "("_$$one(depth1)_"["_$$zero(depth2)_")"
	if rand=11 quit "("_$$zero(depth1)_"["_$$one(depth2)_")"
	if rand=12 quit "("_$$zero(depth1)_"]"_$$one(depth2)_")"
	if rand=13 quit "("_$$zero(depth1)_"]]"_$$one(depth2)_")"
	if rand=14 quit "("_$$one(depth1)_"'["_$$one(depth2)_")"
	if rand=15 quit "("_$$zero(depth1)_"'["_$$zero(depth2)_")"
	if rand=16 quit "("_$$one(depth1)_"']"_$$zero(depth2)_")"
	if rand=17 quit "("_$$one(depth1)_"']]"_$$zero(depth2)_")"
	if rand=18 quit "("_$$one(depth1)_"?1""0"""_")"
	if rand=19 quit "("_$$zero(depth1)_"?1""1"""_")"
	if rand=20 quit "("_$$one(depth1)_"'?1""1"""_")"
	if rand=21 quit "("_$$zero(depth1)_"'?1""0"""_")"
	if rand=22 quit "("_"'"_$$one(depth1)_")"
	if rand=23 quit "("_$$zero(depth1)_"&"_$$zero(depth2)_")"
	if rand=24 quit "("_$$one(depth1)_"&"_$$zero(depth2)_")"
	if rand=25 quit "("_$$zero(depth1)_"&"_$$one(depth2)_")"
	if rand=26 quit "("_$$one(depth1)_"'&"_$$one(depth2)_")"
	if rand=27 quit "("_$$zero(depth1)_"!"_$$zero(depth2)_")"
	if rand=28 quit "("_$$zero(depth1)_"'!"_$$one(depth2)_")"
	if rand=29 quit "("_$$one(depth1)_"'!"_$$zero(depth2)_")"
	if rand=30 quit "("_$$one(depth1)_"'!"_$$one(depth2)_")"
	if rand=31 quit "("_$$null(depth1)_"'!"_$$one(depth2)_")"
	if rand=32 quit "("_$$one(depth1)_"'!"_$$null(depth2)_")"
	if rand=33 quit "("_$$null(depth1)_"&"_$$zero(depth2)_")"
	if rand=34 quit "("_$$zero(depth1)_"&"_$$null(depth2)_")"
	if rand=35 quit "('"_$$one(depth1)_")"
	if rand=36 quit $$selecthelper(0,depth1,depth2)
	if rand=37 quit "(@ifalse@("_$$zero(depth1)_"))"
	if rand=38 quit "(@^ifalse@("_$$zero(depth1)_"))"
	if rand=39 quit "('@itrue@("_$$one(depth1)_"))"
	if rand=40 quit "('@^itrue@("_$$one(depth1)_"))"
	if rand=41 quit "$$RetSame("_$$zero(depth1)_","_depth2_")"
	if rand=42 quit "$random("_$$one(depth1)_")"	; This is to test boolean expressions in contexts which require a
							; MUMPS_INT (instead of the usual MUMPS_EXPR/MUMPS_NUM/MUMPS_STR).
							; This tests bool2mint()/OC_COMINT whereas all the previous test paths
							; test bool2mval()/OC_COMVAL
	quit

one(depth)	; Returns a random boolean expression that is guaranteed to evaluate to 1
	new rand,depth1,depth2
	if depth=0 do  quit ret
	. set rand=$random(13)
	. if rand=0 set ret="1"
	. if rand=1 set ret="('false)"
	. if rand=2 set ret="true"
	. if rand=3 set ret=$select(dlrtest:"$test",1:"'$test")
	. if rand=4 set ret="('^false)"
	. if rand=5 set ret="^true"
	. if rand=6 set ret="('@ifalse)"
	. if rand=7 set ret="@itrue"
	. if rand=8 set ret="('@^ifalse)"
	. if rand=9 set ret="@^itrue"
	. if rand=10 set ret=$$incrementhelper(1)
	. if rand=11 set ret="($$Always1)"
	. if rand=12 set ret="('$$Always0)"
	set depth1=$random(depth),depth2=$random(depth)
	set rand=$random(43)
	if rand=0 quit "("_$$zero(depth1)_"="_$$zero(depth2)_")"
	if rand=1 quit "("_$$one(depth1)_"="_$$one(depth2)_")"
	if rand=2 quit "("_$$one(depth1)_"'="_$$zero(depth2)_")"
	if rand=3 quit "("_$$zero(depth1)_"'="_$$one(depth2)_")"
	if rand=4 quit "("_$$one(depth1)_">"_$$zero(depth2)_")"
	if rand=5 quit "("_$$zero(depth1)_"<"_$$one(depth2)_")"
	if rand=6 quit "("_$$one(depth1)_"'<"_$$zero(depth2)_")"
	if rand=7 quit "("_$$zero(depth1)_"'>"_$$one(depth2)_")"
	if rand=8 quit "("_$$one(depth1)_">="_$$zero(depth2)_")"
	if rand=9 quit "("_$$zero(depth1)_"<="_$$one(depth2)_")"
	if rand=10 quit "("_$$zero(depth1)_"["_$$zero(depth2)_")"
	if rand=11 quit "("_$$one(depth1)_"["_$$one(depth2)_")"
	if rand=12 quit "("_$$one(depth1)_"]"_$$zero(depth2)_")"
	if rand=13 quit "("_$$one(depth1)_"]]"_$$zero(depth2)_")"
	if rand=14 quit "("_$$zero(depth1)_"'["_$$one(depth2)_")"
	if rand=15 quit "("_$$one(depth1)_"'["_$$zero(depth2)_")"
	if rand=16 quit "("_$$zero(depth1)_"']"_$$one(depth2)_")"
	if rand=17 quit "("_$$zero(depth1)_"']]"_$$one(depth2)_")"
	if rand=18 quit "("_$$one(depth1)_"?1""1"""_")"
	if rand=19 quit "("_$$zero(depth1)_"?1""0"""_")"
	if rand=20 quit "("_$$one(depth1)_"'?1""0"""_")"
	if rand=21 quit "("_$$zero(depth1)_"'?1""1"""_")"
	if rand=22 quit "("_"'"_$$zero(depth1)_")"
	if rand=23 quit "("_$$one(depth1)_"!"_$$one(depth2)_")"
	if rand=24 quit "("_$$one(depth1)_"!"_$$zero(depth2)_")"
	if rand=25 quit "("_$$zero(depth1)_"!"_$$one(depth2)_")"
	if rand=26 quit "("_$$zero(depth1)_"'!"_$$zero(depth2)_")"
	if rand=27 quit "("_$$one(depth1)_"&"_$$one(depth2)_")"
	if rand=28 quit "("_$$zero(depth1)_"'&"_$$one(depth2)_")"
	if rand=29 quit "("_$$one(depth1)_"'&"_$$zero(depth2)_")"
	if rand=30 quit "("_$$zero(depth1)_"'&"_$$zero(depth2)_")"
	if rand=31 quit "("_$$null(depth1)_"'&"_$$zero(depth2)_")"
	if rand=32 quit "("_$$zero(depth1)_"'&"_$$null(depth2)_")"
	if rand=33 quit "("_$$null(depth1)_"!"_$$one(depth2)_")"
	if rand=34 quit "("_$$one(depth1)_"!"_$$null(depth2)_")"
	if rand=35 quit "('"_$$zero(depth1)_")"
	if rand=36 quit $$selecthelper(1,depth1,depth2)
	if rand=37 quit "(@itrue@("_$$one(depth1)_"))"
	if rand=38 quit "(@^itrue@("_$$one(depth1)_"))"
	if rand=39 quit "('@ifalse@("_$$zero(depth1)_"))"
	if rand=40 quit "('@^ifalse@("_$$zero(depth1)_"))"
	if rand=41 quit "$$RetSame("_$$one(depth1)_","_depth2_")"
	if rand=42 quit "'$random("_$$one(depth1)_")"	; This is to test boolean expressions in contexts which require a
							; MUMPS_INT (instead of the usual MUMPS_EXPR/MUMPS_NUM/MUMPS_STR).
							; This tests bool2mint()/OC_COMINT whereas all the previous test paths
							; test bool2mval()/OC_COMVAL
	quit

null(depth)	; Returns a random boolean expression that is guaranteed to evaluate to $ZYSQLNULL
	new rand,depth1,depth2
	if depth=0 do  quit ret
	. set rand=$random(17)
	. if rand=0  set ret="$zysqlnull"
	. if rand=1  set ret="null"
	. if rand=2  set ret="('null)"
	. if rand=3  set ret=$select(dlrtest:"($test&null)",1:"($test!null)")
	. if rand=4  set ret=$select(dlrtest:"($test'&null)",1:"($test'!null)")
	. if rand=5  set ret=$select(dlrtest:"(null&$test)",1:"(null!$test)")
	. if rand=6  set ret=$select(dlrtest:"(null'&$test)",1:"(null'!$test)")
	. if rand=7  set ret=$select(dlrtest:"($test&'null)",1:"($test!'null)")
	. if rand=8  set ret=$select(dlrtest:"($test'&'null)",1:"($test'!'null)")
	. if rand=9  set ret=$select(dlrtest:"('null&$test)",1:"('null!$test)")
	. if rand=10 set ret=$select(dlrtest:"('null'&$test)",1:"('null'!$test)")
	. if rand=11  set ret="@inull"
	. if rand=12  set ret="('@inull)"
	. if rand=13  set ret="@^inull"
	. if rand=14  set ret="('@^inull)"
	. if rand=15 set ret="($$AlwaysNull)"
	. if rand=16 set ret="('$$AlwaysNull)"
	. ; Note: $$incrementhelper cannot be used in `null` like it is used in `zero` and `one` due to ZYSQLNULLNOTVALID error
	set depth1=$random(depth),depth2=$random(depth)
	set rand=$random(34)
	if rand=0 quit $$nullhelper("=",depth1,depth2)
	if rand=1 quit $$nullhelper("'=",depth1,depth2)
	if rand=2 quit $$nullhelper(">",depth1,depth2)
	if rand=3 quit $$nullhelper("<",depth1,depth2)
	if rand=4 quit $$nullhelper("'<",depth1,depth2)
	if rand=5 quit $$nullhelper("'>",depth1,depth2)
	if rand=6 quit $$nullhelper(">=",depth1,depth2)
	if rand=7 quit $$nullhelper("<=",depth1,depth2)
	if rand=8 quit $$nullhelper("[",depth1,depth2)
	if rand=9 quit $$nullhelper("]",depth1,depth2)
	if rand=10 quit $$nullhelper("]]",depth1,depth2)
	if rand=11 quit $$nullhelper("'[",depth1,depth2)
	if rand=12 quit $$nullhelper("']",depth1,depth2)
	if rand=13 quit $$nullhelper("']]",depth1,depth2)
	if rand=14 quit "("_$$null(depth1)_"?1""0"""_")"
	if rand=15 quit "("_$$null(depth1)_"?1""1"""_")"
	if rand=16 quit "("_$$null(depth1)_"'?1""0"""_")"
	if rand=17 quit "("_$$null(depth1)_"'?1""1"""_")"
	if rand=18 quit "("_"'"_$$null(depth1)_")"
	if rand=19 quit "("_$$one(depth1)_"&"_$$null(depth2)_")"
	if rand=20 quit "("_$$null(depth1)_"&"_$$one(depth2)_")"
	if rand=21 quit "("_$$zero(depth1)_"!"_$$null(depth2)_")"
	if rand=22 quit "("_$$null(depth1)_"!"_$$zero(depth2)_")"
	if rand=23 quit "("_$$one(depth1)_"'&"_$$null(depth2)_")"
	if rand=24 quit "("_$$null(depth1)_"'&"_$$one(depth2)_")"
	if rand=25 quit "("_$$zero(depth1)_"'!"_$$null(depth2)_")"
	if rand=26 quit "("_$$null(depth1)_"'!"_$$zero(depth2)_")"
	if rand=27 quit "('"_$$null(depth1)_")"
	if rand=28 quit $$selecthelper(2,depth1,depth2)
	if rand=29 quit "(@inull@("_$$zero(depth1)_"))"
	if rand=30 quit "('@inull@("_$$zero(depth1)_"))"
	if rand=31 quit "(@^inull@("_$$zero(depth1)_"))"
	if rand=32 quit "('@^inull@("_$$zero(depth1)_"))"
	if rand=33 quit "($$RetSame("_$$null(depth1)_","_depth2_"))"
	quit

nullhelper(operator,depth1,depth2)
	; Given an operator, it generates an expression using that operator which is guaranteed to evaluate to $ZYSQLNULL
	new rand
	set rand=$random(5)
	if rand=0 quit "("_$$one(depth1)_operator_$$null(depth2)_")"
	if rand=1 quit "("_$$zero(depth1)_operator_$$null(depth2)_")"
	if rand=2 quit "("_$$null(depth1)_operator_$$one(depth2)_")"
	if rand=3 quit "("_$$null(depth1)_operator_$$zero(depth2)_")"
	if rand=4 quit "("_$$null(depth1)_operator_$$null(depth2)_")"
	quit

selecthelper(return,depth1,depth2)
	quit $$selecthelpertemporary(return) ; NARSTODO: Remove this line and `selecthelpertemporary` label when YDB#546 and YDB#555 gets fixed.
	; Note: The below test code, when enabled, exposed longstanding pre-existing YDB issues YDB#546 and YDB#555.
	;	Since those issues are still open, the below test code is currently disabled.
	;	If/When this is re-enabled after YDB#546 and YDB#555 are fixed, it is possible this exposes more issues.
	;	For the record, below are the assert failures (in dbg test runs) that were seen when this test code was enabled.
	;
	;	%YDB-F-ASSERT, Assert failed in sr_port/gvcst_search.c line 579 for expression (pTarg->clue.end)
	;	%YDB-F-GTMASSERT2, YottaDB r1.28 Linux x86_64 - Assert failed sr_port/op_gvrectarg.c line 68 for expression (MV_IS_STRING(v))
	;	%YDB-F-ASSERT, Assert failed in sr_port/op_gvrectarg.c line 82 for expression (GVSAVTARG_FIXED_SIZE <= len)
	;
	new numterms,i,choice,retexpr,retstr
	set numterms=$random(4)
	set:0=return retexpr=$$zero(depth2)
	set:1=return retexpr=$$one(depth2)
	set:2=return retexpr=$$null(depth2)
	set retstr="($select("
	for i=1:1:numterms do
	. set choice=$random(3)
	. set:0=choice retstr=retstr_$$zeroORnull(depth1)_":"_$$anyexpr(depth2)
	. set:1=choice retstr=retstr_$$one(depth1)_":"_retexpr
	. set:2=choice retstr=retstr_$$zeroORnull(depth1)_":"_$$anyexpr(depth2)
	. set retstr=retstr_","
	; In case `1=choice` was never chosen in above for loop, choose it as last term unconditionally
	set retstr=retstr_$$one(depth1)_":"_retexpr
	set retstr=retstr_"))"
	quit retstr

selecthelpertemporary(return)
	; $SELECT usage inside boolean expressions cause GTMASSERT2 failures that are partly fixed by GTM-9155 in GT.M V6.3-009
	; The full fix has to wait for a future GT.M release or when YDB#546 is fixed.
	; So until that is integrated, use this simplistic return.
	quit:0=return "$select(false:1,1:0)"
	quit:1=return "$select(true:1)"
	quit:2=return "$select(false:1,1:$zysqlnull)"
	quit

zeroORnull(depth)
	; Returns a random expression that evaluates to 0 or $zysqlnull
	new rand
	set rand=$random(2)
	quit:0=rand $$zero(depth)
	quit $$null(depth)

anyexpr(depth)
	; Returns a random expression that evaluates to 0 or 1 or $zysqlnull
	new rand
	set rand=$random(3)
	quit:0=rand $$zero(depth)
	quit:1=rand $$one(depth)
	quit $$null(depth)

incrementhelper(num)
	new rand,ret
	if num=0 do  quit ret
	. set rand=$random(3)
	. set:rand=0 ret="("_$$incrementhelper2(0)_"-"_$$incrementhelper2(0)_")"
	. set:rand=1 ret="(0<("_$$incrementhelper2(-1)_"-"_$$incrementhelper2(1)_"))"
	. set:rand=2 ret="(0>("_$$incrementhelper2(1)_"-"_$$incrementhelper2(-1)_"))"
	if num=1 do  quit ret
	. set rand=$random(2)
	. set:rand=0 ret="(0>("_$$incrementhelper2(-1)_"-"_$$incrementhelper2(1)_"))"
	. set:rand=1 ret="(0<("_$$incrementhelper2(1)_"-"_$$incrementhelper2(-1)_"))"
	quit

incrementhelper2(num)
	quit "$increment(incrvar,"_num_")" ; NARSTODO: Remove this line when YDB#552 is fixed.
	new rand
	set rand=$random(2)
	quit:0=rand "$increment(incrvar,"_num_")"
	quit:1=rand "$increment(@iincrvar,"_num_")"
	quit

AllCmdPostConditionalTest
	do valueinit	; sets value() array (needed by below code)
	for boolrslt=0,$zysqlnull do
	. do getboolexpr(.dlrtest,.boolexpr)
	. set:((boolrslt=0)!$ZYISSQLNULL(boolrslt)) xstr="halt:"_boolexpr
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ;
	. set xstr="zedit:"_boolexpr_" x"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or boolrslt=$zysqlnull zedit is not executed.
	. ; If it does error is seen as a null argument is passed resulting in the test failure.
	. ;
	. set x="dummydebug"
	. set xstr="zgoto:"_boolexpr_" x"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or boolrslt=$zysqlnull. zgoto is not executed.
	. ; If it is then test execution stops abruptly indicating an error.
	. ;
	. set xstr="zhalt:"_boolexpr
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or boolrslt=$zysqlnull. zhalt is not executed.
	. ; If it is then test execution stops abruptly indicating an error.
	. ;
	. set xstr="zhelp:"_boolexpr
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or boolrslt=$zysqlnull. zhelp is not executed..
	. ; If it is then test execution is redirected indicating an error.
	. ;
	. set xstr="zmessage:"_boolexpr_" 150381803"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or boolrslt=$zysqlnull zmessage is not executed.
	. ; If it does it will throw an error indicating test failure.
	. ;
	. set xstr="break:"_boolexpr
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or boolrslt=$zysqlnull break is not executed.
	. ; If it is then the test execution abruptly stops resulting in test failure.
	. ;
	. set xstr="goto:"_boolexpr_" dummydebug"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or boolrslt=$zysqlnull goto is not executed.
	. ; If it is then testcase execution stops abruptly resulting in test failure.
	;
	;
	for boolrslt=0,1,$zysqlnull do
	. do getboolexpr(.dlrtest,.boolexpr)
	. ;
	. ; HANG
	. ; verification is done based on time. Difference in time before and after hang is checked.
	. set xstr="hang:"_boolexpr_" 1"
	. set innerstartime=$horolog,innerelapsedtime=0	; time before HANG
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set innerelapsedtime=$$^difftime($horolog,innerstartime)	; time after HANG
	. ; case boolrslt=0 or $zysqlnull,(innerelapsedtime>0): hang is not executed so elapsed time should be 0
	. ; case boolrslt=1,'(innerelapsedtime>0): hang is executed so elapsed time should be 1.
	. ; >0 is considered in case due to processor load the hang is more than expected.
	. do verifypcrslt("HANG",boolrslt,(innerelapsedtime>0),'(innerelapsedtime>0),dlrtest,boolexpr,.failcnt)
	.
	. ; IF
	. set result=0,xstr="if "_boolexpr_" set result=1"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. do verifypcrslt("IF",boolrslt,result,'result,dlrtest,boolexpr,.failcnt)
	. ;
	. ; JOB
	. set beforezjobval=$ZJOB
	. set xstr="JOB:"_boolexpr_" dummydebug"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set afterzjobval=$ZJOB
	. new result1,result2
	. set result1='(beforezjobval=afterzjobval)
	. set result2=((beforezjobval=afterzjobval)&(afterzjobval=0))
	. ; In case of boolrslt=0 or $zysqlnull job is not executed so beforezjobval should be equal to afterzjobval
	. ; In case of boolrslt=1 job is executed so beforezjobval should not be equal to afterzjobval and its value should not be 0
	. do verifypcrslt("JOB",boolrslt,result1,result2,dlrtest,boolexpr,.failcnt)
	. ;
	. ; KILL
	. set ^result=0,xstr="kill:"_boolexpr_" ^result"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$get(^result,1)
	. ; In case of boolrslt=0 or $zysqlnull kill is not executed so result should be ^result which is 0
	. ; In case of boolrslt=1 kill is executed so result should be 1
	. do verifypcrslt("KILL",boolrslt,result,'result,dlrtest,boolexpr,.failcnt)
	. ;
	. ; LOCK
	. zkill result("L",1)		; removing previous iteration result
	. zkill result	; removing previous iteration result
	. set x=1,result("L",1)=0,xstr="lock:"_boolexpr_" x zshow ""L"":result lock"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$get(result("L",1),0)
	. ; In case of boolrslt=0 or $zysqlnull lock is not executed so the result should be 0
	. ; In case of boolreslt=1 lock is executed so the result should be "LOCK x LEVEL=1"
	. do verifypcrslt("LOCK",boolrslt,result'=0,(result'="LOCK x LEVEL=1"),dlrtest,boolexpr,.failcnt)
	. ;
	. ; MERGE
	. zkill ^gb2(1,1)	; removing previous result by undefining ^gb2(1,1)
	. set ^gb1="one",^gb1(1,1)="oneone",xstr="merge:"_boolexpr_" ^gb2=^gb1"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$get(^gb2(1,1),0)
	. ; In case of boolrslt=0 or $zysqlnull merge is not executed so result should be 0 as ^gb2(1,1) is not defined
	. ; In case of boolreslt=1 merge is executed so result should be "oneone" as ^gb2(1,1) is defined and has value "oneone"
	. do verifypcrslt("MERGE",boolrslt,(result'=0),(result'="oneone"),dlrtest,boolexpr,.failcnt)
	. ;
	. ; NEW
	. set ^result=0,x=0,xstr="new:"_boolexpr_" x set ^result=$get(x,1)"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or $zysqlnull new is not executed so ^result should be 0
	. ; In case of boolreslt=1 new is executed so ^result should be 1
	. do verifypcrslt("NEW",boolrslt,(^result'=0),(^result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; OPEN
	. set x="ydb484pcopen.m"
	. zkill out("D",3)		; removing previous value
	. set out=0,xstr="open:"_boolexpr_" x zshow ""D"":out"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$get(out("D",3),0)
	. if (boolrslt=1) close x
	. ; In case of boolrslt=0 or $zysqlnull open is not executed so result should be 0
	. ; In case of boolrslt=1 open is executed so result should indicate that the file is open (zshow output)
	. do verifypcrslt("OPEN",boolrslt,(result'=0),(result'="ydb484pcopen.m OPEN RMS "),dlrtest,boolexpr,.failcnt)
	. ;
	. ; READ
	. set x="ydb484pcread.m"
	. open x use x write "dummydebug" close x
	. set result=0,xstr="open x use x read:"_boolexpr_" result close x"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or $zysqlnull read not executed so result should be 0
	. ; In case of boolrslt=1 read is executed so result should be the content "dummydebug" present in file "ydb484pcread.m"
	. do verifypcrslt("READ",boolrslt,(result'=0),(result'="dummydebug"),dlrtest,boolexpr,.failcnt)
	. ;
	. ; TRESTART
	. set result=0,xstr="trestart:"_boolexpr
	. tstart ():serial
	. set result=result+1
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute:(result<2) xstr
	. tcommit
	. ; In case of boolrslt=0 or $zysqlnull trestart is not executed so result should be 1 indicating
	. ;	the transaction was executed once.
	. ; In case of boolrslt=1 trestart is executed so result should be 2 indicating the transaction
	. ;	was executed twice due to restart
	. do verifypcrslt("TRESTART",boolrslt,(result'=1),(result'=2),dlrtest,boolexpr,.failcnt)
	. ;
	. ; USE
	. set x="ydb484pcuse.m" open x use x write "hello",! close x
	. if (value(boolrslt)=1) open x
	. set result="",xstr="use:"_boolexpr_" x"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. if (value(boolrslt)=1) read result close x
	. ; In case of boolresult=0 or $zysqlnull, use is not executed.
	. ;	If it does, test reports an error as USE is executed on a device which is not open.
	. ; In case of boolrslt=1 use is executed so result is read from device ("ydb484pcuse.m" file)
	. do verifypcrslt("USE",boolrslt,0,(result'="hello"),dlrtest,boolexpr,.failcnt)		; dummy third argument
	. ;
	. ; VIEW
	. view "SETENV":"result":0
	. set result=0,xstr="view:"_boolexpr_" ""SETENV"":""result"":1"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$ztrnlnm("result")
	. ; In case of boolrslt=0 or $zysqlnull view is not executed so result should be 0 as env variable is not set to 1
	. ; In case of boolrslt=1 view is executed so result should be 1 as env variable is set to 1
	. do verifypcrslt("VIEW",boolrslt,result,(result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; WRITE
	. set x="ydb484pcwrite.txt",cnt=1
	. if (value(boolrslt)=1) open x:(newversion) use x
	. set result=0,xstr="write:"_boolexpr_" "_cnt
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. if (value(boolrslt)=1) close x open x use x read result close x
	. ; In the case when boolrslt is 0 or $zysqlnull. write is not executed.
	. ;	If it does then output of write is directed to the stdout which will result in test failure.
	. ; In case of boolrslt=1 write is executed so result is equal to cnt.
	. ;	Here result is read from a file("ydb484pcwrite.txt") to which WRITE had written data to.
	. do verifypcrslt("WRITE",boolrslt,0,(result'=cnt),dlrtest,boolexpr,.failcnt)	; dummy third argument
	. ;
	. ; ZALLOCATE
	. set result=0,xstr="zallocate:"_boolexpr_" x zshow ""L"":result zdeallocate x"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$get(result("L",1),0)
	. zkill result("L",1)
	. ; In case of boolrslt=0 or $zysqlnull zallocate is not executed so result is 0 as zshow
	. ;	doesnt indicate a variable is zallocated
	. ; In case of boolrslt=1 zallocate is executed so result is "ZAL x" as indicated by zshow
	. do verifypcrslt("ZALLOCATE",boolrslt,(result'=0),(result'="ZAL x"),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZBREAK
	. set result=0,xstr="zbreak:"_boolexpr_" dummydebug zshow ""B"":result zbreak -dummydebug"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$get(result("B",1),0)
	. zkill result("B",1)
	. ; In case of boolrslt=0 or $zysqlnull zbreak is not executed so result is 0 as no breakpoints are set
	. ; In case of boolrslt=1 zbreak is executed so result is indicative of the location of breakpoint
	. do verifypcrslt("ZBREAK",boolrslt,(result'=0),(result'="dummydebug^ydb484"),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZCOMPILE
	. set x="ydb484compilepass.m"
	. set y="ydb484compilefail.m"
	. open x:(newversion) use x write "dummydebug",!," set ^result=1",!," quit",! close x
	. open y:(newversion) use y write "dummydebug",!," sset ^result=1",!," quit",! close y
	. if (value(boolrslt)=1) set ^result=0,xstr="zcompile:"_boolexpr_" x"
	. else  set result=$ZCSTATUS,xstr="zcompile:"_boolexpr_" y"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. if (value(boolrslt)=1) do dummydebug^ydb484compilepass
	. ; In case of boolrslt=0 or $zysqlnull zcompile is not executed so the result is same as $ZCSTATUS.
	. ;	If it does execute in the case of boolrslt=0 or boolrslt=$zysqlnull then the file being compiled
	. ;	ensures compilation fails and $ZCSTATUS is different from its value before compilation which
	. ;	results in test failure.
	. ; In case of boolrslt=1 zcompile is executed so the result is set by executing the program that was compiled
	. do verifypcrslt("ZCOMPILE",boolrslt,(result'=$ZCSTATUS),(^result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZDEALLOCATE
	. zallocate x
	. zshow "L":result
	. set xstr="zdeallocate:"_boolexpr_" x"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. zshow "L":result
	. set result=$get(result("L",1),1)
	. if (value(boolrslt)'=1) zdeallocate x
	. ; In case of boolrslt=0 or $zysqlnull zdeallocate is not executed so the result set from zshow should contain "ZAL x"
	. ; In case of boolrslt=1 zdeallocate is executed so the result is 1 indicating no variable is reserved by zallocate
	. do verifypcrslt("ZDEALLOCATE",boolrslt,(result'="ZAL x"),(result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZKILL and ZWITHDRAW
	. for func="ZKILL","ZWITHDRAW" do
	. . set x(1)=1,x(1,1)=1,x(1,1,1)=1
	. . set result=0,xstr=func_":"_boolexpr_" x(1)"
	. . if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. . xecute xstr
	. . if (value(boolrslt)=1) do
	. . . set res1=$get(x(1),0)
	. . . set res2=$get(x(1,1),0)
	. . . set res3=$get(x(1,1),0)
	. . . set result=('res1)&res2&res3
	. . else  do
	. . . set res1=$get(x(1),0)
	. . . set res2=$get(x(1,1),0)
	. . . set res3=$get(x(1,1),0)
	. . . set result=res1&res2&res3
	. . ; In case of boolrslt=0 or $zysqlnull zkill/zwithdraw is not executed so result is 1 as all decendents of x
	. . ;	and its value is intact
	. . ; In case of boolrslt=1 zkill/zwithdraw is executed so result is computed by ('res1)&res2&res3 which
	. . ;	indicates that res1 is killed/withdrawn
	. . do verifypcrslt(func,boolrslt,'result,'result,dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZLINK
	. set x="ydb484zlink.m" open x:(newversion) use x write "dummydebug",!," set ^result=0",!," quit",! close x
	. zlink x
	. set y="ydb484zlink.m" open y:(newversion) use y write "dummydebug",!," set ^result=1",!," quit",! close y
	. set ^result=0,xstr="zlink:"_boolexpr_" y"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. do dummydebug^ydb484zlink
	. ; In case of boolrslt=0 or $zysqlnull zlink is not executed so 1st version of the program is executed
	. ;	setting ^result to 0
	. ; In case of boolrslt=1 zlink is executed so 2nd version of the program is executed setting ^result to 1
	. do verifypcrslt("ZLINK",boolrslt,^result,(^result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZPRINT
	. set x="ydb484pczprint.m" open x:(newversion) use x
	. set res=0,xstr="zprint:"_boolexpr_" dummydebug"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. close x
	. open x
	. use x
	. read res
	. close x
	. ; In case of boolrslt=0 or $zysqlnull zprint is not executed so res value read from file ydb484pczprint.m is ""
	. ; In case of boolrslt=1 zprint is executed so res value read from file ydb484pczprint.m is "dummydebug"
	. do verifypcrslt("ZPRINT",boolrslt,(res'=""),(res'="dummydebug"),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZSHOW
	. zkill result("L",0)
	. set result=0,xstr="zshow:"_boolexpr_" ""L"":result"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. set result=$get(result("L",0),0)
	. ; In case of boolrslt=0 or $zysqlnull zshow is not executed so result is 0
	. ; In case of boolrslt=1 zshow is executed so result is equal to the output of zshow "L" which is not 0
	. do verifypcrslt("ZSHOW",boolrslt,(result'=0),(result=0),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZSTEP
	. set x="ydb484pszstep.m" open x:(newversion) use x
	. set result=0,xstr="zstep:"_boolexpr_" INTO:""W 1"""
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. close x
	. open x
	. use x
	. read result
	. close x
	. ; In case of boolrslt=0 or $zysqlnull zstep is not executed so result read from ydb484pszstep.m is ""
	. ; In case of boolrslt=1 zstep is executed so result read from ydb484pszstep.m is 1
	. do verifypcrslt("ZSTEP",boolrslt,(result'=""),(result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZSYSTEM
	. set x="ydb484pczsystem.txt"
	. set result=0,xstr="zsystem:"_boolexpr_" ""echo 1>ydb484pczsystem.txt"""
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. open x use x read result close x:(delete)
	. ; In case of boolrslt=0 or $zysqlnull zsystem is not executed so result=""
	. ;	as data is not written to ydb484pczsystem.txt
	. ; In case of boolrslt=1 zsystem is executed so result=1.
	. ;	The value is written to ydb484pczsystem.txt file through the zsystem command.
	. do verifypcrslt("ZSYSTEM",boolrslt,(result'=""),(result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; ZWRITE
	. set x="ydb484pczwrite" open x:(newversion) use x
	. set result=0,xstr="zwrite:"_boolexpr_" result"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. close x
	. open x use x read result close x
	. ; In case of boolrslt=0 or $zysqlnull zwrite is not executed so the result is ""
	. ; In case of boolrslt=1 zwrite is executed so the result is equal to the value written to the file ydb484pczwrite
	. do verifypcrslt("ZWRITE",boolrslt,(result'=""),(result'="result=0"),dlrtest,boolexpr,.failcnt)
	. ;
	. ; CLOSE
	. set result=0
	. set x="ydb484pcclose.m" open x zshow "D":result
	. set xstr="close:"_boolexpr_" x"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. zshow "D":result
	. if (value(boolrslt)'=1) close x
	. set result=$get(result("D",3),0)
	. if (value(boolrslt)=1) zkill result("D",3)
	. ; In case of boolrslt=0 or $zysqlnull close is not executed so result is equal to the output of
	. ;	zshow command indicating the open file
	. ; In case of boolrslt=1 close is executed so result is 0 as the file is closed successfully
	. ;	(indicated by output of zshow command)
	. do verifypcrslt("CLOSE",boolrslt,(result'="ydb484pcclose.m OPEN RMS "),(result'=0),dlrtest,boolexpr,.failcnt)
	. ;
	. ; DO
	. set ^result=0,xstr="do:"_boolexpr_" dummydebug"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or $zysqlnull do is not executed so the ^result is 0
	. ; In case of boolrslt=1 do is executed so the ^result is 1 which is set by the code do executes
	. do verifypcrslt("DO",boolrslt,^result,(^result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; XECUTE
	. set result=0,xstr="xecute:"_boolexpr_" ""set result=1"""
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or $zysqlnull xecute command is not exected so the result is 0
	. ; In case of boolrslt=1 xecute command is executed so the result is 1
	. do verifypcrslt("XECUTE",boolrslt,result,(result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; QUIT
	. set result=0,xstr="do  set result=1 quit:"_boolexpr_"  set result=2"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or $zysqlnull quit is not executed so the result is 2.
	. ;	Because, the sequence of commands being executed within do is not interrupted.
	. ; In case of boolrslt=1 quit is executed so the result is 1.
	. ;	Because, the sequence of commands being executed within do is interrupted by quit.
	. do verifypcrslt("QUIT",boolrslt,(result'=2),(result'=1),dlrtest,boolexpr,.failcnt)
	. ;
	. ; TCOMMIT
	. set level=$tlevel,result=0,xstr="tcommit:"_boolexpr
	. tstart
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. tcommit:((value(boolrslt)'=1)&($tlevel=(level+1))) 	; need tcommit here to reduce $tlevel
	. set:((value(boolrslt)=1)&($tlevel=level)) result=1	; tcommit not required here as earlier
	.							;	postconditional tcommit was executed
	. ; In case of boolrslt=0 or $zysqlnull tcommit is not executed so the result is 0
	. ; In case of boolrslt=1 tcommit is executed so the result is 1
	. do verifypcrslt("TCOMMIT",boolrslt,result,(result'=1),dlrtest,boolexpr,.failcnt)
	. if ((value(boolrslt)=1)&(result'=1)) do
	. . tcommit		; need to remove additional tlevel here as earlier tcommit with postcondition failed
	. ;
	. ; TROLLBACK
	. set result=0,xstr="trollback:"_boolexpr
	. tstart
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. if $tlevel=1 do
	. . tcommit
	. . set result=1
	. ; In case of boolrslt=0 or $zysqlnull trollback is not executed because of which
	. ;	we expect tlevel=1 and result set to 1 in this case
	. ; In case of boolrslt=1 trollback is executed because of which we expect tlevel=0
	. ;	resulting in result set to 0 in this case
	. do verifypcrslt("TROLLBACK",boolrslt,(result'=1),result,dlrtest,boolexpr,.failcnt)
	. ;
	. ; TSTART
	. set result=0,xstr="tstart:"_boolexpr_"  if ($tlevel=1) tcommit  set result=1"
	. if dlrtest		; sets $test to dlrtest before boolexpr is evaluated
	. xecute xstr
	. ; In case of boolrslt=0 or $zysqlnull tstart is not executed so the result is 0
	. ; In case of boolrslt=1 tstart is executed so the $tlevel is 1 because of which result=1
	. do verifypcrslt("TSTART",boolrslt,result,(result'=1),dlrtest,boolexpr,.failcnt)
	write:'$get(failcnt) "    -> PASS from AllCmdPostConditionalTest",!
	quit

verifypcrslt(func,boolrslt,result1,result2,dlrtest,boolexpr,failcnt)
	new fail
	set fail=0
	if ((value(boolrslt)'=1)&result1) do
        . write "FAIL from "_func_" postconditionaltest : dlrtest=",dlrtest
        . write " : boolexpr : [",boolexpr,"] evaluates to ",value(boolrslt)," but postconditional evaluated to TRUE",!
        . if $increment(failcnt)
	. set fail=1
	if ((value(boolrslt)=1)&result2) do
        . write "FAIL from "_func_" postconditionaltest : dlrtest=",dlrtest
        . write " : boolexpr : [",boolexpr,"] evaluates to ",value(boolrslt)," but postconditional evaluated to FALSE",!
        . if $increment(failcnt)
	. set fail=1
	write:'fail "       -> PASS from "_func_" postconditionaltest",!
	quit

getboolexpr(dlrtest,boolexpr)
	new depth
	set depth=$random(256)
	set dlrtest=$random(2)	; construct boolexpr assuming $test=dlrtest
	set boolexpr=$select(0=boolrslt:$$zero(depth),1=boolrslt:$$one(depth),1:$$null(depth))
	quit

valueinit	;
	set value(0)=0,value(1)=1,value($zysqlnull)=2
	quit

Always0()
	quit 0

Always1()
	quit 1

AlwaysNull()
	quit $ZYSQLNULL

RetSame(boolvalue,depth)
	quit:$random(8) boolvalue	; return boolean value as is from function call 87.5% of the time
	; 12.5% of the time, evaluate a boolean expression inside a function call that is already inside a boolean expression
	new xstr,boolret,boolexpr
	set boolexpr=$select(0=boolvalue:$$zero(depth),1=boolvalue:$$one(depth),1:$$null(depth))
	set xstr="set boolret="_boolexpr
	xecute xstr
	quit boolret

boolexprtoodeep	;
	;
	; Below generates an M program that will issue a BOOLEXPRTOODEEP error when run
	;
	set maxdepth=4091
	for i=1:1:(maxdepth+1)  write " set a"_(i#128)_"="_(i#2),!
	write " set x="
	for i=1:2:maxdepth  write "a"_(i#128)_"&(a"_((i+1)#128)_"!"
	write "a"_((i+1)#128)
	for i=1:2:maxdepth  write ")"
	write !
	write " zwrite x",!
	quit
