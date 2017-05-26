VSRWT2 ;IW-KO-TS,VENVIRON,MVTS V9.10;15/7/96;UTILITY
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 F I=1:1 S L=$T(WT+I) Q:L=""  W !,$P(L,";",2,99)
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
WT ;
 ;8) The following 5 SET PIECE tests were suppressed in Part-84 for FIPS PUB
 ;   125-1 (Phase 2)
 ;
 ;20116   II-107  glvn is naked reference
 ;20117   II-108  Interpretation sequence of subscripted left hand $PIECE
 ;20118   II-109  If setpiece on gvn affects naked indicator when intexpr2>intexpr3
 ;20119   II-110  If setpiece on gvn affects naked indicator when intexpr3<1
 ;20120   II-182  If setpiece on lvn affects naked indicator
 ;
 ;9) The following 6 tests were were suppressed in Part-90 for FIPS PUB 125-1
 ;   (Phase 2)
 ;
 ;30323  I,III-323   numexpr is greater than zero and less than one
 ;30539  III-0539  numexpr=01.2340
 ;30540  III-0540  numexpr=-01.2340
 ;30541  III-0541  numexpr="01.2340"
 ;30542  III-0542  numexpr="-01.2340"
 ;31068  III-1068  $TEST value
 ;
 ;10) The following 12 tests were suppressed from the Part-94 for ANSI/MDC
 ;    X11.1-1994.
 ;
 ;40088  IV-88  $FNUMBER(09878979.78E-2,"")
 ;40089  IV-89  $FN(0000.00000951200000,"")
 ;40090  IV-90  $FN(-0000.00000951200000,"")
 ;40091  IV-91  $FN(603.450000000E+4,"")
 ;40092  IV-92  $FN(-00020000.00000,"")
 ;40134  IV-134  $FNUMBER(-00020000.00000,"",0)
 ;40135  IV-135  $FN(09878979.78E-2,"",1)"
 ;40136  IV-136  $FN(-""0000.951200000"","",1)
 ;40137  IV-137  $FN(""603.450000000E+4"","",3)
 ;40138  IV-138  $fn(9.999979,"",4)"
 ;40139  IV-139  $fn(0000.00000951200000,"",8)
 ;40140  IV-140  $FN(-0000.00000951200000,"",8)
 ;
