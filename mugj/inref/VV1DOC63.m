VV1DOC63	;VV1DOC V.7.1 -63-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;Argument level indirection -2-
	;     (V1IDARG2)
	;
	;     KILL command
	;
	;     I-426. indirection of killargument
	;     I-427. indirection of killargument list
	;     I-428. subscript is denoted by name level indirection
	;     I-429. indirection of exclusive KILL
	;     I-430. Value of indirection contains indirection
	;     I-431. Value of indirection contains operators
	;     I-432. Value of indirection is function
	;     I-433. Value of indirection is lvn
	;     I-434. Value of indirection is gvn
	;
	;
	;Argument level indirection -3-
	;     (V1IDARG3)
	;
	;     SET command
	;
	;     I-435. indirection of setargument
	;     I-436. indirection of setargument list
	;     I-437. indirection of multi-assignment
	;     I-438. 2 levels of setargument indirection
	;     I-439. 3 levels of setargument indirection
	;     I-440. Value of indirection contains name level indirection
	;     I-441. Value of indirection contains operators
	;     I-442. Value of indirection is function
	;     I-443. Value of indirection contains subscripted local variable
	;
	;
	;Argument level indirection -4-
	;     (V1IDARG4)
	;
	;     WRITE command
	;
	;     I-444. indirection of writeargument except format
	;     I-445. indirection of writeargument list
	;     I-446. indirection of format control parameters
	;     I-447. 2 levels of writeargument indirection
	;     I-448. 3 levels of writeargument indirection
	;     I-449. Value of indirection contains name level indirection
	;     I-450. Value of indirection contains operators
	;     I-451. Value of indirection contains function
