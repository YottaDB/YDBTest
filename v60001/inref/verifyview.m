envview;
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        view "NOLOGTPRESTART"
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        quit
mumpsview;
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        view "NOLOGTPRESTART"
        view "LOGTP":7
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        view "NOLOGTPRESTART"
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        set ^a=4
        view "LOGTP":^a
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        set b=3
        view "LOGTP":b+1+^a+.1
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        view "LOGTP":"abcd":.1234
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        view "NOLOGTPRESTART"
        write "Logging frequency = "_$view("LOGTPRESTART"),!
        quit
