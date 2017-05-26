;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8245	;
	; TPFAIL uuuu in MERGE GVN2=GVN1 where GVN1 contains spanning nodes
	;
	; In this test, ^a* maps to AREG which has blocksize=2048 and ^b* maps to DEFAULT which has blocksize=1024
	; Note that when run with gtm_test_spanreg and *.sprgde files, this assumed mapping might not be true.
	; But that is okay since the test should pass in either case (both regions have same max-rec-size=4000).
	; Just that we wont be testing the codepath that triggered the TPFAIL in this case. But we get code coverage
	; for other codepaths in this case and because gtm_test_spanreg is chosen randomly at 50%, we will exercise
	; the TPFAIL codepath once every 2 test runs and that is considered good enough test coverage.
	;
	quit

testa	;
	; Case a) GVN2 has longer key than GVN1 and GVN1 has spanning node as only (and last) node
        set ^b1=$j(1,1024)
	merge ^b2("a")=^b1
	if $zl(^b2("a"))'=$zl(^b1) write "MERGE-E-ERROR"  zshow "*"  halt
	quit

testb	;
	; Case b) GVN2 has longer key than GVN1 and GVN1 has spanning node as last (but not only) node
        set ^b1=""
	set ^b1(1)=1
	set ^b1(2)=$j(1,1024)
	merge ^b2("a")=^b1
	if $zl(^b2("a"))'=$zl(^b1) write "MERGE-E-ERROR"  zshow "*"  halt
	quit
	quit

testc	;
	; Case c) GVN2 has same OR lesser keysize as GVN1 and GVN1 has spanning node as only (and last) node
	;		and GVN2 maps to different region (than GVN1) with a smaller blocksize
	;
        set ^a1=""
	set ^a1(1)=1
	set ^a1(2)=$j(1,2048)
	merge ^b1=^a1
	if $zl(^b1)'=$zl(^a1) write "MERGE-E-ERROR"  zshow "*"  halt
	quit
