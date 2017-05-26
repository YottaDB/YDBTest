test33	;
        ; test compilation error in $ETRAP is handled appropriately
        ; 	below, we have a "go etr" instead of "goto etr" in $ETRAP 
x       ;
        set $etrap="goto ecprint"
        do y
        quit
y       ;
        new $etrap
        set $etrap="go etr"
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
ecprint ;
        Write:(0=$STACK) "Error occurred: ",$ZSTATUS,!
        write "$l($ecode) = ",$l($ecode),!
        quit
