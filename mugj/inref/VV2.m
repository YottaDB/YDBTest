VV2	;PART-II DRIVER;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
START	W !!!,"*** STD. MUMPS VALIDATION FOR EXTENSIONS IN ANSI/MDC X11.1-1984 ***"
	W !," Std. MUMPS Validation Suite Version 7.1, Part-II."
	W !,"    ( The last Test number for Part-II is II-181. )",!!
	K ^VREPORT S ^VREPORT(0)=0,^VREPORT="Part-II"
VV2CS	W !!,"VV2CS" D ^VV2CS ;Command space
VV2LCC1	W !!,"VV2LCC1" D ^VV2LCC1 ;Lower case letter command words and $data -1-
VV2LCC2	W !!,"VV2LCC2" D ^VV2LCC2 ;Lower case letter command words and $data -2-
VV2LCF1	W !!,"VV2LCF1" D ^VV2LCF1 ;Lower case letter function names (less $data) and special variable names -1-
VV2LCF2	W !!,"VV2LCF2" D ^VV2LCF2 ;Lower case letter function names (less $data) and special variable names -2-
VV2FN1	W !!,"VV2FN1" D ^VV2FN1 ;Functions extended -1-
VV2FN2	W !!,"VV2FN2" D ^VV2FN2 ;Functions extended -2-
VV2LHP1	W !!,"VV2LHP1" D ^VV2LHP1 ;Left hand $PIECE -1-
VV2LHP2	W !!,"VV2LHP2" D ^VV2LHP2 ;Left hand $PIECE -2-
VV2VNIA	W !!,"VV2VNIA" D ^VV2VNIA ;Variable name indirection -1-
VV2VNIB	W !!,"VV2VNIB" D ^VV2VNIB ;Variable name indirection -2-
VV2VNIC	W !!,"VV2VNIC" D ^VV2VNIC ;Variable name indirection -3-
VV2NR	W !!,"VV2NR" D ^VV2NR ;Naked reference
VV2READ	W !!,"VV2READ" D ^VV2READ ;Read count
VV2PAT1	W !!,"VV2PAT1" D ^VV2PAT1 ;Pattern match -1-
VV2PAT2	W !!,"VV2PAT2" D ^VV2PAT2 ;Pattern match -2-
VV2PAT3	W !!,"VV2PAT3" D ^VV2PAT3 ;Pattern match -3-
VV2NO	W !!,"VV2NO" D ^VV2NO ;$NEXT and $ORDER
VV2SS1	W !!,"VV2SS1" D ^VV2SS1 ;String subscript -1-
VV2SS2	W !!,"VV2SS2" D ^VV2SS2 ;String subscript -2-
END	D STATIS^VREPORT
	W !!,"*** STD. MUMPS VALIDATION FOR EXTENSIONS IN ANSI/MDC X11.1-1984 ***"
	W !," Std. MUMPS Validation Suite Version 7.1, Part-II END.",!!
	Q
