trigcolunicode
	; load the trigger file before doing the test
	do text^dollarztrigger("tfile^trigcolunicode","trigcolunicode.trg")
	do file^dollarztrigger("trigcolunicode.trg",1)

	do ^echoline
	; do some updates to Hindi numbers to fire the trigger below.
	write "Hindi 1, 4, and 9",!
	set i=1,^hindinum($char(2406+i))=i
	set i=4,^hindinum($char(2406+i))=i
	set i=9,^hindinum($char(2406+i))=i
	do ^echoline

tfile
	;+^hindinum(lvn=$char(2415):$char(2406)) -commands=S -xecute="write lvn,$char(9),$ztvalue,$char(9),$reference,!"
