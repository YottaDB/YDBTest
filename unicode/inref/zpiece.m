zpiece ;
		write !,"Testing ZPIECE with some arabic delimeters",!
		set delim1="۩"
		set delim2="۝"
		for i=1:1:^cntstr do
		. set strcombined(i)=^str(i)_delim1_^str(i)_"ABC"_delim2_^str(i)_delim1_"DEF"_^str(i)
		. do multiequal^examine($ZPIECE(strcombined(i),delim1),$PIECE(strcombined(i),delim1),^str(i),"ERROR 1 from zpiece")
		. do multiequal^examine($ZPIECE(strcombined(i),delim1,3),$PIECE(strcombined(i),delim1,3),"DEF"_^str(i),"ERROR 2 from zpiece")
		. do multiequal^examine($ZPIECE(strcombined(i),delim2),$PIECE(strcombined(i),delim2),^str(i)_delim1_^str(i)_"ABC","ERROR 3 from zpiece")
		. do multiequal^examine($ZPIECE(strcombined(i),delim2,2),$PIECE(strcombined(i),delim2,2),^str(i)_delim1_"DEF"_^str(i),"ERROR 4 from zpiece")
		;
invalidmix ;
		write !,"Testing ZPIECE with invalid mix of characters",!
		if ("UTF-8"=$ZCHSET) do
		. for i=1:1:^cntstr do
		. . set strcombined(i)=^str(i)_delim1_^str(i)_$ZCHAR(3999,499,1999)_"ABC"_delim2_^str(i)_"DEF"_$ZCHAR(3999,499,1999)
		. . do multiequal^examine($ZPIECE(strcombined(i),delim1),$PIECE(strcombined(i),delim1),^str(i),"ERROR 1 from invalidmix")
		. . do multiequal^examine($ZPIECE(strcombined(i),delim1,2),$PIECE(strcombined(i),delim1,2),^str(i)_"ABC"_delim2_^str(i)_"DEF","ERROR 2 from invalidmix")
		. . do multiequal^examine($ZPIECE(strcombined(i),$ZCHAR(3999,499,1999),3),$PIECE(strcombined(i),$ZCHAR(3999,499,1999),3),"","ERROR 3 from invalidmix")
		;
indirection;
		write !,"Testing ZPIECE for indirection",!
		set indelim1="delim1"
		set indelim2="delim2"
		for i=1:1:^cntstr do
		. set strcombined(i)=^str(i)_@indelim1_^str(i)_"ABC"_@indelim2_^str(i)_@indelim1_"DEF"_^str(i)
		. do multiequal^examine($ZPIECE(strcombined(i),@indelim1),$PIECE(strcombined(i),@indelim1),^str(i),"ERROR 1 from indirection")
		. do multiequal^examine($ZPIECE(strcombined(i),@indelim1,3),$PIECE(strcombined(i),@indelim1,3),"DEF"_^str(i),"ERROR 2 from indirection")
		. do multiequal^examine($ZPIECE(strcombined(i),@indelim2),$PIECE(strcombined(i),@indelim2),^str(i)_@indelim1_^str(i)_"ABC","ERROR 3 from indirection")
		. do multiequal^examine($ZPIECE(strcombined(i),@indelim2,2),$PIECE(strcombined(i),@indelim2,2),^str(i)_@indelim1_"DEF"_^str(i),"ERROR 4 from indirection")
