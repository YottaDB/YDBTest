unicoderewind(encoding)  
	;Test the deviceparameter REWIND
        set file=encoding_"_unicoderewind.txt"
        set openpar=""
        set closepar=""
	do open^io(file,"NEWVERSION:BIGRECORD:RECORDSIZE=1048576",encoding)
        set width=1048576
        use file:WIDTH=width
	; lineno is a local that is used to count the no of lines written and then checks it when the file is read. 
	; since the same local is shared between wirtfile and readfile, it cannot be killed inside filop.m
	; And since this routine unicoderewind.m is called multiple times from the same gtm process, lineno doesn't lose its old value.
	; The workaround to avoid it is a) to call this routine each time in a different gtm process or b) to kill it before a new writfile
	; the locals ulongstr* is shared across calls, so we chose option b)
	kill lineno
        do writfile^filop(file,"BLAH")
        do writfile^filop(file,"MORE BLAH")
        do writfile^filop(file,ulongstr9)
        do writfile^filop(file,ulongstr15)
        do writfile^filop(file,ulongstr32)
        do writfile^filop(file,ulongstr64)
        do writfile^filop(file,ulongstr1024)
        do writfile^filop(file,ulongstr128)
        do writfile^filop(file,ulongstr1024)
        do writfile^filop(file,"END OF FILE")
        use $PRINCIPAL write !,"REWIND with USE:",! 
        use file:(REWIND:WIDTH=width)
        d readfile^filop(file)
        use $PRINCIPAL write !,"AGAIN:",!
        use file:(REWIND:WIDTH=width)
        d readfile^filop(file)
        use $PRINCIPAL write !,"REWIND with CLOSE:",!
        close file:(REWIND)
	;
        open file:(RECORDSIZE=1048576:ICHSET=encoding)
        d readfile^filop(file)
        use $PRINCIPAL write !,"REWIND with OPEN:",!
	do open^io(file,"READONLY:REWIND",encoding)
        d readfile^filop(file)
        close file
        quit
