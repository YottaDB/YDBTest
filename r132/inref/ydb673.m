;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Attempt 56 locks whose modulo hashed values (so they all try to occupy the same neighborhood
; in the internal Hopscotch Hash) fill the local neighborhood of 32 entries. With the lock
; retry added in r1.32, we expect all locks to all be obtained (versus say V63009 where only
; the first 32 locks would be successful).
;
lock    ;
        set substr=""
        set substr=substr_"155800 400988 606638 641040 1112116 1326373 1761409 1878858 "
        set substr=substr_"2114883 2422980 2669839 2852966 3248953 3279500 3313281 3364214 "
        set substr=substr_"3502498 3548913 3734921 4128107 4217835 4232011 4400044 4462539 "
        set substr=substr_"4520810 4858665 5039476 5044597 5364586 5422757 5658325 5683384 "
        set substr=substr_"6311005 6344061 6517532 6563137 6694683 6806176 7112467 7165953 "
        set substr=substr_"7831563 7874626 7887309 8207267 8260435 8280795 8332349 8691930 "
        set substr=substr_"8774756 9158172 9195370 9260478 9273682 9325923 9642001 9774660"
        for i=1:1:$length(substr," ") do mylock($piece(substr," ",i))
	;
	; Our output shows whether we got all the locks or not so just exit now.
	;
        quit

mylock(subs)
        set name="x("_subs_")"
        write "Attempting LOCK +",name,":0"
        LOCK +@name:0
        if $test=1  write " : SUCCESS",!
        else        write " :  -------------------------> FAILURE",!
        quit

