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
alskillstargen;
	;
	; Test that KILL * works when there are LOTS of aliased unsubscripted variable names
	;
        set file="alskillstar.m"
        open file:(newversion)
        use file
        write " set a=1",!
	write " write !,""Create 20,000 alias variables named x0001, x0002, ..."",!",!
	; Create 20K unique local variables all of which are aliased to point to variable "a".
	; And then try KILL *
	; Do not go close to 32K of variables as that causes STACKCRIT error in Unix
	;	(M-stack requires 8-bytes per variable name and the M-stack size in Unix is ~ 250K).
	for i=100000:1:120000 write " set *x",$extract(i,2,$length(i)),"=a",!
	write " write !,""Do KILL * to remove all those 20,000 alias variables x0001, x0002, ..."",!",!
        write " kill *",!
	write " write !,""Do ZWRITE : We dont expect to see any of x0001, x0002, ..."",!",!
        write " zwrite",!
        write " quit",!
        close file
        quit

