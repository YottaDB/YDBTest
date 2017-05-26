VV1DOC73	;VV1DOC V.7.1 -73-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Precedence of operators and effect of parenthesis
	;     (V1PO)
	;
	;     I-719. priority of unary operators
	;     I-720. priority of binary operators
	;       I-720.1  * and +
	;       I-720.2  \ and *
	;       I-720.3  # and *
	;       I-720.4  ' and =
	;       I-720.5  & and =
	;       I-720.6  ! and =
	;     I-721. priority of all operators
	;     I-722. effect of parenthesis on interpretation sequence
	;     I-723. nesting of parenthesis
	;
	;
	;$RANDOM function -1-
	;     (V1RANDA)
	;
	;     $RANDOM(intexpr)
	;
	;     I-738. randomness of $RANDOM(10)
	;     I-739. interpretation of intexpr
	;     I-740. intexpr is 9 digits ( maximum range )
	;     I-741. range of returned value ( transition test )
	;
	;
	;$RANDOM function -2-
	;     (V1RANDB)
	;
	;     Gap test
	;
	;     I-742. Randomness of $R(2)
	;     I-743. Randomness of $R(3)
	;     I-744. Randomness of $R(4)
	;     I-745. Randomness of $R(5)
	;
	;     Frequency test
	;
	;     I-746. Randomness of $R(2)
	;     I-747. Randomness of $R(3)
	;     I-748. Randomness of $R(10)
	;
	;
	;
