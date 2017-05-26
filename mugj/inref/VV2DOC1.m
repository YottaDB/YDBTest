VV2DOC1	;VV2DOC V.7.1 -1-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;                                                                 August 31, 1987
	;                                              COPYRIGHT: MUMPS SYSTEM LABORATORY
	;
	;EXTENSIONS IN ANSI/MDC X11.1-1984  Validation Suite Version 7.1 Part-II
	;
	;     The last Test number for Part-II is I-181.
	;
	;1) Routines contained
	;
	;      0. VV2 ------- Main Driver Part-II
	;
	;      1. VV2CS ----- Command space
	;      2. VV2LCC1 --- Lower case letter command words and $DATA -1-
	;      3. VV2LCC2 --- Lower case letter command words and $DATA -2-
	;      4. VV2LCF1 --- Lower case letter function names (less $DATA)
	;                     and special variable names -1-
	;      5. VV2LCF2 --- Lower case letter function names (less $DATA)
	;                     and special variable names -2-
	;      6. VV2FN1 ---- Functions extended -1-
	;      7. VV2FN2 ---- Functions extended -2-
	;      8. VV2LHP1 --- Left hand $PIECE -1-
	;      9. VV2LHP2 --- Left hand $PIECE -2-
	;     10. VV2VNIA --- Variable name indirection -1-
	;     11. VV2VNIB --- Variable name indirection -2-
	;     12. VV2VNIC --- Variable name indirection -3-
	;     13. VV2NR ----- Naked reference
	;     14. VV2READ --- Read count
	;     15. VV2PAT1 --- Pattern match -1-
	;     16. VV2PAT2 --- Pattern match -2-
	;     17. VV2PAT3 --- Pattern match -3-
	;     18. VV2NO ----- $NEXT and $ORDER
	;     19. VV2SS1 ---- String subscript -1-
	;     20. VV2SS2 ---- String subscript -2-
	;
	;     21. STATIS^VREPORT --- Result Reporting for Validation Part-II
	;
	;
	;2)   Session titles  (Routine name)
	;     Section titles with or without ID#s and propositions
	;     Tests (.child tests .grandchild tests ) with ID#s and propositions
	;
	;Command space
	;     (VV2CS)
	;
	;     II-1. cs between ls and comment
