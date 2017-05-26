VVE	;;TS,VVE,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	D ^VVE1
	D ^VVE2
	K ^VREPORT
	S ^VREPORT(0)=0
	Q
TEX	;
	;               VVE: Validation Instruction for Part-III
	;
	;
	;  Steps to be followed to execute Part-III
	;
	;1)  Get the Structure Table of Part-III from the Instruction Document at hand. 
	;
	;2)  Following to the sequence of routines in the Table, repeat direct mode 
	;  executions as;
	;
	;                  >D 1^VVENAK<cr>
	;                  >D 2^VVENAK<cr>
	;                  >D 3^VVENAK<cr>
	;                  >D 4^VVENAK<cr>
	;
	;   All the routines have four labels for entry (1, 2, 3, and 4), and the direct
	;   command "DO" must always identify only these labels of the routines.
	;
	;3) Results of the subroutines would stop in one of the following three examples.
	;
	;  Example 1: Passing Test
	;           (Stopping with MUMPS error message and returning to direct mode)
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
	;  Example 2: Ignored Error or Erroneous Output
	;           (Automatically detected and reported as Failure in VVESTAT)
	;
	;    >D 1^VVETEXT<cr>        ....Entry to the test III-4.1
	;
	;    III-4  P.I-22  I-3.2.8  $TEXT(lineref), $TEXT(+intexpr)
	;           An error will occur if the value of intexpr is less than 0.
	;
