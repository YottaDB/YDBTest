VVOVER4	;Overview V.7.1 -4-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;
	; Left hand $PIECE -1-                      ....(Session Title)
	;   (VV2LHP1)                               ....(Routine Name)
	;
	;  $PIECE(glvn,expr1,intexpr2,intexpr3)
	;       K=max(0,$L(glvn,expr1)-1)           ....(Section Title)
	;
	;  II-98   intexpr2>intexpr3                ....(Test ID# with its proposition)
	;  II-99   intexpr3<1                       ....(Test ID# with its proposition)
	;  II-100  K<intexpr2-1<intexpr3            ....(Test ID# with its proposition)
	;  II-101  intexpr2-1<=K<intexpr3           ....(Test ID# with its proposition)
	;
	;
	; Test of Binary Operators -1.2- (Arithmetic: +-*/#\)  ....(Session Title)
	;   (V1BOA2)                                           ....(Routine Name)
	;
	;  Algebraic Difference                      ....(Section Title)
	;
	; I-30   expratom=0                          ....(Test ID# with its proposition,
	;                                                 not counted as a test, but 
	;   I-30.1  0-0                              ....undertaken by these child tests
	;   I-30.2  1-0                              ....which are  counted as tests.) 
	;   I-30.3  000-2
	;   I-30.4  0-+.999
	;   I-30.5  00000-00000.00000E2
	;
	;
	; Test of Unary Operator -10-                ....(Session Title)
	;   (V1UO5B)                                 ....(Routine Name)
	;
	; I-801 Duplicate Unary Operators            ....(Section Title with ID# 
	;                                                 undertaken by child tests)
	;   I-801.6   Unary Operator(s) and a strlit 
	;                                          ....(Child test ID# with proposition,
	;     I-801.6.1  -"+-2"                 not counted as a test, but undertaken by
	;     I-801.6.2  '"+++2"                these grandchild tests which are counted
	;     I-801.6.3  -"-+-2"                as tests for automatic detection.)
	;     I-801.6.4  ++--+-"+-+.20E+01.5"  
	;
	;   The test ID's were numbered originally according to the sequence of program
	;listing, not according to the sequence of program execution. However, 
	;the documents of the test items are written according to the execution 
	;sequence, carrying the original numberings. 
	;   Merging of ID numbers have occurred by uniting two or more groups of tests 
	;under one more logical proposition while integrating child tests of the united
	;tests.  When two items were merged, they were made to carry the original test 
	;numbers in the form as "I-238/239".  If a test was nullified by some reasons 
