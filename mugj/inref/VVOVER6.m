VVOVER6	;Overview V.7.1 -6-;TS,OVERVIEW,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;
	;   Rigorousness of this validation suite is due to its complete coverage 
	;of syntactic elements in minimum required combinations and  their semantic 
	;behaviors being detected by the 2,236 tests. 
	;
	;   Limitation of the Validation Suite lies in that it does not provide such 
	;tests either beyond the boundaries of, or the behaviors not specified in the 
	;ANSI/MDC X11.1-1984.  Namely, it does not provide such testings as,
	;
	; a) How far the boundaries of the standard specifications are extended; as 
	;   numbers of characters in a string literal beyond 255, existence of control 
	;   characters in the string subscripts, acceptance of non-ASCII characters, or 
	;   acceptance of non-MUMPS commands and functions, etc.
	; b) If a MUMPS process B initiated by a JOB command in the process A continues 
	;   without disturbance when the triggering process A ends and exits from the 
	;   partition. 
	; c) If so called "garbage collector" dominates and freezes the user partition  
	;   for a long time when a large global data is KILLed. 
	; d) Database performance and robustness tests including such tests including  
	;  if a certain data pointers are lost during repeated SETting and KILLing of 
	;  globals, resulting in accidental loss of data values. 
	;
	;   An  implementer detected for some failures in the validation test  should 
	;not  take  immediately  that he is mandated to correct "his" errors  to  pass 
	;these  particular  tests  unless he is  truly  persuaded.  Whatever  question 
	;arises,  it  should not be left unanswered.  Standard specification  and  its 
	;validation, by its nature, become too conservative within a few years of ever 
	;evolving hardware/software environment. 
	;
	;    It  has  been  experienced  that  older  technique  of  the  Global  tree 
	;implementation had affected the wordings of definitions in the specification, 
	;so  that  $DATA value was not to change even if all the descendants had  been 
	;killed,  and it forced that a variable with no descendent to have $DATA value 
	;of  10  or  11.   By  overlooking  some  definitions,   there  appeared  such 
	;implementations as $DATA was set to 0 or 1 whenever all existing  descendents 
	;of a node were KILLed.  The on-site validation service was aware of the  two 
	;contradictory implementations existing. The test disputes on $DATA semantics, 
	;as well as Naked Indicator combined with $DATA, were referred to the 
	;appropriate solution at the MUMPS/ANSI committee to revise the specifications.
	;
	;   Very  often failures on both validation routines and implementation  were 
	;able  to  be  attributed  to the ambiguity of  the  standard  specifications. 
	;Experiences on 28 on-site validation services have added to the stability  of 
	;the specifications, the validation suite, while accelerating the completion of
	;implementations of Standard MUMPS, through coordination and feed-back. 
	;
	;
