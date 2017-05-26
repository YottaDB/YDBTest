V1OV1 ;IW-YS-TS,VV1,MVTS V9.10;15/6/96;GOTO (OVERLAY) COMMAND
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1978-1996
 W !!,"126---V1OV1: GOTO command  (overlay) -1-",!
%677 D 677
%678 D 678
%679 D 679
%680 D 680
%681 D 681
%682 D 682
%683 D 683
%684 D 684
%687 D 687
END W !!,"End of 126---V1OV1",!
 K  K ^V1OVE Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
677 W !,"I-677  Postconditional of argument"
 S ^ABSN="11606",^ITEM="I-677  Postconditional of argument",^NEXT="%678^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="E2 "
 S A=0 G E1^V1OVE:A=1 G E2^V1OVE:A=0 G E3^V1OVE
 ;
678 W !,"I-678  GOTO ^routineref"
 S ^ABSN="11607",^ITEM="I-678  GOTO ^routineref",^NEXT="%679^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="^V1OVE "
 G ^V1OVE
 ;
679 W !!,"GOTO label^routineref",!
 W !,"I-679/685  label is alpha"
 S ^ABSN="11608",^ITEM="I-679/685  label is alpha",^NEXT="%680^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="ABC "
 G ABC^V1OVE
 ;
680 W !,"I-680/686  label is intlit"
 S ^ABSN="11609",^ITEM="I-680/686  label is intlit",^NEXT="%681^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="0012 "
 G 0012^V1OVE
 ;
681 W !,"I-681  label is ""%"""
 S ^ABSN="11610",^ITEM="I-681  label is ""%""",^NEXT="%682^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="% "
 G %^V1OVE
 ;
682 W !,"I-682  label is ""%"" and alpha"
 S ^ABSN="11611",^ITEM="I-682  label is ""%"" and alpha",^NEXT="%683^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="%ALPHA "
 G %ALPHA^V1OVE
 ;
683 W !,"I-683  label is ""%"" and digit"
 S ^ABSN="11612",^ITEM="I-683  label is ""%"" and digit",^NEXT="%684^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="%009900 "
 G %009900^V1OVE
 ;
684 W !,"I-684  label is ""%"" and combination of alpha and digit"
 S ^ABSN="11613",^ITEM="I-684  label is ""%"" and combination of alpha and digit",^NEXT="%687^V1OV1,V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="%ZZ0090A "
 G %ZZ0090A^V1OVE
 ;
687 W !,"I-687  label is combination of alpha and digit"
 S ^ABSN="11614",^ITEM="I-687  label is combination of alpha and digit",^NEXT="V1OV2^V1OV,V1DO^VV1" D ^V1PRESET
 S ^VCOMP="",^VCORR="ZERO0 "
 G ZERO0^V1OVE
 ;
