VVOVER2	;Overview V.7.1 -2-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;   VVEDOC.DOC:   "WordStar" processed Content of Validation Items of Part-III,
	;                the latter 3 of which provide precise validation items with 
	;                their ID numbers and validation propositions with metalanguage
	;                elements which require unlerlines.  
	;
	;   OVERVIEW.RTN:    For those preferring MUMPS generated documents, the above
	;   INSTRUCT.RTN:  documents are saved in the routines (**.RTN) in sequential
	;   VV1DOC.RTN:    file format.   
	;   VV2DOC.RTN:
	;   VVEDOC.RTN:
	;   
	;   VV1A, VV1B.RTN:  All the MUMPS routines including driver for Part-I 
	;                      validation.
	;   VV2.RTN:  All the MUMPS routines including driver for Part-II validation. 
	;   VVE.RTN:  All the MUMPS routines including instruction driver for Part-III
	;              validation.
	;
	;   %ZRS.RTN:  MUMPS sample routine to restore the RTN sequential files of 
	;            routines on the floppy disk to executable routine format. 
	;
	;2.2  Magnetic tape content:
	;
	;   OVERVIEW: MUMPS routines to print/or display this Overview.
	;   INSTRUCT: MUMPS routines to print/or display the Validation Instructions
	;               with Structure Tables and Samples of Automated Report Forms for
	;               Part-I, II, and III. 
	;   VV1DOC: MUMPS routines to print/or display the Content of Validation 
	;             Items of Part-I,
	;   VV2DOC: The same for Part-II, and 
	;   VVEDOC: The same for the Part-III.
	;
	;
	;   VV1: All the MUMPS routines including driver for Part-I validation, 
	;   VV2: All the MUMPS routines including driver for Part-II validation. 
	;   VVE: All the MUMPS routines including instruction driver for Part-III 
	;           validation.
	;
	;  These sequential files should be restored as executable routines.
	;
	;
	;3.  Running  the Validation Suite. 
	;
	;   The Validation Instructions with Structure Tables and Samples of Automated 
	;Report Forms for Part-I, II, and III should be read before entering each  
	;validation process of Part-I, II, and III. The Structure Tables are to be used
	;as references to the program flows, so that when the program stops producing an
	;error they will assist to resume the course of validation. 
