VVOVER14	;Overview V.7.1 -14-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;
	;    **Failure in producing ERROR for III-4.1    ....Stopped by Validation
	;                                                 and the failure is counted. 
	;   >                                         ....Returns to direct mode
	;
	;
	; 3) Permanent loop or system hang-up needing forced interruption or rebooting.
	;
	;    >D 4^VVELINA<cr>        ....Entry to the test III-9.4
	;
	;    III-9  P.I-32  I-3.5.7   Line References (2)
	;           In the context of DO or GOTO, either of the following conditions 
	;           is erroneous.
	;           a. A value of intexpr so large as not to denote a line within the 
	;              bounds of the given routine.
	;
	;    NO RESPONSE FOREVER!    ....System must be interrupted forcefully
	;
	; Syntax checking during pre-compilation may detect errors in the test routines,
	;making it simpler to fill the statistics report, without executing those label 
	;lines.  
	;
	;
	;END
