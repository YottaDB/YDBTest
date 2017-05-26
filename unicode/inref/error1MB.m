error1MB	;
		; This routine uses $CHAR() of 168,22785 and 120121. All three are valid UTF-8 characters.
		; $EXTRACT() does UTF8 validity, by default and doing it so many times really slows down the routine
		; and for 1MB strig, the time taken could exponentially rise due to the validation.
		; so disable UTF8 validation for this routine. Take backup and restore (though it is not necessary in the current context)
		set badcharstate=$view("BADCHAR")
		view "NOBADCHAR"
		set $ZTRAP="set errpos=$ZPOS goto errortrap"
		set errcnt=0
		set estr=$JUSTIFY("A",1024000)
		; #####################################################################################
		;		unicode characters chosen to check for 1 MB limit
		; $CHAR(168)		combining diaresis(0xA8) 			; two byte
		; $CHAR(22785)		unicode han char(0x5901) 			; three byte
		; $CHAR(120121)		mathematical double struck capital B(0x1D539)	; four byte
		; #####################################################################################
		for utfchar=$CHAR(168),$CHAR(22785),$CHAR(120121) do
		. for I=1:1:102400 do
		. . set $EXTRACT(estr,I,I)=utfchar
		; at the end of utfchar loop check for expected errcnt value
		if $CHAR(120121)=utfchar do
		. do ^examine(errcnt,3,"TEST-E-LIMITS, expected error count 3 not achieved for 1MB string check")
		. if badcharstate view "BADCHAR"
		quit
errortrap	;
		write "---- Expected Error on "_utfchar_" exceeding 1MB at I = "_I_" ----",!
        	set lab=$PIECE(errpos,"+",1)
        	set offset=$PIECE($PIECE(errpos,"+",2),"^",1)+1
        	set nextline=lab_"+"_offset
		set errcnt=errcnt+1
		set estr=$JUSTIFY("A",1024000) ; reset estr with the original value for the next iteration
        	set I=102400 ; because once we reach the 1MB limit there is no point in continuing till 102400 to see the same error
        	goto @nextline
