rewind  ;Test the deviceparameter REWIND
        set file="rewind.txt"
        set openpar=""
        set closepar=""
        open file:(NEWVERSION:BIGRECORD:RECORDSIZE=1048576)
        set width=1048576
        use file:WIDTH=width
        do writfile^filop(file,"BLAH")
        do writfile^filop(file,"MORE BLAH")
        do writfile^filop(file,$$^longstr(9))
        do writfile^filop(file,$$^longstr(15))
        do writfile^filop(file,$$^longstr(32*1024))
        do writfile^filop(file,$$^longstr(64*1024))
        do writfile^filop(file,$$^longstr(1024*1024))
        do writfile^filop(file,$$^longstr(128*1024))
        do writfile^filop(file,$$^longstr(1024*1024))
        do writfile^filop(file,"END OF FILE")
        use $PRINCIPAL write !,"REWIND with USE:",! 
        use file:(REWIND:WIDTH=width)
        d readfile^filop(file)
        use $PRINCIPAL write !,"AGAIN:",!
        use file:(REWIND:WIDTH=width)
        d readfile^filop(file)
        use $PRINCIPAL write !,"REWIND with CLOSE:",!
        close file:(REWIND)
        open file
        d readfile^filop(file)
        use $PRINCIPAL write !,"REWIND with OPEN:",!
        open file:(READONLY:REWIND)
        d readfile^filop(file)
        close file
        quit
