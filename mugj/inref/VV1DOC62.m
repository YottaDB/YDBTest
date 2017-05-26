VV1DOC62	;VV1DOC V.7.1 -62-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Indirection in DO command -1-
	;     (V1IDDOA)
	;
	;     (V1IDDOA is overlaid with V1IDDO1.)
	;
	;     I-461. indirection of dlabel
	;     I-462. indirection of dlabel, while dlabel contains indirection
	;     I-463. indirection of dlabel+intexpr
	;     I-464. indirection of dlabel+intexpr, while intexpr contains indirection
	;     I-465. indirection of dlabel+intexpr, while dlabel and intexpr contains
	;            indirection
	;     I-466. indirection of routine name
	;     I-467. indirection of routine name, while routine name contains indirection
	;
	;
	;Indirection in DO command -2-
	;     (V1IDDOB)
	;
	;     (V1IDDOB is overlaid with V1IDDO1.)
	;
	;     I-468. indirection of dlabel^routinename
	;     I-469. indirection of dlabel+intexpr^routinename
	;     I-470. argument level indirection without postcondition
	;     I-471. argument level indirection with postcondition
	;     I-472. indirection of argument list without postcondition
	;     I-473. indirection of argument list with postcondition
	;     I-474. indirection of postcondition
	;
	;
	;Argument level indirection -1-
	;     (V1IDARG1)
	;
	;     IF command
	;
	;     I-417. indirection of ifargument
	;     I-418. indirection of ifargument list
	;     I-419. list of indirection and ifargument
	;     I-420. 2 levels of ifargument indirection
	;     I-421. 3 levels of ifargument indirection
	;     I-422. Value of indirection expratom contains operator
	;     I-423. Value of indirection expratom is function
	;     I-424. Value of indirection expratom contains indirection
	;     I-425. Value of indirection expratom subscripted variable name
	;
	;
