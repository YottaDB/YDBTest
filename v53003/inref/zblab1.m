;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2008, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lab1;
	write "# In zblab1 : Force zlink of zbmain",!,"# Expect it to error out",!
	set objfile="zbmain.o"
	set chset=$SELECT($ZV["OS390":":chset=""BINARY""",1:"")
        open objfile:@("(notruncate"_chset_")") close objfile:delete
	do writeZbmain^zbtest(2)
        zlink "zbmain"
        for lineno=begline:1:maxline  do
        . zbreak zbmain+lineno^zbmain:"set zbcnt("_lineno_")=zbcnt("_lineno_")+99"
        do ^zbmain
	write "TEST-E-UNEXPECTED This section should't have been reached.",!
	write "zlink of an active routine did not error as expected",!
        quit
