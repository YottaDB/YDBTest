 ;
 ; **** Routine compiled from DATA-QWIK Procedure ZJSON ****
 ;
 ; 11/02/2015 06:08 - Frank Sanchez
 ;
 ;
parse(obj,json,schema,ref) ; obj() branch key (optional) - adds dimensions to ref
 ;
 S ref=$get(ref)
 ;
 N charStrip S charStrip=$CHAR(32,9,10,12,13) ; White space
 ;
 ; If input ends with JSON delimiter other than terminator, throw error
 I (":,[{"[$ZEXTRACT(json,$ZLENGTH(json))) D error("Unexpected delimiter",$ZLENGTH(json))
 ;
 ; tokenize location of json delimiters :,[]{}
 N tjson S tjson=$ZTRANSLATE(json,":,[]{}",$CHAR(1,1,1,1,1,1))
 ;
 N del N dt N stack S stack="" N val S val="" N pk
 N i N level N q S q=0 N qp N y S y=0 N yt S yt=1 N ye
 ;
 I (ref="") S level=0
 E  D refToPk(ref,.pk) S level=$order(pk(""),-1)
 ;
 I '(tjson[$char(1)) S val=json D setVal Q
 ;
 S level=level+1 S pk(level)=""
 S tjson=tjson_$char(1)
 ;
 F  S y=$ZFIND(tjson,$char(1),y) D  I (y>$ZLENGTH(json)) Q
 .	;
 .	S ye=y-2
 .	; If json delimiter is protected inside quotes, skip it
 .	; Modified to ignore escaped JSON quotes \"
 .	;
 .	S qp=$ZFIND(json,"""",yt)
 .	; if quotes exist before delimiter, count unescaped quotes, if 'odd' number then quit
 .	I (qp>0&(qp'>(y-1))) D  I q S y=$S(qp:qp,1:$ZLENGTH(json)+1) Q
 ..		S q=($ZEXTRACT(json,qp-2)'="\")
 ..		F  S qp=$ZFIND(json,"""",qp) Q:(qp=0!(qp-1>ye))  I ($ZEXTRACT(json,qp-2)'="\") S q='q
 ..		Q
 .	;
 .	S del=$ZEXTRACT(json,y-1) ; get json delimiter
 .	;
 .	; Move ye before whitespace at end and yt past whitespace at beginning
 .	F  Q:'(charStrip[$ZEXTRACT(json,ye))!(ye<yt)  S ye=ye-1
 .	F  Q:'(charStrip[$ZEXTRACT(json,yt))!(yt>ye)  S yt=yt+1
 .	;
 .	S val=$ZEXTRACT(json,yt,ye)
 .	S yt=y
 .	;
 .	I (","[del) D  Q
 ..		;
 ..		I $ZEXTRACT(json,y)="," D error("Value expected before ','",y) Q
 ..		I '(val="") D setVal
 ..		;
 ..		I ($ZEXTRACT(stack,1)="]") S pk(level)=pk(level)+1
 ..		E  S pk(level)=""
 ..		Q
 .	;
 .	; Tag syntax
 .	I (del=":") D jtagToMtag(.val) S pk(level)=val D:(val="") error("Tag expected",y-1) Q
 .	;
 .	; Initiate an object or array
 .	I ("{["[del) D  Q
 ..		; Must be directly preceeded by a delimiter :,[{
 ..		I '(val="") D error("Unexpected string before initiator",y-1) Q
 ..		I '($get(pk(level))="") S level=level+1
 ..		;
 ..		I (del="[") S pk(level)=1 S stack="]"_stack ; Array initiator
 ..		E  S stack="}"_stack ; Object initator
 ..		Q
 .	;
 .	; Terminate an object or array, pop off stack on key
 .	I ("}]"[del) D  Q
 ..		;
 ..		I '(del=$ZEXTRACT(stack,1)) D error($S($ZEXTRACT(stack,1)="}":"Object",1:"Array")_" terminator expected",y-1)
 ..		I '(val="") D setVal
 ..		;
 ..		I level S level=level-1
 ..		S stack=$ZEXTRACT(stack,2,1048575)
 ..		Q
 .	Q
 ;
 I q D error("Closing string delimiter "" expected",yt)
 I '(stack="") D error("Terminator expected '"_stack_"'",$ZLENGTH(json)+1)
 ;
 Q
 ;
setVal ; Set the value in the array
 ; Private procedure called from parse
 ; Input variables: obj(), pk(), level, val
 ;
 ; Key (tag) is null, $c(255) in M database
 I ($get(pk(level))="") S pk(level)=$char(255)
 ;
 S val=$$jstrToMstr(val,pk(level))
 ;
 I (level=0) S obj=val Q
 I (level=1) S obj(pk(1))=val Q
 I (level=2) S obj(pk(1),pk(2))=val Q
 I (level=3) S obj(pk(1),pk(2),pk(3))=val Q
 I (level=4) S obj(pk(1),pk(2),pk(3),pk(4))=val Q
 I (level=5) S obj(pk(1),pk(2),pk(3),pk(4),pk(5))=val Q
 I (level=6) S obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6))=val Q
 I (level=7) S obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7))=val Q
 I (level=8) S obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8))=val Q
 I (level=9) S obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9))=val Q
 I (level=10) S obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10))=val Q
 I (level=11) S obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10),pk(11))=val Q
 ; Add code to drop level via indirection as needed, or more levels here
 Q
 ;
