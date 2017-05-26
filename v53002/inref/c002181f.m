c002181f;
	; tnum = 6 needs special handling so it is done now.
	; It is an example from the Error Processing chapter of the Programmer's Guide
	;	of how to use GT.M to do resilient error reporting
	; In case of an error, this program tries to dump all debug info to a database first.
	; If that fails, it tries to dump the info into a file.
	; If that fails, it dumps the info into the current principal device.
	; The driver should call it with 3 cases
	; a) Database exists. The driver should check that ^ERR global is set appropriately.
	; b) Database does not exist. The driver should check that the file EP13.ERR gets created and contains debug info.
	; c) Database does not exist and a file by name EP13.ERR is not creatable in current directory.
	;	The driver should verify that the debug info gets dumped into the principal device (terminal if using expect).
	; The last case is not easily testable in VMS since we dont have expect so only (a) and (b) will be tested there.
	;
EP13    WRITE !,"THIS IS "_$TEXT(+0)
        SET $ETRAP="GOTO ^ERR"
        DO SUB1
        WRITE !,"THIS IS THE END"
        QUIT
SUB1    WRITE !,"THIS IS SUB1"
        NEW
        SET (A,B,C)=$ZLEVEL
        DO SUB2
        QUIT
SUB2    WRITE !,"THIS IS SUB2"
        NEW
        SET (B,C,D)=$ZLEVEL
        DO SUB3
        QUIT
SUB3    WRITE !,"THIS IS SUB3"
        NEW
        SET (A,C,D)=$ZLEVEL
        DO BAD
	QUIT
BAD     NEW (A)
        SET B="BAD"
        WRITE 1/0
        WRITE !,"THIS IS NOT DISPLAYED"
        QUIT
