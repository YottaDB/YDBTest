;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	write $ZJOBEXAM("zje_star.txt","*"),!
	ZSYSTEM "cat zje_star.txt"
	write $ZJOBEXAM("zje_d.txt","d"),!
	ZSYSTEM "cat zje_d.txt"
	write $ZJOBEXAM("zje_i.txt","i"),!
	ZSYSTEM "cat zje_i.txt"
	write $ZJOBEXAM("zje_g.txt","g"),!
	ZSYSTEM "cat zje_g.txt"
	write $ZJOBEXAM("zje_l.txt","l"),!
	ZSYSTEM "cat zje_l.txt"
	write $ZJOBEXAM("zje_t.txt","t"),!
	ZSYSTEM "cat zje_t.txt"
	do stack
	quit
stack
	do exam
	quit
vars
	set a=77
	set b=444
	set c=89
	set d=2344
	set x=15
	set y=33
	write $ZJOBEXAM("zje_v.txt","v"),!
	ZSYSTEM "cat zje_v.txt"
	quit
breakpoint
	zbreak donotcall^zjobexam
	write $ZJOBEXAM("zje_b.txt","b"),!
	ZSYSTEM "cat zje_b.txt"
	quit
donotcall
	write "This should never be called",!
exam
	write $ZJOBEXAM("zje_r.txt","r"),!
	ZSYSTEM "cat zje_r.txt"
	write $ZJOBEXAM("zje_s.txt","s"),!
	ZSYSTEM "cat zje_s.txt"
	quit
singlearg
	write $ZJOBEXAM("zje.txt"),!
	ZSYSTEM "cat zje.txt"
