V4SVQ3 ;IW-KO-YS-TS,V4SVQ,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"71---V4SVQ3:  Special variable $QUIT  -3-"
 ;
 W !!,"nesting"
 W !!,"$QUIT=0"
 W !!,"DO",!
 ;
1 S ^ABSN="40523",^ITEM="IV-523  extrinsic special variable"
 S ^NEXT="2^V4SVQ3,V4SVQ4^V4SVQ,V4MERGE^VV4" D ^V4PRESET K
 ;(test fixed in V9.02;7/10/95)
 S V="" D DOESV^V4SVQE
 S ^VCOMP=V
 S ^VCORR="010" D ^VEXAMINE
 ;
2 S ^ABSN="40524",^ITEM="IV-524  extrinsic function"
 S ^NEXT="3^V4SVQ3,V4SVQ4^V4SVQ,V4MERGE^VV4" D ^V4PRESET K
 ;(test fixed in V9.02;7/10/95)
 S V="" D DOEF^V4SVQE
 S ^VCOMP=V
 S ^VCORR="010" D ^VEXAMINE
 ;
 W !!,"argumentless DO",!
 ;
3 S ^ABSN="40525",^ITEM="IV-525  extrinsic special variable"
 S ^NEXT="4^V4SVQ3,V4SVQ4^V4SVQ,V4MERGE^VV4" D ^V4PRESET K
 ;(test fixed in V9.02;7/10/95)
 S V="" D
 . S V=V_$Q S A=$$ESV^V4SVQE
 . S V=V_$Q
 S ^VCOMP=V
 S ^VCORR="010" D ^VEXAMINE
 ;
4 S ^ABSN="40526",^ITEM="IV-526  extrinsic function"
 S ^NEXT="V4SVQ4^V4SVQ,V4MERGE^VV4" D ^V4PRESET K
 S V="" D
 . S V=V_$Q S A=$$EF^V4SVQE S V=V_$Q
 S ^VCOMP=V
 S ^VCORR="010" D ^VEXAMINE
 ;
END W !!,"End of 71 --- V4SVQ3",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
