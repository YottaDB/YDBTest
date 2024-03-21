;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
init;
	; for debugging
	set debug=0
	; for v option
	set aaaaa=1
	set zzzzz=1
	; for b option
	zbreak forzbreak^gtmf135292
	; for c option
	set x=$&ydbposix.unsetenv("SHELL",.errno)
	kill x,errno
	; for l option
	lock ^optl
	; for g option
	set ^optg=1
	quit
	;
generatezje();
	do init
	new iter,optlist
	set optlist="abcdgilrstv"
	for iter=1:1:5 do
	. new opt,optlimit,optlen,x
	. new file set file="zje_"_iter_".txt"
	. new optfile set optfile="opt.txt"
	. set opt=""
	. set optlimit=6
	. ; Generate random argument that have length=0-5
	. set optlen=$random(optlimit)
	. new j for j=1:1:optlen do
	. . set optr=$zextract(optlist,$random($zlength(optlist))+1)
	. . ; If already there, don't add it again. Try again
	. . if opt[optr set j=j-1 quit
	. . set opt=opt_optr
	. new outf set outf=$zjobexam(file,opt)
	. open optfile:append
	. use optfile
	. write "Run ",iter,": ",opt,!
	. close optfile
	. ; Analyze the file to check to see if it contains the opts in the correct order
	. open file
	. use file
	. ; Read file into x
	. for i=1:1 read x(i) quit:$zeof
	. close file
	. set order=$$analyze(.x)
	. if order=opt write "Iteration "_iter_": PASS",!
	. ; This condition is for empty option which will result like a "*" ("vibdlgrc").;
	. else  if opt="",order="vibdlgrc" write "Iteration "_iter_": PASS",!
	. else  write "Iteration "_iter_": FAIL with expected output="_opt_" but output="_order,!
	quit
	;
forzbreak
	write "This should never be called",!
	quit
	;
analyze(x)
	new i set i=""
	new code set code=""
	new state,line,endoffile
	set endoffile=0
	for  set i=$order(x(i)) quit:'i  set line=x(i) do out(line) do  do:state'="" @state  quit:endoffile
	. if line["generatezje+17^gtmf135292:" set state="r" quit
	. if line["generatezje+17^gtmf135292" set state="s" quit
	. if $zextract(line)="$" set state="i" quit
	. if line["posix." set state="c" quit
	. if line["GLD:*" set state="gld" quit
	. if line["MLG:" set state="locks" quit
	. if line["aaaaa" set state="v" quit
	. if line["forzbreak" set state="b" quit
	. if line["OPEN" set state="d" quit
	. if line["Object Directory" set state="a" quit
	. if line="" set state="" quit
	. write ": not handled",! set state=""
	quit code
	;
a ; handle "a" code
	set code=code_"a"
	do outc("a")
	for  set i=$order(x(i)) quit:i=""  quit:x(i)["rec#1"  do outskip(x(i))
	quit
	;
d ; handle "d" code
	set code=code_"d"
	do outc("d")
	for  set i=$order(x(i)) quit:i=""  quit:$zextract(x(i))'="0"  do outskip(x(i))
	if i="" set endoffile=1
	else  set i=i-1
	quit
	;
b ; handle "b" code
	set code=code_"b"
	do outc("b")
	quit
	;
i ; handle "i" code
	set code=code_"i"
	do outc("i")
	; skip the rest of the ISVs
	for  set i=$order(x(i)) quit:i=""  quit:$zextract(x(i))'="$"  do outskip(x(i))
	if i="" set endoffile=1
	else  set i=i-1
	quit
	;
v ; handle "v" code
	set code=code_"v"
	do outc("v")
	; skip the rest of the variables
	for  set i=$order(x(i)) quit:i=""  quit:x(i)["zzzzz"  do outskip(x(i))
	quit
	;
r ; handle "r" code
	set code=code_"r"
	do outc("r")
	do outskip(x(i+1))
	set i=i+1
	quit
s ; handle "s" code
	set code=code_"s"
	do outc("s")
	do outskip(x(i+1))
	set i=i+1
	quit
c ; handle "c" code
	set code=code_"c"
	do outc("c")
	; skip the rest of the call-in table
	for  set i=$order(x(i)) quit:i=""  quit:x(i)'["posix."  do outskip(x(i))
	if i="" set endoffile=1
	else  set i=i-1
	quit
gld	; handle "T" or "G"
	if x(i+1)["MLG:" set code=code_"t" do outc("t")
	if x(i+1)["GLD:/" set code=code_"g" do outc("g")
	do outskip(x(i+1))
	set i=i+1
	quit
locks	; handle locks. Should be "L" only
	if x(i+1)'["LOCK" write "TEST-E-FAIL",! quit
	set code=code_"l"
	do outc("l")
	do outskip(x(i+1))
	set i=i+1
	quit
	;
out(line) ; For debugging (debug=1)
	quit:'debug
	write "Analyzing ",line,": "
	quit
	; 
outc(code) ; For debugging (debug=1)
	quit:'debug
	write code,!
	quit
	;
outskip(line) ; For debugging (debug=1)
	quit:'debug
	write "skipping "_line,!
	quit
	;
