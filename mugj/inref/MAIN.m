main	;; by tcd 3/7/88;
	w ### f b=1:1:15 w ?10,$p($t(text+b),";",2),!
table	w ! f i=1:1:8 w ?20	w:'(i#2) ?50 w i,".)  ",$p($T(tab+i),";",2) w:'(i#2) !
loop	r !,?10,"Select module you would like to run. (1-8) : ",ans,! q:ans=""
	i "12345678"'[ans w !,?30,"Error selection must be an integer.",! g loop
	w ### d @($p($T(tab+ans),";",2)) g loop
	q
text	;
	;Welcome to Dr. Wakai's MUMPS validation test suite.   This main driver serves to 
	;show overall operation and integration of test suite modules.
	;
	; Overview module    - text on operation of the suite
	; Instruction module - instructions on how to operate
	; VV1DOC module      - documentation on version 1 validation
	; VV1 module         - driver for version 1 validation
	; VV2DOC module      - documentation on version 2 validation
	; VV2 module         - driver for version 2 validation
	; VVEDOC module      - documentation on version E validation
	; VVE module         - driver for version E validation
	;	
	;You may select the module you wish to run below.  It is necessary
	;to use the hold screen key as the documentation and the test results
	;scroll past quickly.
tab	
	;^OVERVIEW
	;^INSTRUCT
	;^VV1DOC
	;^VV1
	;^VV2DOC
	;^VV2
	;^VVEDOC
	;^VVE