set;
		write !,"Testing ZPIECE that it can appear on the left side of the expression",!
		for i=1:1:^cntstr do
		. set strbegin(i)=^str(i)_"۩۩"_"place"_^str(i)_"۞"
		. set strend(i)=^str(i)_"۝۝"_"ayah"_^str(i)_"۞"
		. ; look to change both strbegin equal and strend
		. ; and arrive at the same string at the end of the steps
		. set $ZPIECE(strbegin(i),"۩",2)="۝"
		. set $ZPIECE(strbegin(i),"۩",3)="۝"_"place"_^str(i)_"۞"
		. set $ZPIECE(strend(i),"۝",1)=^str(i)_"۩"
		. set $ZPIECE(strend(i),"۝",2)="۩"
		. set $ZPIECE(strend(i),"۝",3)="place"_^str(i)_"۞"
		. do multiequal^examine(strbegin(i),strend(i),^str(i)_"۩۝۩۝"_"place"_^str(i)_"۞","ERROR 1 from set")
		; same check for $PIECE as well
		write !,"Testing PIECE that it can appear on the left side of the expression",!
		for i=1:1:^cntstr do
		. set strbegin(i)=^str(i)_"۩۩"_"place"_^str(i)_"۞"
		. set strend(i)=^str(i)_"۝۝"_"ayah"_^str(i)_"۞"
		. set $PIECE(strbegin(i),"۩",2)="۝"
		. set $PIECE(strbegin(i),"۩",3)="۝"_"place"_^str(i)_"۞"
		. set $PIECE(strend(i),"۝",1)=^str(i)_"۩"
		. set $PIECE(strend(i),"۝",2)="۩"
		. set $PIECE(strend(i),"۝",3)="place"_^str(i)_"۞"
		. do multiequal^examine(strbegin(i),strend(i),^str(i)_"۩۝۩۝"_"place"_^str(i)_"۞","ERROR 1 from set")
boundary;
		write !,"Testing ZPIECE for boundary conditions",!
		for i=1:1:^cntstr do
		. set strcombined(i)=^str(i)_delim1_^str(i)_"ABC"_delim2_^str(i)_delim1_"DEF"_^str(i)
		. do multiequal^examine($ZPIECE(strcombined(i),delim1),$PIECE(strcombined(i),delim1),^str(i),"ERROR 1 from boundary")
		. do multiequal^examine($ZPIECE(strcombined(i),"ڦ"),$PIECE(strcombined(i),"ڦ"),strcombined(i),"ERROR 2 from boundary")
		. do multiequal^examine($ZPIECE(strcombined(i),delim1,0),$PIECE(strcombined(i),delim1,0),"","ERROR 3 from boundary")
		. do multiequal^examine($ZPIECE(strcombined(i),delim1,-99),$PIECE(strcombined(i),delim1,-99),"","ERROR 4 from boundary")
		. do multiequal^examine($ZPIECE(strcombined(i),delim1,2,1),$PIECE(strcombined(i),delim1,2,1),"","ERROR 5 from boundary")
noncharbytes;
		; since we have byte by byte processing below we need to turn BADCHAR off
		if $VIEW("BADCHAR") do
		. set bch=1
		. view "NOBADCHAR"
		; the invalid tmpsets below is to avoid $PIECE compilation error even when we switch of BADCHAR
		set tmpset1=$ZCHAR(206),tmpset2=$ZCHAR(206,240),tmpset3=$ZCHAR(240)
		write !,"Testing ZPIECE with some non character mix of bytes",!
		set strt="ΨΈẸẪΆΨ"_$ZCHAR(206,240,144,128)_"ῷ" ;$ZCHAR(206,168) is "Ψ" U+03A8, and $ZCHAR(240,144,128,128) is U+10000
		if ("UTF-8"=$ZCHSET) do
		. do ^examine($PIECE(strt,tmpset1),"ΨΈẸẪΆΨ","ERROR 1 from invalidmix") ; it will not be able to find $ZCHAR(206) as a character in the string and so will return the whole string
		. do ^examine($PIECE(strt,tmpset1,2),$ZCHAR(240,144,128)_"ῷ","ERROR 2 from invalidmix") ; same as above but since we want a second piece in specific it is going to return null
		. do ^examine($PIECE(strt,tmpset3,2),$ZCHAR(144,128)_"ῷ","ERROR 3 from invalidmix")
		. do ^examine($PIECE(strt,tmpset2,2),$ZCHAR(144,128)_"ῷ","ERROR 4 from invalidmix")
		if ("M"=$ZCHSET) do
		. do multiequal^examine($PIECE(strt,tmpset1),$ZPIECE(strt,$ZCHAR(206)),"","ERROR 5 from invalidmix")
		. do multiequal^examine($PIECE(strt,tmpset1,2),$ZPIECE(strt,$ZCHAR(206),2),$ZCHAR(168),"ERROR 6 from invalidmix")
		. do multiequal^examine($PIECE(strt,tmpset3),$ZPIECE(strt,$ZCHAR(240)),"ΨΈẸẪΆΨ"_$ZCHAR(206),"ERROR 7 from invalidmix")
		. do multiequal^examine($PIECE(strt,tmpset2),$ZPIECE(strt,$ZCHAR(206,240)),"ΨΈẸẪΆΨ","ERROR 8 from invalidmix")
		;
		if $data(bch) view "BADCHAR"
