V2LCF1 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;LOWER CASE FUNCTION NAMES (LESS $data) AND SPECIAL VARIABLES -1-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 w !!,"4---V2LCF1: Lower case function names (LESS $data)",!
 W "            and special variables -1-",!
 W !,"Function names are lower case ($a $c $e $f $j $l $o $p)",!
33 W !,"II-33  $ascii"
 S ^ABSN="20033",^ITEM="II-33  $ascii",^NEXT="34^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$ascii(ABC)_$aSCII(ABC,2)_$Ascii(ABC,3)_$ascII(ABC(1)) S ^VCORR="65666748" D ^VEXAMINE
 ;
34 W !,"II-34  $a"
 S ^ABSN="20034",^ITEM="II-34  $a",^NEXT="35^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$a(ABC)_$a(ABC,2)_$a(ABC,3)_$a(+ABC(1)) S ^VCORR="65666749" D ^VEXAMINE
 ;
35 W !,"II-35  $char"
 S ^ABSN="20035",^ITEM="II-35  $char",^NEXT="36^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",X=32,X(1)=33,^VCOMP=$char(65)_$cHaR(66)_$Char(67,X,X(1)),^VCORR="ABC !" D ^VEXAMINE
 ;
36 W !,"II-36  $c"
 S ^ABSN="20036",^ITEM="II-36  $c",^NEXT="37^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",X=70,^VCOMP=$c(65)_$c(66)_$c(67,68,69.9,X),^VCORR="ABCDEF" D ^VEXAMINE
 ;
37 W !,"II-37  $extract"
 S ^ABSN="20037",^ITEM="II-37  $extract",^NEXT="38^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",X="ABC",X(1)="00123.45"
 S ^VCOMP=$extract(X,2)_$Extract(X,3)_$exTRACT(X(1),1)_$extracT(X(1)+0,1),^VCORR="BC01" D ^VEXAMINE
 ;
38 W !,"II-38  $e"
 S ^ABSN="20038",^ITEM="II-38  $e",^NEXT="39^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",X="ABC",X(1)="00123.45"
 S ^VCOMP=$e(X,2)_$e(X,3)_$e(X(1),1)_$e(X(1)+0,2.9),^VCORR="BC02" D ^VEXAMINE
 ;
39 W !,"II-39  $find"
 S ^ABSN="20039",^ITEM="II-39  $find",^NEXT="40^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$find("abc","d")_$Find(ABC,"")_$fiND(ABC(1),"."),^VCORR="017" D ^VEXAMINE
 ;
40 W !,"II-40  $f"
 S ^ABSN="20040",^ITEM="II-40  $f",^NEXT="41^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$f("ABCabc","b")_$f(ABC,"")_$f(ABC(1),"."),^VCORR="617" D ^VEXAMINE
 ;
41 W !,"II-41  $justify"
 S ^ABSN="20041",^ITEM="II-41  $justify",^NEXT="42^V2LCF1,V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$justify(1.23,4,1)_$Justify(ABC,4)_$JUStify(ABC(1),7,1)
 S ^VCORR=" 1.2 ABC  123.5" D ^VEXAMINE
 ;
42 W !,"II-42  $j"
 S ^ABSN="20042",^ITEM="II-42  $j",^NEXT="V2LCF2^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$j(1.23,4,1)_$j(ABC,4)_$j(ABC(1),7,1),^VCORR=" 1.2 ABC  123.5" D ^VEXAMINE
 ;
END w !!,"End of 4---V2LCF1",!
 k  q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
