V4NAME17 ;IW-KO-YS-TS,V4NAME,MVTS V9.10;15/6/96;PART-94
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1994-1996
 ;
 W !!,"38---V4NAME17:  $NAME function  -7-"
 ;
1 S ^ABSN="40284",^ITEM="IV-284  subscript is naked reference"
 S ^NEXT="2^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V(12,112)="V1"
 S ^V(1,1,2)=112,^V(1,1,1,2)=1112,^V(1,2)="12"
 S ^VCOMP=$NA(^V(^(1,2),^(1,2)))
 S ^VCORR="^V(112,1112)" D ^VEXAMINE K ^V
 ;
 ;
2 S ^ABSN="40285",^ITEM="IV-285  gvn contains operators"
 S ^NEXT="3^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^VCOMP=$name(^V(1-2,5/2,"A"!"1B",123.45E-1>1))
 S ^VCORR="^V(-1,2.5,1,1)" D ^VEXAMINE
 ;
3 S ^ABSN="40286",^ITEM="IV-286  gvn contains naked refernce"
 S ^NEXT="4^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S A=$D(^V("A","B","C"))
 S ^VCOMP=$NAME(^(1,2,3))
 S ^VCORR="^V(""A"",""B"",1,2,3)" D ^VEXAMINE
 ;
4 S ^ABSN="40287",^ITEM="IV-287  gvn has indirections"
 S ^NEXT="5^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V="^V(""A"")",^V("A",1,2)="^V(""C"",4)"
 S ^VCOMP=$na(@@^V@(1,2)@(5,6))
 S ^VCORR="^V(""C"",4,5,6)" D ^VEXAMINE
 ;
 W !,"gvn contains functions"
 ;
5 S ^ABSN="40288",^ITEM="IV-288  gvn contains $GET function"
 S ^NEXT="6^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S A("A",1)=1,A("B")="^V(A(""A"",1))"
 S ^VCOMP=$NA(@$G(A("A"),A("B")))
 S ^VCORR="^V(1)" D ^VEXAMINE
 ;
6 S ^ABSN="40289",^ITEM="IV-289  gvn contains $ORDER function"
 S ^NEXT="7^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V("A","B")="AB",A="A",^V("C",2)="#"
 S ^VCOMP=$NAME(^V($O(^V(A)),$O(^(2))))
 S ^VCORR="^V(""C"",""A"")" D ^VEXAMINE
 ;
7 S ^ABSN="40290",^ITEM="IV-290  gvn contains $QUERY function"
 S ^NEXT="8^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 s ^V("a","b","c","d","e","f","g",0,1,2)=""
 S ^VCOMP=$NA(@$Q(^V))
 S ^VCORR="^V(""a"",""b"",""c"",""d"",""e"",""f"",""g"",0,1,2)" D ^VEXAMINE
 ;
8 S ^ABSN="40291",^ITEM="IV-291  gvn contains $SELECT function"
 S ^NEXT="9^V4NAME17,V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V(1,2,3)="",A="1;2;3;4;5;6;7"
 S ^VCOMP=$NA(^($S($P(A,";",1)=0:9,$P(A,";",4)=1:13,.1:999)))
 S ^VCORR="^V(1,2,999)" D ^VEXAMINE
 ;
9 S ^ABSN="40292",^ITEM="IV-292  gvn contains $NAME function"
 S ^NEXT="V4NAME18^V4NAME,V4QLEN^VV4" D ^V4PRESET K  K ^V
 S ^V("A","B",1,2)=""
 S ^V("A","B",1,3)="^V(""a"",""b"",""c"")"
 s ^V("A","B","C")="ABC"
 S ^VCOMP=$NAME(@^($O(@$NAME(^(1,2)))))
 S ^VCORR="^V(""a"",""b"",""c"")" D ^VEXAMINE
 ;
END W !!,"End of 38 --- V4NAME17",!
 K  Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
