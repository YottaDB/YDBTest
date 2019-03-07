;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;
       W !,"Executing Shared Copy of MAIN in shlib3..."
       For I=1:1:10 Do
       . ;Do oddeven(I)
       . Do sqroot^sqrt(I,.sqrt) Set NUM(I,"root")=sqrt
       . Set sqr=$$squar^square(I),NUM(I,"square")=sqr
       . Set cube=$$cubeit^cube(I),NUM(I,"cube")=cube
       . Set factrl=$$fact^factor(I),NUM(I,"factorial")=factrl
       . Set base=10,base2=2,base8=8
       . Set binary=$$base^base(sqr,base,base2),NUM(I,"square","binary")=binary
       . Set octal=$$base^base(sqr,base,base8),NUM(I,"square","octal")=octal
       Q
       ;
oddeven(X) ;
       W !,X,$S(X#2=0:" is even. ",1:" is odd. ")
       Q
       ;
