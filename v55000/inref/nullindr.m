;
; Test for GTM-7176 checking indirect of routine name with a truly null value (i.e. value from
; literal_null). Note that just a literal null won't do it because of the way literal NULL
; string values are created - they always have a zero length but non-zero address. This bug
; is only tripped by an mval with an address of 0x0000*. We can get one of these from $GET()
; of an undefined variable name. Bug was causing a sig-11 due to the NULL dereference.
;
nullindr
	Set experror(150373650)=1	; (RTNNAME) Define error codes we allow to be ignored
	Set experror(150373978)=1	; (ZLINKFILE)
	;
	Kill undef
	Set rtn=$Get(undef)		; Guaranteed to be null address null string
	Set errors=0,baselvl=$ZLevel
	Set $ETrap="Do NextSrcLine"
	;
	; First test - Set x=$Text()
	;
	Set x=$Text(lbl+1^@rtn)
	;
	; Second test - ZPrint lbl+1^@rtn
	;
	ZPrint lbl+1^@rtn
	;
	; Third test - ZBreak lbl+1^@rtn
	;
	ZBreak lbl+1^@rtn
	;
	Write "PASS",!			; If we got this far, we succeeded
	Quit

;
; Routine to check the error and if one of the errors we expect, continue with the next line of code.
;
NextSrcLine
	New entryref,lblref,lbl,rtn,lbloff
	Write $ZStatus,!
	Halt:('$Get(experror($ZStatus+0)))	; Halt if not an error defined in experror array
	Write "  ** Above error is expected - continuing with next test",!!
	Set $ECode=""
	Set entryref=$ZPiece($ZStatus,",",2)
	Set lblref=$ZPiece(entryref,"^",1)
	Set rtn=$ZPiece(entryref,"^",2)
	Set lbl=$ZPiece(lblref,"+",1)
	Set lbloff=$ZPiece(lblref,"+",2)
	ZGoto @(baselvl_":"_lbl_"+"_(lbloff+1)_"^"_rtn)