delete(obj,ref) ;
 ;
 ; Delete the branch from Json object beneath ref
 ; Also can just kill the Json object (array) substript directly!!!
 ;
 I (ref="") K obj Q
 ;
 N pk
 N level
 ;
 D refToPk(ref,.pk) S level=$order(pk(""),-1)
 ;
 I (level=1) K obj(pk(1)) Q
 I (level=2) K obj(pk(1),pk(2)) Q
 I (level=3) K obj(pk(1),pk(2),pk(3)) Q
 I (level=4) K obj(pk(1),pk(2),pk(3),pk(4)) Q
 I (level=5) K obj(pk(1),pk(2),pk(3),pk(4),pk(5)) Q
 I (level=6) K obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6)) Q
 I (level=7) K obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7)) Q
 I (level=8) K obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8)) Q
 I (level=9) K obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9)) Q
 I (level=10) K obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10)) Q
 I (level=11) K obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10),pk(11)) Q
 ;
 Q
 ;
stringify(obj,schema,ref) ; Primary key reference (to grab a branch only)
 ;
 I '$D(ref) S ref=""
 ;
 N keyLevel N i
 N pk N val
 ;
 I (ref="") S keyLevel=0
 ;
 ; Map the primary keys from the input reference
 E  D  I '(val="") Q val
 .	;
 .	D refToPk(ref,.pk) ; Parse primary keys
 .	S keyLevel=$order(pk(""),-1)
 .	;
 .	I (keyLevel=1) S val=$get(obj(pk(1))) Q
 .	I (keyLevel=2) S val=$get(obj(pk(1),pk(2))) Q
 .	I (keyLevel=3) S val=$get(obj(pk(1),pk(2),pk(3))) Q
 .	;
 .	; Done optimizing, use indirection now
 .	S val="obj(pk(1),pk(2),pk(3)"
 .	F i=4:1:keyLevel S val=val_",pk("_i_")"
 .	S val=val_")" S val=$get(@val)
 .	Q
 ;
 N arptr N hwaLevel N minLevel N savLevel
 N ok
 N dt S dt="" N ret S ret="" N stack S stack="" N tag
 ;
 S keyLevel=keyLevel+1
 S minLevel=keyLevel S savLevel=keyLevel S hwaLevel=keyLevel
 ;
 S pk(keyLevel)="" ; Initialize this level
 S ok(keyLevel)=""
 ;
 F  D getVal Q:keyLevel=0  D
 .	; Stack was reduced , add }] terminators
 .	I (hwaLevel<savLevel) D
 ..		;
 ..		S ret=ret_$ZEXTRACT(stack,1,savLevel-hwaLevel)
 ..		S stack=$ZEXTRACT(stack,savLevel-hwaLevel+1,1048575)
 ..		Q
 .	;
 .	F i=hwaLevel:1:keyLevel D
 ..		; Reset the next descendant, for arrays
 ..		I (i<keyLevel) S ok(i+1)=""
 ..		;
 ..		S tag=pk(i)
 ..		;
 ..		; JSON array index if initialized and sequential, otherwise an integer tag
 ..		I (tag?1N.N) D  Q:ok(i)
 ...			I (tag=1) D  Q
 ....				I (ok(i)="") S ret=ret_"[" S stack="]"_stack S arptr(i)=$ZLENGTH(ret) S ok(i)=1
 ....				Q
 ...			;
 ...			S:(ok(i)="") ok(i)="!" I ok(i)="!" Q
 ...			;
 ...			; if array exists and this is sequential integer it is an index
 ...			I (ok(i)+1=tag) S ret=ret_"," S ok(i)=tag
 ...			E  D indexToTag(arptr(i),ok(i)) S ok(i)="!"
 ...			Q
 ..		;
 ..		E  I ok(i) D indexToTag(arptr(i),ok(i)) S ok(i)="!"
 ..		;
 ..		; tag: value
 ..		I '("{[,:"[$ZEXTRACT(ret,$ZLENGTH(ret))) S ret=ret_","
 ..		I (hwaLevel<i!(ret="")) S ret=ret_"{" S stack="}"_stack
 ..		D:'(tag?1AN.AN) escape(.tag) S ret=ret_""""_tag_""":"
 ..		Q
 .	;
 .	S ret=ret_$$mstrToJstr(val)
 .	S hwaLevel=keyLevel S savLevel=keyLevel
 .	Q
 ;
 Q ret_stack
 ;
