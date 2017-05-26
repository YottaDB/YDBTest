test32	;
	; Test scenario where set $ecode to a nearly 32K length string followed by a nested error that causes 
	; $ecode to go more than 32K.  One should not overwrite the first ECODE to accommodate the latest one.
x	;
        new $etrap
        set $etrap="goto ecprint"
        do y
        quit
y	;
        new $etrap
        set $etrap="goto ecprint1"
        do z
        quit
z	;
        new $etrap
        set $etrap="goto etr"
        s x=""
        s y=",M10"
        f i=1:1:13 s x=x_y if i'=13 s y=y_y
        s x=x_","
        set $ecode=x
        w $l(x)
        q
etr     ;
        set x=1/0
        quit
ecprint1;
        set x=$ecode_","        ; to cause an error
ecprint ;
        w "$l($ecode) = ",$l($ecode),!
        quit
