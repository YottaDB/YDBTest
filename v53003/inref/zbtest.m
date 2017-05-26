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
zbtest;
        new lineno
        set $ZTRAP="set $ZTRAP="""" goto ERROR^zbtest"
	set objfile="zbmain.o"
	;; need a better mechanism to get chset set because all utf8
	; modes should open with chset=m to disable unicode procesirng
	set chset=$SELECT($ZV["OS390":":chset=""BINARY""",1:"")
        ;
initlab ;
	do writeZbmain(1)
        set begline=2
        set maxline=2
        for lineno=begline:1:maxline  do
        . set zbcnt(lineno)=0
        for lineno=begline:1:maxline  do
        . zbreak zbmain+lineno^zbmain:"set zbcnt("_lineno_")=zbcnt("_lineno_")+1 zc"
        do ^zbmain
        open objfile:@("(notruncate"_chset_")") close objfile:delete
        zlink "zbmain"
	write "# Set zbreak at zbmain+lineno and xecute lab1^zblab1",!
        for lineno=begline:1:maxline  do
        . zbreak zbmain+lineno^zbmain:"do lab1^zblab1 zc"
	write "# Call zbmain - Should break and xecute zblab1",!
        do ^zbmain
	write "# End of routine. Check the values of locals - zwrite :",!
        zwrite
        quit
        ;
ERROR   ;
	write "# In error trap routine",!
	write "$zstatus : ",$zstatus,!
	write "# Stack information",!
	zshow "S"
	write "# Breakpoints",!
	zshow "B"
	write "# Local variables",!
	zshow "V"
        quit

; Produce zbmain.m, one of whose lines depends on the passed argument.
writeZbmain(ver)
	new file
	set file="zbmain.m"
	open file:newversion
	use file
	write "zbmain;",!
        write " xecute ""set A=1""",!
        write " xecute ""set B=1""",!
        write " xecute ""set C=1""",!
        write " xecute ""set D=1""",!
	write:(ver>1) " ; Just for diff",!
        write " xecute ""set E=1""",!
        write " xecute ""set F=1""",!
        write " xecute ""set G=1""",!
        write " xecute ""set H=1""",!
        write " xecute ""set I=1""",!
        write " quit"
	close file
	quit
