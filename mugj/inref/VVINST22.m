VVINST22	;Instruction V.7.1 -22-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;          Validation Instruction - Sample of Automated Report Form 
	;
	; Example of the Result Evaluations (Validation Part-III Statistics)
	;written at the end of VVELIMN.
	;
	;
	;Final Evaluation of Std. MUMPS conformance Test V.7.1  Part-III
	;  ( Blanks in visual checks must be manually filled in.)
	;
	;                                                AUG 31, 1987   16:30
	;+--------+---------+------+---------+---------+----------+----------+
	;|Checked | Routine   Label  Test    |Pass       Defects    Defects  |
	;|sequence|    name           number | detected   detected   detected|
	;|        |                          | visual.    automat.   visual. |
	;+--------+---------+------+---------+---------+----------+----------+
	;|      1 | VVENAK.......1..III-1.1  |         |    ----  |          |
	;|      2 | VVENAK.......2..III-1.2  |         |    ----  |          |
	;|      3 | VVENAK.......3..III-1.3  |         |    ----  |          |
	;|      4 | VVENAK.......4..III-1.4  |         |    ----  |          |
	;|      5 | VVERAND......1..III-2.1  |         |    ----  |          |
	;|      6 | VVERAND......2..III-2.2  |         |    ----  |          |
	;|      7 | VVERAND......3..III-2.3  |         |    ----  |          |
	;|      8 | VVERAND......4..III-2.4  |         |    ----  |          |
	;|      9 | VVESEL.......1..III-3.1  |         |    ----  |          |
	;|     10 | VVESEL.......2..III-3.2  |         |    ----  |          |
	;|     11 | VVESEL.......3..III-3.3  |         |    ----  |          |
	;|     12 | VVESEL.......4..III-3.4  |         |    ----  |          |
	;|     13 | VVETEXT......1..III-4.1  |         |    ----  |          |
	;|     14 | VVETEXT......2..III-4.2  |         |    ----  |          |
	;|     15 | VVETEXT......3..III-4.3  |         |    ----  |          |
	;|     16 | VVETEXT......4..III-4.4  |         |    ----  |          |
	;|     17 | VVEUNDF......1..III-5.1  |         |    ----  |          |
	;|     18 | VVEUNDF......2..III-5.2  |         |    ----  |          |
	;|     19 | VVEUNDF......3..III-5.3  |         |    ----  |          |
	;|     20 | VVEUNDF......4..III-5.4  |         |    ----  |          |
	;|     21 | VVEDIV.......1..III-6.1  |         |    ----  |          |
	;|     22 | VVEDIV.......2..III-6.2  |         |    ----  |          |
	;|     23 | VVEDIV.......3..III-6.3  |         |    ----  |          |
	;|     24 | VVEDIV.......4..III-6.4  |         |    ----  |          |
	;|     25 | VVEPAT.......1..III-7.1  |         |    ----  |          |
	;|     26 | VVEPAT.......2..III-7.2  |         |    ----  |          |
	;|     27 | VVEPAT.......3..III-7.3  |         |    ----  |          |
	;|     28 | VVEPAT.......4..III-7.4  |         |    ----  |          |
	;|     29 | VVELINN......1..III-8.1  |         |    ----  |          |
	;|     30 | VVELINN......2..III-8.2  |         |    ----  |          |
	;|     31 | VVELINN......3..III-8.3  |         |    ----  |          |
	;|     32 | VVELINN......4..III-8.4  |         |    ----  |          |
