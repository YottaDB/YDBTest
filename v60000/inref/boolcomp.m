;
; Compare the btest output files for bool0 and bool1. Report differences if any.
;
	Write "Starting comparison of outputs from bool-0 and bool-1 runs",!!
	Set (expcnt,badcnt,diffval,diffref)=0
	For i="exp","if","apc","cpc" Set (badvalcnt(i),badrefcnt(i))=0
	Set (eofbool0,eofbool1)=0
	Set ExpCol=18		; Define output columns in btest_output file
	Set IfCol=37
	Set APCCol=58
	Set CPCCol=78
	Set ExpColMax=IfCol-4
	Set IfColMax=APCCol-5
	Set APCColMax=CPCCol-5
	Set CPCColMax=999
	Set bool0fil="btest_output_bool0.txt"
	Set bool1fil="btest_output_bool1.txt"
	Open bool0fil:Readonly
	Open bool1fil:Readonly

	For  Use bool0fil Quit:$ZEof  Do
	. Read bool0ln
	. Set:($ZEof) eofbool0=1
	. Use bool1fil
	. Read bool1ln
	. Set:($ZEof) eofbool1=1
	. If (eofbool0&eofbool1) Quit:(0<expcnt)  Do		; Done if had some records, else error
	. . Do DoWrite("FAILURE - both input files empty")
	. . ZShow "*"
	. . ZHalt 1
	. If (eofbool0'=eofbool1)				; Both files should end at same time, if not - error
	. . Do DoWrite("FAILURE - premature end on bool"_eofbool1_"fil after record "_expcnt)
	. . ZShow "*"
	. . ZHalt 1
	. Set expcnt=expcnt+1		   ; Both records read - increment count
	. ;
	. ; Else we need to tear it apart to check the components
	. ;
	. Set (bval,bref)=""	; Mark as not set - processing first field sets as comparator for other fields
	. Set exprok=1		; Set to false on first error this expression - prevents further checks of equivalency for
	.     			; .. values and refs across the use types for a given expression
	. Set outbool0=$ZExtract(bool0ln,ExpCol,ExpColMax)
	. Set outbool1=$ZExtract(bool1ln,ExpCol,ExpColMax)
	. Do CompType("exp","expression",.outbool0,.outbool1)
	. Set outbool0=$ZExtract(bool0ln,IfCol,IfColMax)
	. Set outbool1=$ZExtract(bool1ln,IfCol,IfColMax)
	. Do CompType("if","if-statement",.outbool0,.outbool1)
	. Set outbool0=$ZExtract(bool0ln,APCCol,APCColMax)
	. Set outbool1=$ZExtract(bool1ln,APCCol,APCColMax)
	. Do CompType("apc","argument post-conditional",.outbool0,.outbool1)
	. Set outbool0=$ZExtract(bool0ln,CPCCol,CPCColMax)
	. Set outbool1=$ZExtract(bool1ln,CPCCol,CPCColMax)
	. Do CompType("cpc","command post-conditional",.outbool0,.outbool1)
	. Set:('exprok) badcnt=badcnt+1
	;
	; Shutdown/reporting..
	;
	Close bool0fil,bool1fil
	Do:(0<badcnt)
	. Write !,"Total failures of at least 1 fail in 3 types w/one expression: ",badcnt," out of ",expcnt," (",$Justify(badcnt/expcnt*100,0,2),"%)",!
	. Set fmtlen=$ZLength(expcnt)	; Max digits for error count
	. Write "Failure detail:",!
	. Write "  Expression failures:                     ",$Justify(badvalcnt("exp"),fmtlen)," values and ",$Justify(badrefcnt("exp"),fmtlen)," $Reference values",!
	. Write "  If expression failures:                  ",$Justify(badvalcnt("if"),fmtlen)," values and ",$Justify(badrefcnt("if"),fmtlen)," $Reference values",!
	. Write "  Argument Post-conditional failures:      ",$Justify(badvalcnt("apc"),fmtlen)," values and ",$Justify(badrefcnt("apc"),fmtlen)," $Reference values",!
	. Write "  Command Post-conditional failures:       ",$Justify(badvalcnt("cpc"),fmtlen)," values and ",$Justify(badrefcnt("cpc"),fmtlen)," $Reference values",!
	. Write "  Different values across expression:      ",$Justify(diffval,fmtlen),!
	. Write "  Different $References across expression: ",$Justify(diffval,fmtlen),!
	Write:(0=badcnt) !,"No failures",!
	Quit

;
; Compare pieces of 3 types of expression output. Each one has two components: value and $Reference.
;
CompType(typ1,typ2,out0,out1)
	New valbool0,refbool0,valbool1,refbool1
	Set valbool0=$ZExtract(out0,1)
	Set refbool0=$$StripTrail($ZExtract(out0,3,99))
	Set valbool1=$ZExtract(out1,1)
	Set refbool1=$$StripTrail($ZExtract(out1,3,99))
	Do:(valbool0'=valbool1)
	. Do FailedComp(.badvalcnt,typ1,typ2,"expression value",valbool0,valbool1)	; Boolean value of expression differs
	. Set exprok=0
	Do:(refbool0'=refbool1)
	. Do FailedComp(.badrefcnt,typ1,typ2,"$Reference",refbool0,refbool1)		; $Reference differs
	. Set exprok=0
	Do:(exprok)
	. If (""=bval) Do		; This is the first check for this expression - save value
	. . Set bval=valbool0
	. . Set bref=refbool0
	. Else  Do			; Verify values for this type are same
	. . Do:(bval'=valbool0)
	. . . Do DoWrite("Expression #"_expcnt_" Value for "_typ1_" ("_valbool0_") usage differs from exp type ("_bval_")")
	. . . Set diffval=diffval+1
	. . . Set exprok=0
	. . Do:(bref'=refbool0)
	. . . Do DoWrite("Expression #"_expcnt_" $Reference for "_typ1_" ("_refbool0_") usage differs from exp type ("_bref_")")
	. . . Set diffref=diffref+1
	. . . Set exprok=0
	Quit

;
; Failed comparison accounting
;
FailedComp(cntr,typ1,typ2,typ3,expected,actual)
	Set cntr(typ1)=cntr(typ1)+1
	Do DoWrite("Expression #"_expcnt_" "_typ2_" type test failed with different "_typ3_" - expected '"_expected_"' but got '"_actual_"'")
	Quit

;
; Strip trailing blanks
;
StripTrail(str)
	New len
	Set len=$ZLength(str)
	For len=$ZLength(str):-1:0 Quit:(" "'=$ZExtract(str,len))
	Quit $ZExtract(str,1,len)

;
; Do necessary for outputting debug messages to $P. Useful to debug changes to above rtns since can be
; used without changing $IO around (this rtn takes care of that). Rtn used for debugging.
;
dbgzwrite(zwrarg,sfx)
	New saveio
	Do DoWrite("DbgZwrite ----------- "_$Select(""'=$Get(sfx,""):"("_sfx_")",TRUE:"")_":")
	Set saveio=$IO
	Use $P
	ZWrite @zwrarg
	Use saveio
	Quit

;
; Routine to write text $P while doing other IO. Can be used instead of dbgzwrite if more appropriate.
;
DoWrite(msg)
	New saveio
	Set saveio=$IO
	Use $P
	Write msg,!
	Use saveio
	Quit
