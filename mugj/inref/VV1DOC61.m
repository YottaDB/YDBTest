VV1DOC61	;VV1DOC V.7.1 -61-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     $DATA(@expratom)
	;
	;     I-509. indirection of $DATA argument
	;     I-510. indirection of subscript
	;     I-511. 2 levels of indirection
	;     I-512. 3 levels of indirection
	;
	;     $NEXT(@expratom)
	;
	;     I-513. indirection of $NEXT argument
	;     I-514. indirection of subscript
	;     I-515. indirection of naked reference
	;     I-516. 2 levels of indirection
	;     I-517. 3 levels of indirection
	;
	;
	;Indirection in GOTO command -1-
	;     (V1IDGOA)
	;
	;     (V1IDGOA is overlaid with V1IDGO1.)
	;
	;     I-475. indirection of dlabel
	;     I-476. indirection of dlabel, while dlabel contains indirection
	;     I-477. indirection of dlabel+intexpr
	;     I-478. indirection of dlabel+intexpr, while intexpr contains indirection
	;     I-479. indirection of dlabel+intexpr, while dlabel and intexpr contains
	;            indirection
	;     I-480. indirection of routine name
	;
	;
	;Indirection in GOTO command -2-
	;     (V1IDGOB)
	;
	;     (V1IDGOB is overlaid with V1IDGO1.)
	;
	;     I-481. indirection of routine name, while routine name contains indirection
	;     I-482. indirection of dlabel^routinename
	;     I-483. indirection of dlabel+intexpr^routinename
	;     I-484. argument level indirection without postcondition
	;     I-485. argument level indirection with postcondition
	;     I-486. indirection of argument list without postcondition
	;     I-487. indirection of argument list with postcondition
	;     I-488. indirection of postcondition
	;
	;
