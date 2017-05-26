; GVPUTFAIL regression test  8/24/93
;
; Requirements:
; These tests (putfail1 - putfail8) require the block size to be 2048 bytes
; and the record size to be at least 1900 bytes.
;
; A bug in gvcst_put() caused it to attempt to split the block and place
; the new record in the new left block instead of the empty right block.
putfail

	New
	Do begin^header($TEXT(+0))

	Do ^putfail1
	Do ^putfail2
	Do ^putfail3
	Do ^putfail4
	Do ^putfail5
	Do ^putfail6
	Do ^putfail7
	Do ^putfail8
	Do ^putfail9
	If errcnt=0 Write "   PASS - putfail",!
	Else  Write "** FAIL - putfail",!

	Do end^header($TEXT(+0))
	Quit
