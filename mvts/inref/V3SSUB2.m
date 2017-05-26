V3SSUB2 ;IW-KO-TS,VV3,MVTS V9.10;15/6/96;STRING SUBSCRIPT -2-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"       Moved from V2SSUB2"
 W !!,"33---V3SSUB2: String subscript -2-",!
 ;
1 W !,"II,III-354  Naked reference when the total length of global variable is 127 characters (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="30354",^ITEM="II,III-354  Naked reference when the total length of global variable is 127 characters (max)"
 S ^NEXT="2^V3SSUB2,V3JOB^VV3" D ^V3PRESET
 S VCOMP="" S MAX="#" F I=0:2:252 S MAX=MAX_"QW"
 S ^VV("ABCDEFGHIJKLMNO","ABCDEFGHIJKLMNO","ABCDEFGHIJKLMNO","ABCDEFGHIJKLMNO","ABCDEFGHIJKLMNO","ABCDEFGHIJKLMNO","ABCDEFGHIJKLMNO","BCDE")=MAX
 S ^("GHIJ")=5,VCOMP=^("GHIJ"),^("GHIJ")=MAX,VCOMP=VCOMP_(^("GHIJ")=^("BCDE"))
 S ^VCOMP=VCOMP,^VCORR="51" D ^VEXAMINE K ^VV
 ;
2 W !,"II,III-355  Minimum (-.999999999999E25) to maximum (.999999999999E25) number of one subscript of local variable"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="30355",^ITEM="II,III-355  Minimum (-.999999999999E25) to maximum (.999999999999E25) number of one subscript of local variable"
 S ^NEXT="3^V3SSUB2,V3JOB^VV3" D ^V3PRESET
 S VCOMP="" S A(-.999999999999E25)=6,A(-999999999999E-25)=7,A(999999999999E-25)=8,A(.999999999999E25)=9
 SET VCOMP=A(-.999999999999E+25)_A(-999999999999E-25)_A(999999999999E-25)_A(.999999999999E+25)
 S ^VCOMP=VCOMP,^VCORR="6789" D ^VEXAMINE
 ;
3 W !,"II,III-356  Minimum (-.999999999999E25) to maximum (.999999999999E25) number of one subscript of global variable"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="30356",^ITEM="II,III-356  Minimum (-.999999999999E25) to maximum (.999999999999E25) number of one subscript of global variable"
 S ^NEXT="4^V3SSUB2,V3JOB^VV3" D ^V3PRESET
 S VCOMP="" S ^VV(-.999999999999E25)=10,^VV(-999999999999E-25)=11,^VV(999999999999E-25)=12,^VV(.999999999999E25)=13
 S VCOMP=^VV(-.999999999999E+25)_^VV(-999999999999E-25)_^VV(999999999999E-25)_^VV(.999999999999E+25)
 S ^VCOMP=VCOMP,^VCORR="10111213" D ^VEXAMINE K ^VV
 ;
;**MVTS LOCAL CHANGE**
 ; Max subscripts for GT.M is documented at 32 so we are changing the 42
; subscript max to 32 for our tests. 10/2001 SE.
4 W !,"II,III-357  Total number of local variable subscripts is 31 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="30357",^ITEM="II,III-357  Total number of local variable subscripts is 31 (max)"
 S ^NEXT="5^V3SSUB2,V3JOB^VV3" D ^V3PRESET
 S VCOMP="" S MAX="#" F I=0:2:252 S MAX=MAX_"QW"
 S A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=14
 S VCOMP=A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")
 S A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX
 S VCOMP=VCOMP_(A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX)
 S ^VCOMP=VCOMP,^VCORR="141" D ^VEXAMINE
 ;
;**MVTS LOCAL CHANGE**
 ; Max subscripts for GT.M is documented at 32 so we are changing the 42
;  subscript max to 32 for our tests. 10/2001 SE.
5 W !,"II,III-358  Total number of global variable subscripts is 31 (max)"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="30358",^ITEM="II,III-358  Total number of global variable subscripts is 31 (max)"
 S ^NEXT="V3JOB^VV3" D ^V3PRESET
 S VCOMP="" S MAX="#" F I=0:2:252 S MAX=MAX_"QW"
 S ^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=15
 S ^("q")=16
 S VCOMP=^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")
 S VCOMP=VCOMP_^("q")
 S ^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX
 S ^("q")=MAX
 S VCOMP=VCOMP_(^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX)
 S VCOMP=VCOMP_(^("q")=MAX)
 S ^VCOMP=VCOMP,^VCORR="151611" D ^VEXAMINE K ^V
 ;
END W !!,"End of 33 --- V3SSUB2",!
 K  K ^VV,^V Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
