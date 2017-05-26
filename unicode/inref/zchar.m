zchar ;
		; Identify the $ZCHSET value and set corresponding local vars to proceed appropriately
		; since the steps and the M-arrays used from unicodesampledata.m will vary based on that
		if ("UTF-8"=$ZCHSET) set arr="^ucp"
		else  set arr="^utf8"
		write !,"Testing ZCHAR,CHAR for the entire unicode sample data range",!
		for cnti=1:1:^cntstr do
		. ; we cannot pass any evaluated strings inside $CHAR.This is a feature in the language. So we need to use charit calls to pass one
		. set tmpstr=$$^charit(@arr@(cnti))
		. do ^examine(tmpstr,^str(cnti),"$CHAR of the ucp failed for "_^comments(cnti))
		for cnti=1:1:^cntstr do
		. set tmpstr=$$zcharit^charit(^utf8(cnti))
		. do ^examine(tmpstr,^str(cnti),"$ZCHAR of the utf8 failed for "_^comments(cnti))
		do ^examine($ZCHAR(1000),"","$ZCHAR(x), x>255, is null, regardless of $ZCHSET")
notequal ;
		write !,"Testing ZCHAR,CHAR for notequal checks",!
		set tmpstr=$CHAR(0)
		for cnti=1:1:^cntstr do
		. if ("UTF-8"=$ZCHSET) do
		. . ; the check is to ensure we do not do notequal check on $char(0) item.
		. . ; because $char(0) and $char("") will return the same string of length 1 and it cannot be NOT equal.
		. . if (tmpstr'=^str(cnti)) do notequal^examine($ZCHAR($PIECE(^utf8(cnti),",",1,$LENGTH(^utf8(cnti),",")-1)),^str(cnti),"ZCHAR returned the entire string inspite of one byte missing for "_^str(cnti)_" "_^comments(cnti))
		. . ; this is to ensure we don't get abnormal behavior nor any core dumps with this kind of $CHAR usage - passing utf8 bytes instead of ucp
		. . do notequal^examine($CHAR(^utf8(cnti)),"あぬげ","$CHAR of utf8 representation cannot be equal to "_^str(cnti))
		. else  do notequal^examine($CHAR(^ucp(cnti)),"ώψξ","$CHAR of ucp when ZCHSET is M cannot give "_^str(cnti))
		if ("UTF-8"=$ZCHSET) do
		. ; there is another zchset comparison here because we dont want the below few notequal examines to
		. ; run across for all of str(cnti)
		. do notequal^examine($CHAR(128),$ZCHAR(128),"$CHAR(x) and $ZCHAR(x) behave differently for x>127")
		. do notequal^examine($CHAR(150,250),$ZCHAR(150,250),"$CHAR(x) and $ZCHAR(x) behave differently for x>127")
		. do notequal^examine($CHAR(1000),$ZCHAR(1000),"$CHAR(x) and $ZCHAR(x) behave differently for x>127")
		if ("M"=$ZCHSET) do
		. do ^examine($CHAR(128),$ZCHAR(128),"$CHAR(x) and $ZCHAR(x) behave same for $ZCHSET=M")
		. do ^examine($CHAR(150,250),$ZCHAR(150,250),"$CHAR(x) and $ZCHAR(x) behave same for $ZCHSET=M")
		. do ^examine($CHAR(1000),$ZCHAR(1000),"$CHAR(x) and $ZCHAR(x) behave same for $ZCHSET=M, x>255")
		. do ^examine($CHAR(1000),"","$CHAR(x), x>255, is null, for $ZCHSET=M")

basic ;
		; this is just the replica from basic/inref/char.m with all $CHAR calls replaced by $ZCHAR, it should work
		w !,"ZCHAR BASIC TEST",!
		for i=0:1:255 if $ZASCII($ZCHAR(i))'=i w "ERROR WITH $ZASCII($ZCHAR(",i,")",!
		for i=0:1:255 if $ZASCII($ZCHAR(i+.1))'=i w "ERROR WITH $ZASCII($ZCHAR(",i,")",!
		for i=0:1:255 if $ZASCII($ZCHAR(i+.9))'=i w "ERROR WITH $ZASCII($ZCHAR(",i,")",!
		for i=0:1:255 if $ZASCII($ZCHAR(i_"BUG"))'=i w "ERROR WITH $ZASCII($ZCHAR(",i,")",!
		for i=-10:1:245 if $ZASCII($ZCHAR(i+10))'=(i+10) w "ERROR WITH $ZASCII($ZCHAR(",i,"+10)",!
		set x="i" for i=0:1:255 if $ZASCII($ZCHAR(@x))'=i w "ERROR WITH $ZASCII($ZCHAR(@x)) WHERE @x = ",@x,!
		for i=-1:-1:-10 if $ZCHAR(i)'="" w "ERROR WITH $ZCHAR(",i,") = ",$ZCHAR(i),!
		if $ZCHAR($ZASCII("A"),$ZASCII("B"),$ZASCII("C"),$ZASCII("D"),$ZASCII("E"),$ZASCII("F"),$ZASCII("G"),$ZASCII("H"),$ZASCII("I"))'="ABCDEFGHI" w "ERROR",!
		if $ZCHAR($ZASCII("J"),$ZASCII("K"),$ZASCII("L"),$ZASCII("M"),$ZASCII("N"),$ZASCII("O"),$ZASCII("P"),$ZASCII("Q"),$ZASCII("R"))'="JKLMNOPQR" w "ERROR",!
		if $ZCHAR($ZASCII("S"),$ZASCII("T"),$ZASCII("U"),$ZASCII("V"),$ZASCII("W"),$ZASCII("X"),$ZASCII("Y"),$ZASCII("Z"))'="STUVWXYZ" w "ERROR",!
indirection;
		w !,"ZCHAR indirection test",!
		if ("UTF-8"=$ZCHSET) do
		. set i=1
		. set unicode="▛▜▶◀◮◘"
		. set bytestr="226,150,155,226,150,156,226,150,182,226,151,128,226,151,174,226,151,152"
		. set strbyte(1)="226,150,156,226,150,182"
		. set var="bytestr"
		. set str="strbyte"
		. set tmpstr=$$zcharit^charit(@var)
		. if tmpstr'="▛▜▶◀◮◘" write "ERROR 1 INDIRECTION ",!
		. set tmpstr=$$zcharit^charit(@str@(i))
		. if tmpstr'="▜▶" write "ERROR 2 INDIRECTION ",!
		quit
