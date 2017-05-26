test15	;
	; ZGOTO should always override error rethrow handling i.e. ZGOTO to a lower level past an error-frame 
	; should not trigger error rethrow. In the below example, we should not rethrow the error at frame 
	; y or frame x even though $ecode is non-NULL.
x       ;
        do y
        write "$ecode = ",$ecode,!
        quit
y       ;
        s $et="do etr"
        do z
        write "$ecode = ",$ecode,!
        quit
z       ;
        s x=1/0
        quit
etr     ;
        write "I am in etr",!
        zgoto 2
        write "I should not see this",!
        quit
