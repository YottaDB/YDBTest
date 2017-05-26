gtm6779
	for i=1:1:511 lock +abc("xyz",1,2,$C(0))
	zshow "L" ; This should work fine
	write "Expect an RTS error here",!
	lock +abc("xyz",1,2,$C(0)) ; This should issue RTS error
	quit
