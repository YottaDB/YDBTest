VV1DOC50	;VV1DOC V.7.1 -50-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-649.1  local variable's subscript
	;       I-649.2  glvn is naked reference
	;       I-649.3  subscripts are naked reference
	;       I-649.4  nesting naked reference
	;       I-649.5  6 level subscripts
	;     I-650. effect of global reference in $DATA on naked indicator
	;       I-650.1  2 level subscripts
	;       I-650.2  a subscript
	;       I-650.3  2 globals using
	;
	;
	;Naked reference -2-
	;     (V1NR2)
	;
	;     I-651. effect of KILLing global variables on naked indicator
	;       I-651.1  killing defined global variable
	;       I-651.2  killing undefined global variable
	;       I-651.3  2 globals using
	;     I-652. interpretation of naked reference
	;     I-825. Naked reference of undefined global node whose immediate
	;            ascendant exist
	;     I-826. Naked reference of undefined global node whose immediate
	;            ascendant does not exist
	;       I-826.1  immediate ascendant is unsubscripted variable
	;       I-826.2  immediate ascendant is 2-subscripts variable
	;       I-826.3  another same level variable exist
	;
	;
	;$NEXT function -1-
	;     (V1NX1)
	;
	;     $NEXT(glvn)
	;
	;     I-669. glvn does not defined
	;     I-670. glvn has no neighboring node
	;     I-671. the last subscript of glvn is -1
	;     I-672. glvn as naked reference
	;     I-673. expected returned value is zero
	;
	;
	;$NEXT function -2-
	;     (V1NX2)
	;
	;     I-674. glvn is lvn
	;     I-675. glvn is gvn
