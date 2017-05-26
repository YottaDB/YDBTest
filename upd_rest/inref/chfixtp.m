chfixtp;
	SET $ZT="g ERROR"
	set fail=0
	set maxerr=10
	; Node Spanning Blocks - BEGIN
	set keysize=^%fixtp("key_size")
	set recsize=^%fixtp("record_size")
	; Node Spanning Blocks - END
	F I=^begi:1:^lasti D  q:(fail>maxerr)
	. SET val=$justify(I,recsize)
	. SET key=$justify(I,keysize)
	. if $GET(^a(key))'=val w "Wrong : ^a(",I,")=",$GET(^a(key)),! S fail=fail+1
	. if $GET(^b(key))'=val w "Wrong : ^b(",I,")=",$GET(^b(key)),! S fail=fail+1
	. if $GET(^c(key))'=val w "Wrong : ^c(",I,")=",$GET(^c(key)),! S fail=fail+1
	. if $GET(^d(key))'=val w "Wrong : ^d(",I,")=",$GET(^d(key)),! S fail=fail+1
	. if $GET(^e(key))'=val w "Wrong : ^e(",I,")=",$GET(^e(key)),! S fail=fail+1
	. if $GET(^f(key))'=val w "Wrong : ^f(",I,")=",$GET(^f(key)),! S fail=fail+1
	. if $GET(^g(key))'=val w "Wrong : ^g(",I,")=",$GET(^g(key)),! S fail=fail+1
	. if $GET(^h(key))'=val w "Wrong : ^h(",I,")=",$GET(^h(key)),! S fail=fail+1
	. if $GET(^i(key))'=val w "Wrong : ^i(",I,")=",$GET(^i(key)),! S fail=fail+1
	if fail=0 w "chfixtp PASSED.",!
	else  w "chfixtp FAILED.",!
	Q		
ERROR	SET $ZT=""
	IF $TLEVEL TROLLBACK
	ZSHOW "*"
	ZM +$ZS
	Q
