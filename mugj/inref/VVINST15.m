VVINST15	;Instruction V.7.1 -15-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;              Validation Instruction - Sample of Automated Report Form 
	;
	; Example of the Result Evaluations (Validation Part-I Statistics)
	;written at the end of VV1.
	;
	;Final Evaluation of Std. MUMPS conformance Test V.7.1  Part-I
	;  ( Blanks in visual checks must be manually filled in.)
	;
	;                                                   AUG 31, 1987   15:30
	;+--------+----------+-------------+------+------+--------+------+------+
	;|executed| routine    tests       | auto   auto  aborted!|    visual   |
	;|  order |    name        (visual)| pass   fail          | pass   fail |
	;+--------+----------+-------------+------+------+--------+------+------+
	;|      1 | V1WR...........4 (   4)|  None   None        0|             |
	;|      2 | V1CMT..........5 (   5)|  None   None        0|             |
	;|      3 | V1LL1.........13 (   0)|    13      0        0|  None   None|
	;|      4 | V1LL2.........21 (   0)|    21      0        0|  None   None|
	;|      5 | V1PRGD.........9 (   0)|     9      0        0|  None   None|
	;|      6 | V1RN...........5 (   0)|     5      0        0|  None   None|
	;|      7 | V1PRSET........4 (   4)|  None   None        0|             |
	;|      8 | V1PRIE.........9 (   0)|     9      0        0|  None   None|
	;|      9 | V1PRFOR........4 (   0)|     4      0        0|  None   None|
	;|     10 | V1NUM1........28 (   0)|    28      0        0|  None   None|
	;|     11 | V1NUM2........21 (   0)|    21      0        0|  None   None|
	;|     12 | V1NUM3........23 (   0)|    23      0        0|  None   None|
	;|     13 | V1NUM4........31 (   0)|    31      0        0|  None   None|
	;|     14 | V1FC1..........9 (   9)|  None   None        0|             |
	;|     15 | V1FC2..........6 (   6)|  None   None        0|             |
	;|     16 | V1UO1A........19 (   0)|    19      0        0|  None   None|
	;|     17 | V1UO1B........26 (   0)|    26      0        0|  None   None|
	;|     18 | V1UO2A........19 (   0)|    19      0        0|  None   None|
	;|     19 | V1UO2B........26 (   0)|    26      0        0|  None   None|
	;|     20 | V1UO3A........19 (   0)|    19      0        0|  None   None|
	;|     21 | V1UO3B........26 (   0)|    26      0        0|  None   None|
	;|     22 | V1UO4A........18 (   0)|    18      0        0|  None   None|
	;|     23 | V1UO4B........30 (   0)|    30      0        0|  None   None|
	;|     24 | V1UO5A........36 (   0)|    36      0        0|  None   None|
	;|     25 | V1UO5B........22 (   0)|    22      0        0|  None   None|
	;|     26 | V1BOA1........32 (   0)|    32      0        0|  None   None|
	;|     27 | V1BOA2........27 (   0)|    27      0        0|  None   None|
	;|     28 | V1BOA3........25 (   0)|    25      0        0|  None   None|
	;|     29 | V1BOA4........27 (   0)|    27      0        0|  None   None|
	;|     30 | V1BOA5........26 (   0)|    26      0        0|  None   None|
	;|     31 | V1BOA6........47 (   0)|    47      0        0|  None   None|
	;|     32 | V1BOB1........39 (   0)|    39      0        0|  None   None|
	;|     33 | V1BOB2........41 (   0)|    41      0        0|  None   None|
	;|     34 | V1BOB3........37 (   0)|    37      0        0|  None   None|