getVal ; Get the next value in an array (depth first)
 ;
 ;*** Start of code by-passed by compiler
 if (keyLevel=1) G getPK1
 if (keyLevel=2) G getPK2
 if (keyLevel=3) G getPK3
 if (keyLevel=4) G getPK4
 if (keyLevel=5) G getPK5
 if (keyLevel=6) G getPK6
 if (keyLevel=7) G getPK7
 if (keyLevel=8) G getPK8
 if (keyLevel=9) G getPK9
 if (keyLevel=10) G getPK10
 if (keyLevel=11) G getPK11
 ; Add additional keyLevels or indirection code as indicated
 ;*** End of code by-passed by compiler ***
 Q
 ;
getPK1 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>1) G getEnd
 set pk(1)=$O(obj(pk(1))) if pk(1)="" G getEnd
 if hwaLevel>1 set hwaLevel=1
 set val=$G(obj(pk(1))) if '(val="")!($D(obj(pk(1)))=1) set keyLevel=1 quit
 set pk(2)=""
 ;*** End of code by-passed by compiler ***
 ;
getPK2 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>2) G getEnd
 set pk(2)=$O(obj(pk(1),pk(2))) if pk(2)="" G getPK1
 if hwaLevel>2 set hwaLevel=2
 set val=$G(obj(pk(1),pk(2))) if '(val="")!($D(obj(pk(1),pk(2)))=1) set keyLevel=2 quit
 set pk(3)=""
 ;*** End of code by-passed by compiler ***
getPK3 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>3) G getEnd
 set pk(3)=$O(obj(pk(1),pk(2),pk(3))) if pk(3)="" G getPK2
 if hwaLevel>3 set hwaLevel=3
 set val=$G(obj(pk(1),pk(2),pk(3))) if '(val="")!($D(obj(pk(1),pk(2),pk(3)))=1) set keyLevel=3 quit
 set pk(4)=""
 ;*** End of code by-passed by compiler ***
getPK4 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>4) G getEnd
 set pk(4)=$O(obj(pk(1),pk(2),pk(3),pk(4))) if pk(4)="" G getPK3
 if hwaLevel>4 set hwaLevel=4
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4)))=1) set keyLevel=4 quit
 set pk(5)=""
 ;*** End of code by-passed by compiler ***
