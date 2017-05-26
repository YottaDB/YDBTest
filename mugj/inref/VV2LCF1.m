VV2LCF1	;LOWER CASE LETTER FUNCTION NAMES (LESS $data) AND SPECIAL VARIABLES -1-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	S PASS=0,FAIL=0
	w !!,"VV2LCF1: TEST OF LOWER CASE LETTER FUNCTION NAMES (LESS $data)",!
	W "         AND SPECIAL VARIABLES -1-",!
	W !,"function names are lower case letters ($a $c $e $f $j $l $n $o $p)",!
33	W !,"II-33  $ascii"
	S ITEM="II-33  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$ascii(ABC)_$aSCII(ABC,2)_$Ascii(ABC,3)_$ascII(ABC(1)) S VCORR="65666748" D EXAMINER
	;
34	W !,"II-34  $a"
	S ITEM="II-34  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$a(ABC)_$a(ABC,2)_$a(ABC,3)_$a(+ABC(1)) S VCORR="65666749" D EXAMINER
	;
35	W !,"II-35  $char"
	S ITEM="II-35  ",VCOMP="",X=32,X(1)=33,VCOMP=$char(65)_$cHaR(66)_$Char(67,X,X(1)),VCORR="ABC !" D EXAMINER
	;
36	W !,"II-36  $c"
	S ITEM="II-36  ",VCOMP="",X=70,VCOMP=$c(65)_$c(66)_$c(67,68,69.9,X),VCORR="ABCDEF" D EXAMINER
	;
37	W !,"II-37  $extract"
	S ITEM="II-37  ",VCOMP="",X="ABC",X(1)="00123.45"
	S VCOMP=$extract(X,2)_$Extract(X,3)_$exTRACT(X(1),1)_$extracT(X(1)+0,1),VCORR="BC01" D EXAMINER
	;
38	W !,"II-38  $e"
	S ITEM="II-38  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$e(X,2)_$e(X,3)_$e(X(1),1)_$e(X(1)+0,2.9),VCORR="BC02" D EXAMINER
	;
39	W !,"II-39  $find"
	S ITEM="II-39  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$find("abc","d")_$Find(ABC,"")_$fiND(ABC(1),"."),VCORR="017" D EXAMINER
	;
40	W !,"II-40  $f"
	S ITEM="II-40  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$f("ABCabc","b")_$f(ABC,"")_$f(ABC(1),"."),VCORR="617" D EXAMINER
	;
41	W !,"II-41  $justify"
	S ITEM="II-41  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$justify(1.23,4,1)_$Justify(ABC,4)_$JUStify(ABC(1),7,1)
	S VCORR=" 1.2 ABC  123.5" D EXAMINER
	;
42	W !,"II-42  $j"
	S ITEM="II-42  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$j(1.23,4,1)_$j(ABC,4)_$j(ABC(1),7,1),VCORR=" 1.2 ABC  123.5" D EXAMINER
	;
43	W !,"II-43  $length"
	S ITEM="II-43  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$length("abcde")_$Length(ABC)_$leNGTH(ABC(1)),VCORR="538" D EXAMINER
	;
44	W !,"II-44  $l"
	S ITEM="II-44  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$l("abcde")_$l(ABC)_$l(ABC(1)),VCORR="538" D EXAMINER
	;
45	W !,"II-45  $next" K ABC
	S ITEM="II-45  ",VCOMP="",ABC="ABC",ABC(100)="00123.45"
	S VCOMP=$next(ABC(-1))_$Next(ABC(100)) S VCORR="100-1" D EXAMINER
	;
46	W !,"II-46  $n" K ABC
	S ITEM="II-46  ",VCOMP="",ABC="ABC",ABC(121)="00123.45"
	S VCOMP=$n(ABC(-1))_$n(ABC(121)) S VCORR="121-1" D EXAMINER
	;
47	W !,"II-47  $order" K ABC
	S ITEM="II-47  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$order(ABC(""))_$Order(ABC(1)) S VCORR="1" D EXAMINER
	;
48	W !,"II-48  $o" K ABC
	S ITEM="II-48  ",VCOMP="",ABC(1)="00123.45"
	S VCOMP=$o(ABC(""))_$o(ABC(1)) S VCORR="1" D EXAMINER
	;
49	W !,"II-49  $piece"
	S ITEM="II-49  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$piece(ABC,"A",2)_$Piece(ABC,"B",1)_$PIece(ABC(1),".",1),VCORR="BCA00123" D EXAMINER
	;
50	W !,"II-50  $p"
	S ITEM="II-50  ",VCOMP="",ABC="ABC",ABC(1)="00123.45"
	S VCOMP=$p(ABC,"A",2)_$p(ABC,"B",1)_$p(ABC(1),".",1),VCORR="BCA00123" D EXAMINER
	;
END	w !!,"END OF VV2LCF1",!
	S ROUTINE="VV2LCF1",TESTS=18,AUTO=18,VISUAL=0 D ^VREPORT
	k  q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
