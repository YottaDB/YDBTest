VVINST20	;Instruction V.7.1 -20-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;          Validation Instruction - Sample of Automated Report Form 
	;
	;
	; Example of the Result Evaluations (Validation Part-II Statistics)
	;written at the end of VV2.
	;
	;Final Evaluation of Std. MUMPS conformance Test V.7.1  Part-II
	;  ( Blanks in visual checks must be manually filled in.)
	;
	;                                                   AUG 31, 1987   15:30
	;+--------+----------+-------------+------+------+--------+------+------+
	;|executed| routine    tests       | auto   auto  aborted!|    visual   |
	;|  order |    name        (visual)| pass   fail          | pass   fail |
	;+--------+----------+-------------+------+------+--------+------+------+
	;|      1 | VV2CS..........8 (   0)|     8      0        0|  None   None|
	;|      2 | VV2LCC1.......10 (   4)|     6      0        0|             |
	;|      3 | VV2LCC2.......10 (   0)|    10      0        0|  None   None|
	;|      4 | VV2LCF1.......18 (   0)|    18      0        0|  None   None|
	;|      5 | VV2LCF2.......18 (   0)|    18      0        0|  None   None|
	;|      6 | VV2FN1........14 (   0)|    14      0        0|  None   None|
	;|      7 | VV2FN2........14 (   0)|    14      0        0|  None   None|
	;|      8 | VV2LHP1.......21 (   0)|    21      0        0|  None   None|
	;|      9 | VV2LHP2.......13 (   0)|    13      0        0|  None   None|
	;|     10 | VV2VNIA.......10 (   0)|    10      0        0|  None   None|
	;|     11 | VV2VNIB........7 (   0)|     7      0        0|  None   None|
	;|     12 | VV2VNIC........3 (   0)|     3      0        0|  None   None|
	;|     13 | VV2NR..........4 (   0)|     4      0        0|  None   None|
	;|     14 | VV2READ........8 (   0)|     8      0        0|  None   None|
	;|     15 | VV2PAT1........7 (   0)|     7      0        0|  None   None|
	;|     16 | VV2PAT2.......11 (   0)|    11      0        0|  None   None|
	;|     17 | VV2PAT3.......15 (   0)|    15      0        0|  None   None|
	;|     18 | VV2NO..........8 (   0)|     8      0        0|  None   None|
	;|     19 | VV2SS1.........6 (   0)|     6      0        0|  None   None|
	;|     20 | VV2SS2.........5 (   0)|     5      0        0|  None   None|
	;+--------+----------+-------------+------+------+--------+------+------+
	;| TOTAL  | .............210 (   4)|   210      0        0|( 4)         |
	;+--------+----------+-------------+------+------+--------+------+------+
	;
	;
	;
	;
	;
	;
	;
	;
	;
	;
