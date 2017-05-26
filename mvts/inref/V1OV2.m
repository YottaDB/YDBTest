V1OV2 ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;GOTO (OVERLAY) COMMAND  -2-
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"127---V1OV2: GOTO command  (overlay)  -2-",!
%688 D 688
%689 D 689
%690 D 690
%691 D 691
%692 D 692
%693 D 693
%694 D 694
%695 D 695
%829 D 829
%830 D 830
%831 D 831
END W !!,"End of 127---V1OV2",!
 K  K ^V1OVE Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
688 W !!,"GOTO label+intexpr^routineref",!
 W !,"I-688  intexpr is positive integer"
 S ^ABSN="11615",^ITEM="I-688  intexpr is positive integer",^NEXT="%689^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="000 "
 G %+00003^V1OVE
 ;
689 W !,"I-689  intexpr is zero"
 S ^ABSN="11616",^ITEM="I-689  intexpr is zero",^NEXT="%690^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="XYZ 012 "
 G XYZ+0^V1OVE
 S ^VCOMP=^VCOMP_"***"
R689 G 012+0^V1OVE
 ;
690 W !,"I-690  intexpr is non-integer numeric"
 S ^ABSN="11617",^ITEM="I-690  intexpr is non-integer numeric",^NEXT="%691^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="00120 690 00 " G 000+2.9999999^V1OVE
 S ^VCOMP=^VCOMP_"690 " G 000+"4ABC"^V1OVE
 ;
691 W !,"I-691  intexpr contains binary operators"
 S ^ABSN="11618",^ITEM="I-691  intexpr contains binary operators",^NEXT="%692^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="0+2 690 6901 " G 00+1-12+15^V1OVE
 S ^VCOMP=^VCOMP_"690 ",A=999 G 691+A/9-11/19^V1OV2
 S ^VCOMP=^VCOMP_"@@@ "
 S ^VCOMP=^VCOMP_"6901 " G EXAMINER^V1OVE
 ;
692 W !,"I-692  intexpr contains unary operators"
 S ^ABSN="11619",^ITEM="I-692  intexpr contains unary operators",^NEXT="%693^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="0 "
 G 0+-+-+'-'0^V1OVE
 ;
693 W !,"I-693  intexpr contains functions"
 S ^ABSN="11620",^ITEM="I-693  intexpr contains functions",^NEXT="%694^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="0+1 "
 S A(1,1)=11 G ZERO0+$D(A(1))-$L(0.20)^V1OVE
 ;
694 W !,"I-694  intexpr is a gvn"
 S ^ABSN="11621",^ITEM="I-694  intexpr is a gvn",^NEXT="%695^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="0+3 "
 S ^V1OVE=3 G 0+^V1OVE^V1OVE
 ;
695 W !,"I-695  intexpr contains gvn as expratom"
 S ^ABSN="11622",^ITEM="I-695  intexpr contains gvn as expratom",^NEXT="%829^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="E4+4 "
 S ^V1OVE(0)=1,^(1)=3 G E4+^V1OVE(1)+^(0)^V1OVE
 ;
829 W !,"I-676/829  Argument list ^routineref without postcondition"
 S ^ABSN="11623",^ITEM="I-676/829  Argument list ^routineref without postcondition",^NEXT="%830^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="^V1OVE "
 G ^V1OVE,^V1OVE
 ;
830 W !,"I-676/830  Argument list label^routineref without postcondition"
 S ^ABSN="11624",^ITEM="I-676/830  Argument list label^routineref without postcondition",^NEXT="%831^V1OV2,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="E4 "
 G E4^V1OVE,ABD^V1OVE,E4^V1OVE
 ;
831 W !,"I-676/831  Argument list label+intexpr^routineref without postcondition"
 S ^ABSN="11625",^ITEM="I-676/831  Argument list label+intexpr^routineref without postcondition",^NEXT="V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="E4+2 "
 G E4+2^V1OVE,E4+3^V1OVE,E4+1^V1OVE
