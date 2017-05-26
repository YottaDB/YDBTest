VVINST24	;Instruction V.7.1 -24-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;          Validation Instruction - Sample of Automated Report Form 
	;
	;|     78 | VVELIMN......2..III-20.2 |         |    ----  |          |
	;|     79 | VVELIMN......3..III-20.3 |         |    ----  |          |
	;|     80 | VVELIMN......4..III-20.4 |         |    ----  |          |
	;+--------+---------+------+---------+---------+----------+----------+
	;|  TOTAL |                       80 |         |        0 |          |
	;+--------+---------+------+---------+---------+----------+----------+
	;
	;
	;END
	;
