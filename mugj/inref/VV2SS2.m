VV2SS2	;STRING SUBSCRIPT -2-;KO-TS,,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1984
	W !!,"VV2SS2: TEST OF STRING SUBSCRIPT -2-",!
	S PASS=0,FAIL=0 S MAX="#" F I=0:2:252 S MAX=MAX_"QW"
177	W !,"II-177  Naked reference when length of global variable is 63 characters"
	S ITEM="II-177  ",VCOMP=""
	S ^VV("ABCDEFGHIJ","ABCDEFGHIJ","ABCDEFGHIJ","ABCDEFGHIJ","ABCDEFGHIJ","ABCDE")=MAX
	S ^("FGHIJ")=5,VCOMP=^("FGHIJ"),^("FGHIJ")=MAX,VCOMP=VCOMP_(^("FGHIJ")=MAX)
	S VCORR="51" D EXAMINER
	;
178	W !,"II-178  Maximum and minimum number of local variable subscript"
	S ITEM="II-178  ",VCOMP=""
	S A(-.999999999E25)=6,A(-999999999E-25)=7,A(999999999E-25)=8,A(.999999999E25)=9
	SET VCOMP=A(-.999999999E+25)_A(-999999999E-25)_A(999999999E-25)_A(.999999999E+25)
	S VCORR="6789" D EXAMINER
	;
179	W !,"II-179  Maximum and minimum number of global variable subscript"
	S ITEM="II-179  ",VCOMP=""
	S ^VV(-.999999999E25)=10,^VV(-999999999E-25)=11,^VV(999999999E-25)=12,^VV(.999999999E25)=13
	S VCOMP=^VV(-.999999999E+25)_^VV(-999999999E-25)_^VV(999999999E-25)_^VV(.999999999E+25)
	S VCORR="10111213" D EXAMINER
	;
180	W !,"II-180  Number of local variable subscripts is 31 (max)"
	S ITEM="II-180  ",VCOMP=""
	S A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=14
	S VCOMP=A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")
	S A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX
	S VCOMP=VCOMP_(A("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX)
	S VCORR="141" D EXAMINER
	;
181	W !,"II-181  Number of global variable subscripts is 31 (max)"
	S ITEM="II-181  ",VCOMP=""
	S ^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=15
	S ^("f")=16
	S VCOMP=^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")
	S VCOMP=VCOMP_^("f")
	S ^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX
	S ^("f")=MAX
	S VCOMP=VCOMP_(^V("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e")=MAX)
	S VCOMP=VCOMP_(^("f")=MAX)
	S VCORR="151611" D EXAMINER
	;
END	W !!,"END OF VV2SS2",!
	S ROUTINE="VV2SS2",TESTS=5,AUTO=5,VISUAL=0 D ^VREPORT
	K  K ^VV,^V Q
	;
EXAMINER	I VCORR=VCOMP S PASS=PASS+1 W !,"   PASS  ",ITEM W:$Y>55 # Q
	S FAIL=FAIL+1 W !,"** FAIL  ",ITEM W:$Y>55 #
	W !,"           COMPUTED =""",VCOMP,"""" W:$Y>55 #
	W !,"           CORRECT  =""",VCORR,"""" W:$Y>55 #
	Q
