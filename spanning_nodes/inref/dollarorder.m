; Verify $order works fine with spanning nodes.
; This script is called from basic.csh.
order;
	kill ^a,^b,^c
	set a("31100180200000000003")="BEGIN1"_$justify(" ",3000)_"END1"
	set x=$order(a(""))
	if $order(a(""))'=$next(a("")) write "$order-$next disagree 1",! halt
	write a(x),!
	set b("1111")="BEGIN2"_$justify(" ",2500)_"END2"
	set x=$order(b(""))
	if $order(b(""))'=$next(b("")) write "$order-$next disagree 2",! halt
	write b(x),!
	set c("123456789012345678901234567890")="BEGIN3"_$justify(" ",2750)_"END3"
	set x=$order(c(""))
	if $order(c(""))'=$next(c("")) write "$order-$next disagree 3",! halt
	write c(x),!
	set ^c(1)="short"
	set ^c(2)="BEGIN4"_$justify(" ",2750)_"END4"
	set ^c("")="BEGIN5"_$justify(" ",2750)_"END5"
	write $order(^c("")),!
	write $order(^c(1)),!
	write $order(^c(2)),!
	quit
