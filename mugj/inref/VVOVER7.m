VVOVER7	;Overview V.7.1 -7-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;   There  remain unsolved propositions of the standardized language.  
	;Validation routines written in the standard language, for example, took one 
	;hour to run on the computer, while it took overnight labor of a versed engineer
	;for its loading because of the lack of common routine and data transfer format 
	;among different implementations. 
	;
	;   Changing concept in the user partition due to abundance of core memory makes
	;one wonder if each implementation should return for the value of $STORAGE an 
	;integer which is the number of characters of free space available for use every
	;time a data is set to a variable or a variable is killed in the local symbol 
	;table.  While the validation sticks close to the standard specifications, new 
	;implementers might find such a specification rather awkward. 
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
	;
	;
	;
	;
	;
