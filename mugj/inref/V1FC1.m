V1FC1	;FORMAT CONTROL CHARACTERS -1-;YS-TS,V1FC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1978
	I $Y>50 W #
	W !!,"V1FC1: TEST FORMAT CHARACTERS !,?,# -1-"
248	I $Y>50 W #
	W !!,"I-248  parameters occur in a single instance of format  (visual)"
	S ITEM="I-248  "
	W !,"       following two lines should be identical"
	W !,"       12345"
	W !
	W ?7
	W 12345
	;
249	I $Y>50 W #
	W !!,"I-249  ""New line"" operation by !  (visual)"
	S ITEM="I-249  "
	W !,"       following two lines should be identical"
	W !,"""New line"" operation by !",!,"""New line"" operation by !"
	;
250	W !!,"I-250  ""Top of page"" operation by #  (visual)"
	S ITEM="I-250  "
	W #,"Top of page  operation by #"
	;
251	I $Y>50 W #
	W !!,"I-251  Effect of comma in WRITE command  (visual)"
	S ITEM="I-251  "
	W !,"       following two lines should be identical"
	W !,"01 0 000 A",$C(34),"B ABC"
	W !,0,1," ",000," ",0,0,0," ","A""B"," ","A","B","C"
	;
252	I $Y>50 W #
	W !!,"I-252  Effect of comma between ""new line operator"" (!)  (visual)"
	S ITEM="I-252  "
	W !,"       CORRECT OUTPUT: 5 ROWS OF ASTERISKS; 1ST AND 2ND ROWS SINGLE"
	W !,"       PACED, 2ND AND 3RD SKIP ONE LINE, 3RD AND 4TH SKIP 2 LINES,"
	W !,"       4TH AND 5TH SKIP 3 LINES",!!
	I $Y>50 W #
	W "*****",!,"*****",!!,"*****",!,!,!,"*****",!!!!,"*****"
	;
253	I $Y>50 W #
	W !!,"I-253  Effect of comment delimiter on format  (visual)"
	S ITEM="I-253  "
	W !,"       following two lines should be identical"
	W !,"COMMENT DELIMITERS ;OUTPUT IS ON ONE LINE"
	W !,"COMMENT DELIMITERS ;" ; THIS SHOULD BE IGNORED
	; IGNORE THIS, TOO
	W "OUTPUT IS ON ONE LINE"
	;
	I $Y>50 W #
	W !!!,"Tab operation  ?intexpr"
254	I $Y>50 W #
	W !!,"I-254  intexpr is positive integer  (visual)"
	S ITEM="I-254  "
	W !,"       following two lines should be identical five times"
	I $Y>50 W #
	W !,"          1         2         3         4         5         6"
	W !,?10,1,?20,2,?30,3,?40,4,?50,5,?60,6
	W !,"12345     12345     12345     12345     12345     12345     12345"
	W !,12345,?10,12345,?20,12345,?30,12345,?40,12345,?50,12345
	W ?60,12345
	I $Y>50 W #
	W !,"          A         B         C         D         E         F"
	W !?10,"A",?20,"B",?30,"C",?40,"D",?50,"E",?60,"F"
	W !,"ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH  ABCDEFGH"
	W !,"ABCDEFGH",?10,"ABCDEFGH",?20,"ABCDEFGH",?30,"ABCDEFGH",?40
	W "ABCDEFGH",?50,"ABCDEFGH",?60,"ABCDEFGH"
	W !,"1.23      -1.23     123       123       0         0         10"
	W !,1.23,?10,-1.23,?20,000000123,?30,000000123.00000,?40,-.000000,?50,00000E000,?60,1E1
	;
255	I $Y>50 W #
	W !!!,"I-255  intexpr is zero  (visual)"
	S ITEM="I-255  "
	W !,"       following three lines should be identical"
	W !,"12345     12345     12345     12345     12345     12345     12345"
	W !?00,12345.0,?10,012345,?20,0012345,?30,12345.000,?40,12345,?50,12345,?60,12345
	W !?"ABC",12345,?0,?10,12345,?20,12345,?30.2000,12345,?40.0,12345.00000,?50,12345,?60,123_45
	;
256	I $Y>50 W #
	W !!!,"I-256  intexpr less than zero  (visual)"
	S ITEM="I-256  "
	W !,"       following two lines should be identical"
	W !,"ABC       ABC       ABC       ABC       ABC       ABC       ABC"
	W !,"ABC       AB",?-10,"C       ABC       A",?-20,"BC",?30,"       A",?-40,"BC",?50,"ABC",?60,"ABC"
	;
END	W !!!,"END OF V1FC1",!
	S ROUTINE="V1FC1",TESTS=9,AUTO=0,VISUAL=9 D ^VREPORT
	K  Q