fourarg ;
		for i=1:1:^cntstr do
		. set literalpiece=^str(i)_"𝐴"_^str(i)_"piece2"_"𝐴"_^str(i)_"piece3"_"𝐴"_"piece4"
		. do multiequal^examine($PIECE(literalpiece,"𝐴",2,3),$ZPIECE(literalpiece,"𝐴",2,3),^str(i)_"piece2"_"𝐴"_^str(i)_"piece3","Four argument $piece/$zpiece failure on "_literalpiece)
		. do multiequal^examine($PIECE(literalpiece,"𝐴",3,20),$ZPIECE(literalpiece,"𝐴",3,99),^str(i)_"piece3"_"𝐴"_"piece4","Four argument $piece/$zpiece failure outside boundary on "_literalpiece)
		. do multiequal^examine($PIECE(literalpiece,"𝐴",3,2),$ZPIECE(literalpiece,"𝐴",4,2),"","Four argument $piece/$zpiece failure for less for intexpr1 less than intexpr2 "_literalpiece)
		. do multiequal^examine($PIECE(literalpiece,"𝐴",-1,2),$ZPIECE(literalpiece,"𝐴",-1,2),^str(i)_"𝐴"_^str(i)_"piece2","Four argument $piece/$zpiece failure for negative intexpr "_literalpiece)
basic;
		write !,"ZPIECE BASIC TEST",!
		set (p(-1),p(0),p(7))=""
		set p(1)="abc",p(2)="def",p(3)="ghi",p(4)="jkl",p(5)="mno",p(6)="pqr"
		set d="x"
		set P("")="",P("x")=p(1),P("xg")=p(1)_d_p(2)
		set P("xyz")=p(1)_d_p(2)_d_p(3)_d_p(4)_d_p(5)_d_p(6)
		set ITEM="$ZPIECE(",ERR=0
		for d="","x","xg","xyz"  do arg2(P("xyz"),d)
		if ERR=0  write "a  PASS",!
		set ITEM="$ZPIECE(",ERR=0
		for d="x","xy"  do arg3(p(1)_d_p(2)_d_p(3)_d_p(4)_d_p(5)_d_p(6),d)
		if ERR=0  w "b  PASS",!
		set ITEM="$ZPIECE(",ERR=0
		for d="x","xy"  do arg4(p(1)_d_p(2)_d_p(3)_d_p(4)_d_p(5)_d_p(6),d)
		if ERR=0  w "c  PASS",!
		set ITEM="$ZPIECE(",ERR=0
		set d="hi there",p="xx"
		do EXAM(ITEM_d_",p)  p = ""xx""",$ZPIECE(d,p),d)
		if ERR=0  w "d  PASS",!
		set ITEM="$ZPIECE(",ERR=0
		set d="hi there"
		do EXAM(ITEM_d_",xx)",$ZPIECE(d,"xx"),d)
		if ERR=0  write "e  PASS",!
		quit
arg2(s,D) do EXAM(ITEM_s_","_D_")",$ZPIECE(s,D),P(d))
		quit
arg3(s,D) new k
		set ITEM=ITEM_s_","_D_","
		for k=-1:1:7  do EXAM(ITEM_k_")",$ZPIECE(s,D,k),p(k))
		quit
arg4(s,D) new i,j,TEM,EM
		set TEM=ITEM_s_","_D_","
		for i=-1:1:7 s vs="",EM=TEM_i_"," for j=-1:1:7 do
		.	s:(j'<i) vs=vs_p(j)
		.	d EXAM(EM_j_")",$ZPIECE(s,D,i,j),vs)
		.	s:(j<6)&(vs'="") vs=vs_D
		quit
EXAM(LAB,VCOMP,VCORR)
		if VCOMP=VCORR quit
		set ERR=ERR+1
		write " ** FAIL in ",LAB,!
		write ?10,"CORRECT  =",VCORR,!
		write ?10,"COMPUTED =",VCOMP,!
		quit
