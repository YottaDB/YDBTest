VV1DOC56	;VV1DOC V.7.1 -56-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-518.2  tvexpr is false
	;     I-519. tvexpr contains unary operator
	;     I-520. tvexpr is string literal
	;       I-520.1  "ABC"
	;       I-520.2  "1ABC"
	;       I-520.3  ".05EEE"
	;     I-521. tvexpr is empty string
	;     I-522. tvexpr is integer
	;     I-523. tvexpr is non-integer
	;     I-524. ELSE command, while $T=1
	;     I-525. ELSE command, while $T=0
	;     I-526. argumentless IF command, while $T=1
	;
	;
	;IF, ELSE, $TEST -2-
	;     (V1IE2)
	;
	;     I-527. argumentless IF command, while $T=0
	;     I-528. equal operator (=) in ifargument
	;       I-528.1  IF $TEST=1
	;       I-528.2  ifargument list is true
	;       I-528.3  ifargument list is false
	;       I-528.4  ifargument is 0=""
	;       I-528.5  ifargument contains lvn; all ifargument are true
	;       I-528.6  ifargument contains lvn; a ifargument is false
	;     I-529. effect on $TEST by executing IF command
	;       I-529.1  ifargument is true
	;       I-529.2  ifargument is false
	;     I-530. $TEST included in ifargument
	;       I-530.1  $T=1
	;       I-530.2  $T=1 another
	;       I-530.3  $T=0
	;     I-531. interpretation sequence of ifargument
	;
	;
	;Post conditional -1-
	;     (V1PCA)
	;
	;     (V1PCA is overlaid with V1PC1.)
	;
	;     I-712. WRITE command
	;       I-712.1  postcondition contains = operator
	;       I-712.2  postcondition contains lvn
	;     I-713. SET command
	;       I-713.1  local
