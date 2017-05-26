d002676	;
        quit
test1	;
	; Test that $ZSTATUS reports labelref AT the line where the error occurred
	; Also test that ZSHOW "S" reports labelref correctly for all callers even though
	;	the mpc of the caller frame would have moved to one line AFTER where the call occurred.
	; Since symb_line() is the function that is invoked for both cases, we name the testcase accordingly.
	;
	do ^symblinetest
	quit
test2	;
	; Iselin's testcase which demonstrated that 
	;	a) nested STACKCRIT were occurring AND
	;	b) that $ZSTATUS is not correctly reported 
	;
	do ^TestTrap1
	quit
test3	; reserved for test2 run with POPADAPTIVE	
test4	;
	; This testcase demonstrates a bug in symb_line.c introduced in V53001A as part of D9F06-002676
	; The object of symb_line is to get the M source-line. There are two parts to it.
	;	a) The closest label name
	;	b) The line number offset relative to the above label.
	; As part of D9F06-002676, the choice of (a) was changed to be driven by whether or not we want
	;	the current source line or the line before. But the choice of (b) was not changed.
	; This could cause the LABEL+OFFSET output to be inconsistent. But no existing test showed this issue.
	; This test is constructed from an existing test program (M11^erransi.m) with a slight modification
	;	to introduce additional labels that demonstrate the inconsistency in symb_line.c.
	; This issue is fixed as part of C9I04-002976
	;
	do ^c002976
	quit

