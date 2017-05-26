VV1DOC55	;VV1DOC V.7.1 -55-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;       I-245.2  _ operator
	;       I-245.3  combination binary operators
	;     I-246. label+intexpr   intexpr contains unary operator
	;     I-247. label+intexpr   intexpr contains gvn as expratom
	;     I-832. argument list label without postcondition
	;     I-833. argument list label+intexpr without postcondition
	;
	;
	;DO command ( call external routine )
	;     (V1CALL)
	;
	;     (V1CALL is overlaid with V1CALL1.)
	;
	;     I-172. argument list
	;     I-173. ^routineref
	;
	;     DO label^routineref
	;
	;     I-174. label^routineref   label is alpha
	;     I-175. label^routineref   label is intlit
	;     I-176. label^routineref   label is % and alpha
	;     I-177. label^routineref   label is % and digit
	;
	;     DO label+intexpr^routineref
	;
	;     I-178. label+intexpr^routineref   intexpr is positive integer
	;     I-179. label+intexpr^routineref   intexpr is zero
	;     I-180. label+intexpr^routineref   intexpr is non-integer numlit
	;     I-181. label+intexpr^routineref   intexpr contains binaryop
	;     I-182. label+intexpr^routineref   intexpr contains unaryop
	;     I-183. label+intexpr^routineref   intexpr is function
	;     I-184. label+intexpr^routineref   intexpr is gvn
	;     I-185. label+intexpr^routineref   intexpr contains gvn as expratom
	;     I-834. argument list ^routineref without postcondition
	;     I-835. argument list label^routineref without postcondition
	;     I-836. argument list label+intexpr^routineref without postcondition
	;
	;
	;IF, ELSE, $TEST -1-
	;     (V1IE1)
	;
	;     IF tvexpr
	;
	;     I-518. tvexpr contains binary operator
	;       I-518.1  tvexpr is true
