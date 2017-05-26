test29	;
	; Get an error in frame level 4 and in the error handler "ZGOTO" frame level 2. 
	; See if QUIT out of frame 2 rethrows the error in frame level 1 where $ECODE is still non-NULL.
x	;
	do y
	w "in x : $ecode (should be non-NULL) = ",$ecode,!
	quit
y	;
	do z
	do ecprint
	w "in y : $ecode (should be non-NULL) = ",$ecode,!
	quit
z	;
	set $etrap="goto etr"
	do k
	quit
k	;
	set x=1/0
	quit
etr	;
	do ecprint
	zgoto 2
	quit
ecprint ;
        write !,"$ecode     = ",$ecode
        write !,"$stack     = ",$stack
        write !,"$stack(-1) = ",$stack(-1)
        for index=0:1:$stack(-1)  do
        .       write !,"$stack("_index_",""ECODE"") = ",$j($stack(index,"ECODE"),16)
        .       write " :: $stack("_index_",""MCODE"") = ",$stack(index,"MCODE")
        write !
        quit
