V4PAT7 ;IW-KO-YS-TS,V4PAT,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"132---V4PAT7: pattern match operator  -7-"
 ;
1 S ^ABSN="40840",^ITEM="IV-840  expr ? repcount (patatom,patatom,patatom)"
 S ^NEXT="2^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="123-45-567ABCDEFG3233---"
 S ^VCOMP=X?4.(1.3A,1"-",2.N)
 S ^VCORR="1" D ^VEXAMINE
 ;
2 S ^ABSN="40841",^ITEM="IV-841  expr ? repcount (patatom,patatom,patatom,patatom,patatom)"
 S ^NEXT="3^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="abcd1234-A-A-A-*ABCD12345-*-*-"
 S ^VCOMP=X?5.7(2.NU,2."-A",2.P,2.L)
 S ^VCORR="1" D ^VEXAMINE
 ;
3 S ^ABSN="40842",^ITEM="IV-842  expr ? repcount (patatom,patatom,patatom,patatom,patatom,patatom)"
 S ^NEXT="4^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="-1234-ab-AB-12-12"
 S ^VCOMP=X?.4(.2"-12-",.3NA,.3NP,.2"-AB-",.3PL,1E)
 S ^VCORR="0" D ^VEXAMINE
 ;
 ;
4 S ^ABSN="40843",^ITEM="IV-843  expr ? repcount (...) repcount patcode"
 S ^NEXT="5^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="-1-1*AB+-"
 S ^VCOMP=X?2.4(.4AN,1.3AP,1E,2"-1")1.3P
 S ^VCORR="1" D ^VEXAMINE
 ;
5 S ^ABSN="40844",^ITEM="IV-844  expr ? repcount (...) repcount strlit"
 S ^NEXT="6^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="1ABCD1E#####"
 S ^VCOMP=X?2(.4AN,1.3AP,2."#")1.4"#"
 S ^VCORR="0" D ^VEXAMINE
 ;
6 S ^ABSN="40845",^ITEM="IV-845  expr ? repcount (...) repcount patcode repcount (...)"
 S ^NEXT="7^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="AAABCCCCCCCCCCCBBBB BBBBAAAA 12  1AAAAABBBBCCC"
 S ^VCOMP=X?.5(1."A",1."B",1."C")1.PN.5(1.NP,1."A",1."B",1."C")
 S ^VCORR="0" D ^VEXAMINE
 ;
7 S ^ABSN="40846",^ITEM="IV-846  expr ? repcount (...) repcount strlit  repcount (...)"
 S ^NEXT="8^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="CCCCCCCCCCCAAAAAAABBBBBBBBBBBAAAAAAAAA   XY  BBBBCCCAAAAAAAAAAAA"
 S ^VCOMP=X?.5(1."A",1."B",1."C")1" ".4(1."A",1."B",1."C",1.13AP)
 S ^VCORR="1" D ^VEXAMINE
 ;
8 S ^ABSN="40847",^ITEM="IV-847  expr ? repcount (...) repcount (...) repcount patcode"
 S ^NEXT="9^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="*-=BBBBBB123A--="
 S ^VCOMP=X?2.(.A,3.P)2.5(3A,2.NA,1P)3.4AP
 S ^VCORR="1" D ^VEXAMINE
 ;
9 S ^ABSN="40848",^ITEM="IV-848  expr ? repcount (...) repcount (...) repcount strlit"
 S ^NEXT="10^V4PAT7,V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="1--ABabAAab  "
 S ^VCOMP=X?1.3(.N,2"-",.2A).3(."AB",."ab",1"AA",1"ab")1.3" "
 S ^VCORR="1" D ^VEXAMINE
 ;
10 S ^ABSN="40849",^ITEM="IV-849  expr ? repcount (...) repcount (...) repcount (...)"
 S ^NEXT="V4PAT8^V4PAT,V4NST1^VV4" D ^V4PRESET K
 S X="AB1212112 -12AAA1"
 S ^VCOMP=X?9.(1.AN,.3PN)1(1"12",1"AB").2(1.3"A",.3AN)
 S ^VCORR="1" D ^VEXAMINE
 ;
END W !!,"End of 132 --- V4PAT7",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
