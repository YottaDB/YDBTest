V3NEWDE1 ;IW-KO-YS-TS,V3NEW,MVTS V9.10;15/6/96;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 ;
 S ^VCOMP=^VCOMP_$D(A)_" "_$D(A(2))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(B)_" "_$D(B(2))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(C)_" "_$D(C(2))_" "   ;0 0 
 S ^VCOMP=^VCOMP_$D(D)_" "_$D(D(2))_" "   ;0 0 
 S A="AA",A(2)="AA(2)",B="BB",B(2)="BB(2)",C="CC",C(2)="CC(2)"
 Q
 ;
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
 ;
NEWDOE2 S A="a",A(2)="a(2)",B="b",B(2)="b(2)",C(2)="c(2)"
 KILL B(2)
