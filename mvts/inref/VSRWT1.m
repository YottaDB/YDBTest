VSRWT1 ;IW-KO-TS,VENVIRON,MVTS V9.10;15/7/96;UTILITY
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 F I=1:1 S L=$T(WT+I) Q:L=""  W !,$P(L,";",2,99)
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
WT ;
 ;6) The following 10 tests were were suppressed in Part-84 for FIPS PUB 125-1 (Phase 2)
 ;
 ;20045  II-45  $next
 ;20046  II-46  $n
 ;20198  II-167.1.1  Interpretation of a subscript string
 ;20199  II-167.1.2  What is the set A (local)?
 ;20200  II-167.1.3  The last returned value
 ;20201  II-167.2  Subscript is one character (95 graphics including space)
 ;20202  II-168.1.1  Interpretation of a subscript string
 ;20203  II-168.1.2  What is the set A (global)?
 ;20204  II-168.1.3  The last returned value
 ;20205  II-168.2  Subscript is one character (95 graphics including space)
 ;
 ;7) The following 9 tests were withdrawn from the Part-84 by extension 
 ;   in ANSI/MDC X11.1-1990, then moved into the Part-90.
 ;
 ;20216  II-173  Length of one subscript of a local variable is 31 (max)
 ;20217  II-174  Total length of a local variable is 63 (max)
 ;20218  II-175  Length of one subscript of a global variable is 31 (max)
 ;20219  II-176  Total length of a global variable is 63 (max)
 ;20220  II-177  Naked reference when the total length of global variable is 63
 ;               characters (max)
 ;20221  II-178  Minimum (-.999999999E25) to maximum (.999999999E25) number
 ;               for one subscript of local variable
 ;20222  II-179  Minimum (-.999999999E25) to maximum (.999999999E25) number
 ;               for one subscript of global variable
 ;20223  II-180  Total number of local variable subscripts is 31 (max)
 ;20224  II-181  Total number of global variable subscripts is 31 (max)
 ;
