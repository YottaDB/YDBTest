;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alssymvalinherit;
	;
	; Test that alias activity is inherited from a child symbol table (exclusive new) to a parent symbol table
	;
        set a=0
        do
        . new (a)
        . set *a=g
        . set *a(1)=b
	. set a=1
        . do disp
        do disp
        quit
disp    ;
        write !,"ZWRITE output at XNEW depth = ",a,!
        write "-----------------------------------------",!
        zwrite
        quit
