zcmdltst	; test $zcmdline ; ; 
	;
	Write !,$Select("command line text"'=$$FUNC^%LCASE($ZCMDLINE):"FAIL",1:"PASS")," from ",$Text(+0),!
	Quit
