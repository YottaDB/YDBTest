VSRWT ;IW-KO-TS,VENVIRON,MVTS V9.10;15/7/96;UTILITY
 ;COPYRIGHT MUMPS SYSTEMS LABORATORY 1990-1996
 F I=1:1 S L=$T(WT+I) Q:L=""  W !,$P(L,";",2,99)
 D ^VSRWT1,^VSRWT2
 Q
SUM S SUM=0 F I=1:1 S L=$T(+I) Q:L=""  F K=1:1:$L(L) S SUM=SUM+$A(L,K)
 Q
WT ;
 ;1)  12004  I-581 $JUSTIFY, optional test for intexpr2<0 and intexpr3<0
 ;                 Test I-581 was withdrawn by explicit portability prohibition
 ;                 by X11.1-'84.
 ;
 ;2)  12141  I-638 LOCK on non-variable name
 ;                 Test I-638 was withdrawn for its implementation dependency
 ;                 before X11.1-'77.
 ;
 ;3) The following 7 tests were suppressed in Part-77 for FIPS PUB 125-1 (Phase 2)
 ;
 ;11551  I-669  glvn is not defined
 ;11552  I-670  glvn has no neighboring node
 ;11553  I-671  The last subscript of glvn is -1
 ;11554  I-672  glvn as naked reference
 ;11555  I-673  Expected returned value is zero
 ;11556  I-674  glvn is lvn
 ;11557  I-675  glvn is gvn
 ;
 ;4) The following 5 tests were withdrawn from Part-77 for FIPS PUB 125-1 (Phase 2)
 ;
 ;11815  I-513  Indirection of $NEXT argument
 ;11816  I-514  Indirection of subscript
 ;11817  I-515  Indirection of naked reference
 ;11818  I-516  2 levels of indirection
 ;11819  I-517  3 levels of indirection
 ;
 ;5) The following 37 tests were withdrawn from Part-77 by extension 
 ;   in ANSI/MDC X11.1-1990, then moved into the Part-90.
 ;
 ;11954  I-653.1  1 level of DO, and 14 levels of FOR;  Termination by GOTO
 ;11955  I-653.2  1 level of DO, and 14 levels of FOR;  Termination by QUIT
 ;11956  I-654    1 level of DO, and 14 levels of XECUTE
 ;11957  I-655.1  15 levels of DO; Local DO
 ;11958  I-655.2  15 levels of DO; External DO
 ;11959  I-656    15 levels of combined DO, FOR, XECUTE
 ;11960  I-657    1 level of DO, and 14 levels of argument level indirection
 ;11961  I-658    1 level of DO, and 14 levels of name level indirection
 ;11962  I-659    Up to 6 nesting levels of functions
 ;11963  I-660.1  Effect of GOTO on nesting; Local GOTO
 ;11964  I-660.2  Effect of GOTO on nesting; External GOTO
 ;11965  I-661    Effect of QUIT on nesting
 ;12033  I-797    Partition size for assurance of routine transferability (4000 Bytes)
 ;12038  I-622    Numeric range ( 10 power -25 to 10 power 25 )
 ;12039  I-623.1  Significant digit up to 9 digits; Local data
 ;12040  I-623.2  Significant digit up to 9 digits; Global data
 ;12041  I-624    9 digits subscript of local variable
 ;12042  I-625    9 digits subscript of global variable
 ;12043  I-626    15 levels subscript of local variable
 ;12044  I-627    15 levels subscript of global variable
 ;12082  I-401    HANG duration by $H            (by OPERATOR)
 ;12083  I-402    List of hangargument           (by OPERATOR)
 ;12084  I-403    HANG in FOR scope              (by OPERATOR)
 ;12085  I-404    HANG with postconditional      (by OPERATOR)
 ;12086  I-405    Argument level indirection     (by OPERATOR)
 ;12087  I-406    Name level indirection         (by OPERATOR)
 ;12088  I-407   intexpr is integer              (by OPERATOR)
 ;12089  I-408  intexpr=0                        (by OPERATOR)
 ;12090  I-409  intexpr<0                        (by OPERATOR)
 ;12091  I-410  intexpr is non-integer positive numeric literal  (by OPERATOR)
 ;12092  I-411  intexpr is greater than zero and less than one   (by OPERATOR)
 ;12093  I-412  intexpr is string literal                        (by OPERATOR)
 ;12094  I-413  intexpr is an empty string                       (by OPERATOR)
 ;12095  I-414  intexpr is lvn                                   (by OPERATOR)
 ;12096  I-415  intexpr contains unary operator                  (by OPERATOR)
 ;12097  I-416  intexpr contains binary operator                 (by OPERATOR)
 ;12110  I-740  intexpr is 9 digits ( maximum range )
 ;
