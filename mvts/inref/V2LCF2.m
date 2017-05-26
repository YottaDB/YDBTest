V2LCF2 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;LOWER CASE FUNCTION NAMES (LESS $data) AND SPECIAL VARIABLES -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 w !!,"5---V2LCF2: Lower case function names (LESS $data)",!
 W "            and special variables -2-",!
 W !,"Function names are lower case ($a $c $e $f $j $l $o $p)",!
 ;
43 W !,"II-43  $length"
 S ^ABSN="20043",^ITEM="II-43  $length",^NEXT="44^V2LCF2,V2LCF3^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$length("abcde")_$Length(ABC)_$leNGTH(ABC(1)),^VCORR="538" D ^VEXAMINE
 ;
44 W !,"II-44  $l"
 S ^ABSN="20044",^ITEM="II-44  $l",^NEXT="45^V2LCF2,V2LCF3^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$l("abcde")_$l(ABC)_$l(ABC(1)),^VCORR="538" D ^VEXAMINE
 ;
45 W !,"II-45  $next"
 S ^ABSN="20045",^ITEM="II-45  $next",^NEXT="46^V2LCF2,V2LCF3^VV2" D ^V2PRESET
 W !,"       (This test II-45 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
46 W !,"II-46  $n"
 S ^ABSN="20046",^ITEM="II-46  $n",^NEXT="47^V2LCF2,V2LCF3^VV2" D ^V2PRESET
 W !,"       (This test II-46 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
47 W !,"II-47  $order"
 S ^ABSN="20047",^ITEM="II-47  $order",^NEXT="48^V2LCF2,V2LCF3^VV2" D ^V2PRESET
 K ABC S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$order(ABC(""))_$Order(ABC(1)) S ^VCORR="1" D ^VEXAMINE
 ;
48 W !,"II-48  $o"
 S ^ABSN="20048",^ITEM="II-48  $o",^NEXT="49^V2LCF2,V2LCF3^VV2" D ^V2PRESET
 K ABC
 S ^VCOMP="",ABC(1)="00123.45"
 S ^VCOMP=$o(ABC(""))_$o(ABC(1)) S ^VCORR="1" D ^VEXAMINE
 ;
49 W !,"II-49  $piece"
 S ^ABSN="20049",^ITEM="II-49  $piece",^NEXT="50^V2LCF2,V2LCF3^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$piece(ABC,"A",2)_$Piece(ABC,"B",1)_$PIece(ABC(1),".",1),^VCORR="BCA00123" D ^VEXAMINE
 ;
50 W !,"II-50  $p"
 S ^ABSN="20050",^ITEM="II-50  $p",^NEXT="V2LCF3^VV2" D ^V2PRESET
 S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$p(ABC,"A",2)_$p(ABC,"B",1)_$p(ABC(1),".",1),^VCORR="BCA00123" D ^VEXAMINE
 ;
END w !!,"End of 5---V2LCF2",!
 k  q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
