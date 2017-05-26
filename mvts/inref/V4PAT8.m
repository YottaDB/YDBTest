V4PAT8 ;IW-KO-YS-TS,V4PAT,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"133---V4PAT8: pattern match operator  -8-"
 ;
1 S ^ABSN="40850",^ITEM="IV-850  expr ? repcount patcode repcount (...)"
 S ^NEXT="2^V4PAT8,V4PAT9^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="     ABC456789"
 S ^VCOMP=X?2.E2.(4.AN,4.N)
 S ^VCORR="1" D ^VEXAMINE
 ;
2 S ^ABSN="40851",^ITEM="IV-851  expr ? repcount strlit repcount (...)"
 S ^NEXT="3^V4PAT8,V4PAT9^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="XY XY XY *"
 S ^VCOMP=X?2."XY "3.(1"XY ",2A,1P)
 S ^VCORR="1" D ^VEXAMINE
 ;
3 S ^ABSN="40852",^ITEM="IV-852  expr ? repcount patcode repcount (...) repcount patcode"
 S ^NEXT="4^V4PAT8,V4PAT9^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="ABABC**"
 S ^VCOMP=X?2A.4(1.A,2.P).3P
 S ^VCORR="1" D ^VEXAMINE
 ;
4 S ^ABSN="40853",^ITEM="IV-853  expr ? repcount patcode repcount (...) repcount strlit"
 S ^NEXT="5^V4PAT8,V4PAT9^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="ABCD475---ABCDE-------"
 S ^VCOMP=X?2.NA.4(1.A,2.P).3"--"
 S ^VCORR="1" D ^VEXAMINE
 ;
5 S ^ABSN="40854",^ITEM="IV-854  expr ? repcount strlit repcount (...)  repcount patcode"
 S ^NEXT="6^V4PAT8,V4PAT9^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="    =AB 12345"
 S ^VCOMP=X?1." "4.(2A,2.P,1."=").N
 S ^VCORR="0" D ^VEXAMINE
 ;
6 S ^ABSN="40855",^ITEM="IV-855  expr ? repcount strlit repcount (...)  repcount strlit"
 S ^NEXT="V4PAT9^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="ABABABAB12341234AXAXAXAXAX"
 S ^VCOMP=X?2."AB"2.7(.A,4N)2."AX"
 S ^VCORR="1" D ^VEXAMINE
 ;
END W !!,"End of 133 --- V4PAT8",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
