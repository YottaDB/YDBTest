VV1DOC49	;VV1DOC V.7.1 -49-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;     I-235. Mixture of selective KILL and exclusive KILL in one argument
	;
	;
	;$DATA of unsubscripted globals and KILL command
	;     (V1DGA)
	;
	;     I-822. KILL undefined unsubscripted global variables
	;     I-191. SET unsubscripted global variables
	;     I-192. The value of $DATA of above
	;     I-193. KILL unsubscripted global variables
	;     I-194. The value of $DATA of above
	;     I-195. Assign numeric literal to unsubscripted global variables
	;     I-196. Assign string literal to unsubscripted global variables
	;     I-197. Effect on global variables by killing local variables
	;     I-198. Effect on global variables by executing exclusive kill
	;     I-199. Effect on global variables by executing kill all
	;     I-200. Allowed global variable name
	;
	;
	;$DATA of subscripted globals and KILL command -1-
	;     (V1DGB1)
	;
	;     I-823. KILL undefined subscripted global variables.
	;     I-201. $DATA of undefined node which has immediate descendants
	;     I-202. $DATA of undefined node which has descendants 2 levels below
	;     I-203. $DATA of undefined node whose immediate descendants are killed
	;     I-204. $DATA of undefined node whose descendants 2 levels below are killed
	;     I-205. $DATA of defined node which has immediate descendants
	;
	;
	;$DATA of subscripted globals and KILL command -2-
	;     (V1DGB2)
	;
	;     I-206. $DATA of defined node which has descendants 2 levels below
	;     I-207. $DATA of defined node whose immediate descendants are killed
	;     I-208. $DATA of defined node whose descendants 2 levels below are killed
	;     I-209. $DATA of defined node whose parent is killed
	;     I-210. $DATA of defined node whose neighboring node is killed
	;
	;
	;Naked reference -1-
	;     (V1NR1)
	;
	;     I-648. interpretation sequence of SET command
	;     I-649. interpretation sequence of subscripted variable
