filezeof
	; test for $ZEOF behavior and error handling
	; the primary reason for the test is to show that $ETRAP and $ZTRAP occur on the READ after
	; $ZEOF is set by a prior READ, while EXCEPTION triggers on the same read that sets $ZEOF.

	set $etrap="goto EX1"
	for f="nullfile","nonnullfile" for devp="APPEND","READONLY" for exc="","goto EX1" do  close f
	. open @("f:("_devp_":EXC=exc)")
	. use f
	. set z=$ZEOF
	. use $p
	. write "$ZEOF after open of ",f," file ",devp," = ",z,!
	. for rcnt="first","second" do
	.. use f
	.. read x
	.. set z=$ZEOF
	.. use $p
	.. write "$ZEOF after ",rcnt," read from ",f," file ",devp," = ",z,!
	quit

EX1
	set z=$ZEOF
	use $p
	if "second"=rcnt,""=exc write "BAD",!
	else  write "EX1",!
	write "$ZEOF after ",rcnt," read from ",f," file ",devp," = ",z,!
	write $zstatus,!
	zshow "d"
	set $ecode=""
	quit
