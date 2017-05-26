; 3N+1 test with SN. SNs are created by appending a random ^padding string.
; Called from threeen.csh.
threeen1f
        ; Although the problem can be solved by using strictly integer subscripts and values, this program is
        ; written to show that the GT.M key-value store can use arbitrary strings for both keys and values -
        ; each subscript and value is spelled out using the strings in the program source line labelled "digits".
        ; Furthermore, the strings are in a number of international languages when GT.M is run in UTF-8 mode.

        ; The program reads the program source at the label digits to get strings (separated by ;) for each language used.
digits  ;zero;eins;deux;tres;quattro;пять;ستة;सात;捌;ஒன்பது
        new m,x
        set x=$text(digits)
	set ^padding=$$%RANDSTR^%RANDSTR(1000) ; Random string to append at the end of each value. Needed to force spanning.
        for m=0:1:9 set di($piece(x,";",m+2))=m,ds(m)=$piece(x,";",m+2)
	set ^result=1

        ; Loop forever, read a line (quit on end of file), process that line
        for  read input quit:$ZEOF!'$length(input)  do ; input has entire input line
        . set i=$piece(input," ",1) ; i - first number on line is starting integer for the problem
        . set j=$piece(input," ",2) ; j - second number on line is ending integer for the problem
	set ^stime=$justify($horolog,12)
	do calc(i,j)
	set ^ftime=$justify($horolog,12)
        write " ",$fnumber(^result,",",0),! ; Show largest number of steps for the range i through j
        kill ^result,^step
        quit

inttostr(n) ; Convert an integer to a string
        new m,s
        set s=ds($extract(n,1))
        for m=2:1:$length(n) set s=s_" "_ds($extract(n,m))
        quit s

strtoint(s) ; Convert a string to an integer
        new m,n
        set n=di($piece(s," ",1))
        for m=2:1:$length(s," ") set n=10*n+di($piece(s," ",m))
        quit n

calc(first,last) ; Calculate the maximum number of steps from first through last
        new current,currpath,i,n
        for current=first:1:last do
        . set n=current                          ; Start n at current
        . kill currpath                          ; Currpath holds path to 1 for current
        . ; Go till we reach 1 or a number with a known number of steps
        . for i=0:1 quit:($data(^step($$inttostr(n)))!(1=n))  do
        ..  set currpath(i)=n                     ; log n as current number in sequence
        ..  set n=$select('(n#2):n/2,1:3*n+1) ; compute the next number
        . do:0<i                                 ; if 0=i we already have an answer for n, nothing to do here
        ..  if 1<n set i=i+$$strtoint($$stepget($$inttostr(n)))
        ..  set:i>$get(^result) ^result=i
        ..  set n="" for  set n=$order(currpath(n)) quit:""=n  do stepset($$inttostr(currpath(n)),$$inttostr(i-n))
        quit

stepset(key,val)
	set ^step(key)=val_";"_^padding
	quit

stepget(key)
	if $piece(^step(key),";",2)'=^padding write "ERROR! Padding value of ^step("_key_") is wrong!",! halt
	quit $piece(^step(key),";",1)
