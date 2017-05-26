VVOVER13	;Overview V.7.1 -13-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;|     17 | VV2PAT3.......15 (   0)|    15      0        0|  None   None|
	;|     18 | VV2NO..........8 (   0)|     6      2        0|  None   None|
	;|     19 | VV2SS1.........6 (   0)|     6      0        0|  None   None|
	;|     20 | VV2SS2.........5 (   0)|     5      0        0|  None   None|
	;+--------+----------+-------------+------+------+--------+------+------+
	;| TOTAL  | .............210 (   4)|   199      3        4|( 4) 4    0  |
	;+--------+----------+-------------+------+------+--------+------+------+
	;                                                               ^    ^
	;                                                               |    |
	;                           To be manually filled in to make the total of 210.
	;
	;   Total 210 tests were provided. 4 visual evaluation of the results were
	;manually entered. There are 3 failures and 4 error stops reported. Their
	;locations could be found quickly in the output of their corresponding routine 
	;executions. 
	;
	;
	;7.3  Part-III
	;
	; 1) Passing tests stop with MUMPS error messages and return to direct mode.
	;
	;     >D 1^VVERAND<cr>   ....Entry to the test III-2.1
	;
	;     III-2  P.I-22 I-3.2.8  $RANDOM(intexpr)
	;            If the value of intexpr is less than 1, an error will occur.
	;
	;     III-2.1  $RANDOM(0)   (visual)   ....Test ID# and its proposition
	;
	;     W $RANDOM(0)
	;               *                      ....Error indication
	;
	;     Illegal expression (1+6^VVERAND)  ....Error message
	;
	;     >                                ....Return to direct mode.
	;
	;
	; 2) Ignored errors or erroneous interpretations are automatically detected 
	;   and reported as failures in the statistical report (VVESTAT).
	;
	;    >D 1^VVETEXT<cr>        ....Entry to the test III-4.1
	;
	;    III-4  P.I-22  I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)
	;           An error will occur if the value of intexpr is less than 0.
	;
	;    III-4.1  $TEXT(+-1) (visual)     ....Test ID# and its proposition
	;
	;    (some result may be output)      ....Absence of error message
