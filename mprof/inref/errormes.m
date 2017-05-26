errormes ; This routine test all error messages that might come up, as well as some examples that should work.
	w "========================================",!
	s line=$ZCMDLINE_"+1"
	w "Command is:(",line,")",!
	zp @line
	w "----------------------------------------",!
pre	;
	K ^X
	d @$ZCMDLINE
post	;
	view "TRACE":0
	w "d ^examin ^X",! d ^examin("^X")
	q
c1	; extra characters after ) ERR_EORNOTFND (820)
	view "TRACE":1:"^X($J) "
	q
c2	; ERR_TRACINGON
	view "TRACE":1:"^X"
	view "TRACE":1:"^X"
	q
c3	; ERR_NOTGBL
	view "TRACE":1:"X"
	q
c4	; ERR_MAXTRACELEVEL
	; tested by ^mnylvl 
	q
c5	; ERR_GVINVALID
	view "TRACE":1:"^X#"
	q
c6	; ERR_GVINVALID
	view "TRACE":1:"^#X"
	q
c7	;  ERR_TRACEON
	view "TRACE":1
	q
c8	; ERR_STRUNXEOR 
	view "TRACE":1:"^X("""
	q
c9	; ERR_STRUNXEOR 
	view "TRACE":1:"^X("X""
	q
c10	; ERR_DLRCUNXEOR some other intrinsic than $J
	view "TRACE":1:"^X($X)"
	q
c11	; ERR_DLRCUNXEOR abrupt $
	view "TRACE":1:"^X($"
	q
c12	; ERR_NUMUNXEOR
	view "TRACE":1:"^X("
	q
c13	; ERR_NUMUNXEOR
	view "TRACE":1:"^X(^##)"
	q
c14	; ERR_RPARENREQD (818)
	view "TRACE":1:"^X(4#)"
	q
c15	; ERR_NUMUNXEOR (785)
	view "TRACE":1:"^X(^4#)"
	q
c16	; ERR_NUMUNXEOR  (792)
	view "TRACE":1:"^X(4.4"
	q
c17	; ERR_NUMUNXEOR  (800)
	view "TRACE":1:"^X(4..)"
	q
c18	;
	view "TRACE":1:"^X12@weR_2"
	q
c19	;
	view "TRACE":1:"^X("""""
	q
c20	;
	view "TRACE":1:"^X($J"
	q
c21	;
	view "TRACE":1:"^X($JO"
	q
c22	;
	view "TRACE":1:"^X($JOB"
	q
c23	;
	view "TRACE":1:"^X($JOA)"
	q
c24	;
	view "TRACE":1:"^X($JA)"
	q
c25	;
	view "TRACE":1:"^X($JOBS)"
	q
c26	;
	view "TRACE":1:"^X($JO_""a"")"
	q
c27	;
	view "TRACE":1:"^X($JO,""a"")"
	q
cg1	;
	view "TRACE":1:"^X"
	q
cg2	;
	view "TRACE":1:"^X(1)"
	q
cg3	;
	view "TRACE":1:"^X(""x"")"
	q
cg4	;
	view "TRACE":1:"^X(""x"",""y"")"
	q
cg5	;
	view "TRACE":1:"^X($J,""y"")"
	q
cg6	;
	view "TRACE":1:"^X(""x"",$job)"
	q
cg61	;
	view "TRACE":1:"^X($job,""x"")"
	q
cg62	;
	view "TRACE":1:"^X($JOB)"
	q
cg63	;
	view "TRACE":1:"^X($J_""a"")"
	q
cg64	;
	view "TRACE":1:"^X($JOB_""a"")"
	q
cg7	; indirection, this should work
	s x="y"
	s y="^X"
	view "TRACE":1:@x
	q
