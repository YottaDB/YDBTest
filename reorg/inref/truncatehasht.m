truncatehasht
	;
	; Fill up some globals in each region
	for i=1:1:50000 set (^a(i),^b(i),^c(i))=$justify(i,20)
	;
	; Add trigger definitions
	set X=$ztrigger("i","+^a -command=S -xecute=""write 123,!""")
	set X=$ztrigger("i","+^b -command=S -xecute=""write 456,!""")
	;
	; Check $zprevious [GTM-7433]. Convenient to do this here instead of creating a separate subtest.
	set prev=$zprevious(^a)
	if prev'="" write "incorrect: $zprevious(^a)="_prev,!
	;
	; Kill globals to free up some space
	kill ^a,^b,^c
	quit
	
