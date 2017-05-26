VV1DOC57	;VV1DOC V.7.1 -57-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-713.2  global
	;     I-714. GOTO command ( command word )
	;     I-715. GOTO command ( argument )
	;     I-837. GOTO with postconditionalized label list
	;     I-838. GOTO with postconditionalized label+intexpr list
	;     I-839. GOTO with postconditionalized ^routineref list
	;     I-840. GOTO with postconditionalized label^routineref list
	;     I-841. GOTO with postconditionalized label+intexpr^routineref list
	;
	;
	;Post conditional -2-
	;     (V1PCB)
	;
	;     (V1PCB is overlaid with V1PC1.)
	;
	;     I-716. DO command ( command word )
	;     I-717. DO command ( argument )
	;     I-842. DO with postconditionalized label list
	;     I-843. DO with postconditionalized label+intexpr list
	;     I-844. DO with postconditionalized ^routineref list
	;     I-845. DO with postconditionalized label^routineref list
	;     I-846. DO with postconditionalized label+intexpr^routineref list
	;
	;     I-718. KILL command
	;       I-718.1  local
	;       I-718.2  global
	;
	;
	;FOR command -1.1-
	;     (V1FORA1)
	;
	;     FOR lvn=expr
	;
	;     I-335. expr is intlit
	;       I-335.1  lvn does not exist
	;       I-335.2  lvn exist
	;     I-336. expr is numlit
	;     I-337. expr is strlit
	;
	;     FOR lvn=numexpr1:numexpr2:numexpr3
	;
	;     I-338. numexpr1<numexpr3 and numexpr2>0
	;     I-339. numexpr1=numexpr3 and numexpr2>0
	;     I-342. numexpr1>numexpr3 and numexpr2>0
	;       I-338/339/342.1  numexpr1<numexpr3 and numexpr2>0
