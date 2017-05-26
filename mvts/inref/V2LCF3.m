V2LCF3 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;LOWER CASE FUNCTION NAMES (LESS $data) AND SPECIAL VARIABLES -3-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 w !!,"6---V2LCF3: Lower case function names (less $data)"
 W !,"            and special variable neames -3-",!
 W !,"Function names are lower case ($r $s $t)",!
51 W !,"II-51  $random"
 S ^ABSN="20051",^ITEM="II-51  $random",^NEXT="52^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$random(1)_$Random(1),^VCORR="00" D ^VEXAMINE
 ;
52 W !,"II-52  $r"
 S ^ABSN="20052",^ITEM="II-52  $r",^NEXT="53^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP="",^VCOMP=$r(1)_$r(1),^VCORR="00" D ^VEXAMINE
 ;
53 W !,"II-53  $select"
 S ^ABSN="20053",^ITEM="II-53  $select",^NEXT="54^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 K ABC S ^VCOMP="",ABC="ABC",ABC(1)="00123.45"
 S ^VCOMP=$select(ABC="ABC":"abc",1:1)_$Select(ABC=1:"EFG",1:2),^VCORR="abc2" D ^VEXAMINE
 ;
54 W !,"II-54  $s"
 S ^ABSN="20054",^ITEM="II-54  $s",^NEXT="55^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 K ABC S ^VCOMP="",ABC="abc",ABC(1)="00123.45"
 S ^VCOMP=$s(ABC="abc":"abc",1:1)_$s(ABC(1)=1:"EFG",1:2),^VCORR="abc2" D ^VEXAMINE
 ;
55 W !,"II-55  $text"
 SET ^ABSN="20055",^ITEM="II-55  $text",^NEXT="56^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP=""
 S ^VCOMP=$p($text(55)," ",1)_$p($Text(55+1)," ",2),^VCORR="55SET" D ^VEXAMINE
 ;
56 W !,"II-56  $t"
 S ^ABSN="20056",^ITEM="II-56  $t",^NEXT="57^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP=""
 S ^VCOMP=$p($t(56)," ",1)_$p($t(56+1)," ",2),^VCORR="56S" D ^VEXAMINE
 ;
57 W !!,"Special variable names are lower case ($x $y $i $j $h $s $t)",!
 W !,"II-57  $x"
 S ^ABSN="20057",^ITEM="II-57  $x",^NEXT="58^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$x,^VCORR=+$x D ^VEXAMINE
 ;
58 W !,"II-58  $y"
 S ^ABSN="20058",^ITEM="II-58  $y",^NEXT="59^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$y,^VCORR=+$y D ^VEXAMINE
 ;
59 W !,"II-59  $io"
 S ^ABSN="20059",^ITEM="II-59  $io",^NEXT="60^V2LCF3,V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$io,^VCORR=$IO D ^VEXAMINE ;(test corrected in V7.3;20/6/88)
 ;
60 W !,"II-60  $i"
 S ^ABSN="20060",^ITEM="II-60  $i",^NEXT="V2LCF4^VV2" D ^V2PRESET
 S ^VCOMP="" S ^VCOMP=$i,^VCORR=$I D ^VEXAMINE ;(test corrected in V7.3;20/6/88)
 ;
END w !!,"End of 6---V2LCF3",!
 k  q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
