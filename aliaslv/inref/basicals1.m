;
; Make sure basic functionality of aliasing works
;
	
	Write !,!,"******* Start of ",$Text(+0)," *******",!,!

	; test #1 - simple alias, check value and reference count and $ZDATA return
	Set x=42,y=43	
	Set *a=x
	If 42'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=x Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","x")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","a")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(x)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(a)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(y)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","x")'=0 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","a")'=0 Write "Fail ",$Text(+0),! ZShow "*" Halt

	; test #2 - simple container creation, dereference back to base var and check as above
	Set *b(1)=a
	Set *c=b(1)
	If 42'=c Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=x Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","c")'=4 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","b")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","x")'=4 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","a")'=4 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(c)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(x)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(a)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(y)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","c")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","x")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","a")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt

	; test #3 - container copy, dereference back to base var and check as above
	Set *d(1)=b(1)
	Set *e=d(1)
	If 42'=e Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=c Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=x Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","e")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","d")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","c")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","b")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","x")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","a")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(e)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(c)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(x)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(a)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(y)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","e")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","c")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","x")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","a")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt

	; test #4 - Set alias to self a couple different ways, verify ref counts did not change
	Set *a=a
	Set *e=c
	If 42'=e Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=c Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=x Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","e")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","d")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","c")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","b")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","x")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","a")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(e)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(c)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(x)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(a)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(y)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","e")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","c")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","x")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","a")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	
	; test #5 - Set container to self, verify ref counts did not change
	Set *b(1)=d(1)
	If 42'=e Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=c Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 42'=x Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","e")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","d")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","c")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","b")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","x")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","a")'=6 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(e)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(c)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(x)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(a)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(y)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","e")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","c")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","x")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","a")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt

	; test #6 - Change value in one var .. verify change reflected in other vars
	Set a=24
	If 24'=e Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 24'=c Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 24'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 24'=x Write "Fail ",$Text(+0),! ZShow "*" Halt

	; test #7 - KILL * of an alias reduces ref count for remaining vars
	Kill *x
	If 24'=e Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 24'=c Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 24'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","e")'=5 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","d")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","c")'=5 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","b")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","a")'=5 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(e)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(c)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(x)'=0 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(a)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(y)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","e")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","c")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","a")'=2 Write "Fail ",$Text(+0),! ZShow "*" Halt

	; test #8 - kill a container and verify reduction of refcount for remaining vars
	Kill b(1)
	If 24'=e Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 24'=c Write "Fail ",$Text(+0),! ZShow "*" Halt
	If 24'=a Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","e")'=4 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","d")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","c")'=4 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","b")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_REF","a")'=4 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(e)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(d(1))<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(b)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(c)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(x)'=0 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(a)<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $ZData(y)'<100 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","e")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","c")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt
	If $View("LV_CREF","a")'=1 Write "Fail ",$Text(+0),! ZShow "*" Halt

	Write $Text(+0),": PASS",!
	Quit
