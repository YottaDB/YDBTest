;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb469	;
	; Test additions by YDB#469 to $FNUMBER() function adding a new formatting code '.' which tests the possible
	; combinations of formatting codes with the new code to verify correct functioning.
	;
	set $etrap="zshow ""*"" zhalt 1"
	;
	; Create combinations of values with formatting codes that can be specified with the new dot format code.
	;
	set vindx=0
	set values($increment(vindx))=0			; No decimal digits
	set values($increment(vindx))=1			; 1 decimal digit
	set values($increment(vindx))=12		; 2 decimal digits
	set values($increment(vindx))=123		; 3 decimal digits
	set values($increment(vindx))=1234		; 4 decimal digits (requires 1 separator)
	set values($increment(vindx))=0.1		; 1 fractional digit
	set values($increment(vindx))=0.12		; 2 fractional digits
	set values($increment(vindx))=0.123		; 3 fractional digits
	set values($increment(vindx))=0.1234		; 4 fractional digits
	set values($increment(vindx))=123456789.012	; Large value with decimals
	set values($increment(vindx))=1.23456789012	; Small value, large fractional component
	for i=1:1:vindx set values($increment(vindx))=-values(i) ; Create negative values of above
	set findx=0
	set fmtcodes($increment(findx))="."		; European style
	set fmtcodes($increment(findx))=".+"		; Add '+' on positive values
	set fmtcodes($increment(findx))=".-"		; Suppress '-' on negative values
	set fmtcodes($increment(findx))=".T"		; Put sign at end of number
	set fmtcodes($increment(findx))=".T+"		; Sign at end whether plus or minus
	set fmtcodes($increment(findx))=".T-"		; No sign - just a blank after the number
	set fmtcodes($increment(findx))=".P"		; Put parens on negative numbers
	;
	; Drive tests
	;
	set vindx=0
	for  set vindx=$order(values(vindx)) quit:""=vindx  set val=values(vindx) do
	. set findx=0
	. for  set findx=$order(fmtcodes(findx)) quit:""=findx  set fmt=fmtcodes(findx) do
	. . do checkfnumber(val,fmt)
	;
	; Drive expected errors
	;
	write !,"We expect errors from the next two tests",!!
	do checkfnumber(123.456,".PT")
	do checkfnumber(123.456,".,")
	;
	write !,"Test complete",!
	quit

;
; Routine to run the test and recover and return if there was an error
;
checkfnumber(val,fmt)
	new elvl,$etrap
	set elvl=$zlevel
	set $etrap="zwr $zstatus set $ecode="""" zgoto elvl-1"
	write "$FNUMBER(",val,",""",fmt,""")=",$fnumber(val,fmt),!
	quit

