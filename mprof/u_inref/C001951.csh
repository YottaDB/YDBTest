$gtm_tst/com/dbcreate.csh . 
# test for C9C03-001951 (view command part)
#The first  view command should error out, and the last h should place the trace info into ^TRACE
$GTM << FIN
	; bad view command:
	view "TRACE":1:"^TRACE("
	view "TRACE":1:"^TRACE"
	d ^one
	; bad view command:
	view "TRACE":0:"^TRACE("
	h
FIN
$GTM << FIN
	w "d ^examin ^TRACE",! d ^examin("^TRACE")
	k ^TRACE
	h
FIN
$gtm_tst/com/dbcheck.csh
