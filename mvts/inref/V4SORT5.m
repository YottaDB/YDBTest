V4SORT5 ;IW-KO-YS-TS,V4SORT,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"5---V4SORT5: Sort After operator  -5-"
 ;
1 S ^ABSN="40035",^ITEM="IV-35  ""0.0""]]-84456565.5545"
 S ^NEXT="2^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="0.0"]]-84456565.5545
 S ^VCORR="1" D ^VEXAMINE
 ;
2 S ^ABSN="40036",^ITEM="IV-36  ""0.1""]]4384329328E8"
 S ^NEXT="3^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="0.1"]]4384329328E8
 S ^VCORR="1" D ^VEXAMINE
 ;
3 S ^ABSN="40037",^ITEM="IV-37  ""00""]]0000000000000000000000000000"
 S ^NEXT="4^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="00"]]0000000000000000000000000000
 S ^VCORR="1" D ^VEXAMINE
 ;
4 S ^ABSN="40038",^ITEM="IV-38  ""01""]]01"
 S ^NEXT="5^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="01"]]01
 S ^VCORR="1" D ^VEXAMINE
 ;
5 S ^ABSN="40039",^ITEM="IV-39  ""1.""]]1000.0000000000000E-3"
 S ^NEXT="6^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="1."]]1000.0000000000000E-3
 S ^VCORR="1" D ^VEXAMINE
 ;
6 S ^ABSN="40040",^ITEM="IV-40  ""1.0""]]9E-6"
 S ^NEXT="7^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 ;(test fixed in V9.02;7/10/95)
 S ^VCOMP="1.0"]]9E-6
 S ^VCORR="1" D ^VEXAMINE
 ;
7 S ^ABSN="40041",^ITEM="IV-41  ""1.1.2""]]-100789.899E+9"
 S ^NEXT="8^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="1.1.2"]]-100789.899E+9
 S ^VCORR="1" D ^VEXAMINE
 ;
8 S ^ABSN="40042",^ITEM="IV-42  ""123e1""]]0E-0"
 S ^NEXT="9^V4SORT5,V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="123e1"]]0E-0
 S ^VCORR="1" D ^VEXAMINE
 ;
9 S ^ABSN="40043",^ITEM="IV-43  ""A""]]000000000.9999999999E+9"
 S ^NEXT="V4SORT6^V4SORT,V4SORT^VV4" D ^V4PRESET K
 S ^VCOMP="A"]]000000000.9999999999E+9
 S ^VCORR="1" D ^VEXAMINE
 ;
END W !!,"End of 5 --- V4SORT5",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
