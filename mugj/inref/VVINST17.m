VVINST17	;Instruction V.7.1 -17-;TS,INSTRUCT,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;           Validation Instruction - Sample of Automated Report Form 
	;
	;
	;|     79 | V1IE2.........13 (   0)|    13      0        0|  None   None|
	;|     80 | V1PCA.........11 (   2)|     9      0        0|             |
	;|     81 | V1PCB..........9 (   0)|     9      0        0|  None   None|
	;|     82 | V1FORA1.......17 (   0)|    17      0        0|  None   None|
	;|     83 | V1FORA2.......11 (   0)|    11      0        0|  None   None|
	;|     84 | V1FORB........15 (   0)|    15      0        0|  None   None|
	;|     85 | V1FORC1........9 (   0)|     9      0        0|  None   None|
	;|     86 | V1FORC2........8 (   0)|     8      0        0|  None   None|
	;|     87 | V1IDNM1........8 (   0)|     8      0        0|  None   None|
	;|     88 | V1IDNM2.......12 (   0)|    12      0        0|  None   None|
	;|     89 | V1IDNM3........9 (   0)|     9      0        0|  None   None|
	;|     90 | V1IDGOA........6 (   0)|     6      0        0|  None   None|
	;|     91 | V1IDGOB........8 (   0)|     8      0        0|  None   None|
	;|     92 | V1IDDOA........7 (   0)|     7      0        0|  None   None|
	;|     93 | V1IDDOB........7 (   0)|     7      0        0|  None   None|
	;|     94 | V1IDARG1.......9 (   0)|     9      0        0|  None   None|
	;|     95 | V1IDARG2.......9 (   0)|     9      0        0|  None   None|
	;|     96 | V1IDARG3.......9 (   0)|     9      0        0|  None   None|
	;|     97 | V1IDARG4.......9 (   9)|  None   None        0|             |
	;|     98 | V1IDARG5.......8 (   0)|     8      0        0|  None   None|
	;|     99 | V1XECA1........9 (   0)|     9      0        0|  None   None|
	;|    100 | V1XECA2.......13 (   0)|    13      0        0|  None   None|
	;|    101 | V1XECB.........7 (   0)|     7      0        0|  None   None|
	;|    102 | V1SEQ..........7 (   0)|     7      0        0|  None   None|
	;|    103 | V1PAT1........14 (   0)|    14      0        0|  None   None|
	;|    104 | V1PAT2........10 (   0)|    10      0        0|  None   None|
	;|    105 | V1NST1.........6 (   0)|     6      0        0|  None   None|
	;|    106 | V1NST2.........3 (   0)|     3      0        0|  None   None|
	;|    107 | V1NST3.........3 (   0)|     3      0        0|  None   None|
	;|    108 | V1JST1........22 (   0)|    22      0        0|  None   None|
	;|    109 | V1JST2........21 (   0)|    21      0        0|  None   None|
	;|    110 | V1JST3........17 (   0)|    17      0        0|  None   None|
	;|    111 | V1SVH..........2 (   1)|     1      0        0|             |
	;|    112 | V1SVS..........5 (   0)|     5      0        0|  None   None|
	;|    113 | V1MAX1.........7 (   1)|     6      0        0|             |
	;|    114 | V1MAX2.........4 (   0)|     4      0        0|  None   None|
	;|    115 | V1BR...........7 (   0)|     7      0        0|  None   None|
	;|    116 | V1READA1.......8 (   0)|     8      0        0|  None   None|
	;|    117 | V1READA2.......5 (   0)|     5      0        0|  None   None|
	;|    118 | V1READB1.......8 (   0)|     8      0        0|  None   None|
	;|    119 | V1READB2.......9 (   0)|     9      0        0|  None   None|
	;|    120 | V1HANG........16 (  16)|  None   None        0|             |
	;|    121 | V1PO..........10 (   0)|    10      0        0|  None   None|
	;|    122 | V1RANDA........7 (   7)|  None   None        0|             |
