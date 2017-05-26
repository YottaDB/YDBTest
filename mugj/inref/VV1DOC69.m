VV1DOC69	;VV1DOC V.7.1 -69-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-583.1  expr1="5.449"
	;       I-583.2  expr1="9995E-4"
	;     I-584. intexpr2<intexpr3
	;     I-585. interpretation of intexpr2, intexpr3
	;
	;
	;$JUSTIFY, $SELECT, $TEXT -3-
	;     (V1JST3)
	;
	;     $SELECT(L tvexpr:expr)
	;
	;     I-586. single argument
	;     I-587. effect on $TEST
	;       I-587.1  $TEST=1
	;       I-587.2  $TEST=0
	;     I-588. interpretation sequence of $SELECT argument
	;     I-589. interpretation of tvexpr
	;     I-590. interpretation of expr, while tvexpr=0
	;     I-591. interpretation of expr, while tvexpr=1
	;     I-592. nesting of functions
	;
	;  $TEXT(lineref),  $TEXT(+intexpr)
	;
	;     I-593. the line specified by lineref does not exist
	;     I-594. the line specified by +intexpr does not exist
	;     I-595. the line specified by lineref exist
	;       I-595.1  lineref is a label
	;       I-595.2  lineref is a another label
	;       I-595.3  nesting of function
	;     I-596. the line specified by +intexpr exist
	;     I-597. lineref=label
	;     I-598. lineref=label+intexpr
	;     I-599. indirection of label
	;     I-600. indirection of intexpr
	;       I-599/600  indirection of argument
	;
	;
	;Special variable $HOROLOG
	;     (V1SVH)
	;
	;     I-793. Format of $H
	;     I-794. Value of $H
	;
	;
	;
