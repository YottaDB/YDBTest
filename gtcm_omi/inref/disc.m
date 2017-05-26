; disc	Send disconnect message to server and close the TCP connection
;
; Return value-
;	1	Success.  We ignore return values and simply remove
;		the connection.
;
disc()
	new msg
	s msg=$$str2LS^cvt("OMI Agent disconnect request")
	do send^tcp(OpType("Disconnect"),msg)
	do close^tcp
	q 1