getPK5 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>5) G getEnd
 set pk(5)=$O(obj(pk(1),pk(2),pk(3),pk(4),pk(5))) if pk(5)="" G getPK4
 if hwaLevel>5 set hwaLevel=5
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4),pk(5))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4),pk(5)))=1) set keyLevel=5 quit
 set pk(6)=""
 ;*** End of code by-passed by compiler ***
getPK6 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>6) G getEnd
 set pk(6)=$O(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6))) if pk(6)="" G getPK5
 if hwaLevel>6 set hwaLevel=6
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6)))=1) set keyLevel=6 quit
 set pk(7)=""
 ;*** End of code by-passed by compiler ***
getPK7 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>7) G getEnd
 set pk(7)=$O(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7))) if pk(7)="" G getPK6
 if hwaLevel>7 set hwaLevel=7
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7)))=1) set keyLevel=7 quit
 set pk(8)=""
 ;*** End of code by-passed by compiler ***
getPK8 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>8) G getEnd
 set pk(8)=$O(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8))) if pk(8)="" G getPK7
 if hwaLevel>8 set hwaLevel=8
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8)))=1) set keyLevel=8 quit
 set pk(9)=""
 ;*** End of code by-passed by compiler ***
getPK9 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>9) G getEnd
 set pk(9)=$O(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9))) if pk(9)="" G getPK8
 if hwaLevel>9 set hwaLevel=9
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9)))=1) set keyLevel=9 quit
 set pk(10)=""
 ;*** End of code by-passed by compiler ***
getPK10 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>10) G getEnd
 set pk(9)=$O(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10))) if pk(10)="" G getPK9
 if hwaLevel>10 set hwaLevel=10
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10)))=1) set keyLevel=10 quit
 set pk(11)=""
 ;*** End of code by-passed by compiler ***
getPK11 ;
 ;*** Start of code by-passed by compiler
 if (minLevel>11) G getEnd
 set pk(9)=$O(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10),pk(11))) if pk(11)="" G getPK10
 if hwaLevel>11 set hwaLevel=11
 set val=$G(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10),pk(11))) if '(val="")!($D(obj(pk(1),pk(2),pk(3),pk(4),pk(5),pk(6),pk(7),pk(8),pk(9),pk(10),pk(11)))=1) set keyLevel=11 quit
 set pk(12)=""
 ;*** End of code by-passed by compiler ***
 ;
 ; Add additional keyLevels or indirection as needed
getEnd ;
 ;
 S keyLevel=0 S val=""
 Q
 ;
