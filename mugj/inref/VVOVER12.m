VVOVER12	;Overview V.7.1 -12-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;   PASS  II-158  
	;II-159  expr ? repcount strlit when expr is empty string
	;   PASS  II-159  
	;II-160  Lower case letter pattern code "c"
	;   PASS  II-160.1  repcount
	;   PASS  II-160.2  its mapping
	;   PASS  II-160.3  lvn?5c
	;II-161  Lower case letter pattern code "p"
	;   PASS  II-161.1  repcount
	;   PASS  II-161.2  its mapping
	;   PASS  II-161.3  lvn?5p
	;
	;END OF VV2PAT2
	;-----------------------------------------------------------------------
	;     END OF TEST -- VV2PAT2      Std. MUMPS Conformance Test V.7.1.
	;     11 tests were executed.
	;        0 visual    Test(s).
	;       11 automatic Test(s) (    10 passed,     0 failed,   1 aborted! ).
	;
	;
	;Example:  Part-II Statistics 
	;          Automated summary for the validation results of the Part-II. 
	;
	;Final Evaluation of Std. MUMPS conformance Test V.7.1.   Part-II
	;  ( Blanks in visual checks must be manually filled in.)
	;
	;                                                   AUG 31, 1987   14:30
	;+--------+----------+-------------+------+------+--------+------+------+
	;|executed| routine    tests       | auto   auto  aborted!|    visual   |
	;|  order |    name        (visual)| pass   fail          | pass   fail |
	;+--------+----------+-------------+------+------+--------+------+------+
	;|      1 | VV2CS..........8 (   0)|     8      0        0|  None   None|
	;|      2 | VV2LCC1.......10 (   4)|     6      0        0|   4      0  |
	;|      3 | VV2LCC2.......10 (   0)|    10      0        0|  None   None|
	;|      4 | VV2LCF1.......18 (   0)|    18      0        0|  None   None|
	;|      5 | VV2LCF2.......18 (   0)|    18      0        0|  None   None|
	;|      6 | VV2FN1........14 (   0)|    14      0        0|  None   None|
	;|      7 | VV2FN2........14 (   0)|    14      0        0|  None   None|
	;|      8 | VV2LHP1.......21 (   0)|    20      0        1|  None   None|
	;|      9 | VV2LHP2.......13 (   0)|    12      1        0|  None   None|
	;|     10 | VV2VNIA.......10 (   0)|    10      0        0|  None   None|
	;|     11 | VV2VNIB........7 (   0)|     5      0        2|  None   None|
	;|     12 | VV2VNIC........3 (   0)|     3      0        0|  None   None|
	;|     13 | VV2NR..........4 (   0)|     4      0        0|  None   None|
	;|     14 | VV2READ........8 (   0)|     8      0        0|  None   None|
	;|     15 | VV2PAT1........7 (   0)|     7      0        0|  None   None|
	;|     16 | VV2PAT2.......11 (   0)|    10      0        1|  None   None|
