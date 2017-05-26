VV1DOC48	;VV1DOC V.7.1 -48-;TS,VV1DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-I
	;
	;$DATA of unsubscripted local variable and KILL command
	;     (V1DLA)
	;
	;     I-824. KILL undefined unsubscripted local variables
	;     I-211. SET unsubscripted local variable
	;     I-212. Value of $DATA of above
	;       I-211/212  SETting unsubscripted local variable and its $DATA value
	;     I-213. KILL unsubscripted local variable
	;     I-214. Value of $DATA of above
	;       I-213/214  KILLing unsubscripted local variable and its $DATA value
	;     I-215. Assign string literal to unsubscripted local variables
	;     I-216. Assign numeric literal to unsubscripted local variables
	;     I-217. KILL all local variable
	;     I-218. Exclusive KILL
	;     I-219. Allowed local variable name
	;
	;
	;$DATA of subscripted local variable name and KILL command -1-
	;     (V1DLB1)
	;
	;     I-220. $DATA of undefined node which has immediate descendants
	;     I-221. $DATA of undefined node which has descendants 2 levels below
	;     I-222. $DATA of undefined node whose immediate descendants are killed
	;     I-223. $DATA of undefined node whose descendants 2 levels below are killed
	;     I-224. $DATA of defined node which has immediate descendants
	;     I-225. $DATA of defined node which has descendants 2 levels below
	;
	;
	;$DATA of subscripted local variable name and KILL command -2-
	;     (V1DLB2)
	;
	;     I-226. $DATA of defined node whose immediate descendants are killed
	;     I-227. $DATA of defined node whose descendants 2 levels below are killed
	;     I-228. $DATA of defined node whose parent is killed
	;     I-229. $DATA of defined node whose neighboring node is killed
	;     I-230. KILL undefined subscripted local variables
	;
	;
	;$DATA of subscripted local variables and exclusive KILL
	;     (V1DLC)
	;
	;     I-231. Selective KILL
	;     I-232. Exclusive KILL with argument list
	;     I-233. Exclusive KILL with one argument
	;     I-234. Exclusive KILL, which lvn is not defined