indexToTag(ptr,index) ; Convert an array to tags (forced when M array is sparse)
 ;
 N x S x=$ZEXTRACT(ret,ptr+1,1048575)
 S ret=$ZEXTRACT(ret,1,ptr-1)_"{"
 S stack="}"_$ZEXTRACT(stack,2,1048575)
 ;
 I index=1 S ret=ret_"""1"":"_x_"," Q
 ;
 N zx S zx=$ZTRANSLATE(x,"""[]{},",$C(1,1,1,1,1,1))_$char(1)
 N i S i=1 N y S y=1 N yb S yb=1 N ye
 N c N s S s=""
 ;
 F  S y=$F(zx,$char(1),y) Q:y=0  D  I y=0 Q
 .	S ye=y-2
 .	I ($ZEXTRACT(x,ye)=" ") F ye=ye-1:-1 Q:'($ZEXTRACT(x,ye)=" ")
 .	I y>$L(zx) S ret=ret_""""_i_""":"_$ZEXTRACT(x,yb,ye)_"," Q
 .	S c=$ZEXTRACT(x,y-1)
 .	I c="""" F  S y=$ZFIND(x,"""",y) Q:'y!'($ZEXTRACT(x,y-2)="\")
 .	I $ZEXTRACT(x,y)=" " F y=y+1:1 Q:'($ZEXTRACT(x,y)=" ")
 .	I c="," I (s="") S ret=ret_""""_i_""":"_$ZEXTRACT(x,yb,ye)_"," S i=i+1 S yb=y Q
 .	I "[{"[c S s=c_s Q
 .	I "]}"[c S s=$E(s,2,1048575)
 .	Q
 ;
 Q
 ;
pop(obj,json,levels,schema,ref) ;
 ;
 S ref=$get(ref)
 I +$get(levels)=0 S levels=1 ; Default to 1 level
 ;
 N charStrip S charStrip=$CHAR(32,9,10,12,13) ; White space
 ;
 ; If input ends with JSON delimiter other than terminator, throw error
 I (":,[{"[$ZEXTRACT(json,$ZLENGTH(json))) D error("Unexpected delimiter",$ZLENGTH(json))
 ;
 ; tokenize location of json delimiters :,[]{}
 N tjson S tjson=$ZTRANSLATE(json,":,[]{}",$CHAR(1,1,1,1,1,1))
 ;
 N del N stack S stack="" N val S val="" N pk
 N i N level N q S q=0 N qp N y S y=0 N yt S yt=1 N ye
 ;
 I (ref="") S level=0
 E  D refToPk(ref,.pk) S level=$order(pk(""),-1)
 ;
 I '(tjson[$char(1)) S val=json D setVal Q
 ;
 S levels=levels+level ; Maximum # levels to pop
 S level=level+1 S pk(level)=""
 S tjson=tjson_$char(1)
 ;
 F  S y=$ZFIND(tjson,$char(1),y) D  I (y>$ZLENGTH(json)) Q
 .	;
 .	S ye=y-2
 .	;
 .	S qp=$ZFIND(json,"""",yt)
 .	; if quotes exist before delimiter, count unescaped quotes, if 'odd' number then quit
 .	I (qp>0&(qp'>(y-1))) D  I q S y=$S(qp:qp,1:$ZLENGTH(json)) Q
 ..		S q=($ZEXTRACT(json,qp-2)'="\")
 ..		F  S qp=$ZFIND(json,"""",qp) Q:(qp=0!(qp-1>ye))  I ($ZEXTRACT(json,qp-2)'="\") S q='q
 ..		Q
 .	;
 .	S del=$ZEXTRACT(json,y-1) ; get json delimiter
 .	;
 .	; Move ye before whitespace at end and yt past whitespace at beginning
 .	F  Q:'(charStrip[$ZEXTRACT(json,ye))!(ye<yt)  S ye=ye-1
 .	F  Q:'(charStrip[$ZEXTRACT(json,yt))!(yt>ye)  S yt=yt+1
 .	;
 .	S val=$ZEXTRACT(json,yt,ye)
 .	S yt=y
 .	;
 .	I (","[del) D  Q
 ..		;
 ..		I $ZEXTRACT(json,y)="," D error("Value expected before ','",y) Q
 ..		I '(val="") D setVal
 ..		;
 ..		; Increment the array index
 ..		I ($ZEXTRACT(stack,1)="]") S pk(level)=pk(level)+1
 ..		E  S pk(level)=""
 ..		Q
 .	;
 .	; Tag syntax
 .	I (del=":") D jtagToMtag(.val) S pk(level)=val D:(val="") error("Tag expected",y-1) Q
 .	;
 .	; Initiate an object or array
 .	I ("{["[del) D  Q
 ..		; Must be directly preceeded by a delimiter :,[{
 ..		I '(val="") D error("Unexpected string before initiator",y-1) Q
 ..		I '($get(pk(level))="") S level=level+1
 ..		;
 ..		; Find the matching terminator
 ..		I (level>levels) D getClose Q
 ..		;
 ..		I (del="[") S pk(level)=1 S stack="]"_stack ; Array initiator
 ..		E  S stack="}"_stack ; Object initator
 ..		Q
 .	;
 .	; Terminate an object or array, pop off stack on key
 .	I ("}]"[del) D  Q
 ..		;
 ..		I '(del=$ZEXTRACT(stack,1)) D error($S($ZEXTRACT(stack,1)="}":"Object",1:"Array")_" terminator expected",y-1)
 ..		I '(val="") D setVal
 ..		;
 ..		I level S level=level-1
 ..		S stack=$ZEXTRACT(stack,2,1048575)
 ..		Q
 .	Q
 ;
 I q D error("Closing string delimiter "" expected",yt)
 I '(stack="") D error("Terminator expected '"_stack_"'",$ZLENGTH(json)+1)
 ;
 Q
 ;
getClose ; Get the closing delimiter for pop
 ;
 N del2
 ;
 F  S y=$ZFIND(tjson,$char(1),y) D  I (y>$ZLENGTH(json)!(level=levels)) Q
 .	;
 .	S ye=y-2
 .	;
 .	; If json delimiter is protected inside quotes, skip it
 .	S qp=$ZFIND(json,"""",yt)
 .	; if quotes exist before delimiter, count unescaped quotes, if 'odd' number then quit
 .	I (qp>0&(qp'>ye)) D  I q Q
 ..		;
 ..		S q=($ZEXTRACT(json,qp-2)'="\")
 ..		F  S qp=$ZFIND(json,"""",qp) Q:(qp=0!(qp-1>ye))  I ($ZEXTRACT(json,qp-2)'="\") S q='q
 ..		Q
 .	;
 .	S del2=$ZEXTRACT(json,y-1)
 .	I ("{["[del2) S level=level+1
 .	E  I ("]}"[del2) S level=level-1
 .	Q
 ;
 S val=del_$ZEXTRACT(json,yt,y-1)
 S yt=y
 ;
 D setVal
 Q
 ;
refToPk(ref,pk) ; Convert ref string to primary key array
 ;
 N y S y=0 N yt S yt=1 N pkNum S pkNum=1
 N v
 ;
 I '($E(ref,$L(ref))=",") S ref=ref_","
 ;
 F  S y=$F(ref,",",y) Q:y=0  I $L($E(ref,1,y-2),"""")#2 D
 .	;
 .	S v=$E(ref,yt,y-2) S yt=y
 .	I ($E(v,1)="""") S v=$S($F(v,"""",2)>$L(v):$E(v,2,$L(v)-1),1:$$QSUB^%ZS(v,""""))
 .	S pk(pkNum)=v
 .	S pkNum=pkNum+1
 .	Q
 ;
 Q
 ;
mstrToJstr(str) ; Convert from a m string to JSON string
 ;
 ; Can be either a Boolean, Date, Time, Integer, Number - Use schema
 ; Must be an +-integer to check schema, otherwise just a number
 I str=+str D  Q str
 .	;
 .	; Need to add a '0' to decimal values in this range to appease JSON
 .	I str<1&(str>-1)&str S str=$S(str>0:"0"_str,1:"-0"_-str) Q
 .	I str["."!'$D(schema) Q  ; Only Integers for schema
 .	;
 .	; Get the data type of this tag if defined in the schema
 .	; *** Only checks schema if the value is an integer ***
 .	S dt=$$getType() I (dt="") Q
 .	I dt="Boolean" S str=$S(str:"true",1:"false") Q
 .	I dt="Date" S str=""""_$ZD(str,"YEAR-MM-DD")_"""" Q
 .	I dt="Time" S str=""""_$ZD(str,"24:60:SS")_"""" Q
 .	Q
 ;
 I (str="") Q "null"
 ;
 ; Alread serialized into Json, don't touch
 I """{["[$E(str,1) I $get(schema(tag))="Json" Q str
 ;
 ; Can be DateTime if this pattern, return ISO 8601 Date format
 I str?1N.N1","1N.N I ($$getType()="Date") Q """"_$translate($ZD(str,"YEAR-MM-DD 24:60:SS")," ","T")_""""
 I '(str?1AN.AN) D escape(.str)
 Q """"_str_""""
 ;
getType() ; Check if tag has schema associated with type Date, Time, Bool
 ; MAY be able to even further optimize to minimize array lookups, especially *xxx
 ;
 ; Public for performance only (called only from mstrToJstr & jstrToMstr
 ;
 ; Start just past tag in the array and find the first prior key
 ; If it's the tag or a matching xxx* wildcard, *done!, return here
 ; If null, there are no possible wildcard matches so also return!
 N z S z=$order(schema(tag_$char(1)),-1) I (z="") Q ""
 I (z=tag)!($ZEXTRACT(z,$ZLENGTH(z))="*")&($ZEXTRACT(tag,1,$ZLENGTH(z)-1)=$ZEXTRACT(z,1,$ZLENGTH(z)-1)) Q schema(z)
 ;
 ; What the heck, could get lucky and match the last key in *xxx patterns
 I $ZEXTRACT(z,1)="*" I ($ZEXTRACT(tag,$ZLENGTH(tag)-$ZLENGTH(z)+2,1048575)=$ZEXTRACT(z,2,1048575)) Q schema(z)
 ;
 ; Continue search for beginsWith pattern: xxx*
 ; Go back in schema array until keys is out of range or 'xxx*' found
 I ($ZEXTRACT(tag,1,$ZLENGTH(z))=z) F  S z=$order(schema(z),-1) Q:(z="")!($ZEXTRACT(z,$ZLENGTH(z))="*")!'($ZEXTRACT(tag,1,$ZLENGTH(z))=z)
 I   I $ZEXTRACT(z,$ZLENGTH(z))="*" I $ZEXTRACT(tag,1,$ZLENGTH(z)-1)=$ZEXTRACT(z,1,$ZLENGTH(z)-1) Q schema(z)
 ;
 I (z="") Q ""
 ;
 ; Now check all of the endsWith pattern: *xxx
 S z="*"
 F  S z=$order(schema(z)) Q:'($ZEXTRACT(z,1)="*")!($ZEXTRACT(tag,$ZLENGTH(tag)-$ZLENGTH(z)+2,1048575)=$ZEXTRACT(z,2,1048575))
 I $ZEXTRACT(z,1)="*" Q schema(z)
 ;
 Q ""
 ;
escape(str) ; Find and replace JSON escape character in M string
 ; Pass str by reference
 ;
 ; Convert escape characters to '^' if there are any
 N cstr S cstr=$ZTRANSLATE(str,$CHAR(34,47,92,8,9,10,12,13),"^^^^^^^^")
 ;
 ; Then compare strings, if different there are escape characters
 I (cstr'=str) D
 .	N y S y=0 N c S c=0
 .	F  S y=$ZFIND(cstr,"^",y) Q:y=0  I ($ZEXTRACT(str,y+c-1)'="^") D
 ..		S str=$ZEXTRACT(str,1,y+c-2)_"\"_$E("""/\btnfr",$F($CHAR(34,47,92,8,9,10,12,13),$ZEXTRACT(str,y+c-1))-1)_$ZEXTRACT(str,y+c,1048575)
 ..		S c=c+1
 ..		Q
 .	Q
 ;
 Q
 ;
jstrToMstr(str,tag) ; Convert from a JSON string to M string
 ;
 I str=+str Q str
 I str="false" Q 0
 I str="true" Q 1
 I str="null" Q ""
 ;
 ; if not a simple number, First look for escape initiator '\' and translate escapes
 I str["\" D
 .	N y S y=$ZFIND(str,"\")
 .	;
 .	I y F  Q:'y  D
 ..		S str=$ZEXTRACT(str,1,y-2)_$TRANSLATE($ZEXTRACT(str,y),"bfnrt",$CHAR(8,12,10,13,9))_$ZEXTRACT(str,y+1,1048575)
 ..		S y=$ZFIND(str,"\",y)
 ..		Q
 .	Q
 ;
 I $ZLENGTH(str)<2 Q str
 ;
 ; Remove quote string delimiters
 I $ZEXTRACT(str,1)=""""&($ZEXTRACT(str,$ZLENGTH(str))="""") D  Q str
 .	S str=$ZEXTRACT(str,2,$ZLENGTH(str)-1)
 .	;check for Date or Time schema, convert if match
 .	I ($ZEXTRACT(str,3)=":"!($ZEXTRACT(str,5)="-")) D
 ..		S dt=$$getType()
 ..		I dt="Date" S str=$$getJulien(str) Q
 ..		I dt="Time" S str=(($ZEXTRACT(str,1,2)*3600)+($ZEXTRACT(str,4,5)*60)+$ZEXTRACT(str,7,8)) Q
 ..		Q
 .	Q
 ;
 Q str
 ;
jtagToMtag(str) ; Convert a Json tag to an M tag, no need to look for keywords or schema (so faster processing)
 ;
 ; Also pass by ref
 ;
 I str["\" D
 .	;
 .	N y S y=$ZFIND(str,"\")
 .	;
 .	F  Q:'y  D
 ..		S str=$ZEXTRACT(str,1,y-2)_$ZTRANSLATE($ZEXTRACT(str,y),"bfnrt",$CHAR(8,12,10,13,9))_$ZEXTRACT(str,y+1,1048575)
 ..		S y=$ZFIND(str,"\",y)
 ..		Q
 .	Q
 ;
 I $ZEXTRACT(str,1)="""" S str=$ZEXTRACT(str,2,$ZLENGTH(str)-1)
 Q
 ;
getJulien(str) ; Return Julien date from ISO 8601 String YYYY-MM-DDT24:60:SS"
 ;
 N year S year=$ZEXTRACT(str,1,4)
 N month S month=$ZEXTRACT(str,6,7)
 N jdate S jdate=$ZEXTRACT(str,9,10)
 ;
 I (jdate>30) I month=4!(month=6)!(month=9)!(month=11) D error("Invalid Date: "_str)
 I (month>12) D error("Invalid Date: "_str)
 I (+month=2) I jdate>$S((year#4=0)&('(year#100=0)!(year#400=0)):29,1:28) D error("Invalid Date: "_str)
 ;
 S jdate=jdate+$piece("0,31,59,90,120,151,181,212,243,273,304,334",",",month)
 I (year#4=0)&('(year#100=0)!(year#400=0)) I (month>2) S jdate=jdate+1
 ;
 ; (days in normal 365 day year) + (1 for each leap year) - (1 for each century) + 1 (for each fourth century)
 S jdate=jdate+((year-1841)*365)+((year-1841)\4)-((year-1)\100-18)+((year-1)\400-4)
 ;
 ; TimeStamp
 I ($ZEXTRACT(str,11)="T") S jdate=jdate_","_(($ZEXTRACT(str,12,13)*3600)+($ZEXTRACT(str,15,16)*60)+$ZEXTRACT(str,18,19))
 Q jdate
 ;
error(text,y) ; Throw error
 ;
 N er S er=$$newInstance^vError("Error","")
 S $P(er,$C(8),4)="InvalidJsonSyntax"
  D setQuoteProp^vError(.er,5,text_" ("_y_")")
 S $ZE=$$chkThrownAt^vError(.er,$ZPOS),$EC=",U1001,"
 Q
 ;
testString() ; Return simple test json transaction object, modify as needed
 ;
 N x
 S x="""userId"": 2497, ""foo"":null, ""date"":""2014-12-31T12:00:05"", ""transactions"": ["
 S x=x_"{""trancode"": ""SD"", ""amount"": 1000, ""account"": 23223,  ""party"": {""first"": ""John"", ""last"": [""Smith"", ""Jones""]}}, "
 S x=x_"{""trancode"": ""SW"", ""amount"": 1000, ""account"": 567566, ""isMult"": false, ""comment"": ""wowee""} "
 S x=x_"]"
 Q x
 ;
test(testString) ; Test Json Parser
 ;
 N obj N schema
 I ($get(testString)="") S testString=$$testString() WRITE !,testString,!
 S schema("*date")="Date"
 D parse(.obj,testString,.schema)
 ;
 ;*** Start of code by-passed by compiler
 zwr obj
 ;*** End of code by-passed by compiler ***
 ;
 ;  #OPTION ResultClass ON
 Q
vSIG() ;
 Q "63858^22089^frank.sanchez.home^27000" ; Signature - LTD^TIME^USER^SIZE
