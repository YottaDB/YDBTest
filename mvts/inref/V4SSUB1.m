V4SSUB1 ;IW-KO-TS-YS,VV4,MVTS V9.10;15/6/96;STRING SUBSCRIPT -1-
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"123---V4SSUB1: String subscript -1-",!
 ;
1 W !,"IV-760  Length of one subscript of a local variable is 237"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="40760",^ITEM="IV-760  Length of one subscript of a local variable is 237"
 S ^NEXT="2^V4SSUB1,V4SSUB2^V4SSUB,V4JOB^VV4" D ^V4PRESET
 S VCOMP="" S MAX="#" F I=0:2:252 S MAX=MAX_"QW"
 ; total=N+I+(2*L)+15
 ; N=$l("A"),L=1,total=255
 ; ? I=255-1-2-15
 S D="" F I=1:1:237 S D=D_"#"
 S A(D)=1
 S VCOMP=A(D)
 S A(D)=MAX
 S VCOMP=VCOMP_(A(D)=MAX) K ABC
 S ^VCOMP=VCOMP,^VCORR="11" D ^VEXAMINE
 ;
2 W !,"IV-761  Total length of a local variable is 255"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="40761",^ITEM="IV-761  Total length of a local variable is 255"
 S ^NEXT="3^V4SSUB1,V4SSUB2^V4SSUB,V4JOB^VV4" D ^V4PRESET K
 S VCOMP="" S MAX="" F I=1:1:255 S MAX=MAX_"W"
 S D="ABCDEFGHIJKLMNO",D16="ABCDEFGHIJKLMNOP"
 S V(D,D,D,D,D,D,D,D,D,D,D,D,D,D16)=2
 S VCOMP=V(D,D,D,D,D,D,D,D,D,D,D,D,D,D16)
 S V(D,D,D,D,D,D,D,D,D,D,D,D,D,D16)=MAX
 S VCOMP=VCOMP_(V(D,D,D,D,D,D,D,D,D,D,D,D,D,D16)=MAX)
 S ^VCOMP=VCOMP,^VCORR="21" D ^VEXAMINE
 ;
3 W !,"IV-762  Length of one subscript of a global variable is 234"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="40762",^ITEM="IV-762  Length of one subscript of a global variable is 234"
 S ^NEXT="4^V4SSUB1,V4SSUB2^V4SSUB,V4JOB^VV4" D ^V4PRESET
 S VCOMP="" S MAX="#" F I=0:2:252 S MAX=MAX_"QW"
 ; total=E+3+N+I+(2*L)+15
 ; N=$l("V"),L=1,total=255,E=$L("")
 ; ? I=255-0-3-1-2-15
 S D="" F I=1:1:234 S D=D_"#"
 S ^V(D)=3
 S VCOMP=^V(D)
 S ^V(D)=MAX
 S VCOMP=VCOMP_(^V(D)=MAX)
 S ^VCOMP=VCOMP,^VCORR="31" D ^VEXAMINE K ^V
 ;
4 W !,"IV-763  Total length of a global variable is 255"
 ;(title corrected in V7.4;16/9/89)
 S ^ABSN="40763",^ITEM="IV-763  Total length of a global variable is 255"
 S ^NEXT="V4SSUB2^V4SSUB,V4JOB^VV4" D ^V4PRESET
 S VCOMP="" S MAX="" F I=1:1:255 S MAX=MAX_"1"
 S D="ABCDEFGHIJKLMNO",D13="ABCDEFGHIJKLM"
 S ^V(D,D,D,D,D,D,D,D,D,D,D,D,D,D13)=4
 S VCOMP=^V(D,D,D,D,D,D,D,D,D,D,D,D,D,D13)
 S ^V(D,D,D,D,D,D,D,D,D,D,D,D,D,D13)=MAX
 S VCOMP=VCOMP_(^V(D,D,D,D,D,D,D,D,D,D,D,D,D,D13)=MAX)
 S ^VCOMP=VCOMP,^VCORR="41" D ^VEXAMINE K ^V
 ;
END W !!,"End of 123 --- V4SSUB1",!
 K  K ^V Q
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
