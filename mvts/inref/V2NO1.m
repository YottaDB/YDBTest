V2NO1 ;IW-KO-TS,VV2,MVTS V9.10;15/6/96;$NEXT AND $ORDER
 ;
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1984-1996
 W !!,"23---V2NO1: $NEXT and $ORDER  -1-",!
 ;W !,"   Although the usage of negative numeric subscripts is restricted in Part III "
 ;W !,"MUMPS Portability Requirements 2.2.3, they are not restricted in the Part I "
 ;W !,"MUMPS Language Specifications. Therefore, behaviors of $NEXT are tested on "
 ;W !,"negative numeric subscripts as regards ""If sn is -1, let A be the set of all "
 ;W !,"subscripts (I-20, line 20-21). Then $N(Name(s1,s2,...,sn)) returns the value t "
 ;W !,"in A such that CO(t,s) = s for all s not equal to t."" Note that Part I MUMPS "
 ;W !,"Language Specifications states that $N will return AMBIGUOUS results for lvn "
 ;W !,"and gvn arrays which have negative numeric values."
 W !!,"$NEXT(glvn)",!
167 W !,"II-167  Sequence from -1 when glvn is lvn"
16711 S ^ABSN="20198",^ITEM="II-167.1.1  Numeric interpretation of a subscript",^NEXT="16712^V2NO1,V2NO2^VV2" D ^V2PRESET
 W !,"       (This test II-167.1.1 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
16712 S ^ABSN="20199",^ITEM="II-167.1.2  What is the set A (local)?",^NEXT="16713^V2NO1,V2NO2^VV2" D ^V2PRESET
 ;Test isolated in V7.4;16/9/89
 W !,"       (This test II-167.1.2 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
16713 S ^ABSN="20200",^ITEM="II-167.1.3  The last returned value",^NEXT="1672^V2NO1,V2NO2^VV2" D ^V2PRESET
 W !,"       (This test II-167.1.3 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
1672 S ^ABSN="20201",^ITEM="II-167.2  Subscript is one character (95 graphics including space)",^NEXT="168^V2NO1,V2NO2^VV2" D ^V2PRESET
 W !,"       (This test II-167.1.2 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
168 W !,"II-168  Sequence from -1 when glvn is gvn"
16811 S ^ABSN="20202",^ITEM="II-168.1.1  Numeric interpretation of a subscript",^NEXT="16812^V2NO1,V2NO2^VV2" D ^V2PRESET
 W !,"       (This test II-168.1.1 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
16812 S ^ABSN="20203",^ITEM="II-168.1.2  What is the set A (global)?",^NEXT="16813^V2NO1,V2NO2^VV2" D ^V2PRESET
 W !,"       (This test II-168.1.2 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
16813 S ^ABSN="20204",^ITEM="II-168.1.3  The last returned value",^NEXT="1682^V2NO1,V2NO2^VV2" D ^V2PRESET
 ;Test isolated in V7.4;16/9/89
 W !,"       (This test II-168.1.3 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
1682 S ^ABSN="20205",^ITEM="II-168.2  Subscript is one character (95 graphics including space)",^NEXT="V2NO2^VV2" D ^V2PRESET
 W !,"       (This test II-168.2 was withdrawn in 20/8/1992 on X11.1-1984, MSL)"
 S ^VREPORT("Part-84",^ABSN)="*WITHDR*"
 ;
END W !!,"End of 23---V2NO1",!
 K  K ^VV,^V1 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
