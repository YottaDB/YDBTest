V4RAND ;IW-YS-KO-TS,VV4,MVTS V9.10;15/6/96;$RANDOM FUNCTION
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"107---V4RAND: $RANDOM function",!
 ;
;**MVTS LOCAL CHANGE**
 ; Value that can fit in an int4 is the maximum we support for $Random argument
; 10/2001 SE
1 ;W !,"IV-680  intexpr is 15 digits ( maximum range )"
 ;S ^ABSN="40680",^ITEM="IV-680  intexpr is 15 digits ( maximum range )"
 ;S ^NEXT="V4ORDER^VV4" D ^V4PRESET
 ;W !,"       $R(999999999999999) : " S VCOMP=0
 ;F I=1:1:20 S R=$R(999999999999999) W R," " I R'?1.N!(R'<999999999999999) S VCOMP=VCOMP+1
 ;S ^VCOMP=VCOMP,^VCORR=0 D ^VEXAMINE
 ;
END W !!,"End of 107 --- V4RAND",!
 K  Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
