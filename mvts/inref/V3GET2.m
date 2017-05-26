V3GET2 ;IW-KO-YS-TS,V3GET,MVTS V9.10;15/6/96;PART-90
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
 W !!,"2---V3GET2: $GET function -2-"
 W !!,"$D(lvn)=10"
 ;
1 S ^ABSN="30017",^ITEM="III-17  unsubscripted lvn"
 S ^NEXT="2^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S C("ibk",98.780)=100
 S ^VCOMP=$Get(C)
 S ^VCORR="" D ^VEXAMINE
 ;
2 S ^ABSN="30018",^ITEM="III-18  1 subscript"
 S ^NEXT="3^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S L("980M",67.89)="HJDK"
 S ^VCOMP=$G(L("980M"))
 S ^VCORR="" D ^VEXAMINE
 ;
3 S ^ABSN="30019",^ITEM="III-19  2 subscripts"
 S ^NEXT="4^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S KO0JK(378.768,"k09k,",47849)=89,KO0JK(378.768,"k09k,","HFKSJ")=87
 S KO0JK(378.768)=100
 S ^VCOMP=$G(KO0JK(378.768,"k09k,"))
 S ^VCORR="" D ^VEXAMINE
 ;
4 S ^ABSN="30020",^ITEM="III-20  5 subscripts"
 S ^NEXT="5^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S M0000("767.89000",89.678,3638,327438,78,36378)=78
 S M0000(767.89,89.678,3638,327438)=78
 S ^VCOMP=$G(M0000("767.89000",89.678,3638,327438,78.00))
 S ^VCORR="" D ^VEXAMINE
 ;
5 S ^ABSN="30021",^ITEM="III-21  lvn has subscript and ancestors have values"
 S ^NEXT="6^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S V3("abc","def","ghi")="xyz",V3("abc")="abc"
 S ^VCOMP=$g(V3("abc","def"))
 S ^VCORR="" D ^VEXAMINE
 ;
6 S ^ABSN="30022",^ITEM="III-22  lvn has subscript and siblings have values"
 S ^NEXT="7^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S V3("abc","def","ghi")="xyz",V3("abc","def0")="def0"
 S ^VCOMP=$g(V3("abc","def"))
 S ^VCORR="" D ^VEXAMINE
 ;
7 S ^ABSN="30023",^ITEM="III-23  lvn has subscript and ancestors have no values"
 S ^NEXT="8^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S V3("abc","def","ghi")="xyz",V30("abc")="abc"
 S ^VCOMP=$g(V3("abc","def"))
 S ^VCORR="" D ^VEXAMINE
 ;
8 S ^ABSN="30024",^ITEM="III-24  lvn has subscript and siblings have no values"
 S ^NEXT="9^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S V3("abc","def","ghi")="xyz",V30("abc","def0")="def0"
 S ^VCOMP=$g(V3("abc","def"))
 S ^VCORR="" D ^VEXAMINE
 ;
 W !!,"$D(lvn)=11"
 ;
9 S ^ABSN="30025",^ITEM="III-25  unsubscripted lvn"
 S ^NEXT="10^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S P0ZZZZ="COMPUTER",P0ZZZZ("sub00",90098,0988)="S3"
 S ^VCOMP=$g(P0ZZZZ)
 S ^VCORR="COMPUTER" D ^VEXAMINE
 ;
10 S ^ABSN="30026",^ITEM="III-26  1 subscript"
 S ^NEXT="11^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S NAME("USA")="NORTH AMERICA",NAME("JAPAN")="EAST FAR"
 S ^VCOMP=$G(NAME("USA"))
 S ^VCORR="NORTH AMERICA" D ^VEXAMINE
 ;
11 S ^ABSN="30027",^ITEM="III-27  2 subscripts"
 S ^NEXT="12^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S ADDRESS="paint"
 S ADDRESS(0.0000789,"code",0,0,0,0,12,44,"vibrate")="track"
 S ADDRESS(0.0000789,"code")="TRACE"
 S ^VCOMP=$G(ADDRESS(0.0000789,"code"))
 S ^VCORR="TRACE" D ^VEXAMINE
 ;
12 S ^ABSN="30028",^ITEM="III-28  5 subscripts"
 S ^NEXT="13^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 s DIC(679,77,-688)="78"
 s DIC(-679,77,-688)="778"
 s DIC(-679,677,-688)="ita"
 s DIC(-679,677,-688,"pair","page")="OK"
 s DIC(-679,677,-688,"pair","page",0)="ITA"
 S ^VCOMP=$G(DIC(-679,677,-688,"pair","page"))
 S ^VCORR="OK" D ^VEXAMINE k
 ;
13 S ^ABSN="30029",^ITEM="III-29  lvn has subscript and ancestors have values"
 S ^NEXT="14^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S ADDRESS="paint"
 S ADDRESS(0.0000789,"code",0,0,0,0,12,44,"vibrate")="track"
 S ADDRESS(0.0000789,"code")="TRACE"
 S ADDRESS(0.0000789)="qwery"
 S ^VCOMP=$G(ADDRESS(.0000789,"code"))
 S ^VCORR="TRACE" D ^VEXAMINE
 ;
14 S ^ABSN="30030",^ITEM="III-30  lvn has subscript and siblings have values"
 S ^NEXT="15^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 s DIC(679,6770,-688,"pair","page",0)="ITA"
 s DIC(679,6770,-688,"pair","page")="GOOD"
 s DIC(679,6770,-688,"pair","line",0)="LINE"
 s DIC(679,6770,-688,"pair","line")="line"
 S ^VCOMP=$G(DIC(679,6770,-688,"pair","page"))
 S ^VCORR="GOOD" D ^VEXAMINE
 ;
15 S ^ABSN="30031",^ITEM="III-31  lvn has subscript and ancestors have no values"
 S ^NEXT="16^V3GET2,V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S ADDRESS(0.0000789,"code",0,0,0,0,12,44,"e")="track"
 S ADDRESS(0.0000789,"code")="TRACE"
 S ^VCOMP=$G(ADDRESS(0.0000789,"code"))
 S ^VCORR="TRACE" D ^VEXAMINE
 ;
16 S ^ABSN="30032",^ITEM="III-32  lvn has subscript and siblings have no values"
 S ^NEXT="V3GET3^V3GET,V3TR^VV3" D ^V3PRESET K
 S V3("abc","def","ghi")="xyz",V30("abc","def","ghi",1)="def1",V30("abc","def","ghi",1,2)="def1"
 S ^VCOMP=$g(V3("abc","def","ghi"))
 S ^VCORR="xyz" D ^VEXAMINE
 ;
END W !!,"End of 2 --- V3GET2",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
