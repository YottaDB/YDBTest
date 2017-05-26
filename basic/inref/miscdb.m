miscdb	; Miscellaneous PER tests.  These require a database.
	New
	Do begin^header($TEXT(+0))

; Test for PER 002209:
	Set errstep=errcnt
	Set ^cd("abc")="",^cdl("def")=""
	Set x="foo"
	Set y="foo"
	Do ^examine((((x'="")&($ORDER(^cdl(x))=""))!((y'="")&($ORDER(^cd(y))=""))),"1","PER 002209 - 1")
	Do ^examine($DATA(^cd),"10","PER 002209 - $DATA(^cd) 1")
	Do ^examine($DATA(^foo),"0","PER 002209 - $DATA(^foo)")
	Do ^examine($DATA(^cd),"10","PER 002209 - $DATA(^cd) 2")
	If errstep=errcnt Write "   PASS - PER 002209",!

	Do end^header($TEXT(+0))
	Quit
